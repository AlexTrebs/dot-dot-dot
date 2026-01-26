#!/usr/bin/env bash
# Link or copy files from your dotfiles repo into target directories
# Usage: ./symlink_config.sh [copy|symlink]
#   copy    - Copy all files (for fresh installs)
#   symlink - Symlink .config/.local, copy /etc (default)

MODE="${1:-symlink}"

if [[ "$MODE" != "copy" && "$MODE" != "symlink" ]]; then
  echo "Usage: $0 [copy|symlink]"
  exit 1
fi

echo "Running in $MODE mode..."

# Paths
CONFIG_SRC="$(pwd)/.config"
LOCAL_SRC="$(pwd)/.local"
ETC_SRC="$(pwd)/etc"
CONFIG_DST="$HOME/.config"
LOCAL_DST="$HOME/.local"
ETC_DST="/etc"

# Generic function to link or copy files
# Usage: link_or_copy <source_dir> <target_dir> <mode>
# mode: "symlink" or "copy"
link_or_copy() {
    local src="$1"
    local dst="$2"
    local mode="$3"

    if [ ! -d "$src" ]; then
        echo "Source directory not found: $src"
        return 1
    fi

    find "$src" -type f | while read -r file; do
        local rel_path="${file#$src/}"
        local target="$dst/$rel_path"
        local target_dir
        target_dir=$(dirname "$target")

        mkdir -p "$target_dir"

        # Remove existing file or symlink
        if [ -e "$target" ] || [ -L "$target" ]; then
            rm -rf "$target"
        fi

        if [ "$mode" == "symlink" ]; then
            ln -sf "$file" "$target"
            echo "Linked $target"
        elif [ "$mode" == "copy" ]; then
            cp -p "$file" "$target"
            echo "Copied $target"
        else
            echo "Unknown mode: $mode"
            return 1
        fi
    done
}

# Copy /etc files (requires sudo)
copy_etc() {
    local src="$1"
    local dst="$2"

    if [ ! -d "$src" ]; then
        echo "No etc/ directory found, skipping."
        return 0
    fi

    echo "Copying /etc files (requires sudo)..."
    find "$src" -type f | while read -r file; do
        local rel_path="${file#$src/}"
        local target="$dst/$rel_path"
        local target_dir
        target_dir=$(dirname "$target")

        sudo mkdir -p "$target_dir"
        sudo cp -p "$file" "$target"
        echo "Copied $target"
    done
}

# Run for .config
link_or_copy "$CONFIG_SRC" "$CONFIG_DST" "$MODE"

# Run for .local
link_or_copy "$LOCAL_SRC" "$LOCAL_DST" "$MODE"

# Run for /etc (copy with sudo)
copy_etc "$ETC_SRC" "$ETC_DST"

echo "All operations completed!"

# Reload Hyprland if available
command -v hyprctl &> /dev/null && hyprctl reload
