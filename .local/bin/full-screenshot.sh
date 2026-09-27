#!/bin/bash
# Full-screen screenshot to file + clipboard.
#
# See screenshot.sh — grim's wlr-screencopy protocol is unavailable under KWin,
# so Plasma takes the Spectacle path instead.
FILE=~/Pictures/Screenshots/Screenshot-$(date +%F_%T).png
mkdir -p ~/Pictures/Screenshots

case "${XDG_CURRENT_DESKTOP:-}" in
*KDE*)
    # No -c — it is ignored whenever -o is given. See screenshot.sh.
    spectacle -b -n -f -o "$FILE" || exit 1
    [ -s "$FILE" ] || exit 1
    wl-copy --type image/png < "$FILE"
    ;;
*)
    grim - | tee "$FILE" | wl-copy || exit 1
    ;;
esac

notify-send -i image -a screenshot -u normal "Screenshot taken" "$FILE" -t 1000
