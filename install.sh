#!/usr/bin/env bash
set -euo pipefail

current_dir="$(pwd)"

# ==========================================
# Pacman Packages
# ==========================================
packages=(
  "alacritty" "alsa-firmware" "alsa-utils" "archinstall" "base" "base-devel"
  "betterlockscreen" "blueberry" "blueman" "bluez" "bluez-utils" "brightnessctl"
  "discord" "dolphin" "dunst" "efibootmgr" "firefox" "git" "grim" "grub"
  "gtk2" "gvfs" "htop" "hypridle" "hyprland" "hyprlock" "hyprpaper"
  "hyprpolkitagent" "hyprsunset" "intel-media-driver" "intel-ucode" "iwd" "jq"
  "kitty" "libva-intel-driver" "lightdm" "lightdm-slick-greeter" "linux"
  "linux-firmware" "mesa-utils" "nano" "network-manager-applet" "networkmanager"
  "nm-connection-editor" "nvidia" "nvidia-prime" "nvidia-settings" "nvidia-utils"
  "nwg-look" "openssh" "os-prober" "pamixer" "pavucontrol" "pipewire-alsa"
  "pipewire-jack" "pipewire-pulse" "polkit-gnome" "polkit-kde-agent" "powerline"
  "qt5-wayland" "qt6-wayland" "reflector" "rofi" "slurp" "smartmontools"
  "steam" "swayidle" "swaync" "swayosd" "thunar" "tmux" "ttf-fira-code"
  "ttf-jetbrains-mono-nerd" "uwsm" "vim" "vulkan-intel" "vulkan-nouveau"
  "vulkan-radeon" "waybar" "wget" "wireless_tools" "wireplumber" "wl-clipboard"
  "wofi" "wpa_supplicant" "xdg-desktop-portal-hyprland" "xdg-utils"
  "xf86-video-amdgpu" "xf86-video-ati" "xf86-video-nouveau" "xorg-server"
  "xorg-xinit" "yay-bin" "zram-generator"
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
aur_packages=("pwvucontrol" "rog-control-center" "spotify" "tasks-git" "vimix-cursors-git" "wlogout" "zen-browser-bin")
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
# Run symlink setup
# ==========================================
if [[ -x "$current_dir/create_symlinks.sh" ]]; then
  echo "🔗 Running symlink setup..."
  "$current_dir/create_symlinks.sh"
else
  echo "⚠️ create_symlinks.sh not found or not executable."
fi

# ==========================================
# Enable services
# ==========================================
echo "🔌 Enabling Bluetooth..."
sudo systemctl enable --now bluetooth.service || true

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

echo "🎉 All setup steps completed successfully!"
