#!/bin/bash
# Region screenshot to file + clipboard.
#
# grim/slurp need wlr-screencopy, which KWin lacks, so Plasma uses Spectacle.
FILE=~/Pictures/Screenshots/Screenshot-$(date +%F_%T).png
mkdir -p ~/Pictures/Screenshots

case "${XDG_CURRENT_DESKTOP:-}" in
*KDE*)
    # -b background, -n no notification (ours is below), -r region, -o file.
    # Not -c: it is ignored when -o is given, so copy to the clipboard by hand.
    spectacle -b -n -r -o "$FILE" || exit 1
    [ -s "$FILE" ] || exit 1
    wl-copy --type image/png < "$FILE"
    ;;
*)
    grim -g "$(slurp)" - | tee "$FILE" | wl-copy || exit 1
    ;;
esac

notify-send -i image -a screenshot -u normal "Screenshot taken" "$FILE" -t 1000
