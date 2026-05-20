#!/bin/bash
set -e

# Prerequisites (run as your user before this script):
#   sudo os-prober  (verify it detects Windows — optional sanity check)
#
# Run this script as root: sudo bash setup-secure-boot.sh

if [[ $EUID -ne 0 ]]; then
  echo "Run as root: sudo bash setup-secure-boot.sh"
  exit 1
fi

# No-shim approach: firmware verifies BOOTX64.EFI (grubx64.efi) directly via
# the UEFI db, where sbctl enrolls our custom key + Microsoft's CA.
# Boot chain: firmware (UEFI db) -> BOOTX64.EFI (grubx64.efi) -> kernel
# grub-install uses --disable-shim-lock so GRUB doesn't require shim protocols.

echo "==> Creating keys..."
sbctl create-keys 2>/dev/null || true

echo "==> Re-issuing db cert with Subject Key ID..."
openssl req -new -x509 -sha256 -days 3650 \
  -key /var/lib/sbctl/keys/db/db.key \
  -out /var/lib/sbctl/keys/db/db.pem \
  -subj "/O=Linux/CN=Secure Boot Signing Key/" \
  -addext "subjectKeyIdentifier=hash" \
  -addext "keyUsage=critical,digitalSignature" \
  -addext "extendedKeyUsage=codeSigning"

echo "==> Unlocking EFI variables..."
chattr -i /sys/firmware/efi/efivars/PK-8be4df61-93ca-11d2-aa0d-00e098032b8c 2>/dev/null || true
chattr -i /sys/firmware/efi/efivars/KEK-8be4df61-93ca-11d2-aa0d-00e098032b8c 2>/dev/null || true
chattr -i /sys/firmware/efi/efivars/db-d719b2cb-3d3a-4596-a3bc-dad00e67656f 2>/dev/null || true

if sbctl status 2>/dev/null | grep -qi "setup mode.*true\|setup mode.*enabled"; then
  echo "==> Enrolling keys (sbctl + Microsoft)..."
  sbctl enroll-keys --microsoft
else
  echo "==> Not in Setup Mode, skipping key enrollment..."
fi

echo "==> Installing GRUB..."
mkdir -p /boot/EFI/GRUB /boot/EFI/BOOT
grub-install \
  --target=x86_64-efi \
  --efi-directory=/boot \
  --bootloader-id=GRUB \
  --disable-shim-lock \
  --modules="part_gpt fat ext2 search search_fs_file search_fs_uuid normal configfile linux all_video gfxterm loadenv echo reboot halt tpm"

echo "==> Enabling os-prober for Windows detection..."
if ! grep -q 'GRUB_DISABLE_OS_PROBER' /etc/default/grub; then
  echo 'GRUB_DISABLE_OS_PROBER=false' >> /etc/default/grub
else
  sed -i 's/.*GRUB_DISABLE_OS_PROBER.*/GRUB_DISABLE_OS_PROBER=false/' /etc/default/grub
fi

echo "==> Generating GRUB config..."
grub-mkconfig -o /boot/grub/grub.cfg

echo "==> Setting up direct GRUB boot (no shim)..."
mkdir -p /boot/EFI/BOOT
cp /boot/EFI/GRUB/grubx64.efi /boot/EFI/BOOT/BOOTX64.EFI
# Remove shim leftovers that confuse sbctl verify
rm -f /boot/EFI/BOOT/grubx64.efi /boot/EFI/BOOT/mmx64.efi

echo "==> Updating EFI boot entry..."
EFI_DEV=$(findmnt -n -o SOURCE /boot)
EFI_DISK=$(lsblk -no PKNAME "$EFI_DEV")
EFI_PARTNUM=$(lsblk -no PARTN "$EFI_DEV")

# Remove all stale Arch Linux and GRUB entries before creating a clean one
while IFS= read -r bootnum; do
  efibootmgr --delete-bootnum --bootnum "$bootnum"
done < <(efibootmgr | grep -iE 'Arch Linux|GRUB' | grep -oP 'Boot\K[0-9A-Fa-f]+')
efibootmgr \
  --create \
  --disk "/dev/$EFI_DISK" \
  --part "$EFI_PARTNUM" \
  --loader '\EFI\BOOT\BOOTX64.EFI' \
  --label "Arch Linux"

echo "==> Signing EFI binaries and kernels..."
sbctl sign -s /boot/EFI/GRUB/grubx64.efi
sbctl sign -s /boot/EFI/BOOT/BOOTX64.EFI

# grub-install generates these in the modules dir; sign them so the pacman
# hook doesn't report them as unsigned on every kernel update
for f in /boot/grub/x86_64-efi/core.efi /boot/grub/x86_64-efi/grub.efi; do
  [[ -f "$f" ]] && sbctl sign -s "$f"
done

for kernel in /boot/vmlinuz-*; do
  sbctl sign -s "$kernel"
done

echo "==> Verifying signatures..."
sbctl verify

echo ""
echo "Boot chain: firmware (UEFI db) -> BOOTX64.EFI (grubx64.efi) -> kernel"
echo ""
echo "Done. Now:"
echo "  1. Reboot into BIOS"
echo "  2. Disable Setup Mode / Enable Secure Boot"
echo "  3. Boot Arch — should work, Windows should appear in GRUB menu"
