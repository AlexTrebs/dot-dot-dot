#!/bin/bash
asusctl profile -n > /dev/null
sleep 0.3
asusctl profile -p | awk 'tolower($0) ~ /active profile/ {print tolower($NF)}' | \
  sed -e 's/quiet/󰾆/' -e 's/balanced/󰔟/' -e 's/performance/󰓅/'
