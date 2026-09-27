-- Ported from hyprland.conf lines 83-195 (options only; animations and
-- monitors have their own files).

hl.config({
    general = {
        gaps_in = 1,
        gaps_out = 1,
        border_size = 1,
        layout = "dwindle",

        col = {
            active_border = { colors = { "rgba(658676ee)", "rgba(4F6858ee)" }, angle = 45 },
            inactive_border = "rgba(28342cee)",
        },

        resize_on_border = false,
        allow_tearing = true,
    },

    decoration = {
        rounding = 6,
        rounding_power = 2,

        active_opacity = 1.0,
        inactive_opacity = 0.98,

        shadow = {
            enabled = true,
            range = 6,
            render_power = 3,
            color = "rgba(0d0c09dd)",
        },

        blur = {
            enabled = false,
        },
    },

    dwindle = {
        preserve_split = true,
    },

    master = {
        new_status = "master",
    },

    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo = true,
        disable_splash_rendering = true,
        vrr = 2,
    },

    cursor = {
        -- NVIDIA 610 open module + Hyprland: hardware cursor planes work even
        -- under fractional scale (1.33). Fixes software-cursor input lag.
        -- Now an int: 0 = use hw cursors if possible (was `false`).
        no_hardware_cursors = 0,
    },

    debug = {
        -- vfr=true lets each monitor refresh independently (240Hz internal + 144Hz
        -- external). false forced one global cadence -> mixed-refresh input lag.
        vfr = true,
    },

    group = {
        groupbar = {
            render_titles = false,
            height = 0,
            gradients = false,
            keep_upper_gap = false,
        },
    },

    -- unscale XWayland
    xwayland = {
        force_zero_scaling = true,
    },
})
