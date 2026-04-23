#!/bin/bash
set -euo pipefail
MODE=$(supergfxctl -g | tr '[:upper:]' '[:lower:]' | tr -d '[:space:]')

# Cycle: integrated → hybrid → asusmuxdgpu → integrated
case "$MODE" in
    integrated)
        notify-send "Switching to Hybrid" "iGPU + dGPU offload. Session restarts in 3s..."
        sleep 3
        supergfxctl -m hybrid
        ;;
    hybrid)
        notify-send "Switching to MUX dGPU" "Full dGPU, no Optimus. Session restarts in 3s..."
        sleep 3
        supergfxctl -m AsusMuxDgpu
        ;;
    asusmuxdgpu)
        notify-send "Switching to Integrated" "iGPU only, dGPU off. Session restarts in 3s..."
        sleep 3
        supergfxctl -m integrated
        ;;
    *)
        notify-send "Unknown GPU mode: $MODE" "No switch performed."
        exit 1
        ;;
esac

sudo systemctl restart sddm
