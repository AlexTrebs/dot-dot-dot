#!/bin/bash
# hyprpm_autorebuild.sh
# Rebuild hyprpm plugins when the running Hyprland version changed since last build.
#
# Why: hyprpm plugins are ABI-locked to a Hyprland version. After a pacman upgrade,
# stale plugins segfault at load -> session dies -> SDDM login loop. `hyprpm update`
# must run against the RUNNING compositor (this script runs at startup, so running
# version == installed version -> it rebuilds for the correct ABI, unlike running it
# in the same session as the upgrade, which targets the old in-memory version).
#
# Fires on: version change vs stored commit, or first ever run (no state file).
# Never blocks login: all failures exit 0 quietly.

set -u

STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}"
STATE_FILE="$STATE_DIR/hyprpm_builtver"

# Running Hyprland commit (empty if hyprctl unavailable -> bail without touching anything)
CUR=$(hyprctl version -j 2>/dev/null | grep -oP '"commit"\s*:\s*"\K[0-9a-f]+' | head -1)
[ -z "$CUR" ] && exit 0

PREV=""
[ -f "$STATE_FILE" ] && PREV=$(cat "$STATE_FILE" 2>/dev/null)

# Up to date -> nothing to do
[ "$CUR" = "$PREV" ] && exit 0

command -v notify-send >/dev/null && notify-send "Hyprland changed — rebuilding plugins…"

if hyprpm update && hyprpm reload; then
    mkdir -p "$STATE_DIR"
    printf '%s\n' "$CUR" > "$STATE_FILE"
    command -v notify-send >/dev/null && notify-send "hyprpm plugins rebuilt ✔"
else
    # Do NOT write state on failure, so it retries next login.
    command -v notify-send >/dev/null && \
        notify-send -u critical "hyprpm rebuild FAILED — run 'hyprpm update' manually"
fi

exit 0
