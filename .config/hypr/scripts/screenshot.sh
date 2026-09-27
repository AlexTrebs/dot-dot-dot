#!/bin/bash
# Region screenshot to file + clipboard.
#
# grim/slurp speak wlr-screencopy-unstable-v1, which KWin does not implement —
# under Plasma they fail with "compositor doesn't support the screen capture
# protocol" and produce a zero-byte file, so there is nothing to copy either.
# Branch on the compositor so one keybind behaves the same in both sessions.
FILE=~/Pictures/Screenshots/Screenshot-$(date +%F_%T).png
mkdir -p ~/Pictures/Screenshots

case "${XDG_CURRENT_DESKTOP:-}" in
*KDE*)
    # -b background, -n no Spectacle notification (we send our own below),
    # -r region, -o write to file.
    #
    # Not -c: `spectacle --help` says it copies "unless -o is also used", so
    # asking for both silently gets you only the file. The grim path puts the
    # image on the clipboard, so do it by hand here to match.
    spectacle -b -n -r -o "$FILE" || exit 1
    [ -s "$FILE" ] || exit 1
    wl-copy --type image/png < "$FILE"
    ;;
*)
    grim -g "$(slurp)" - | tee "$FILE" | wl-copy || exit 1
    ;;
esac

notify-send -i image -a screenshot -u normal "Screenshot taken" "$FILE" -t 1000
