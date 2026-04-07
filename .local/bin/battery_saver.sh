#!/bin/bash
# Power profile toggle for battery saver mode

MODE=$1  # "on" or "off"

case "$MODE" in
  on)
    brightnessctl set 40%
    powerprofilesctl set power-saver
    ;;
  off)
    brightnessctl set 80%
    powerprofilesctl set balanced
    ;;
esac
