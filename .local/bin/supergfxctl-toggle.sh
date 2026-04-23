#!/bin/bash
set -euo pipefail
MODE=$(supergfxctl -g | tr '[:upper:]' '[:lower:]' | tr -d '[:space:]')

if [ "$MODE" = "integrated" ]; then
    notify-send "Switching to Hybrid Mode" "Session will restart in 3 seconds..."
    sleep 3
    supergfxctl -m hybrid
else
    notify-send "Switching to Integrated Mode" "Session will restart in 3 seconds..."
    sleep 3
    supergfxctl -m integrated
fi

sudo systemctl restart sddm
