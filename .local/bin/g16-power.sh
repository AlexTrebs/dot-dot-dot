#!/bin/bash
set -euo pipefail
MONITOR="eDP-1"
RES_MAX="2560x1600@240"
RES_LOW="2560x1600@60"

CURRENT_PROFILE=$(asusctl profile -p | grep -oP '(?<=is ).*')

if [ "$CURRENT_PROFILE" = "Quiet" ]; then
    asusctl profile --profile Performance
    hyprctl keyword monitor "$MONITOR,$RES_MAX,0x0,1.33"
    hyprctl keyword decoration:blur:enabled yes
    asusctl aura static --colour ff0000
    notify-send -u critical "MODE: OVERKILL" "240Hz | Performance Fans"
else
    asusctl profile --profile Quiet
    hyprctl keyword monitor "$MONITOR,$RES_LOW,0x0,1.33"
    hyprctl keyword decoration:blur:enabled no
    asusctl aura static --colour 333333
    notify-send -u low "MODE: CONSERVE" "60Hz | Silent Fans"
fi
