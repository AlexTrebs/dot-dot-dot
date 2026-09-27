-- Ported from hyprland.conf lines 9, 69-72.

hl.permission({ binary = "/usr/(bin|local/bin)/hyprpm", type = "plugin", mode = "allow" })

hl.env("XCURSOR_THEME", "Vimix-cursors")
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_THEME", "Vimix Cursors")
hl.env("HYPRCURSOR_SIZE", "24")

-- GPU and Wayland vars live in ~/.config/environment.d/ so Plasma gets them too.
-- That dir only reaches systemd services, not this (non-uwsm) session, so read
-- the same files here. Plain KEY=value lines only; no $VAR expansion.
for _, name in ipairs({ "gpu.conf", "wayland.conf" }) do
    local f = io.open(os.getenv("HOME") .. "/.config/environment.d/" .. name)
    if f then
        for line in f:lines() do
            local key, value = line:match("^%s*([%w_]+)=(.*)$")
            if key then hl.env(key, value) end
        end
        f:close()
    end
end
