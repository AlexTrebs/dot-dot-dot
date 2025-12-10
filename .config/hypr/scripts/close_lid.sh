#!/bin/bash
sleep 1
# Get the output and count the number of lines matching the regex
line_count=$(hyprctl monitors | grep -P 'Monitor\s(?!eDP-1).+?\s\(ID\s\d+\):' | wc -l)

systemctl hibernate

