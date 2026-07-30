#!/usr/bin/env bash
# =============================================================
#  dot-dot-dot — Raspberry Pi OS (Debian Trixie) install
# =============================================================
# This is the pi-os branch. The Arch/pacman + Hyprland/NVIDIA/SDDM/secure-boot
# logic from main does not apply here: this box runs Raspberry Pi OS Trixie on
# labwc (Wayland) with the stock LXDE-pi desktop and wf-panel-pi, and it is also
# a kiosk appliance (see ~/screen-control). So this script installs ONLY the
# terminal stack + theming and leaves the desktop/compositor alone.
#
# Usage: ./install.sh [copy|symlink]
#   (no args) - packages + fonts + plugins only
#   symlink   - also symlink configs (best for editing them in-repo)
#   copy      - also copy configs
set -euo pipefail

current_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_MODE="${1:-}"

echo "🔄 Initialising git submodules..."
git -C "$current_dir" submodule update --init --recursive

# ==========================================
#  apt packages
# ==========================================
# Debian renames two of these binaries: bat -> batcat, fd -> fdfind.
# The .zshrc aliases them back.
packages=(
  # Terminal, multiplexer, shell
  alacritty tmux zsh zsh-autosuggestions zsh-syntax-highlighting

  # Prompt + navigation
  starship fzf zoxide

  # Modern CLI replacements
  eza bat fd-find ripgrep jq tree procs du-dust

  # Dev / system
  neovim git lazygit btop direnv curl unzip

  # Clipboard (Wayland + XWayland)
  wl-clipboard xclip

  # Fonts (Nerd-patched JetBrains Mono is fetched separately below)
  fonts-jetbrains-mono fonts-noto-color-emoji
)

to_install=()
for pkg in "${packages[@]}"; do
  dpkg-query -W -f='${Status}' "$pkg" 2>/dev/null | grep -q "ok installed" || to_install+=("$pkg")
done

if (( ${#to_install[@]} > 0 )); then
  echo "📦 Installing ${#to_install[@]} missing packages..."
  sudo apt update
  sudo apt install -y "${to_install[@]}"
else
  echo "✅ All apt packages already installed."
fi

# ==========================================
#  Nerd Font (not packaged for Debian)
# ==========================================
FONTDIR="$HOME/.local/share/fonts/JetBrainsMonoNerdFont"
if ! fc-list -f '%{family[0]}\n' 2>/dev/null | grep -qx "JetBrainsMono Nerd Font"; then
  echo "🔤 Installing JetBrainsMono Nerd Font..."
  mkdir -p "$FONTDIR"
  tmp=$(mktemp -d)
  tag=$(curl -fsSL https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest \
        | grep -m1 '"tag_name"' | cut -d'"' -f4)
  if [ -n "$tag" ] && curl -fL --retry 3 -o "$tmp/JetBrainsMono.zip" \
       "https://github.com/ryanoasis/nerd-fonts/releases/download/${tag}/JetBrainsMono.zip"; then
    unzip -q -o "$tmp/JetBrainsMono.zip" -d "$tmp/jb"
    find "$tmp/jb" -name '*.ttf' -exec cp -f {} "$FONTDIR/" \;
    fc-cache -f "$FONTDIR" >/dev/null
    echo "  installed $(ls -1 "$FONTDIR" | wc -l) ttf files ($tag)"
  else
    echo "  ⚠️  font download failed — Alacritty will fall back to fonts-jetbrains-mono (no glyphs)"
  fi
  rm -rf "$tmp"
else
  echo "✅ JetBrainsMono Nerd Font already installed."
fi

# ==========================================
#  zsh plugins Debian doesn't package
# ==========================================
ZSH_VENDOR="$HOME/.local/share/zsh/plugins"
mkdir -p "$ZSH_VENDOR"
for repo in "zsh-users/zsh-history-substring-search" "MichaelAquilina/zsh-you-should-use"; do
  name="${repo##*/}"
  if [ -d "$ZSH_VENDOR/$name" ]; then
    echo "✅ $name already vendored."
  else
    echo "🔌 Cloning $name..."
    git clone --depth 1 "https://github.com/$repo.git" "$ZSH_VENDOR/$name"
  fi
done

# ==========================================
#  Default shell
# ==========================================
if [ "$(getent passwd "$USER" | cut -d: -f7)" != "/usr/bin/zsh" ]; then
  echo "🐚 Setting zsh as default shell (prompts for password)..."
  chsh -s /usr/bin/zsh "$USER" || echo "  ⚠️  chsh failed — run it yourself: chsh -s /usr/bin/zsh"
else
  echo "✅ zsh already the default shell."
fi

# ==========================================
#  Configs
# ==========================================
if [[ -n "$CONFIG_MODE" ]]; then
  "$current_dir/symlink_config.sh" "$CONFIG_MODE"
else
  echo "ℹ️  Skipping configs. Run './symlink_config.sh symlink' to set them up."
fi

echo
echo "🎉 Done. Open a new Alacritty window (or run 'zsh') to pick up the new shell."
