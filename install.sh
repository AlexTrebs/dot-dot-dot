#!/usr/bin/env bash
set -euo pipefail
# Usage: ./install.sh [copy|symlink]
#   (no args) - Install packages and configure system only
#   copy      - Also copy all config files
#   symlink   - Also symlink .config/.local (for development/updates)

# Anchor to the repo, not the caller's cwd: every path below is repo-relative.
current_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
cd "$current_dir"
CONFIG_MODE="${1:-}"

# ==========================================
# Initialise submodules
# ==========================================
echo "🔄 Initialising git submodules..."
git submodule update --init --recursive

# ==========================================
# Pacman Packages
# ==========================================
# One package per line in packages/*.txt; blank lines and # comments are skipped.
read_pkgs() { grep -vE '^[[:space:]]*(#|$)' "$1" | sed 's/[[:space:]]*#.*//'; }

mapfile -t packages < <(read_pkgs "$current_dir/packages/pacman.txt")

to_install=()
for pkg in "${packages[@]}"; do
  if ! pacman -Qq "$pkg" &>/dev/null; then
    to_install+=("$pkg")
  fi
done

if (( ${#to_install[@]} > 0 )); then
  echo "📦 Installing missing packages..."
  sudo pacman -S --noconfirm --needed "${to_install[@]}"
else
  echo "✅ All pacman packages already installed."
fi

# ==========================================
# Set zsh as default shell
# ==========================================
if [[ "$SHELL" != "/usr/bin/zsh" ]]; then
  echo "🐚 Setting zsh as default shell..."
  sudo chsh -s /usr/bin/zsh "$USER"
else
  echo "✅ zsh already default shell."
fi

# ==========================================
# Install paru (AUR helper)
# ==========================================
if ! command -v paru &>/dev/null; then
  echo "🚀 Installing paru..."
  tmpdir=$(mktemp -d)
  git clone https://aur.archlinux.org/paru-bin.git "$tmpdir/paru-bin"
  cd "$tmpdir/paru-bin"
  makepkg -si --noconfirm
  cd "$current_dir"
  rm -rf "$tmpdir"
else
  echo "✅ paru already installed."
fi

# ==========================================
# Install AUR Packages
# ==========================================
mapfile -t aur_packages < <(read_pkgs "$current_dir/packages/aur.txt")
aur_to_install=()

for pkg in "${aur_packages[@]}"; do
  if ! pacman -Qq "$pkg" &>/dev/null; then
    aur_to_install+=("$pkg")
  fi
done

if (( ${#aur_to_install[@]} > 0 )); then
  echo "📦 Installing missing AUR packages..."
  paru -S --noconfirm --needed --skipreview "${aur_to_install[@]}"
else
  echo "✅ All AUR packages already installed."
fi

# ==========================================
# Enable services
# ==========================================
echo "🔌 Enabling Bluetooth..."
sudo systemctl enable --now bluetooth.service || true

echo "🔋 Enabling user services..."
systemctl --user enable battery-listener.service || true

echo "🪞 Enabling reflector mirror update timer..."
sudo systemctl enable --now reflector.timer || true

# Socket-activated, so this costs nothing until something actually prints.
echo "🖨️  Enabling CUPS..."
sudo systemctl enable --now cups.socket || true

# ==========================================
# NVIDIA Hibernate Configuration
# ==========================================
# nvidia-open requires special config for hibernate to work:
# 1. Do NOT load nvidia in early KMS (initramfs can't access /var/tmp)
# 2. Use simpledrm for early framebuffer instead
# 3. Enable nvidia power management services
#
# No resume= needed on the kernel command line: systemd (255+) stores the
# swapfile location in an EFI variable when hibernating, and the resume hook
# added below reads it at boot. Needs a swapfile big enough for the RAM image.
# ==========================================
echo "🖥️ Configuring NVIDIA hibernate support..."
INITRAMFS_CHANGED=false

# Configure mkinitcpio: simpledrm for early framebuffer, NO nvidia early loading
if grep -q "^MODULES=()" /etc/mkinitcpio.conf; then
  sudo sed -i 's/^MODULES=()/MODULES=(simpledrm)/' /etc/mkinitcpio.conf
  echo "  Added simpledrm to MODULES"
  INITRAMFS_CHANGED=true
elif grep -q "^MODULES=.*nvidia" /etc/mkinitcpio.conf; then
  sudo sed -i 's/^MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)/MODULES=(simpledrm)/' /etc/mkinitcpio.conf
  echo "  Replaced nvidia early KMS with simpledrm"
  INITRAMFS_CHANGED=true
elif ! grep -q "simpledrm" /etc/mkinitcpio.conf; then
  sudo sed -i 's/^MODULES=(/MODULES=(simpledrm /' /etc/mkinitcpio.conf
  echo "  Added simpledrm to existing MODULES"
  INITRAMFS_CHANGED=true
else
  echo "  simpledrm already configured"
fi

# Ensure resume hook is present for hibernate (must come BEFORE filesystems)
if ! grep -q "\bresume\b" /etc/mkinitcpio.conf; then
  sudo sed -i 's/filesystems/resume filesystems/' /etc/mkinitcpio.conf
  echo "  Added resume hook"
  INITRAMFS_CHANGED=true
fi

# Enable nvidia power services
sudo systemctl enable nvidia-suspend nvidia-hibernate nvidia-resume || true
echo "  Enabled nvidia power services"

# Ensure GRUB has nvidia_drm.modeset=1 for Wayland
if ! grep -q "nvidia_drm.modeset=1" /etc/default/grub; then
  sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="/GRUB_CMDLINE_LINUX_DEFAULT="nvidia_drm.modeset=1 nvidia_drm.fbdev=1 /' /etc/default/grub
  echo "  Added nvidia kernel parameters to GRUB"
  sudo grub-mkconfig -o /boot/grub/grub.cfg
fi

if [ "$INITRAMFS_CHANGED" = true ]; then
  echo "  Rebuilding initramfs..."
  sudo mkinitcpio -P
else
  echo "  initramfs already up to date, skipping rebuild"
fi

# ==========================================
# Reflector mirror config
# ==========================================
if [ -f "$current_dir/etc/xdg/reflector/reflector.conf" ]; then
  sudo mkdir -p /etc/xdg/reflector
  sudo cp "$current_dir/etc/xdg/reflector/reflector.conf" /etc/xdg/reflector/reflector.conf
  echo "✅ Reflector config installed"
fi

# ==========================================
# Secure Boot / Windows direct-boot initramfs
# ==========================================
if sbctl status 2>/dev/null | grep -qi "secure boot.*enabled"; then
  echo "🔐 Secure Boot active — building Windows direct-boot initramfs..."
  sudo bash "$current_dir/secure-boot/build-win-initramfs.sh"
else
  echo "⚠️  Secure Boot not configured. To set up:"
  echo "   1. Enter BIOS → reset Secure Boot keys → enable Setup Mode"
  echo "   2. Boot Arch, run: sudo bash $current_dir/secure-boot/setup-secure-boot.sh"
  echo "   3. Reboot → BIOS → enable Secure Boot"
  echo "   4. Re-run install.sh to build the Windows initramfs"
fi

# ==========================================
# Add user to groups (ignore missing ones)
# ==========================================
for group in network video storage audio wheel kvm; do
  if getent group "$group" &>/dev/null; then
    sudo usermod -aG "$group" "$USER"
  else
    echo "⚠️ Group '$group' does not exist, skipping."
  fi
done

# ==========================================
# Install Zed (if not already)
# ==========================================
if ! command -v zed &>/dev/null; then
  echo "🪄 Installing Zed editor..."
  curl -fsSL https://zed.dev/install.sh | ZED_CHANNEL=preview sh
  mkdir -p ~/.local/share/applications
  cp ./.config/zed/zed.desktop ~/.local/share/applications/zed.desktop
  update-desktop-database ~/.local/share/applications/
else
  echo "✅ Zed already installed."
fi

# ==========================================
# Manual build steps (not automated)
# ==========================================
# hyprcut (keymap overlay, config in .config/hyprcut) is built from source, not
# installed here: build your fork and put the binary at ~/.local/bin/hyprcut.

# ==========================================
# Run symlink/copy config (if mode specified)
# ==========================================
if [[ -n "$CONFIG_MODE" ]]; then
  if [[ -x "$current_dir/symlink_config.sh" ]]; then
    echo "🔗 Running symlink_config.sh ($CONFIG_MODE mode)..."
    "$current_dir/symlink_config.sh" "$CONFIG_MODE"
  else
    echo "⚠️ symlink_config.sh not found or not executable."
  fi
else
  echo "ℹ️ Skipping config files. Run './symlink_config.sh' or './install.sh copy|symlink' to set up configs."
fi

# ==========================================
# Post-install state that lives outside the repo
# ==========================================
# Must run AFTER symlink_config.sh — it is what copies etc/ into /etc, and both
# steps below depend on files it puts there.

# etc/pacman.d/hooks/99-gamescope-setcap.hook reapplies CAP_SYS_NICE on every
# gamescope upgrade, but the first install predates the hook — grant it now.
# Without it gamescope cannot take realtime priority and frame pacing suffers
# under load, with no visible error to explain why.
if command -v gamescope &>/dev/null; then
  sudo setcap 'CAP_SYS_NICE=eip' /usr/bin/gamescope
  echo "✅ gamescope: $(getcap /usr/bin/gamescope)"
fi

# hyprpm plugin repos. Its state lives in /var/cache/hyprpm/$USER, outside this repo,
# so it is not restored by symlink_config.sh — and `hyprpm purge-cache` deletes the
# repos themselves, not just build artifacts. These lines are the only record of the
# upstreams. Must run inside a Hyprland session: hyprpm builds against the RUNNING
# compositor's headers. Skipped otherwise; re-run this script from a session.
if [[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]] && command -v hyprpm &>/dev/null; then
  hyprpm add https://github.com/hyprwm/hyprland-plugins
  hyprpm add https://github.com/gfhdhytghd/hymission
  hyprpm enable borders-plus-plus
  hyprpm enable hymission
  hyprpm reload
  echo "✅ hyprpm plugins: $(hyprctl plugin list | grep -c 'Plugin ') loaded."
else
  echo "ℹ️ Not in a Hyprland session — skipping hyprpm plugin setup. Re-run from Hyprland."
fi

# Daily claude personality: links ~/.local/bin/claude-personality-gen and enables
# its systemd timer. stdin from /dev/null declines its hyprland.conf prompt;
# lua/autostart.lua already runs it at login.
bash "$current_dir/.config/hypr/scripts/claude_personality_gen/install.sh" </dev/null || true

# Must be root-owned (install -o root, never cp -p): asusd runs without
# CAP_DAC_OVERRIDE and rewrites this file on exit, so a user-owned copy makes it
# panic on every boot.
sudo install -o root -g root -m 644 \
  "$current_dir/etc/asusd/fan_curves.ron" /etc/asusd/fan_curves.ron

# Self-healing backstop: re-assert ownership at every boot, before asusd starts,
# in case the file is ever restored by hand with the wrong flags.
sudo install -o root -g root -m 644 /dev/stdin /etc/tmpfiles.d/asusd-fancurves.conf <<'TMPFILES'
# type path                     mode uid  gid  age arg
z      /etc/asusd/fan_curves.ron 0644 root root -   -
TMPFILES

# asusd holds fan curves in memory and rewrites /etc/asusd/fan_curves.ron on
# exit, so the copied file only takes effect after a restart.
if systemctl is-active --quiet asusd; then
  sudo systemctl restart asusd
  echo "✅ asusd restarted — fan curves from etc/asusd/fan_curves.ron applied."
fi

echo "🎉 All setup steps completed successfully!"
echo ""
echo "⚠️  Manual step required: copy your avatar image to ~/.config/hypr/avatar.png"
echo "   This is used by hyprlock for the profile picture on the lock screen."
