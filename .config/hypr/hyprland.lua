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

-- Per-machine overrides (monitors, dock output): lua/hosts/<hardware family>.lua,
-- e.g. "ROG Zephyrus G16" -> lua/hosts/rog-zephyrus-g16.lua. Skipped if absent.
local dmi = io.open("/sys/class/dmi/id/product_family")
if dmi then
    local host = dmi:read("*l"):lower():gsub("[^%w]+", "-")
    dmi:close()
    if package.searchpath("lua.hosts." .. host, package.path) then
        require("lua.hosts." .. host)
    end
end
