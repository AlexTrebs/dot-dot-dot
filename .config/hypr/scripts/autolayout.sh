#!/bin/bash

EDP_NAME="eDP-1"
EDP_MODE="2560x1600@240"

declare -A monitors_width
declare -A monitors_height
declare -A monitors_mode
declare -A monitors_name
external_monitors=()

edp_scale="1"
current_monitor=""
max_external_height=0
current_x=0

# Parse monitors
while IFS= read -r line; do

    # Monitor identifier
    if [[ $line =~ Monitor[[:space:]]+([^\ ]+) ]]; then
        current_monitor="${BASH_REMATCH[1]}"
        if [[ "$current_monitor" != "$EDP_NAME" ]]; then
            external_monitors+=("$current_monitor")
        fi
    fi

    # Resolution line
    if [[ $line =~ ^[[:space:]]*([0-9]+)x([0-9]+)@([0-9]+(\.[0-9]+)?) ]]; then
        width="${BASH_REMATCH[1]}"
        height="${BASH_REMATCH[2]}"
        refresh="${BASH_REMATCH[3]}"
        monitors_width["$current_monitor"]=$width
        monitors_height["$current_monitor"]=$height
        monitors_mode["$current_monitor"]="${width}x${height}@${refresh}"

        # For external monitors, track tallest
        if [[ "$current_monitor" != "$EDP_NAME" ]]; then
            (( height > max_external_height )) && max_external_height=$height
        fi
    fi

    # eDP scale
    if [[ "$current_monitor" == "$EDP_NAME" && $line =~ scale:[[:space:]]*([0-9]+(\.[0-9]+)?) ]]; then
        edp_scale="${BASH_REMATCH[1]}"
    fi

done < <(hyprctl monitors)

# Position external monitors in a row starting at x=0, y=0
current_x=0
for mon in "${external_monitors[@]}"; do
    width=${monitors_width[$mon]}
    mode=${monitors_mode[$mon]}
    echo "Placing external monitor $mon at x=${current_x}, y=0, mode=$mode"
    hyprctl keyword monitor $mon,$mode,${current_x}x0,1
    current_x=$((current_x + width))
done

# Place laptop below external monitors
echo "Placing $EDP_NAME below external monitors at y=$max_external_height with scale=$edp_scale"
hyprctl keyword monitor $EDP_NAME,$EDP_MODE,0x$max_external_height,$edp_scale


