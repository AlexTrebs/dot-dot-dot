-- Generic fallback for any monitor. Machine-specific rules live in
-- lua/hosts/<machine>.lua, loaded last by hyprland.lua.
--
-- `preferred` honours each EDID's native mode; `highres` picked the largest
-- resolution regardless of whether the panel was happy driving it.
hl.monitor({ output = "", mode = "preferred", position = "auto-right", scale = 1 })
