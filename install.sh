#!/usr/bin/env bash
set -euo pipefail
# Usage: ./install.sh [copy|symlink]
#   (no args) - Install packages and configure system only
#   copy      - Also copy all config files
#   symlink   - Also symlink .config/.local (for development/updates)

current_dir="$(pwd)"
CONFIG_MODE="${1:-}"

# ==========================================
# Initialise submodules
# ==========================================
echo "🔄 Initialising git submodules..."
git submodule update --init --recursive

# ==========================================
# Pacman Packages
# ==========================================
packages=(
  # Base system
  "base" "base-devel" "linux" "linux-firmware" "grub" "efibootmgr" "os-prober"

  # CPU/GPU drivers
  "intel-media-driver" "intel-ucode" "libva-intel-driver" "mesa-utils"
  "nvidia-open" "nvidia-prime" "nvidia-settings" "nvidia-utils"
  "vulkan-intel"

  # Audio
  "alsa-firmware" "alsa-utils" "pamixer" "pipewire-alsa"
  "pipewire-jack" "pipewire-pulse" "wireplumber"

  # Bluetooth
  "bluez" "bluez-utils"

  # Network
  "iwd" "networkmanager"
  "openssh" "wget" "wpa_supplicant"

  # Hyprland & Wayland
  "hyprland" "hypridle" "hyprlock" "hyprpaper" "hyprpolkitagent" "hyprsunset"
  "hyprpicker" "swww" "slurp" "grim" "wl-clipboard"
  "xdg-desktop-portal-gtk" "xdg-desktop-portal-hyprland" "xdg-utils"
  "qt5-wayland" "qt6-wayland"
  "wf-recorder"

  # Display manager
  "sddm"

  # Terminal & Shell
  "alacritty" "tmux" "fzf" "zram-generator"
  "zsh" "zsh-autosuggestions" "zsh-syntax-highlighting"

  # File management
  "thunar" "gvfs" "gvfs-mtp" "file-roller"

  # Text editors
  "nano" "neovim" "vim"

  # File viewers
  "zathura" "zathura-pdf-mupdf"
  "imv"
  "mpv"

  # Office
  "libreoffice-fresh"

  # Development
  "bat" "eza" "fd" "git" "git-lfs" "go" "jq" "lazygit" "playerctl" "ripgrep" "stylua" "uv" "yazi" "zoxide"

  # Apps
  "discord" "easyeffects" "firefox" "obs-studio" "rofi" "spotify-launcher" "starship" "steam" "zenity"

  # Gaming — gamescope sits in every game's launch options; mangohud is how you
  # tell whether a change helped. lib32 variant is required for 32-bit titles.
  "gamescope" "mangohud" "lib32-mangohud"

  # Fonts
  "noto-fonts-cjk" "noto-fonts-emoji" "ttf-fira-code" "ttf-jetbrains-mono-nerd"

  # Peripherals. None of this is Hyprland's problem — it is all portal/CUPS/SANE
  # level — but none of it was installed either, so a printer or scanner simply
  # did nothing in the Plasma session. sane-airscan is the driverless backend
  # that makes modern network and USB scanners work without hunting for a
  # vendor driver; print-manager and skanpage are the KDE front ends.
  "cups" "cups-pdf" "print-manager" "sane" "sane-airscan" "skanpage"

  # Firmware updates. Discover already ships fwupd-backend.so, so its firmware
  # page existed and was permanently empty without this.
  "fwupd"

  # System utilities
  "brightnessctl" "btop" "direnv" "dust" "gnome-keyring" "less" "nwg-look" "nvm" "power-profiles-daemon"
  "pacman-contrib" "procs" "reflector"
  "rsync" "sbctl" "smartmontools" "socat" "tree" "uwsm" "wev"
  "zsh-history-substring-search"
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
# Set zsh as default shell
# ==========================================
if [[ "$SHELL" != "/usr/bin/zsh" ]]; then
  echo "🐚 Setting zsh as default shell..."
  sudo chsh -s /usr/bin/zsh "$USER"
else
  echo "✅ zsh already default shell."
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
  "asusctl"
  "wayle-git"
  "automatic-timezoned"
  "clipse"
  "davinci-resolve"
  "gtk2"
  "mullvad-vpn-bin"
  "ninjabrain-bot"
  "obsidian"
  "pwvucontrol"
  "r2modman-bin"
  "rog-control-center"
  "spotify"
  "supergfxctl"
  "tasks-git"

  # SteamOS Gaming Mode as a third SDDM session, alongside Hyprland and Plasma.
  # Pulls gamescope-session-git; needs Steam, which is already in the pacman
  # list. Exit via the power menu -> Switch to Desktop, which drops back to
  # SDDM rather than to a specific session.
  #
  # Two things to watch:
  #  - gamescope-session-git symlinks /usr/share/wayland-sessions/gamescope-session.desktop,
  #    so SDDM can show two near-identical entries. Removing that symlink leaves
  #    the steam one. (Not the same mechanism as the hyprland.desktop shadow —
  #    that one lives in /usr/local/share and is deliberate. See the README.)
  #  - the session is sensitive to the gamescope version, and gamescope here is
  #    load-bearing for every game's launch options. If a gamescope upgrade
  #    breaks Gaming Mode, fix the session, do not downgrade gamescope.
  "gamescope-session-steam-git"

  "paru"
  "vimix-cursors-git"
  "timeshift"
  "wl-clip-persist-git"
  "wlogout"
  "zen-browser-bin"
  "zsh-you-should-use"
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

echo "🔋 Enabling user services..."
systemctl --user enable batteryListener.service || true
systemctl --user enable wayle-resume.service || true

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
# NOTE: For hibernate to work, you also need to configure resume parameters
# in GRUB after setting up swap. Run these commands:
#   ROOT_UUID=$(findmnt / -o UUID -n)
#   SWAP_OFFSET=$(sudo filefrag -v /swapfile | awk 'NR==4 {print $4}' | sed 's/\.\.//')
#   Then add to GRUB_CMDLINE_LINUX_DEFAULT:
#   resume=UUID=$ROOT_UUID resume_offset=$SWAP_OFFSET
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
# The following tools are built locally from source and not installed by this script.
# Configs reference them but the binaries must be present for the related autostart
# entries in hyprland.conf to succeed:
#   - hyprcut  : keymap overlay   -> build from your fork, install to ~/.local/bin/hyprcut
# After building, ensure the binaries are on PATH (or matched in hyprland exec-once).
# wayle is NOT manual — it comes from the wayle-git AUR package above (/usr/bin/wayle).

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

# Must be `install -o root -g root`, never `cp -a`/`cp -p`. asusd.service sets
# CapabilityBoundingSet= and AmbientCapabilities= to EMPTY, so the daemon runs as
# root WITHOUT CAP_DAC_OVERRIDE. It rewrites this file on exit, and opening a
# file owned by another user for write then returns EACCES — asusd panics at
# config-traits/src/lib.rs:94 and core-dumps on every boot until the start limit
# is hit. A `cp -a` from this repo preserves the user ownership and breaks it.
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
