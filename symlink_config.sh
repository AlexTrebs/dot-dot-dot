#!/usr/bin/env bash
# Link or copy files from your dotfiles repo into target directories
# Usage: ./symlink_config.sh [copy|symlink]
#   copy    - Copy all files (for fresh installs)
#   symlink - Symlink .config/.local, copy /etc (default)

MODE="${1:-symlink}"

echo "Running in $MODE mode..."

# Anchored to this script, not the caller's cwd: if src == dst, the rm-then-link
# below replaces every file with a symlink to itself. The guard is the backstop.
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
CONFIG_SRC="$REPO_ROOT/.config"
LOCAL_SRC="$REPO_ROOT/.local"
ETC_SRC="$REPO_ROOT/etc"
CONFIG_DST="$HOME/.config"
LOCAL_DST="$HOME/.local"
ETC_DST="/etc"

if [ "$REPO_ROOT" = "$(cd "$HOME" && pwd -P)" ]; then
    echo "REFUSING: repo root is \$HOME — source and destination are the same." >&2
    echo "This would destroy every file it touched. Move the repo elsewhere." >&2
    exit 1
fi

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

    find "$src" -type f -print0 | while IFS= read -r -d '' file; do
        local rel_path="${file#$src/}"
        local target="$dst/$rel_path"
        local target_dir
        target_dir=$(dirname "$target")

        mkdir -p "$target_dir"

        # Never let source and destination be the same file. rm below is
        # unconditional, so without this a match deletes the only copy.
        if [ "$file" -ef "$target" ]; then
            echo "SKIP (src == dst): $target"
            continue
        fi

        # Remove existing file or symlink
        if [ -e "$target" ] || [ -L "$target" ]; then
            rm -f "$target"
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
    find "$src" -type f -print0 | while IFS= read -r -d '' file; do
        local rel_path="${file#$src/}"
        local target="$dst/$rel_path"
        local target_dir
        target_dir=$(dirname "$target")

        sudo mkdir -p "$target_dir"
        # root:root, not cp -p: that kept your ownership, leaving pacman hooks
        # and pacman.conf user-writable, and it breaks asusd (see install.sh).
        sudo install -o root -g root -m "$(stat -c %a "$file")" "$file" "$target"
        echo "Copied $target"
    done
}

# Remove symlinks that point into this repo but whose target no longer exists.
# Renaming or deleting a repo file leaves its old link behind forever otherwise:
# link_or_copy only ever creates, never prunes. Scoped to links aimed at
# $REPO_ROOT so app-owned files in the destination are never touched.
prune_stale() {
    local dst="$1"
    [ -d "$dst" ] || return 0
    find "$dst" -xtype l -print0 2>/dev/null | while IFS= read -r -d '' link; do
        case "$(readlink "$link")" in
            "$REPO_ROOT"/*)
                rm -f "$link"
                echo "Pruned stale link: $link"
                ;;
        esac
    done
}

prune_stale "$CONFIG_DST"
prune_stale "$LOCAL_DST"

# Run for .config
link_or_copy "$CONFIG_SRC" "$CONFIG_DST" "$MODE"

# Run for .local
link_or_copy "$LOCAL_SRC" "$LOCAL_DST" "$MODE"

# Always copy /etc (cannot symlink into /etc; copy regardless of mode)
copy_etc "$ETC_SRC" "$ETC_DST"

# Link/copy home dotfiles (.bashrc, .gitconfig)
for dotfile in .bashrc .zshrc .gitconfig .profile; do
    src="$REPO_ROOT/$dotfile"
    dst="$HOME/$dotfile"
    if [ ! -f "$src" ]; then
        continue
    fi
    if [ "$src" -ef "$dst" ]; then
        echo "SKIP (src == dst): $dst"
        continue
    fi
    if [ -e "$dst" ] || [ -L "$dst" ]; then
        rm -f "$dst"
    fi
    if [ "$MODE" = "symlink" ]; then
        ln -sf "$src" "$dst"
        echo "Linked $dst"
    else
        cp -p "$src" "$dst"
        echo "Copied $dst"
    fi
done

echo "All operations completed!"

# Reload Hyprland if available
if [ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]; then
    hyprctl reload
fi
