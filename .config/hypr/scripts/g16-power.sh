#!/bin/bash
set -euo pipefail
MONITOR="eDP-1"
RES_MAX="2560x1600@240"
RES_LOW="2560x1600@60"

CURRENT_PROFILE=$(asusctl profile get | grep -oP 'Active profile: \K\w+')

if [ "$CURRENT_PROFILE" = "Quiet" ]; then
    # ── OVERKILL ──────────────────────────────────────
    asusctl profile set Performance
    powerprofilesctl set performance

    # Display: full refresh rate + blur on
    hyprctl eval "hl.monitor({ output = \"$MONITOR\", mode = \"$RES_MAX\", position = \"0x0\", scale = 1.33 })"
    hyprctl eval "hl.config({ decoration = { blur = { enabled = true } } })"

    notify-send -u normal "MODE: OVERKILL" "240Hz | Performance"
else
    # ── CONSERVE ──────────────────────────────────────
    asusctl profile set Quiet
    powerprofilesctl set power-saver

    # Display: 60Hz + blur off (GPU savings)
    hyprctl eval "hl.monitor({ output = \"$MONITOR\", mode = \"$RES_LOW\", position = \"0x0\", scale = 1.33 })"
    hyprctl eval "hl.config({ decoration = { blur = { enabled = false } } })"

    # Reset PipeWire to default quantum (low-latency mode wastes CPU on battery)
    pw-metadata -n settings 0 clock.force-quantum 0

    notify-send -u low "MODE: CONSERVE" "60Hz | Quiet"
fi
