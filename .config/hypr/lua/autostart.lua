-- Ported from hyprland.conf lines 21-64 (exec-once).

hl.on("hyprland.start", function()
    -- Only needed when the session is launched by uwsm — exports env to systemd/dbus
    -- and signals wayland-wm@ ready. Under a plain Hyprland session it just errors:
    -- "Finalization: Could not get ID of active or activating Wayland session".
    -- Uncomment if switching back to the "Hyprland (uwsm-managed)" SDDM entry.
    -- hl.exec_cmd("uwsm finalize")

    -- Load hyprpm-managed plugins (hymission, borders-plus-plus). This is the only
    -- supported way — hyprpm owns the enabled set in /var/cache/hyprpm/$USER.
    -- -n notifies on load and on ABI mismatch after a Hyprland upgrade; when that fires,
    -- run `hyprpm update` manually. Upstream deliberately does not auto-rebuild.
    -- Repos are re-added by install.sh; `hyprpm purge-cache` wipes them irrecoverably.
    hl.exec_cmd("hyprpm reload -n")

    -- Start gnome-keyring for secret service (prevents app delays waiting for keyring)
    hl.exec_cmd("gnome-keyring-daemon --start --components=secrets,pkcs11")

    hl.exec_cmd("systemctl --user start pipewire pipewire-pulse wireplumber")
    hl.exec_cmd("systemctl --user start hyprpolkitagent")
    hl.exec_cmd("systemctl --user start --job-mode=ignore-dependencies xdg-desktop-portal-hyprland.service xdg-desktop-portal.service")
    hl.exec_cmd("wl-clip-persist --clipboard regular")

    hl.exec_cmd("hyprctl setcursor Vimix-cursors 24")
    hl.exec_cmd("hyprpaper")
    hl.exec_cmd("~/.config/hypr/scripts/bing_wallpaper.sh")

    hl.exec_cmd("hyprsunset")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("clipse -listen")
    -- Resolve via PATH, not the cargo target dir. install.sh installs wayle-git
    -- (AUR) to /usr/bin/wayle, so the hardcoded build path broke fresh installs and
    -- silently pinned this machine to a stale local build.
    hl.exec_cmd("wayle panel start")

    hl.exec_cmd("~/.config/hypr/scripts/claude_personality_gen/gen.sh")

    hl.exec_cmd("alacritty -e ~/.local/bin/auto_tmux.sh", { workspace = "special:tilde silent" })
    hl.exec_cmd("spotify-launcher")

    hl.exec_cmd("asusctl leds set low")

    hl.exec_cmd("~/.local/bin/update_all.sh")
    hl.exec_cmd("~/.local/bin/dock-toggle.sh")
end)
