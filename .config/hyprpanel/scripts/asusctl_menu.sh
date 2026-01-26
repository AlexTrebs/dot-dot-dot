#!/bin/bash
# Show rofi menu for asusctl profile selection

current=$(asusctl profile -p 2>/dev/null | grep -oP 'Active profile is \K\w+')

selected=$(echo -e " Quiet\n Balanced\n Performance" | rofi -dmenu -p "Profile ($current)" -theme-str 'window {width: 200px;}')

case "$selected" in
    *"Quiet"*)
        asusctl profile -P Quiet
        notify-send -t 2000 -i power-profile-power-saver "Performance Profile" "Switched to Quiet"
        ;;
    *"Balanced"*)
        asusctl profile -P Balanced
        notify-send -t 2000 -i power-profile-balanced "Performance Profile" "Switched to Balanced"
        ;;
    *"Performance"*)
        asusctl profile -P Performance
        notify-send -t 2000 -i power-profile-performance "Performance Profile" "Switched to Performance"
        ;;
esac
