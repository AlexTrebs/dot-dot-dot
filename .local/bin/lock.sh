#!/bin/bash
# Lock screen in the earth palette (stands in for hyprlock, which is
# Hyprland-only). Colours from ~/dot-dot-dot/.config/colours.css.
exec swaylock \
  --color 13120d \
  --inside-color 13120dcc --inside-clear-color 4b6458cc \
  --inside-ver-color 2e645dcc --inside-wrong-color 9b574dcc \
  --ring-color 28342c --ring-clear-color 658676 \
  --ring-ver-color 4f8a72 --ring-wrong-color 9b574d \
  --key-hl-color 4f8a72 --bs-hl-color 9b574d \
  --text-color d0cfcc --text-clear-color d0cfcc \
  --text-ver-color d0cfcc --text-wrong-color d0cfcc \
  --separator-color 00000000 \
  --indicator-radius 90 --indicator-thickness 6 \
  --ignore-empty-password --show-failed-attempts
