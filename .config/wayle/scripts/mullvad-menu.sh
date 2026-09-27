#!/bin/bash
# Mullvad VPN rofi menu for server selection

status=$(mullvad status 2>/dev/null)

if [[ -z "$status" ]]; then
    notify-send "Mullvad VPN" "Mullvad is not installed" -i network-vpn-disconnected
    exit 1
fi

# Build menu options
is_connected=false
if echo "$status" | grep -q "Connected"; then
    is_connected=true
fi

# Menu options
options="󰖂  Quick Connect\n󰅖  Disconnect\n───────────────\n󰀄  Select Country\n󰙵  Select City\n󱓧  Select Server\n───────────────\n󰒓  Settings"

if $is_connected; then
    options="󰅖  Disconnect\n󰖂  Reconnect\n───────────────\n󰀄  Select Country\n󰙵  Select City\n󱓧  Select Server\n───────────────\n󰒓  Settings"
fi

selected=$(echo -e "$options" | rofi -dmenu -p "Mullvad VPN" -theme-str 'window {width: 300px;}')

case "$selected" in
    *"Quick Connect"*)
        mullvad connect
        notify-send "Mullvad VPN" "Connecting..." -i network-vpn
        ;;
    *"Disconnect"*)
        mullvad disconnect
        notify-send "Mullvad VPN" "Disconnected" -i network-vpn-disconnected
        ;;
    *"Reconnect"*)
        mullvad reconnect
        notify-send "Mullvad VPN" "Reconnecting..." -i network-vpn
        ;;
    *"Select Country"*)
        countries=$(mullvad relay list | grep -E '^\t[a-z]{2} \(' | sed 's/^\t//' | cut -d'(' -f2 | cut -d')' -f1 | sort -u)
        country=$(echo "$countries" | rofi -dmenu -p "Select Country" -theme-str 'window {width: 400px;}')
        if [[ -n "$country" ]]; then
            # Get country code
            code=$(mullvad relay list | grep -E "^\t[a-z]{2} \($country\)" | awk '{print $1}')
            if [[ -n "$code" ]]; then
                mullvad relay set location "$code"
                mullvad connect
                notify-send "Mullvad VPN" "Connecting to $country..." -i network-vpn
            fi
        fi
        ;;
    *"Select City"*)
        # Get current country or list all cities
        cities=$(mullvad relay list | grep -E '^\t\t[a-z]{2,3}-' | sed 's/^\t\t//' | awk '{print $1, $2, $3}')
        city=$(echo "$cities" | rofi -dmenu -p "Select City" -theme-str 'window {width: 500px;}')
        if [[ -n "$city" ]]; then
            code=$(echo "$city" | awk '{print $1}')
            mullvad relay set location "$code"
            mullvad connect
            notify-send "Mullvad VPN" "Connecting to $city..." -i network-vpn
        fi
        ;;
    *"Select Server"*)
        servers=$(mullvad relay list | grep -E '^\t\t\t' | sed 's/^\t\t\t//' | awk '{print $1}')
        server=$(echo "$servers" | rofi -dmenu -p "Select Server" -theme-str 'window {width: 400px;}')
        if [[ -n "$server" ]]; then
            mullvad relay set hostname "$server"
            mullvad connect
            notify-send "Mullvad VPN" "Connecting to $server..." -i network-vpn
        fi
        ;;
    *"Settings"*)
        mullvad-gui &
        ;;
esac
