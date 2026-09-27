-- Ported from hyprland.conf lines 200-278.

hl.config({
    input = {
        kb_layout = "gb",
        follow_mouse = 1,
        sensitivity = 0,
        accel_profile = "flat",

        touchpad = {
            natural_scroll = true,
            scroll_factor = 0.5,
            tap_to_click = true,
            disable_while_typing = true,
        },
    },
})

-- Built-in ASUS laptop keyboard — UK
hl.device({ name = "at-translated-set-2-keyboard", kb_layout = "gb", kb_options = "" })

-- NuPhy Air75 V2 — US ANSI, under every name it shows up as:
--   keyd-virtual-keyboard: keyd grabs the NuPhy dongle (/etc/keyd/default.conf
--     ids = 19f5:3247) and re-emits through this virtual device, so the layout
--     must be set HERE — rules on the physical dongle never see an event. Only
--     add IDs to keyd's config if you want that device on US too.
--   nordic-semiconductor*: dongle fallback for when keyd is stopped; Hyprland
--     names it by the Nordic chip, or by the longer names once the product
--     string enumerates (depends on when it was plugged in).
--   nuphy-nuphy-air75-v2-keyboard: USB cable. Run `hyprctl devices | grep -i nuphy`
--     while plugged in to get the exact name.
--   nuphy-air75-v2-3-keyboard: Bluetooth.
for _, name in ipairs({
    "keyd-virtual-keyboard",
    "nordic-semiconductor-keyboard",
    "nordic-semiconductor",
    "nordic-semiconductor-nuphy-air75-v2-dongle",
    "nordic-semiconductor-nuphy-air75-v2-dongle-keyboard",
    "nuphy-nuphy-air75-v2-keyboard",
    "nuphy-air75-v2-3-keyboard",
}) do
    hl.device({ name = name, kb_layout = "us", kb_options = "" })
end

hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
