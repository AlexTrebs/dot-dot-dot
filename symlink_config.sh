#!/usr/bin/env bash
# Link all files from your repo's .config/ into ~/.config/, preserving structure.

# Path to your dotfiles repo
DOTFILES_DIR="$(pwd)/.config"
TARGET_DIR="$HOME/.config"

# Safety first
if [ ! -d "$DOTFILES_DIR" ]; then
    echo "Dotfiles config directory not found: $DOTFILES_DIR"
    exit 1
fi

# Walk through all files and directories
find "$DOTFILES_DIR" -type f | while read -r file; do
    # Get relative path inside .config/
    rel_path="${file#$DOTFILES_DIR/}"
    target_path="$TARGET_DIR/$rel_path"
    target_dir=$(dirname "$target_path")

    # Make sure target directory exists
    mkdir -p "$target_dir"

    # Remove existing file if it's already a symlink
    if [ -L "$target_path" ]; then
        rm "$target_path"
    fi

    # Create the symlink
    ln -s "$file" "$target_path"
    echo "Linked $rel_path"
done

echo "Done! All files linked into ~/.config/"
