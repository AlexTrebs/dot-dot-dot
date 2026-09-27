#!/usr/bin/env bash
set -euo pipefail

profile=$(asusctl profile get 2>/dev/null | grep -oP 'Active profile: \K\w+' || echo "Unknown")

case "$profile" in
    Performance) echo '{"text":"OVERKILL","alt":"performance","tooltip":"Click to switch to Quiet"}' ;;
    Quiet)       echo '{"text":"CONSERVE","alt":"quiet","tooltip":"Click to switch to Performance"}' ;;
    Balanced)    echo '{"text":"BALANCED","alt":"balanced","tooltip":"Click to switch mode"}' ;;
    *)           echo '{"text":"UNKNOWN","alt":"unknown","tooltip":"asusctl unavailable"}' ;;
esac
