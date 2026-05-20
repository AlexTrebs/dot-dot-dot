#!/bin/bash
set -euo pipefail
EXTERNAL="DP-5"

if hyprctl monitors | grep -q "$EXTERNAL"; then
    hyprctl keyword monitor "$EXTERNAL,1920x1080@144,auto-right,1"
    hyprctl keyword monitor "eDP-1,2560x1600@240,0x0,1.33"
    for ws in 2 3 4; do
        hyprctl dispatch moveworkspacetomonitor "$ws $EXTERNAL"
    done
    mullvad lan set allow
    notify-send "Docked" "External monitor active, LAN allowed"
else
    hyprctl keyword monitor "eDP-1,2560x1600@240,0x0,1.33"
    for ws in 1 2 3 4; do
        hyprctl dispatch moveworkspacetomonitor "$ws eDP-1"
    done
    mullvad lan set block
    notify-send "Undocked" "Laptop only, LAN blocked"
fi
