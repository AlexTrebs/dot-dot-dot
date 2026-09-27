-- Ported from hyprland.conf lines 409-451.

-- Layer rules
hl.layer_rule({ name = "hyprcut-noanim", match = { namespace = "^(hyprcut)$" }, no_anim = true })

-- Window rules
hl.window_rule({ match = { class = ".*" }, suppress_event = "maximize" })

hl.window_rule({
    name = "zen-pip",
    match = { class = "^(zen)$", initial_title = "^(Picture-in-Picture)$" },
    float = true,
    pin = true,
    size = { 640, 360 },
    min_size = { 320, 180 },
    max_size = { 1280, 720 },
    keep_aspect_ratio = true,
    suppress_event = "maximize fullscreen",
})

hl.window_rule({
    match = { class = "^$", title = "^$", xwayland = true, float = true, fullscreen = false, pin = false },
    no_focus = true,
})

hl.window_rule({ match = { class = "^(Spotify)$" }, workspace = "special:spotify silent" })
hl.window_rule({ match = { class = "^(vesktop)$" }, workspace = "special:discord silent" })
hl.window_rule({ match = { class = "^(steam)$" }, workspace = "special:steam silent" })
hl.window_rule({ match = { class = "^(clipse)$" }, float = true, size = { 622, 652 } })

-- No per-game presentation rules: forcing fullscreen/immediate on steam_app_*
-- left the cursor grabbed after exit, and gamescope (in every game's launch
-- options) already owns scaling, tearing and framerate. Benchmarks in 3e01656.
