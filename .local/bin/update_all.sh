#!/bin/bash

# Logging setup
LOGFILE="$HOME/.local/share/update_all.log"
exec > >(tee -a "$LOGFILE") 2>&1
echo "===== Update script started at $(date) ====="

export DISPLAY=:0
export XDG_RUNTIME_DIR="/run/user/$(id -u)"

echo "Sending notification: Checking for updates..."
notify-send "Checking for updates…"

# Wait for network to be ready (max 30 seconds)
echo "Waiting for network..."
for i in {1..30}; do
    if ping -c 1 8.8.8.8 &>/dev/null; then
        echo "Network is ready"
        break
    fi
    sleep 1
done

echo "Checking repository updates..."
repo_updates=$(timeout 30 checkupdates 2>&1)
repo_exit_code=$?
if [ $repo_exit_code -eq 124 ]; then
    echo "Repository check timed out"
    notify-send "Update check timed out"
    exit 1
elif [ $repo_exit_code -ne 0 ] && [ $repo_exit_code -ne 2 ]; then
    echo "Repository check failed with exit code $repo_exit_code: $repo_updates"
fi
echo "Repository updates found: $(echo "$repo_updates" | grep -c '^ ' || echo 0) packages"

echo "Checking AUR updates..."
aur_updates=$(timeout 30 yay -Qua 2>&1)
aur_exit_code=$?
if [ $aur_exit_code -eq 124 ]; then
    echo "AUR check timed out"
fi
echo "AUR updates found: $(echo "$aur_updates" | wc -l) packages"

if [ -n "$repo_updates$aur_updates" ]; then
    echo "Updates available, showing dialog..."
    if zenity --question --text="Updates available. Apply now?" --width=300; then
        echo "User approved updates, applying..."
        notify-send "Applying updates..."

        # Use pkexec instead of sudo for graphical password prompt
        if pkexec pacman -Syu --noconfirm; then
            echo "Repository updates completed successfully"
            yay -Syu --noconfirm
            echo "AUR updates completed"
            notify-send "Updates completed successfully!"
        else
            echo "Repository updates failed or were cancelled"
            notify-send "Update failed or cancelled"
        fi
    else
        echo "User declined updates"
        notify-send "Updates postponed"
    fi
else
    echo "No updates available"
    notify-send "System is up to date!"
fi

echo "===== Update script finished at $(date) ====="
