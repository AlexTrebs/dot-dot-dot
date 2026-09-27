-- Hyprland config. While this file exists Hyprland ignores hyprland.conf (kept for rollback).
-- Each section is its own file so an error in one doesn't stop the others.
-- Check with: Hyprland --verify-config --config "$PWD/hyprland.lua"

require("lua.env")
require("lua.monitors")
require("lua.look")
require("lua.animations")
require("lua.input")
require("lua.binds")
require("lua.rules")
require("lua.autostart")
require("lua.plugins")
