#!/bin/bash
set -euo pipefail
# Power profile toggle for battery saver mode

MODE=$1  # "on" or "off"

case "$MODE" in
  on)
    powerprofilesctl set power-saver
    ;;
  off)
    powerprofilesctl set balanced
    ;;
esac
