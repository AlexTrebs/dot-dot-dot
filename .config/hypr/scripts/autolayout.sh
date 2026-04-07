#!/bin/bash

EDP_NAME="eDP-1"
EDP_MODE="2560x1600@240"

declare -A monitors_width
declare -A monitors_height
declare -A monitors_mode
declare -A monitors_scale
external_monitors=()

edp_scale="1"
max_external_height=0
current_x=0

# Parse monitors from JSON — uses active mode/scale, not text heuristics
while IFS= read -r mon_json; do
    name=$(jq -r '.name'        <<< "$mon_json")
    width=$(jq -r '.width'      <<< "$mon_json")
    height=$(jq -r '.height'    <<< "$mon_json")
    refresh=$(jq -r '.refreshRate' <<< "$mon_json")
    scale=$(jq -r '.scale'      <<< "$mon_json")

    monitors_width["$name"]=$width
    monitors_height["$name"]=$height
    monitors_mode["$name"]="${width}x${height}@${refresh}"
    monitors_scale["$name"]=$scale

    if [[ "$name" == "$EDP_NAME" ]]; then
        edp_scale=$scale
    else
        external_monitors+=("$name")
        (( height > max_external_height )) && max_external_height=$height
    fi
done < <(hyprctl monitors -j | jq -c '.[]')

# Position external monitors in a row starting at x=0, y=0
current_x=0
for mon in "${external_monitors[@]}"; do
    width=${monitors_width[$mon]}
    mode=${monitors_mode[$mon]}
    scale=${monitors_scale[$mon]:-1}
    echo "Placing external monitor $mon at x=${current_x}, y=0, mode=$mode, scale=$scale"
    hyprctl keyword monitor $mon,$mode,${current_x}x0,$scale
    current_x=$((current_x + width))
done

# Place laptop below external monitors
echo "Placing $EDP_NAME below external monitors at y=$max_external_height with scale=$edp_scale"
hyprctl keyword monitor $EDP_NAME,$EDP_MODE,0x$max_external_height,$edp_scale


