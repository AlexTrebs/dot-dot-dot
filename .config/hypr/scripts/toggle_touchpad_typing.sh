#!/bin/bash
# Toggle touchpad disable_while_typing for gaming

current=$(hyprctl getoption input:touchpad:disable_while_typing -j | jq '.int')

if [ "$current" -eq 1 ]; then
    hyprctl keyword input:touchpad:disable_while_typing false
    notify-send "Touchpad" "Typing protection OFF (Game mode)"
else
    hyprctl keyword input:touchpad:disable_while_typing true
    notify-send "Touchpad" "Typing protection ON"
fi
