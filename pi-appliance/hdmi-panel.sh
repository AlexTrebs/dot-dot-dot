#!/bin/sh
# Start/stop the HDMI-bound wf-panel-pi instance.
#
# Why this exists: wf-panel-pi's "panel/monitor" key is NOT a hard binding. When
# the named output is absent the panel falls back to whatever output does exist,
# so the HDMI instance drew a SECOND top bar on the touchscreen whenever HDMI was
# unplugged. Instead of leaving it running permanently from the labwc autostart,
# kanshi calls this from its profile exec directives:
#   profile dual      -> hdmi-panel.sh start   (HDMI present)
#   profile touchonly -> hdmi-panel.sh stop    (HDMI unplugged)
#
# Must be idempotent: kanshi re-applies the profile (and re-runs exec) whenever
# outputs change or it gets SIGHUP — which kiosk.sh does on every kiosk launch.
#
# NOTE: deliberately NOT wrapped in lwrespawn — lwrespawn would immediately
# restart the panel after "stop" kills it.

CFG="$HOME/.config/wf-panel-pi/wf-panel-hdmi.ini"
PATTERN="wf-panel-pi -c $CFG"

export WAYLAND_DISPLAY="${WAYLAND_DISPLAY:-wayland-0}"
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"

case "$1" in
  start)
    # pgrep -f can't match this script's own cmdline ("hdmi-panel.sh start"),
    # so there's no self-match to guard against.
    if ! pgrep -f "$PATTERN" >/dev/null 2>&1; then
      setsid /usr/bin/wf-panel-pi -c "$CFG" >/dev/null 2>&1 &
    fi
    ;;
  stop)
    pkill -f "$PATTERN" >/dev/null 2>&1
    ;;
  *)
    echo "usage: $0 start|stop" >&2
    exit 2
    ;;
esac

exit 0
