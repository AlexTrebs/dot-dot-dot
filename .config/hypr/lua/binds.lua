-- Ported from hyprland.conf lines 14-16, 283-404.
-- Plugin (hymission) binds live in plugins.lua.

local terminal = "alacritty"
local fileManager = "thunar"
local menu = "rofi -show drun"

local exec = hl.dsp.exec_cmd

-- System
hl.bind("SUPER + Q", hl.dsp.window.close())
hl.bind("SUPER + SHIFT + ESCAPE", hl.dsp.exit())
hl.bind("SUPER + L", exec("hyprlock"))

-- Terminal tab navigation (for grouped terminals)
hl.bind("SUPER + bracketleft", hl.dsp.group.prev())
hl.bind("SUPER + bracketright", hl.dsp.group.next())
for i = 1, 9 do
    hl.bind("ALT + " .. i, hl.dsp.group.active({ index = i }))
end

-- Special workspaces
hl.bind("ALT + Tab", hl.dsp.workspace.toggle_special("tilde"))
hl.bind("SUPER + grave", hl.dsp.workspace.toggle_special("tilde"))
hl.bind("SUPER + SHIFT + grave", hl.dsp.window.move({ workspace = "special:tilde" }))

-- Layout & Window Management
hl.bind("SUPER + A", hl.dsp.group.toggle())
hl.bind("SUPER + SHIFT + A", hl.dsp.window.move({ out_of_group = true }))
hl.bind("SUPER + F", hl.dsp.window.float())
hl.bind("SUPER + M", hl.dsp.workspace.toggle_special("spotify"))
hl.bind("SUPER + SHIFT + M", hl.dsp.window.move({ workspace = "special:spotify" }))
hl.bind("SUPER + P", hl.dsp.window.pseudo())
hl.bind("SUPER + J", hl.dsp.layout("togglesplit"))
for key, dir in pairs({ left = "left", right = "right", up = "up", down = "down" }) do
    hl.bind("SUPER + " .. key, hl.dsp.focus({ direction = dir }))
    hl.bind("SUPER + SHIFT + " .. key, hl.dsp.window.move({ direction = dir }))
end

-- Workspaces (SUPER + 0 is workspace 10)
for i = 1, 10 do
    local key = tostring(i % 10)
    hl.bind("SUPER + " .. key, hl.dsp.focus({ workspace = tostring(i) }))
    hl.bind("SUPER + SHIFT + " .. key, hl.dsp.window.move({ workspace = tostring(i) }))
end

hl.bind("SUPER + CTRL + left", hl.dsp.focus({ workspace = "m-1" }), { repeating = true })
hl.bind("SUPER + CTRL + right", hl.dsp.focus({ workspace = "m+1" }), { repeating = true })

hl.bind("SUPER + H", hl.dsp.workspace.toggle_special("hotswap"))
hl.bind("SUPER + SHIFT + H", hl.dsp.window.move({ workspace = "special:hotswap" }))

-- Mouse navigation
hl.bind("SUPER + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind("SUPER + mouse_up", hl.dsp.focus({ workspace = "e-1" }))
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind("SUPER + SHIFT + mouse:272", hl.dsp.window.resize(), { mouse = true })

-- Apps
hl.bind("SUPER + T", exec(terminal .. " -e ~/.local/bin/auto_tmux.sh"))
hl.bind("SUPER + SHIFT + T", exec(terminal))
hl.bind("SUPER + E", exec(fileManager))
hl.bind("SUPER + R", exec(menu))
hl.bind("SUPER + Z", exec("zen-browser"))
hl.bind("SUPER + SHIFT + equal", exec("~/.config/hypr/scripts/scale_monitor.sh up"))
hl.bind("SUPER + SHIFT + minus", exec("~/.config/hypr/scripts/scale_monitor.sh down"))
hl.bind("SUPER + C", exec("~/.local/bin/zed"))
hl.bind("SUPER + N", exec("obsidian"))
hl.bind("SUPER + V", exec(terminal .. " --class clipse -e clipse"))

hl.bind("SUPER + D", hl.dsp.workspace.toggle_special("discord"))
hl.bind("SUPER + SHIFT + D", hl.dsp.window.move({ workspace = "special:discord" }))
hl.bind("SUPER + CTRL + D", exec("vesktop"))
hl.bind("SUPER + G", hl.dsp.workspace.toggle_special("steam"))
hl.bind("SUPER + SHIFT + G", hl.dsp.window.move({ workspace = "special:steam" }))
hl.bind("SUPER + CTRL + G", exec("steam"))
hl.bind("SUPER + CTRL + M", exec("spotify-launcher"))

-- Utilities
hl.bind("SUPER + S", exec("~/.config/hypr/scripts/screenshot.sh"))
hl.bind("SUPER + SHIFT + S", exec("~/.config/hypr/scripts/full_screenshot.sh"))
hl.bind("SUPER + F7", exec("hyprctl hyprsunset temperature -100"))
hl.bind("SUPER + F8", exec("hyprctl hyprsunset temperature +100"))
hl.bind("SUPER + F9", exec("~/.config/hypr/scripts/toggle_touchpad_typing.sh"))
hl.bind("SUPER + F10", exec("~/.local/bin/asus_power_button.sh"))
hl.bind("SUPER + F11", exec("~/.local/bin/g16-power.sh"))
hl.bind("SUPER + F12", exec("~/.local/bin/dock-toggle.sh"))

hl.bind("SUPER + SHIFT + R", exec("~/.config/hypr/scripts/screen_record.sh"))

-- Media / Brightness (bindel: repeat + work while locked)
local rl = { repeating = true, locked = true }
hl.bind("XF86AudioRaiseVolume", exec("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), rl)
hl.bind("XF86AudioLowerVolume", exec("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), rl)
hl.bind("XF86AudioMute", exec("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), rl)
hl.bind("XF86AudioMicMute", exec("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), rl)
hl.bind("XF86MonBrightnessUp", exec("brightnessctl set 5%+"), rl)
hl.bind("XF86MonBrightnessDown", exec("brightnessctl set 5%-"), rl)
hl.bind("XF86KbdBrightnessDown", exec("asusctl leds prev"), rl)
hl.bind("XF86KbdBrightnessUp", exec("asusctl leds next"), rl)

-- bindl: work while locked
local l = { locked = true }
hl.bind("XF86AudioNext", exec("playerctl next"), l)
hl.bind("XF86AudioPause", exec("playerctl play-pause"), l)
hl.bind("XF86AudioPlay", exec("playerctl play-pause"), l)
hl.bind("XF86AudioPrev", exec("playerctl previous"), l)
