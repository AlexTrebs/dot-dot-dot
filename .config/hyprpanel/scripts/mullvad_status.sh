#!/bin/bash
# Mullvad VPN status script for hyprpanel
# Outputs JSON for custom module

status=$(mullvad status 2>/dev/null)

if [[ -z "$status" ]]; then
    echo '{"status": "N/A", "tooltip": "Mullvad not installed", "state": "disconnected"}'
    exit 0
fi

if echo "$status" | grep -q "Connected"; then
    # Extract location info
    city=$(echo "$status" | grep -oP '(?<=in )[^,]+' | head -1)
    country=$(echo "$status" | grep -oP '(?<=, )[A-Za-z ]+$' | head -1)

    if [[ -n "$city" ]]; then
        display="$city"
    else
        display="VPN"
    fi

    # Escape quotes in status for JSON
    tooltip=$(echo "$status" | tr '\n' ' ' | sed 's/"/\\"/g')
    echo "{\"status\": \"$display\", \"tooltip\": \"$tooltip\", \"state\": \"connected\"}"
else
    echo '{"status": "Off", "tooltip": "Mullvad VPN: Disconnected", "state": "disconnected"}'
fi
