#!/bin/bash
set -e

if [[ $EUID -ne 0 ]]; then
  echo "Run as root: sudo bash build-win-initramfs.sh"
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORK=$(mktemp -d)
trap "rm -rf $WORK" EXIT

mkdir -p "$WORK"/{bin,lib,proc,dev,sys/firmware/efi/efivars}
ln -s lib "$WORK/lib64"

gcc -static -o "$WORK/init" "$SCRIPT_DIR/win-init.c"
chmod 755 "$WORK/init"

cp /usr/bin/efibootmgr                "$WORK/bin/"
cp /usr/lib64/ld-linux-x86-64.so.2   "$WORK/lib/"
cp /usr/lib/libc.so.6                 "$WORK/lib/"
cp /usr/lib/libefiboot.so.1.39        "$WORK/lib/libefiboot.so.1"
cp /usr/lib/libefivar.so.1.39         "$WORK/lib/libefivar.so.1"

(cd "$WORK" && find . | cpio -o -H newc | gzip) > /boot/win-init.img
echo "Built /boot/win-init.img"

grep -q 'Windows (direct)' /etc/grub.d/40_custom 2>/dev/null || cat >> /etc/grub.d/40_custom << 'EOF'

menuentry 'Windows (direct)' --class windows --class os {
    load_video
    insmod gzio
    insmod part_gpt
    insmod fat
    search --no-floppy --fs-uuid --set=root 88A6-27A7
    linux /vmlinuz-linux quiet loglevel=0
    initrd /win-init.img
}
EOF

grub-mkconfig -o /boot/grub/grub.cfg
echo "Done. Select 'Windows (direct)' from GRUB to boot Windows with clean PCRs."
