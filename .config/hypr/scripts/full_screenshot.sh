#!/bin/bash
FILE=~/Pictures/Screenshots/Screenshot-$(date +%F_%T).png
mkdir -p ~/Pictures/Screenshots
grim - | tee "$FILE" | wl-copy && notify-send -i image -a screenshot -u normal "Screenshot taken" "$FILE" -t 1000
