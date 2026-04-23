#!/bin/bash
# Usage: supergfxctl-toggle.sh [integrated|hybrid|mux]
# No argument: cycles integrated → hybrid → AsusMuxDgpu → integrated
set -euo pipefail

CURRENT=$(supergfxctl -g | tr '[:upper:]' '[:lower:]' | tr -d '[:space:]')
TARGET="${1:-}"

if [ -n "$TARGET" ]; then
    case "$TARGET" in
        integrated) TARGET_RAW="integrated";  MSG="Integrated — iGPU only, dGPU off" ;;
        hybrid)     TARGET_RAW="hybrid";      MSG="Hybrid — iGPU + dGPU offload" ;;
        mux)        TARGET_RAW="AsusMuxDgpu"; MSG="MUX dGPU — full dGPU, no Optimus" ;;
        *)
            notify-send "supergfxctl" "Unknown mode '$TARGET'. Use: integrated, hybrid, mux"
            exit 1
            ;;
    esac

    if [ "$CURRENT" = "${TARGET_RAW,,}" ]; then
        notify-send "GPU mode" "Already in $TARGET mode."
        exit 0
    fi
else
    # Cycle
    case "$CURRENT" in
        integrated)  TARGET_RAW="hybrid";      MSG="Hybrid — iGPU + dGPU offload" ;;
        hybrid)      TARGET_RAW="AsusMuxDgpu"; MSG="MUX dGPU — full dGPU, no Optimus" ;;
        asusmuxdgpu) TARGET_RAW="integrated";  MSG="Integrated — iGPU only, dGPU off" ;;
        *)
            notify-send "Unknown GPU mode: $CURRENT" "No switch performed."
            exit 1
            ;;
    esac
fi

notify-send "Switching GPU" "$MSG. Session restarts in 3s..."
sleep 3
supergfxctl -m "$TARGET_RAW"
sudo systemctl restart sddm
