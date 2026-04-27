#!/usr/bin/env bash
set -euo pipefail

mapfile -t wifi_devs < <(nmcli -t -f DEVICE,TYPE device status | awk -F: '$2=="wifi"{print $1}')

[ "${#wifi_devs[@]}" -lt 2 ] && exit 0

dev="${wifi_devs[1]}"
state=$(nmcli -t -f DEVICE,STATE device status | awk -F: -v d="$dev" '$1==d{print $2}')
ssid=$(nmcli -t -f DEVICE,CONNECTION device status | awk -F: -v d="$dev" '$1==d{print $2}')

if [ "$state" = "connected" ] && [ -n "$ssid" ] && [ "$ssid" != "--" ]; then
    strength=$(nmcli -t -f IN-USE,SIGNAL dev wifi list ifname "$dev" 2>/dev/null | awk -F: '/^\*/{print $2}' | head -1)
    echo "{\"text\":\"$ssid\",\"percentage\":${strength:-0},\"alt\":\"connected\"}"
else
    echo "{\"text\":\"--\",\"percentage\":0,\"alt\":\"disconnected\"}"
fi
