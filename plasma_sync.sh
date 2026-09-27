#!/usr/bin/env bash
# Push repo-owned Plasma settings live, or read back what is live now.
#
#   ./plasma_sync.sh apply   - write the settings below into ~/.config
#   ./plasma_sync.sh dump    - print current live values of those same keys
#
# Why a script and not tracked kdeglobals/kwinrc: see docs/plasma.md.
# `dump` makes GUI tweaks visible: change something in System Settings, run dump,
# and promote anything worth keeping into the apply block below.

set -euo pipefail

MODE="${1:-}"
SCHEME_NAME="HyprEarth"
SCHEME_FILE="$HOME/.local/share/color-schemes/${SCHEME_NAME}.colors"

# Matches wayle's font-sans and Alacritty's family. The Mono variant is used for
# fixed-width so glyph cells stay aligned; the non-Mono variant lets Nerd Font
# icons keep their natural width in UI labels.
FONT_UI="JetBrainsMono Nerd Font,10,-1,5,400,0,0,0,0,0,0,0,0,0,0,1"
FONT_UI_SMALL="JetBrainsMono Nerd Font,8,-1,5,400,0,0,0,0,0,0,0,0,0,0,1"
FONT_FIXED="JetBrainsMono Nerd Font Mono,10,-1,5,400,0,0,0,0,0,0,0,0,0,0,1"

ACCENT_RGB="79,138,114"   # #4f8a72, same accent as colours.css / wayle
CURSOR_THEME="Vimix-cursors"
CURSOR_SIZE="24"

# Touchpad identity for the per-device kcminputrc group. Decimal, from
# /proc/bus/input/devices (which prints hex): 0x093a=2362, 0x3012=12306.
TOUCHPAD_VID="2362"
TOUCHPAD_PID="12306"
TOUCHPAD_NAME="ASUP1207:00 093A:3012 Touchpad"

# Idle timings, mirroring hypridle.conf. Plasma wants minutes for the lock and
# seconds for the powerdevil actions, hence the two units.
LOCK_MINUTES="4"     # hypridle: listener timeout 240
DPMS_SECONDS="300"   # hypridle: listener timeout 300
SUSPEND_SECONDS="600" # hypridle: listener timeout 600

die() { echo "error: $*" >&2; exit 1; }

# plasma-apply-colorscheme and the KWin reconfigure call both need a live
# Plasma session — outside one, plasma-apply-colorscheme aborts and core-dumps
# rather than exiting cleanly. Everything else is a plain file write and works
# from any session, so `apply` is still useful from Hyprland.
in_plasma() { case "${XDG_CURRENT_DESKTOP:-}" in *KDE*) return 0 ;; *) return 1 ;; esac; }

command -v kwriteconfig6 >/dev/null || die "kwriteconfig6 not found — install plasma-workspace"

case "$MODE" in
apply)
    [ -e "$SCHEME_FILE" ] || die "$SCHEME_FILE missing — run ./symlink_config.sh first"

    # Colour scheme. plasma-apply-colorscheme expands the .colors file into the
    # ~120 Colors:* keys kdeglobals actually wants; writing them by hand here
    # would duplicate the file and drift from it.
    if in_plasma && command -v plasma-apply-colorscheme >/dev/null; then
        plasma-apply-colorscheme "$SCHEME_NAME" >/dev/null 2>&1 \
            || echo "warn: plasma-apply-colorscheme failed" >&2
    fi

    # Accent must be pinned off the wallpaper, otherwise the Bing daily
    # wallpaper script recolours half the UI every morning.
    kwriteconfig6 --file kdeglobals --group General --key AccentColor "$ACCENT_RGB"
    kwriteconfig6 --file kdeglobals --group General --key accentColorFromWallpaper false
    kwriteconfig6 --file kdeglobals --group General --key ColorScheme "$SCHEME_NAME"

    kwriteconfig6 --file kdeglobals --group General --key font "$FONT_UI"
    kwriteconfig6 --file kdeglobals --group General --key menuFont "$FONT_UI"
    kwriteconfig6 --file kdeglobals --group General --key toolBarFont "$FONT_UI"
    kwriteconfig6 --file kdeglobals --group General --key smallestReadableFont "$FONT_UI_SMALL"
    kwriteconfig6 --file kdeglobals --group General --key fixed "$FONT_FIXED"
    kwriteconfig6 --file kdeglobals --group WM --key activeFont "$FONT_UI"

    kwriteconfig6 --file kdeglobals --group Icons --key Theme breeze-dark
    kwriteconfig6 --file kdeglobals --group KDE --key widgetStyle Breeze
    # Hyprland's animations are 1.2-5x beziers, i.e. fast. Breeze defaults feel
    # sluggish next to them.
    kwriteconfig6 --file kdeglobals --group KDE --key AnimationDurationFactor 0.5

    kwriteconfig6 --file kcminputrc --group Mouse --key cursorTheme "$CURSOR_THEME"
    kwriteconfig6 --file kcminputrc --group Mouse --key cursorSize "$CURSOR_SIZE"
    # Mirrors `input { accel_profile = flat }`.
    kwriteconfig6 --file kcminputrc --group Mouse --key X11LibInputXAccelProfileFlat true

    # Mirrors hypr/lua/input.lua `input.touchpad`. Plasma ships all four
    # of these off/adaptive by default, so without this the pad feels wrong the
    # moment you switch sessions.
    #
    # The group name embeds the device's decimal vendor/product and its evdev
    # name — libinput settings are per-device in Plasma, with no wildcard. If
    # the pad ever changes, re-derive from /proc/bus/input/devices (the ids
    # there are hex; 0x093a=2362, 0x3012=12306).
    touchpad_set() {
        kwriteconfig6 --file kcminputrc \
            --group Libinput --group "$TOUCHPAD_VID" --group "$TOUCHPAD_PID" \
            --group "$TOUCHPAD_NAME" --key "$1" "$2"
    }
    touchpad_set NaturalScroll true
    touchpad_set TapToClick true
    touchpad_set DisableWhileTyping true
    touchpad_set ScrollFactor 0.5
    # 1 = flat, matching `accel_profile = flat`.
    touchpad_set PointerAccelerationProfile 1

    # Mirrors `input { kb_layout = gb }`. Without a kxkbrc, Plasma falls back to
    # us and the built-in UK keyboard types the wrong symbols.
    #
    # us is second only because Plasma has no per-device layout: hypr/lua/input.lua
    # gives the NuPhy its own `hl.device({ kb_layout = "us" })` entry, and the closest
    # Plasma gets is both layouts loaded with a manual switch. keyd does not
    # help here — it re-emits scancodes, and the layout is still the
    # compositor's to apply.
    kwriteconfig6 --file kxkbrc --group Layout --key Use true
    kwriteconfig6 --file kxkbrc --group Layout --key LayoutList "gb,us"
    kwriteconfig6 --file kxkbrc --group Layout --key VariantList ","
    kwriteconfig6 --file kxkbrc --group Layout --key DisplayNames ","
    kwriteconfig6 --file kxkbrc --group Layout --key SwitchMode Global

    # Mirrors hypr/lua/input.lua `input.follow_mouse = 1`.
    kwriteconfig6 --file kwinrc --group Windows --key FocusPolicy FocusFollowsMouse
    # A floating window with nowhere sensible to go lands in the middle of the
    # screen rather than wherever it was last time — the SteamOS behaviour of
    # "close it and reopen it and it comes back somewhere reasonable". This is
    # already the Plasma default; pinned so a stray GUI tweak cannot lose it.
    kwriteconfig6 --file kwinrc --group Windows --key Placement Centered
    # Also a Plasma default, and one SteamOS pins explicitly in its own
    # /etc/xdg/kdeglobals. Same reasoning: worth being declarative about.
    kwriteconfig6 --file kdeglobals --group KDE --key SingleClick false
    # Mirrors `bind = $mainMod, 1..0, workspace`.
    kwriteconfig6 --file kwinrc --group Desktops --key Number 10
    kwriteconfig6 --file kwinrc --group Desktops --key Rows 1
    # Mirrors `general { border_size = 1 }` — Breeze has no 1px option, None is
    # the closest and keeps the titlebar as the only chrome.
    #
    # Both group names on purpose. KWin moved this from org.kde.kdecoration2 to
    # org.kde.kdecoration3 (KWin 6.7.3 here reads only the latter — the 2 keys
    # had been silently dead), and the 2 spelling is what an older KWin would
    # read. Writing both costs nothing and survives the next rename in either
    # direction.
    for deco_group in org.kde.kdecoration2 org.kde.kdecoration3; do
        kwriteconfig6 --file kwinrc --group "$deco_group" --key BorderSize None
        kwriteconfig6 --file kwinrc --group "$deco_group" --key BorderSizeAuto false
    done
    # Mirrors `general { allow_tearing = true }`. Per-window opt-in still needs
    # the game's KWin rule or Steam launch option; this only unblocks it.
    kwriteconfig6 --file kwinrc --group Compositing --key AllowTearing true
    # 240Hz internal panel with VRR and tearing already enabled — the whole
    # point of that stack is latency, so do not let KWin trade it back for
    # smoothness. Hyprland's equivalent is `debug { vfr = true }` plus no
    # render-ahead at all.
    kwriteconfig6 --file kwinrc --group Compositing --key LatencyPolicy Low

    # Hyprland runs XWayland unscaled (`xwayland { force_zero_scaling = true }`),
    # which is sharp but renders X11 apps small on the 1.33-scaled eDP. Plasma
    # has no zero-scaling equivalent, so the honest match is the output scale
    # itself: X11 and Wayland windows then agree on physical size across both
    # sessions. Was 1.25, which matched neither.
    kwriteconfig6 --file kwinrc --group Xwayland --key Scale 1.33

    # Titlebar buttons. Hyprland draws none at all, so keep Plasma's to the
    # three that do something you cannot already do from the keyboard, and drop
    # the menu/keep-above cluster on the left. Taste, not parity — change the
    # letters (M enu, S ticky, H elp, I conify, A ximize, X close) to suit.
    for deco_group in org.kde.kdecoration2 org.kde.kdecoration3; do
        kwriteconfig6 --file kwinrc --group "$deco_group" --key ButtonsOnLeft ""
        kwriteconfig6 --file kwinrc --group "$deco_group" --key ButtonsOnRight "IAX"
    done

    # Mirrors hypridle.conf's `timeout = 240 -> loginctl lock-session`. Plasma
    # counts this one in minutes.
    kwriteconfig6 --file kscreenlockerrc --group Daemon --key Autolock true
    kwriteconfig6 --file kscreenlockerrc --group Daemon --key Timeout "$LOCK_MINUTES"
    kwriteconfig6 --file kscreenlockerrc --group Daemon --key LockGrace 0
    kwriteconfig6 --file kscreenlockerrc --group Daemon --key LockOnResume true

    # Mirrors hypridle's dpms-off at 300s and suspend at 600s. hypridle is
    # profile-blind, so both Plasma profiles get the same numbers rather than
    # Plasma's much shorter battery defaults. suspendType 1 = sleep-to-RAM.
    for profile in AC Battery; do
        kwriteconfig6 --file powermanagementprofilesrc \
            --group "$profile" --group DPMSControl --key idleTime "$DPMS_SECONDS"
        kwriteconfig6 --file powermanagementprofilesrc \
            --group "$profile" --group SuspendSession --key idleTime "$SUSPEND_SECONDS"
        kwriteconfig6 --file powermanagementprofilesrc \
            --group "$profile" --group SuspendSession --key suspendType 1
    done

    # The CPU sits at 96C and throttles ~13k times a session (see the benchmark
    # note in hypr/lua/rules.lua). A filesystem indexer is pure heat for something
    # the Hyprland session does not have and has never been missed.
    kwriteconfig6 --file baloofilerc --group "Basic Settings" --key Indexing-Enabled false

    # Hyprland has no splash between SDDM and a usable desktop; Plasma's costs
    # a second of nothing.
    kwriteconfig6 --file ksplashrc --group KSplash --key Engine none
    kwriteconfig6 --file ksplashrc --group KSplash --key Theme None

    # ---------------------------------------------------------------------
    # Global shortcuts
    #
    # Rebinds Plasma's defaults (Meta+1..9, Meta+Q, Meta+T, Meta+arrows) to the
    # Hyprland meanings, and sets shadowed defaults to `none` explicitly.
    # Values are `active,default,friendly`; \t separates alternatives in a field.
    # kglobalaccel can rewrite this file at logout, so apply from Hyprland.
    accel() { # <group> <key> <shortcut> <friendly name>
        kwriteconfig6 --file kglobalshortcutsrc --group "$1" --key "$2" "$3,$3,$4"
    }
    launch() { # <desktop file id> <shortcut> <friendly name>
        kwriteconfig6 --file kglobalshortcutsrc \
            --group services --group "$1" --key _launch "$2,$2,$3"
        kwriteconfig6 --file kglobalshortcutsrc \
            --group services --group "$1" --key _k_friendly_name "$3"
    }

    # `bind = $mainMod, Q, killactive`
    accel kwin "Window Close" "Meta+Q" "Close Window"
    accel plasmashell "manage activities" "none" "Show Activity Switcher"
    # `bind = $mainMod, A, togglegroup` — no KWin equivalent, but the default
    # activity binds would still fire, so clear them.
    accel plasmashell "next activity" "none" "Walk through activities"
    accel plasmashell "previous activity" "none" "Walk through activities (Reverse)"

    # `bind = $mainMod, 1..0, workspace` / `$mainMod SHIFT, 1..0, movetoworkspace`
    for i in 1 2 3 4 5 6 7 8 9 10; do
        key="$i"; [ "$i" = 10 ] && key=0
        accel kwin "Switch to Desktop $i" "Meta+$key" "Switch to Desktop $i"
        accel kwin "Window to Desktop $i" "Meta+Shift+$key" "Window to Desktop $i"
        # Meta+1..9 is Plasma's task manager by default — same keys, wrong action.
        [ "$i" -le 9 ] && accel plasmashell "activate task manager entry $i" "none" \
            "Activate Task Manager Entry $i"
    done

    # `bind = $mainMod, left/right/up/down, movefocus` and the SHIFT movewindow
    # pair. Both sets of keys are quick-tiling in stock Plasma, so those go.
    for dir in Left Right Up Down; do
        case "$dir" in Left) w=Left;; Right) w=Right;; Up) w=Above;; Down) w=Below;; esac
        accel kwin "Switch Window $dir" "Meta+$dir" "Switch to Window $w"
        accel kwin "Window Pack $dir" "Meta+Shift+$dir" "Move Window $dir"
    done
    # Quick-tiling moves rather than disappears. Hyprland wants Meta+arrows for
    # focus, but half-screen snapping is one of the things Plasma does better
    # than Windows and there is no reason to throw it away — Meta+Alt+arrows is
    # free now that window switching moved onto the bare arrows. Edge-drag
    # snapping with the mouse is unaffected either way.
    accel kwin "Window Quick Tile Left" "Meta+Alt+Left" "Quick Tile Window to the Left"
    accel kwin "Window Quick Tile Right" "Meta+Alt+Right" "Quick Tile Window to the Right"
    accel kwin "Window Quick Tile Top" "Meta+Alt+Up" "Quick Tile Window to the Top"
    accel kwin "Window Quick Tile Bottom" "Meta+Alt+Down" "Quick Tile Window to the Bottom"

    # `bind = $mainMod, Tab, hymission:toggle` / `$mainMod SHIFT, Tab, open`.
    # Overview is the closest thing KWin has to the hymission plugin.
    accel kwin "Overview" "Meta+Tab" "Toggle Overview"
    accel kwin "Grid View" "Meta+Shift+Tab" "Toggle Grid View"
    # Stock Plasma also puts Meta+Tab on window walking, which would fight it.
    accel kwin "Walk Through Windows" 'Alt+Tab' "Walk Through Windows"
    accel kwin "Walk Through Windows (Reverse)" 'Alt+Shift+Tab' "Walk Through Windows (Reverse)"
    # Frees Meta+T (terminal) and Meta+D (discord scratchpad).
    accel kwin "Edit Tiles" "none" "Toggle Tiles Editor"
    accel kwin "Show Desktop" "none" "Peek at Desktop"
    # `bind = $mainMod, F7, hyprsunset temperature -100`. KWin has no
    # incremental temperature step, so the nearest key is the on/off toggle.
    accel kwin "Toggle Night Color" "Meta+F7" "Suspend/Resume Night Light"
    # `bind = $mainMod SHIFT, ESCAPE, exit`
    accel ksmserver "Log Out" "Meta+Shift+Escape" "Show Logout Screen"

    # `bind = $mainMod, R, exec, rofi -show drun`. Binding the launcher here
    # also drops Plasma's bare-Meta binding, which fires on any Meta tap and has
    # no Hyprland counterpart.
    accel plasmashell "activate application launcher" "Meta+R" "Activate Application Launcher"

    # Plasma 6 has no khotkeys: a shortcut that runs a command hangs off a
    # .desktop file instead. The hypr-*.desktop entries in
    # .local/share/applications exist only to be these targets.
    launch hypr-terminal-tmux.desktop       "Meta+T"          "Terminal (tmux)"
    launch Alacritty.desktop                "Meta+Shift+T"    "Alacritty"
    launch thunar.desktop                   "Meta+E"          "Thunar"
    launch zen.desktop                      "Meta+Z"          "Zen Browser"
    launch dev.zed.Zed.desktop              "Meta+C"          "Zed"
    launch obsidian.desktop                 "Meta+N"          "Obsidian"
    launch vesktop.desktop                  "Meta+Ctrl+D"     "Vesktop"
    launch steam.desktop                    "Meta+Ctrl+G"     "Steam"
    launch spotify-launcher.desktop         "Meta+Ctrl+M"     "Spotify"
    launch hypr-screenshot-region.desktop   "Meta+S"          "Screenshot (region)"
    launch hypr-screenshot-full.desktop     "Meta+Shift+S"    "Screenshot (full screen)"
    launch hypr-screen-record.desktop       "Meta+Shift+R"    "Screen recording"

    # Deliberately not mirrored, because Plasma has no equivalent to bind:
    #   $mainMod, F        togglefloating   (KWin has no float toggle)
    #   $mainMod, A        togglegroup      (window tabbing was removed in KWin)
    #   $mainMod, W        tasks            (no .desktop file ships with it)
    #   $mainMod, F9/F11/F12               (those scripts drive hyprctl)
    #   special workspaces (M/D/G/H/grave) (no scratchpad concept)

    # Two secret services cannot coexist: whichever claims org.freedesktop.secrets
    # first wins, so credentials saved under one session go missing in the other.
    # gnome-keyring wins here because the Hyprland session and its autostarts
    # already depend on it. Plasma needs no counterpart — gnome-keyring ships
    # /etc/xdg/autostart/gnome-keyring-secrets.desktop, which Plasma honours.
    kwriteconfig6 --file kwalletrc --group Wallet --key Enabled false

    if in_plasma && command -v qdbus6 >/dev/null; then
        qdbus6 org.kde.KWin /KWin reconfigure >/dev/null 2>&1 || true
        echo "applied and reloaded."
        echo
        echo "WARNING: run from inside Plasma. kglobalaccel holds kglobalshortcutsrc"
        echo "         in memory and can write its own copy back at logout, undoing"
        echo "         the shortcut block. Log out and back in now to check they"
        echo "         stuck; if they did not, run this again from Hyprland."
    else
        echo "applied. Log into Plasma to see the changes."
    fi
    echo
    echo "manual, because they are per-output or per-machine:"
    echo "  - adaptive sync (VRR) lives in kwinoutputconfig.json."
    echo "    System Settings > Display > Adaptive Sync. Hyprland uses misc { vrr = 2 }."
    echo "  - night light schedule. System Settings > Display > Night Light, then"
    echo "    ./plasma_sync.sh dump — the group was renamed between releases, so"
    echo "    promote whichever of NightColor/NightLight actually reads back."
    ;;

dump)
    command -v kreadconfig6 >/dev/null || die "kreadconfig6 not found"
    # `>` in the group field means a nested group — kcminputrc's per-device
    # libinput settings and kglobalshortcutsrc's [services][x.desktop] both
    # need more than one --group.
    while IFS='|' read -r file group key; do
        [ -n "$file" ] || continue
        args=(); IFS='>' read -ra parts <<<"$group"
        for p in "${parts[@]}"; do args+=(--group "$p"); done
        printf '%-28s %-46s %-26s = %s\n' "$file" "$group" "$key" \
            "$(kreadconfig6 --file "$file" "${args[@]}" --key "$key" 2>/dev/null)"
    done <<'KEYS'
kdeglobals|General|ColorScheme
kdeglobals|General|AccentColor
kdeglobals|General|accentColorFromWallpaper
kdeglobals|General|font
kdeglobals|General|menuFont
kdeglobals|General|toolBarFont
kdeglobals|General|smallestReadableFont
kdeglobals|General|fixed
kdeglobals|WM|activeFont
kdeglobals|Icons|Theme
kdeglobals|KDE|widgetStyle
kdeglobals|KDE|AnimationDurationFactor
kcminputrc|Mouse|cursorTheme
kcminputrc|Mouse|cursorSize
kcminputrc|Mouse|X11LibInputXAccelProfileFlat
kcminputrc|Libinput>2362>12306>ASUP1207:00 093A:3012 Touchpad|NaturalScroll
kcminputrc|Libinput>2362>12306>ASUP1207:00 093A:3012 Touchpad|TapToClick
kcminputrc|Libinput>2362>12306>ASUP1207:00 093A:3012 Touchpad|DisableWhileTyping
kcminputrc|Libinput>2362>12306>ASUP1207:00 093A:3012 Touchpad|ScrollFactor
kcminputrc|Libinput>2362>12306>ASUP1207:00 093A:3012 Touchpad|PointerAccelerationProfile
kxkbrc|Layout|LayoutList
kxkbrc|Layout|Use
kwinrc|Windows|FocusPolicy
kwinrc|Windows|Placement
kdeglobals|KDE|SingleClick
kwinrc|Desktops|Number
kwinrc|Desktops|Rows
kwinrc|org.kde.kdecoration3|BorderSize
kwinrc|org.kde.kdecoration3|BorderSizeAuto
kwinrc|Compositing|AllowTearing
kwinrc|Compositing|LatencyPolicy
kwinrc|Xwayland|Scale
kwinrc|org.kde.kdecoration3|ButtonsOnLeft
kwinrc|org.kde.kdecoration3|ButtonsOnRight
kwinrc|NightColor|Active
kwinrc|NightLight|Active
kscreenlockerrc|Daemon|Autolock
kscreenlockerrc|Daemon|Timeout
kscreenlockerrc|Daemon|LockGrace
kscreenlockerrc|Daemon|LockOnResume
powermanagementprofilesrc|AC>DPMSControl|idleTime
powermanagementprofilesrc|AC>SuspendSession|idleTime
powermanagementprofilesrc|AC>SuspendSession|suspendType
powermanagementprofilesrc|Battery>DPMSControl|idleTime
powermanagementprofilesrc|Battery>SuspendSession|idleTime
baloofilerc|Basic Settings|Indexing-Enabled
ksplashrc|KSplash|Engine
kglobalshortcutsrc|kwin|Window Close
kglobalshortcutsrc|kwin|Switch to Desktop 1
kglobalshortcutsrc|kwin|Window to Desktop 1
kglobalshortcutsrc|kwin|Switch Window Left
kglobalshortcutsrc|kwin|Window Pack Left
kglobalshortcutsrc|kwin|Window Quick Tile Left
kglobalshortcutsrc|kwin|Overview
kglobalshortcutsrc|kwin|Grid View
kglobalshortcutsrc|kwin|Toggle Night Color
kglobalshortcutsrc|ksmserver|Log Out
kglobalshortcutsrc|plasmashell|activate application launcher
kglobalshortcutsrc|plasmashell|activate task manager entry 1
kglobalshortcutsrc|services>hypr-terminal-tmux.desktop|_launch
kglobalshortcutsrc|services>thunar.desktop|_launch
kglobalshortcutsrc|services>hypr-screenshot-region.desktop|_launch
kwalletrc|Wallet|Enabled
KEYS
    ;;

*)
    echo "usage: $0 {apply|dump}" >&2
    exit 1
    ;;
esac
