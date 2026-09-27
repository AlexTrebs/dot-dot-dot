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

-- No per-game presentation rules. Measured 2026-07-24 on CS2: forcing
-- `fullscreen` on steam_app_* left the cursor grabbed after the game exited,
-- and gamescope (now in every game's launch options) owns scaling, tearing and
-- framerate itself — outer rules only fight it.
--
-- Benchmarks that settled it, 5 min CS2 each, avg / 1% low:
--   no gamescope                    150 / 100
--   gamescope + VRR + tearing       152 / 103
--   gamescope + 144 cap + VRR       158 / 109
-- 5% spread, and the run with the MOST thermal throttling scored best — the
-- CPU sits at 96C and throttles ~13k times a session, which swamps any
-- difference between presentation paths. Don't re-add these rules chasing
-- frames; the bottleneck is cooling, not the compositor.
--   hl.window_rule({ match = { class = "^(steam_app_\\d+)$" }, fullscreen = true })
--   hl.window_rule({ match = { class = "^(steam_app_\\d+)$" }, immediate = true })
