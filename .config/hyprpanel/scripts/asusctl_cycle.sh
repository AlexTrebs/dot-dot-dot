#!/bin/bash
# Cycle through asusctl performance profiles: Quiet -> Balanced -> Performance -> Quiet

current=$(asusctl profile -p 2>/dev/null | grep -oP 'Active profile is \K\w+')

case "$current" in
    Quiet)
        asusctl profile -P Balanced
        notify-send -t 2000 -i power-profile-balanced "Performance Profile" "Switched to Balanced"
        ;;
    Balanced)
        asusctl profile -P Performance
        notify-send -t 2000 -i power-profile-performance "Performance Profile" "Switched to Performance"
        ;;
    Performance)
        asusctl profile -P Quiet
        notify-send -t 2000 -i power-profile-power-saver "Performance Profile" "Switched to Quiet"
        ;;
    *)
        asusctl profile -P Balanced
        notify-send -t 2000 -i power-profile-balanced "Performance Profile" "Switched to Balanced"
        ;;
esac
