#!/bin/bash
# Get current asusctl profile and display with appropriate label/icon

profile=$(asusctl profile -p 2>/dev/null | grep -oP 'Active profile is \K\w+' || echo "Unknown")

case "$profile" in
    Quiet)
        echo "Quiet"
        ;;
    Balanced)
        echo "Balanced"
        ;;
    Performance)
        echo "Perf"
        ;;
    *)
        echo "$profile"
        ;;
esac
