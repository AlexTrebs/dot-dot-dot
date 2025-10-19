#!/bin/bash
# Listen for battery property changes via D-Bus (upower)
# and trigger notifications when levels drop

LOW_LEVEL=25
CRITICAL_LEVEL=10
STATE_FILE="/tmp/.battery_notify_state"

get_capacity() {
  upower -i $(upower -e | grep BAT) | awk '/percentage:/ {gsub(/%/,""); print $2}'
}

get_status() {
  upower -i $(upower -e | grep BAT) | awk -F": " '/state/ {print $2}'
}

send_notification() {
  local urgency=$1
  local title=$2
  local message=$3
  notify-send -u "$urgency" "$title" "$message"
}

handle_update() {
  local cap status
  cap=$(get_capacity)
  status=$(get_status)
  last_state=$(cat "$STATE_FILE" 2>/dev/null || echo "ok")

  if [[ "$status" == "discharging" ]]; then
    if (( cap <= CRITICAL_LEVEL && last_state != "critical" )); then
      send_notification critical "Battery critically low" "Only ${cap}% remaining!"
      echo "critical" > "$STATE_FILE"
    elif (( cap <= LOW_LEVEL && last_state != "low" )); then
      send_notification normal "Battery low" "Battery at ${cap}%."
      echo "low" > "$STATE_FILE"
    elif (( cap > LOW_LEVEL )); then
      echo "ok" > "$STATE_FILE"
    fi
  fi
}

# --- Main loop ---
dbus-monitor --system "type='signal',interface='org.freedesktop.UPower.Device'" |
while read -r line; do
  if echo "$line" | grep -q "percentage" || echo "$line" | grep -q "state"; then
    handle_update
  fi
done
