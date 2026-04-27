#!/bin/bash
status=$(mullvad status 2>/dev/null)

if [[ -z "$status" ]]; then
    echo '{"text": "N/A", "tooltip": "Mullvad not installed", "alt": "disconnected"}'
    exit 0
fi

if echo "$status" | grep -q "Connected"; then
    city=$(echo "$status" | grep -oP '(?<=in )[^,]+' | head -1)
    display="${city:-VPN}"
    tooltip=$(echo "$status" | tr '\n' ' ' | sed 's/"/\\"/g')
    echo "{\"text\": \"$display\", \"tooltip\": \"$tooltip\", \"alt\": \"connected\"}"
else
    echo '{"text": "Off", "tooltip": "Mullvad VPN: Disconnected", "alt": "disconnected"}'
fi
