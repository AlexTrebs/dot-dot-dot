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
    hyprctl keyword monitor "$MONITOR,$RES_MAX,0x0,1.33"
    hyprctl keyword decoration:blur:enabled yes

    # Screen brightness back to full
    brightnessctl set 100%

    # Keyboard LEDs: red
    asusctl aura static --colour ff0000

    notify-send -u normal "MODE: OVERKILL" "240Hz | Performance | Full brightness"
else
    # ── CONSERVE ──────────────────────────────────────
    asusctl profile set Quiet
    powerprofilesctl set power-saver

    # Display: 60Hz + blur off (GPU savings)
    hyprctl keyword monitor "$MONITOR,$RES_LOW,0x0,1.33"
    hyprctl keyword decoration:blur:enabled no

    # Screen brightness: big battery win
    brightnessctl set 30%

    # Keyboard LEDs: off
    asusctl aura static --colour 000000

    # Reset PipeWire to default quantum (low-latency mode wastes CPU on battery)
    pw-metadata -n settings 0 clock.force-quantum 0

    notify-send -u low "MODE: CONSERVE" "60Hz | Quiet | 30% brightness | LEDs off"
fi
