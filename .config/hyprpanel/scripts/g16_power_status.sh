#!/usr/bin/env bash
set -euo pipefail

profile=$(asusctl profile -p 2>/dev/null | grep -oP 'Active profile is \K\w+' || echo "Unknown")

case "$profile" in
    Performance) echo '{"label":"OVERKILL","alt":"performance","tooltip":"Click to switch to Quiet"}' ;;
    Quiet)       echo '{"label":"CONSERVE","alt":"quiet","tooltip":"Click to switch to Performance"}' ;;
    Balanced)    echo '{"label":"BALANCED","alt":"balanced","tooltip":"Click to switch mode"}' ;;
    *)           echo '{"label":"UNKNOWN","alt":"unknown","tooltip":"asusctl unavailable"}' ;;
esac
