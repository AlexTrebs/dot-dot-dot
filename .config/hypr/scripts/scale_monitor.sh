#!/bin/bash
set -euo pipefail
# Bump or reduce DPI scale on the active monitor by 0.1 increments
DIRECTION="${1:-up}"
MONITOR=$(hyprctl activeworkspace -j | jq -r '.monitor')
CURRENT=$(hyprctl monitors -j | jq -r --arg m "$MONITOR" '.[] | select(.name == $m) | .scale')
SCALE=(0.20 0.30 0.40 0.50 0.60 0.67 0.75 0.83 1.00 1.20 1.33 1.50 1.60 1.67)

IDX=-1
for i in "${!SCALE[@]}"; do
    if awk "BEGIN {exit !(${SCALE[$i]} == $CURRENT)}"; then
        IDX=$i
        break
    fi
done

if [ "$DIRECTION" = "up" ]; then
    NEXT=$(( IDX + 1 ))
    [ $NEXT -ge ${#SCALE[@]} ] && NEXT=$(( ${#SCALE[@]} - 1 ))
else
    NEXT=$(( IDX - 1 ))
    [ $NEXT -lt 0 ] && NEXT=0
fi

NEW=${SCALE[$NEXT]}

hyprctl keyword monitor "$MONITOR,preferred,auto,$NEW"
notify-send "Scale" "$MONITOR → $NEW"
