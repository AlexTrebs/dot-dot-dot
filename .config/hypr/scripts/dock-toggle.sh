#!/bin/bash
set -euo pipefail
EXTERNAL="DP-5"

if hyprctl monitors | grep -q "$EXTERNAL"; then
    hyprctl eval "hl.monitor({ output = \"$EXTERNAL\", mode = \"1920x1080@144\", position = \"auto-right\", scale = 1 })"
    hyprctl eval "hl.monitor({ output = \"eDP-1\", mode = \"2560x1600@240\", position = \"0x0\", scale = 1.33 })"
    for ws in 2 3 4; do
        hyprctl dispatch "hl.dsp.workspace.move({ workspace = \"$ws\", monitor = \"$EXTERNAL\" })"
    done
    mullvad lan set allow
    notify-send "Docked" "External monitor active, LAN allowed"
else
    hyprctl eval "hl.monitor({ output = \"eDP-1\", mode = \"2560x1600@240\", position = \"0x0\", scale = 1.33 })"
    for ws in 1 2 3 4; do
        hyprctl dispatch "hl.dsp.workspace.move({ workspace = \"$ws\", monitor = \"eDP-1\" })"
    done
    mullvad lan set block
    notify-send "Undocked" "Laptop only, LAN blocked"
fi
