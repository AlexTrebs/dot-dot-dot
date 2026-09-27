-- Ported from hyprland.conf lines 453-487.
-- Plugins load via `hyprpm reload` in autostart, AFTER this file runs, so
-- hl.plugin.hymission doesn't exist yet here. The binds wrap the calls in a
-- function so the lookup happens at keypress instead.
--
-- Hyprland re-reads the whole config after each plugin loads (PluginSystem.cpp),
-- so the settings below are set on that second pass. Guarding on the loaded list
-- avoids "unknown config key" errors on the first pass.

local loaded = {}
for _, p in ipairs(hl.get_loaded_plugins()) do
    loaded[p.name] = true
end

-- hymission — Mission Control workspace overview
hl.bind("SUPER + Tab", function() hl.plugin.hymission.toggle("forceall") end)
hl.bind("SUPER + SHIFT + Tab", function() hl.plugin.hymission.open("forceall") end)
hl.bind("SUPER + CTRL + Tab", function() hl.plugin.hymission.close() end)

if loaded["hymission"] then
    hl.config({ plugin = {
        hymission = {
            outer_padding_top = 80,
            outer_padding_right = 32,
            outer_padding_bottom = 32,
            outer_padding_left = 32,
            row_spacing = 16,
            column_spacing = 16,
            expand_selected_window = 1,
            overview_focus_follows_mouse = 1,
            multi_workspace_sort_recent_first = 1,
            workspace_change_keeps_overview = 1,
            show_special = 1,
            hide_bar_when_strip = 1,
        },
    } })
end

-- borders-plus-plus — extra accent border ring
if loaded["borders-plus-plus"] then
    hl.config({ plugin = {
        borders_plus_plus = {
            add_borders = 1,
            col = {
                border_1 = "rgba(4f8a7255)",
            },
            border_size_1 = 2,
            natural_rounding = true,
        },
    } })
end
