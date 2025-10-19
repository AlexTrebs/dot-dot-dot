#!/usr/bin/env bash
# Link or copy files from your dotfiles repo into target directories

# Paths
CONFIG_SRC="$(pwd)/.config"
LOCAL_SRC="$(pwd)/.local"
CONFIG_DST="$HOME/.config"
LOCAL_DST="$HOME/.local"

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

# Run for .config (symlink)
link_or_copy "$CONFIG_SRC" "$CONFIG_DST" "symlink"

# Run for .local (copy)
link_or_copy "$LOCAL_SRC" "$LOCAL_DST" "symlink"

echo "All operations completed!"

# Reload Hyprland if available
command -v hyprctl &> /dev/null && hyprctl reload
