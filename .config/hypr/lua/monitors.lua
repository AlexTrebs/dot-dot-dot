-- Ported from hyprland.conf lines 181-190.
-- Rules are checked bottom-up (MonitorRuleManager.cpp): the LAST matching rule wins.

hl.monitor({ output = "eDP-1", mode = "2560x1600@240", position = "0x0", scale = 1.33 })

-- AOC Q27G4 is a 1440p panel; its EDID also lists 4K downscale modes, and
-- `highres` picked those over native. Pin it explicitly.
hl.monitor({ output = "HDMI-A-1", mode = "2560x1440@144", position = "auto-right", scale = 1 })

-- Samsung S22D390 (second desk) sits left of the laptop. Must come after the
-- HDMI-A-1 rule: the later matching rule wins.
hl.monitor({ output = "desc:Samsung Electric Company S22D390 0x304B5050", mode = "preferred", position = "auto-left", scale = 1 })

-- `preferred` honours each EDID's native mode; `highres` picked the largest
-- resolution regardless of whether the panel was happy driving it.
hl.monitor({ output = "", mode = "preferred", position = "auto-right", scale = 1 })
