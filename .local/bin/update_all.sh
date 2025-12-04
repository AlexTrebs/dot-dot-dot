#!/bin/bash

export DISPLAY=:0
export XDG_RUNTIME_DIR="/run/user/$(id -u)"

notify-send "Checking for updates…"
repo_updates=$(checkupdates 2>/dev/null)
aur_updates=$(yay -Qua 2>/dev/null)

if [ -n "$repo_updates$aur_updates" ]; then
    if zenity --question --text="Updates available. Apply now?"; then
        sudo pacman -Syu --noconfirm
        yay -Syu --noconfirm
    fi
else
    notify-send "System is up to date!"
fi
