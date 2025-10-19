#!/usr/bin/env bash
set -e

WALLPAPER_DIR="$HOME/Pictures/BingWallpapers"
mkdir -p "$WALLPAPER_DIR"
WALLPAPER="$WALLPAPER_DIR/today.jpg"
INFO_FILE="$WALLPAPER_DIR/info.json"

# Get Bing metadata
JSON=$(curl -s "https://www.bing.com/HPImageArchive.aspx?format=js&idx=0&n=1&mkt=en-US")
URL="https://www.bing.com$(echo $JSON | jq -r '.images[0].url' | sed 's/1920x1080/3840x2160/')"
TITLE=$(echo "$JSON" | jq -r '.images[0].title')
COPYRIGHT=$(echo "$JSON" | jq -r '.images[0].copyright')
COPYRIGHTLINK=$(echo "$JSON" | jq -r '.images[0].copyrightlink')

JSON=$(curl -s "https://www.bing.com/HPImageArchive.aspx?format=js&idx=0&n=1&mkt=en-US")

# Extract the base image URL
BASE_URL=$(echo "$JSON" | jq -r '.images[0].url')

# Try different resolutions in order: 4K, UHD, fallback
for RES in "3840x2160" "UHD" "1920x1080"; do
    URL="https://www.bing.com${BASE_URL/1920x1080/$RES}"
    echo $URL
    # Try downloading to temp file
    if curl -sf -o $WALLPAPER "$URL"; then
      echo "Downloaded Bing wallpaper at resolution $RES as bing_wallpaper.jpg"
    fi
done

# Save JSON for Waybar
echo "$JSON" > "$INFO_FILE"

# Download wallpaper
curl -s -o "$WALLPAPER" "https://www.bing.com$URL"

# Update Hyprpaper (without restart)
if pgrep hyprpaper >/dev/null; then
  hyprctl hyprpaper reload ,"$WALLPAPER"
else
  CONF="/tmp/hyprpaper.conf"
  cat <<EOF > "$CONF"
preload = $WALLPAPER
wallpaper = ,$WALLPAPER
splash = false
EOF
  hyprpaper -c "$CONF" &
fi
