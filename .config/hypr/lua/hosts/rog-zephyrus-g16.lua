-- ASUS ROG Zephyrus G16 (this laptop) and the desks it docks at.
-- Loaded last by hyprland.lua, so these rules come after the generic fallback in
-- monitors.lua. Among matching rules the LAST one wins (MonitorRuleManager.cpp).

hl.monitor({ output = "eDP-1", mode = "2560x1600@240", position = "0x0", scale = 1.33 })

-- AOC Q27G4 is a 1440p panel; its EDID also lists 4K downscale modes, and
-- `highres` picked those over native. Pin it explicitly.
hl.monitor({ output = "HDMI-A-1", mode = "2560x1440@144", position = "auto-right", scale = 1 })

-- Samsung S22D390 (second desk) sits left of the laptop. Must come after the
-- HDMI-A-1 rule: the later matching rule wins.
hl.monitor({ output = "desc:Samsung Electric Company S22D390 0x304B5050", mode = "preferred", position = "auto-left", scale = 1 })

-- USB-C dock output, read by hypr/scripts/dock-toggle.sh
hl.env("DOCK_OUTPUT", "DP-5")
