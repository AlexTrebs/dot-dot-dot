#!/bin/bash
# Simple power saver toggle for ASUS Zephyrus (Hyprland + Arch)

MODE=$1  # "on" or "off"

case "$MODE" in
  on)
    echo "Enabling battery saver mode..."

    # CPU governor to powersave
    for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
      echo powersave | sudo tee "$cpu" >/dev/null
    done

    # Lower screen brightness (example, adjust to your setup)
    brightnessctl set 40%

    # Enable TLP or power-profiles-daemon battery mode
    if command -v powerprofilesctl >/dev/null; then
      powerprofilesctl set power-saver
    elif command -v tlp >/dev/null; then
      sudo tlp start
    fi

    # Optional: Throttle GPU (NVIDIA)
    if command -v nvidia-smi >/dev/null; then
      sudo nvidia-smi -pl 65  # limit to 65W or adjust
    fi

    ;;
  off)
    echo "Disabling battery saver mode..."

    # Restore performance profile
    for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
      echo schedutil | sudo tee "$cpu" >/dev/null
    done

    # Restore brightness
    brightnessctl set 80%

    # Restore Asus LED
    asusctl led-mode static --color FF8800

    if command -v powerprofilesctl >/dev/null; then
      powerprofilesctl set balanced
    elif command -v tlp >/dev/null; then
      sudo tlp start
    fi

    if command -v nvidia-smi >/dev/null; then
      sudo nvidia-smi -pl 120
    fi
    ;;
esac
