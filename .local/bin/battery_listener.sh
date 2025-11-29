#!/bin/bash
# Battery listener — efficient, debounced, and with "unplugged while low" alerts

LOW_LEVEL=25
CRITICAL_LEVEL=10
STATE_FILE="/tmp/.battery_notify_state"
BATTERY=$(upower -e | grep -m1 BAT)

get_battery_info() {
  # Outputs: "<status> <capacity>"
  upower -i "$BATTERY" | awk -F": " '
    /state/      {status=$2}
    /percentage/ {gsub(/%/,"",$2); capacity=$2}
    END {print status, capacity}
  '
}

send_notification() {
  local urgency=$1
  local title=$2
  local message=$3
  notify-send -u "$urgency" "$title" "$message"
}

handle_update() {
  local status=$1
  local cap=$2
  local prev_status=$3
  local last_state
  last_state=$(cat "$STATE_FILE" 2>/dev/null || echo "unknown")

  case "$status" in
    discharging)

      # If capacity is critical/low and:
      #   - Was previously charging, or
      #   - State has changed (cirtical, low, ok)
      # Notify user
      if (( cap <= CRITICAL_LEVEL )); then
        if [[ "$prev_status" != "discharging" ]]; then
          send_notification critical "Unplugged — Critically Low" "Only ${cap}% remaining!"
        elif [[ "$last_state" != "critical" ]]; then
          send_notification critical "Battery critically low" "Only ${cap}% remaining!"
        fi

        echo "critical" > "$STATE_FILE"
      elif (( cap <= LOW_LEVEL )); then
        if [[ "$prev_status" != "discharging" ]]; then
          send_notification normal "Unplugged — Battery Low" "Battery at ${cap}%."
        elif [[ "$last_state" != "low" ]]; then
          send_notification normal "Battery low" "Battery at ${cap}%."
          /usr/local/bin/battery_saver.sh on
        fi
        echo "low" > "$STATE_FILE"
      elif (( cap > LOW_LEVEL )); then
        if [[ "$last_state" == "low" ]] || [[ "$last_state" == "critical" ]]; then
          /usr/local/bin/battery_saver.sh off
          send_notification low "Battery saver off" "Battery level restored (${cap}%)."
        fi
        echo "ok" > "$STATE_FILE"
      fi
      ;;

    charging)
      # Notify of charging status if previous not charging
      if [[ "$prev_status" != "charging" ]]; then
        send_notification normal "Charging ⚡" "Battery is now charging (${cap}%)."
      fi
      ;;

    fully-charged)
      if [[ "$last_state" != "charged" ]]; then
        send_notification low "Battery Full 🔋" "Battery fully charged (${cap}%)."
        echo "charged" > "$STATE_FILE"
      fi
      ;;
  esac
}

# --- Main loop (event-driven + debounced) ---
last_status=""
last_capacity=""

# Initial snapshot + notify once
read -r last_status last_capacity < <(get_battery_info)
handle_update "$last_status" "$last_capacity" "unknown"

upower --monitor |
while read -r _; do
  # Debounce to coalesce multiple rapid UPower updates
  sleep 0.5

  read -r current_status current_capacity < <(get_battery_info)

  # Only react when status or capacity actually changes
  if [[ "$current_status" != "$last_status" ]] || [[ "$current_capacity" != "$last_capacity" ]]; then
    echo $last_status
    handle_update "$current_status" "$current_capacity" "$last_status"
    last_status="$current_status"
    last_capacity="$current_capacity"
  fi
done
