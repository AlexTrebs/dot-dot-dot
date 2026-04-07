#!/usr/bin/env bash
set -e

WALLPAPER_DIR="$HOME/Pictures/BingWallpapers"
mkdir -p "$WALLPAPER_DIR"

WALLPAPER="$WALLPAPER_DIR/today.jpg"
INFO_FILE="$WALLPAPER_DIR/info.json"
TEMP_WALL="$WALLPAPER_DIR/tmp.jpg"

# Check dependencies
command -v curl >/dev/null 2>&1 || { echo "Error: curl not installed"; exit 1; }
command -v jq >/dev/null 2>&1 || { echo "Error: jq not installed"; exit 1; }

# Wait for hyprpaper to be ready
wait_for_hyprpaper() {
    for _ in $(seq 1 20); do
        hyprctl hyprpaper listloaded >/dev/null 2>&1 && return 0
        sleep 0.5
    done
    echo "Error: hyprpaper did not start in time"
    return 1
}

# Function to set wallpaper using hyprpaper IPC
set_wallpaper() {
    echo "Setting wallpaper with hyprpaper: $WALLPAPER"

    wait_for_hyprpaper || return 1

    hyprctl hyprpaper preload "$WALLPAPER"

    hyprctl monitors -j | jq -r '.[].name' | while read -r monitor; do
        hyprctl hyprpaper wallpaper "$monitor,$WALLPAPER"
    done
}

# Try fetching Bing wallpaper, but don't let failure stop the script
if JSON=$(curl -fsSL "https://www.bing.com/HPImageArchive.aspx?format=js&idx=0&n=1&mkt=en-US" 2>/dev/null); then
    BASE_URL=$(echo "$JSON" | jq -r '.images[0].url')

    # Try resolutions in order
    SUCCESS=false
    for RES in "3840x2160" "UHD" "1920x1080"; do
        URL="https://www.bing.com${BASE_URL/1920x1080/$RES}"
        if curl -fsSL -o "$TEMP_WALL" "$URL"; then
            mv "$TEMP_WALL" "$WALLPAPER"
            echo "$JSON" > "$INFO_FILE"
            echo "Downloaded Bing wallpaper at $RES"
            SUCCESS=true
            break
        fi
    done

    if [ "$SUCCESS" = false ]; then
        echo "Warning: Failed to download Bing wallpaper — keeping existing one."
    fi
else
    echo "Warning: Could not fetch Bing JSON — check your internet connection."
fi

# Always set wallpaper (even if wallpaper fetch failed)
set_wallpaper
