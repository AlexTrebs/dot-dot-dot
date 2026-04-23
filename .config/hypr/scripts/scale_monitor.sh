#!/bin/bash
set -euo pipefail
# Bump or reduce DPI scale on the active monitor by 0.1 increments
DIRECTION="${1:-up}"
MONITOR=$(hyprctl activeworkspace -j | jq -r '.monitor')
CURRENT=$(hyprctl monitors -j | jq -r --arg m "$MONITOR" '.[] | select(.name == $m) | .scale')

if [ "$DIRECTION" = "up" ]; then
    NEW=$(awk "BEGIN {printf \"%.2f\", $CURRENT + 0.1}")
else
    NEW=$(awk "BEGIN {printf \"%.2f\", $CURRENT - 0.1}")
fi

hyprctl keyword monitor "$MONITOR,preferred,auto,$NEW"
notify-send "Scale" "$MONITOR → $NEW"
