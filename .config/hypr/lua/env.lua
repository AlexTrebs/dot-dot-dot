-- Ported from hyprland.conf lines 9, 69-72.

hl.permission({ binary = "/usr/(bin|local/bin)/hyprpm", type = "plugin", mode = "allow" })

hl.env("XCURSOR_THEME", "Vimix-cursors")
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_THEME", "Vimix Cursors")
hl.env("HYPRCURSOR_SIZE", "24")

-- GPU vars (LIBVA_*, GBM_BACKEND, __GL_YIELD) live in
-- ~/.config/environment.d/gpu.conf so Plasma gets them too.
-- XDG_SESSION_TYPE lives in environment.d/wayland.conf.
