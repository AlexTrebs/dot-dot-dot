#!/bin/bash
systemctl --user stop xdg-desktop-portal-hyprland xdg-desktop-portal 2>/dev/null || true
sleep 1
systemctl --user start xdg-desktop-portal-hyprland
sleep 2
systemctl --user start xdg-desktop-portal
