#!/bin/bash
# Mullvad VPN toggle script for hyprpanel
# Toggles between connected and disconnected states

status=$(mullvad status 2>/dev/null)

if [[ -z "$status" ]]; then
    notify-send "Mullvad VPN" "Mullvad is not installed" -i network-vpn-disconnected
    exit 1
fi

if echo "$status" | grep -q "Connected"; then
    mullvad disconnect
    notify-send "Mullvad VPN" "Disconnected" -i network-vpn-disconnected
else
    mullvad connect
    notify-send "Mullvad VPN" "Connecting..." -i network-vpn
fi
