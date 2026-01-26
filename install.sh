#!/usr/bin/env bash
set -euo pipefail
# Usage: ./install.sh [copy|symlink]
#   (no args) - Install packages and configure system only
#   copy      - Also copy all config files
#   symlink   - Also symlink .config/.local (for development/updates)

current_dir="$(pwd)"
CONFIG_MODE="${1:-}"

# ==========================================
# Pacman Packages
# ==========================================
packages=(
  # Base system
  "base" "base-devel" "linux" "linux-firmware" "grub" "efibootmgr" "os-prober"

  # CPU/GPU drivers
  "intel-media-driver" "intel-ucode" "libva-intel-driver" "mesa-utils"
  "nvidia-open" "nvidia-prime" "nvidia-settings" "nvidia-utils"
  "vulkan-intel" "vulkan-nouveau" "vulkan-radeon"

  # Audio
  "alsa-firmware" "alsa-utils" "pamixer" "pavucontrol" "pipewire-alsa"
  "pipewire-jack" "pipewire-pulse" "wireplumber"
  "audacious"

  # Bluetooth
  "blueberry" "blueman" "bluez" "bluez-utils"

  # Network
  "iwd" "networkmanager" "network-manager-applet" "nm-connection-editor"
  "openssh" "wget" "wireless_tools" "wpa_supplicant"

  # Hyprland & Wayland
  "hyprland" "hypridle" "hyprlock" "hyprpaper" "hyprpolkitagent" "hyprsunset"
  "hyprpicker" "swww" "swayosd" "slurp" "grim" "wl-clipboard"
  "xdg-desktop-portal-gtk" "xdg-desktop-portal-hyprland" "xdg-utils"
  "qt5-wayland" "qt6-wayland"
  "wf-recorder"

  # Display manager
  "sddm"

  # Terminal & Shell
  "alacritty" "kitty" "tmux" "powerline" "fzf" "zram-generator"

  # File management
  "dolphin" "thunar" "gvfs" "file-roller"

  # Text editors
  "nano" "neovim" "vim"

  # File viewers
  "zathura" "zathura-pdf-mupdf"
  "imv" "feh"
  "mpv"

  # Office
  "libreoffice-fresh"

  # Development
  "fd" "git" "go" "jq" "stylua" "uv"

  # Apps
  "discord" "firefox" "obs-studio" "rofi" "steam"

  # Fonts
  "noto-fonts-cjk" "ttf-fira-code" "ttf-jetbrains-mono-nerd"

  # System utilities
  "brightnessctl" "gnome-keyring" "gtk2" "htop" "less" "nwg-look"
  "pacman-contrib" "polkit-gnome" "polkit-kde-agent" "reflector"
  "rsync" "smartmontools" "socat" "tree" "uwsm" "wev"
)

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
# Install yay (AUR helper)
# ==========================================
if ! command -v yay &>/dev/null; then
  echo "🚀 Installing yay..."
  tmpdir=$(mktemp -d)
  git clone https://aur.archlinux.org/yay-bin.git "$tmpdir/yay-bin"
  cd "$tmpdir/yay-bin"
  makepkg -si --noconfirm
  cd "$current_dir"
  rm -rf "$tmpdir"
else
  echo "✅ yay already installed."
fi

# ==========================================
# Install AUR Packages
# ==========================================
aur_packages=(
  "ags-hyprpanel-git"
  "asdf-vm"
  "asusctl"
  "automatic-timezoned"
  "betterlockscreen"
  "clipse"
  "nvm"
  "pwvucontrol"
  "rog-control-center"
  "spotify"
  "swaylock-effects-improved-git"
  "tasks-git"
  "vimix-cursors-git"
  "wlogout"
  "zen-browser-bin"
)
aur_to_install=()

for pkg in "${aur_packages[@]}"; do
  if ! pacman -Qq "$pkg" &>/dev/null; then
    aur_to_install+=("$pkg")
  fi
done

if (( ${#aur_to_install[@]} > 0 )); then
  echo "📦 Installing missing AUR packages..."
  yay -S --noconfirm --needed --skipreview "${aur_to_install[@]}"
else
  echo "✅ All AUR packages already installed."
fi

# ==========================================
# Enable services
# ==========================================
echo "🔌 Enabling Bluetooth..."
sudo systemctl enable --now bluetooth.service || true

# ==========================================
# NVIDIA Hibernate Configuration
# ==========================================
# nvidia-open requires special config for hibernate to work:
# 1. Do NOT load nvidia in early KMS (initramfs can't access /var/tmp)
# 2. Use simpledrm for early framebuffer instead
# 3. Enable nvidia power management services
#
# NOTE: For hibernate to work, you also need to configure resume parameters
# in GRUB after setting up swap. Run these commands:
#   ROOT_UUID=$(findmnt / -o UUID -n)
#   SWAP_OFFSET=$(sudo filefrag -v /swapfile | awk 'NR==4 {print $4}' | sed 's/\.\.//')
#   Then add to GRUB_CMDLINE_LINUX_DEFAULT:
#   resume=UUID=$ROOT_UUID resume_offset=$SWAP_OFFSET
# ==========================================
echo "🖥️ Configuring NVIDIA hibernate support..."

# Configure mkinitcpio: simpledrm for early framebuffer, NO nvidia early loading
if grep -q "^MODULES=()" /etc/mkinitcpio.conf; then
  sudo sed -i 's/^MODULES=()/MODULES=(simpledrm)/' /etc/mkinitcpio.conf
  echo "  Added simpledrm to MODULES"
elif grep -q "^MODULES=.*nvidia" /etc/mkinitcpio.conf; then
  # Remove nvidia modules, add simpledrm
  sudo sed -i 's/^MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)/MODULES=(simpledrm)/' /etc/mkinitcpio.conf
  echo "  Replaced nvidia early KMS with simpledrm"
elif ! grep -q "simpledrm" /etc/mkinitcpio.conf; then
  sudo sed -i 's/^MODULES=(/MODULES=(simpledrm /' /etc/mkinitcpio.conf
  echo "  Added simpledrm to existing MODULES"
else
  echo "  simpledrm already configured"
fi

# Ensure resume hook is present for hibernate
if ! grep -q "resume" /etc/mkinitcpio.conf; then
  sudo sed -i 's/filesystems/filesystems resume/' /etc/mkinitcpio.conf
  echo "  Added resume hook"
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

# Rebuild initramfs
echo "  Rebuilding initramfs..."
sudo mkinitcpio -P

# ==========================================
# Add user to groups (ignore missing ones)
# ==========================================
for group in network video storage audio wheel kvm docker; do
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
  cp ./.config/zed/zed.desktop ~/.local/share/application/zed.desktop
  update-desktop-database ~/.local/share/applications/
else
  echo "✅ Zed already installed."
fi

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

echo "🎉 All setup steps completed successfully!"
