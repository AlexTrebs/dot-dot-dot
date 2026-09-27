# Plasma session

A KDE Plasma (Wayland) session runs alongside Hyprland, sharing the same palette,
font and cursor. Nothing is duplicated between the two beyond what genuinely has
to be.

```bash
./plasma_sync.sh apply   # push repo settings live
./plasma_sync.sh dump    # read back current live values
```

## Why Plasma settings are not tracked as config files

KConfig saves atomically — temp file plus `rename()`. A symlinked `kdeglobals`
is therefore replaced by a real file on the first save and silently stops
tracking the repo, and `symlink_config.sh` would then delete the live file on
its next run. Plasma also owns hundreds of unrelated keys in those files.

So the repo owns only the declarative parts:

| Path | Notes |
|---|---|
| `.local/share/color-schemes/HyprEarth.colors` | The palette. Read-only to Plasma, so it is safe to symlink |
| `.config/environment.d/gpu.conf` | Hybrid-GPU vars, shared by both sessions |
| `.config/xdg-desktop-portal/kde-portals.conf` | Portal backends. Never written by anything, so also safe to symlink |
| `.config/autostart/*.desktop` | The `exec-once` entries that are not Hyprland-specific |
| `.local/share/applications/hypr-*.desktop` | Keybind targets — Plasma 6 has no khotkeys, so a shortcut that runs a command needs a `.desktop` to attach to |
| `plasma_sync.sh` | Everything else, as an idempotent list of `kwriteconfig6` calls |

`plasma_sync.sh dump` makes GUI tweaks visible: change something in System
Settings, run it, and promote anything worth keeping into the `apply` block.

## What is shared vs. per-session

Shared: palette (`.config/colours.css` → `HyprEarth.colors`), JetBrainsMono Nerd
Font, Vimix-cursors @24, and the GPU environment. Alacritty, MangoHud, tmux,
Neovim and gamescope are session-agnostic already and need no Plasma-specific
handling.

Per-session: the shell itself. Plasma keeps its own panel and widgets rather
than mirroring the wayle bar, and its tiling is Plasma's, not dwindle.

`plasma_sync.sh` mirrors everything else that KWin has an equivalent for:
focus-follows-mouse, 10 virtual desktops, no window borders, `AllowTearing`,
flat pointer acceleration, the touchpad's four libinput settings, the `gb`
keyboard layout, hypridle's lock/DPMS/suspend timings, and the keybinds.

**Keybinds are the big one.** Stock Plasma collides with almost every Hyprland
bind — `Meta+1..9` is the task manager, `Meta+Q` activities, `Meta+T` the tiling
editor, `Meta+arrows` quick-tiling. `plasma_sync.sh` rebinds those to the
Hyprland meanings and explicitly sets the shadowed defaults to `none`. What has
no KWin equivalent is listed at the end of that block rather than faked:
`togglefloating`, `togglegroup`, and the special workspaces.

Deliberate asymmetries:

- **Per-device keyboard layouts.** `hypr/lua/input.lua` gives the NuPhy its own
  `hl.device({ kb_layout = "us" })`. Plasma has no per-device layout, so `kxkbrc` gets
  `gb,us` and the second one is a manual switch. keyd does not help — it
  re-emits scancodes, and applying the layout is still the compositor's job.
- **XWayland scaling.** Hyprland uses `force_zero_scaling`; KWin has no
  equivalent, so `Xwayland/Scale` is set to the output's own 1.33 to at least
  keep X11 and Wayland windows the same physical size.
- **Alacritty decorations.** `window.decorations = "full"` asks for server-side
  decorations. Hyprland always answers `server_side` and then draws no titlebar,
  so it looks unchanged there, while KWin draws Breeze. The old `"none"` was a
  client-side request that both honoured — hence no titlebar under Plasma.

## What was taken from SteamOS

SteamOS' desktop mode is close to stock Plasma — Valve's `steamdeck-kde-presets`
ships a `kwinrc` containing only virtual-keyboard settings, and a `kdeglobals`
that is mostly the Vapor theme, a font stack and lockdown restrictions. Most of
what gets praised about it is either a Plasma default or curation rather than
configuration. What was worth copying:

| SteamOS behaviour | Here |
|---|---|
| Pointer acceleration off | `X11LibInputXAccelProfileFlat`, matching `accel_profile = flat` |
| New windows land somewhere sensible | `Windows/Placement=Centered`, pinned rather than left to default |
| Single-click off | `KDE/SingleClick=false`, which is the one behavioural key Valve pins too |
| Snapping that behaves | quick-tile kept, moved to `Meta+Alt+arrows` |
| Fast, unobtrusive animations | `AnimationDurationFactor 0.5` |
| App-store-like install | already covered — `flatpak` + Flathub + Discover's flatpak backend |
| Printer working in under a minute | `cups`, `cups-pdf`, `print-manager`, `cups.socket` |
| Scanner working driverlessly | `sane`, `sane-airscan`, `skanpage` |
| Firmware updates in the app store | `fwupd` — Discover already had `fwupd-backend.so` and nothing behind it |

**Gaming Mode** is the one piece that is not a Plasma setting:
`gamescope-session-steam-git` adds a third SDDM entry booting straight into the
Steam Deck UI, next to Hyprland and Plasma. Leave it via the power menu →
Switch to Desktop, which returns to SDDM. Watch for a duplicate SDDM entry from
`gamescope-session-git`'s `/usr/share/wayland-sessions/gamescope-session.desktop`
symlink, and note the session is sensitive to the gamescope version — gamescope
is load-bearing for every game's launch options here, so fix the session rather
than downgrading gamescope.

Not adopted, and why:

- **Immutability.** The whole point of this repo is the opposite.
- **Middle-click autoscroll.** Missing on SteamOS too. Not a compositor setting
  — it needs toolkit support that neither GTK nor Qt has.
- **Volume-slider audio feedback.** Real, but its config key could not be
  pinned down; System Settings → Audio has the toggle.

## Manual steps

- **Adaptive sync (VRR)** is per-output and lives in `kwinoutputconfig.json`,
  which is machine-specific and not tracked. Set it once in System Settings →
  Display → Adaptive Sync. Hyprland gets this from `misc { vrr = 2 }`.
- **Night Light schedule.** Set it in System Settings → Display → Night Light,
  then `./plasma_sync.sh dump` and promote whichever of `NightColor`/`NightLight`
  actually reads back — KWin renamed the group between releases. The on/off
  toggle is already bound to `Meta+F7`, matching hyprsunset's key.
- **Global shortcuts** must be applied from *outside* Plasma. `kglobalaccel`
  keeps `kglobalshortcutsrc` in memory and can write its own copy back at
  logout, so run `./plasma_sync.sh apply` from Hyprland, or apply from Plasma
  and immediately re-login to check it stuck.
- **GPU environment** only takes effect after a full re-login, since
  `environment.d` is read when the systemd user session starts.
- **Touchpad identity** is baked into the `kcminputrc` group name — Plasma has no
  wildcard for libinput devices. If the pad ever changes, re-derive the decimal
  vendor/product from `/proc/bus/input/devices` (which prints hex).

## Secrets

gnome-keyring is the secret service for both sessions; `plasma_sync.sh apply`
disables KWallet (`kwalletrc/Wallet/Enabled=false`). Only one process can own
`org.freedesktop.secrets`, so running both would mean credentials saved in one
session going missing in the other. gnome-keyring wins because the Hyprland
session and its autostarts already depend on it, and it needs no Plasma-side
setup — `/etc/xdg/autostart/gnome-keyring-secrets.desktop` is honoured by
Plasma, and `gnome-keyring-daemon.socket` is enabled.

One thing does need saying explicitly: the packaged
`/usr/share/xdg-desktop-portal/kde-portals.conf` routes
`org.freedesktop.impl.portal.Secret` to KWallet, which `plasma_sync.sh` has just
turned off. Sandboxed apps asking the portal for a secret under Plasma would
talk to a backend that never runs. `.config/xdg-desktop-portal/kde-portals.conf`
overrides that one line to `gnome-keyring`; the other three lines are copied
verbatim from the packaged file, since this replaces it rather than merging, and
are worth re-checking after a Plasma upgrade.
