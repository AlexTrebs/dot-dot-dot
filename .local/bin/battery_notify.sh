#!/bin/bash
# Sends notifications for low battery levels via swaync / notify-send

# CONFIG
BAT_PATH="/sys/class/power_supply/BAT1"
LOW_LEVEL=25      # warning
CRITICAL_LEVEL=10 # critical

# Get current charge percentage
if [ ! -f "$BAT_PATH/capacity" ]; then
  echo "Battery path not found: $BAT_PATH" >&2
  exit 1
fi

capacity=$(<"$BAT_PATH/capacity")
status=$(<"$BAT_PATH/status")

# Determine urgency and message
if [ "$status" = "Discharging" ]; then
  if [ "$capacity" -le "$CRITICAL_LEVEL" ]; then
    notify-send -u critical "Battery critically low" "Only ${capacity}% remaining! Plug in immediately."
  elif [ "$capacity" -le "$LOW_LEVEL" ]; then
    notify-send -u normal "Battery low" "Battery is at ${capacity}%. Consider plugging in soon."
  fi
fi
