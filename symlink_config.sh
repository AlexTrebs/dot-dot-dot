#!/usr/bin/env bash
# =============================================================
#  Link/copy configs — Raspberry Pi OS (pi-os branch)
# =============================================================
# Usage: ./symlink_config.sh [copy|symlink]
#
# Differs from the Arch branch in two important ways:
#
#  1. EXPLICIT ALLOWLIST. The Arch script walks all of .config/ and links
#     everything. On this box that would scatter hypr/, wayle/, rofi/ and
#     xdg-desktop-portal configs into ~/.config where nothing reads them —
#     this machine runs labwc + wf-panel-pi, not Hyprland. Only the terminal
#     stack is linked here.
#
#  2. BACKS UP whatever it replaces to <file>.pre-dotdotdot, so an existing
#     hand-tuned config is never silently destroyed. The appliance configs
#     (labwc, kanshi, wf-panel-pi, screen-control) are NOT in the allowlist
#     and are never touched.
set -uo pipefail

MODE="${1:-symlink}"
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

case "$MODE" in
  symlink|copy) ;;
  *) echo "Unknown mode: $MODE (use 'symlink' or 'copy')" >&2; exit 2 ;;
esac

echo "Running in $MODE mode from $REPO"

# Repo-relative paths to install into $HOME. Directories are linked/copied
# recursively; files individually.
ALLOW=(
  # Terminal stack
  ".config/alacritty"
  ".config/starship.toml"
  ".config/tmux"
  ".config/nvim"
  ".zshrc"
  ".gitconfig"

  # "Earth Arch" theming. Note these are single FILES, not directories —
  # linking .config/labwc or .config/wf-panel-pi wholesale would clobber
  # rc.xml and the panel .ini files, which carry appliance-critical settings
  # (touchscreen mapping, monitor binding). Those live in pi-appliance/ as
  # versioned reference copies and are deliberately never symlinked.
  ".config/gtk-3.0"
  ".config/labwc/themerc-override"
  ".config/wf-panel-pi/panel.css"

  # Helper scripts backing the labwc keybinds
  ".local/bin/screenshot.sh"
  ".local/bin/full_screenshot.sh"
  ".local/bin/auto_tmux.sh"
  ".local/bin/lock.sh"
)

backup() {
  local target="$1"
  if [ -e "$target" ] && [ ! -L "$target" ]; then
    mv -f "$target" "$target.pre-dotdotdot"
    echo "  backed up existing -> $target.pre-dotdotdot"
  elif [ -L "$target" ]; then
    rm -f "$target"
  fi
}

install_path() {
  local rel="$1"
  local src="$REPO/$rel"
  local dst="$HOME/$rel"

  if [ ! -e "$src" ]; then
    echo "⚠️  missing in repo, skipping: $rel"
    return
  fi

  mkdir -p "$(dirname "$dst")"

  if [ "$MODE" = "symlink" ]; then
    backup "$dst"
    ln -sfn "$src" "$dst"
    echo "🔗 $dst -> $src"
  else
    backup "$dst"
    cp -a "$src" "$dst"
    echo "📄 $dst"
  fi
}

for rel in "${ALLOW[@]}"; do
  install_path "$rel"
done

echo
echo "Done. Not touched (appliance configs): ~/.config/labwc, ~/.config/kanshi,"
echo "~/.config/wf-panel-pi, ~/screen-control"
