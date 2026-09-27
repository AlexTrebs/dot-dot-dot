# dot-dot-dot

Arch Linux dotfiles and system setup for an ASUS ROG Zephyrus G16 (Intel + NVIDIA hybrid GPU):
Hyprland with a Wayle panel, plus a KDE Plasma session that shares the same look and keys.

## Stack

- **WM**: Hyprland (Lua config, plugins via hyprpm), with a KDE Plasma (Wayland) session alongside — see [Hyprland](#hyprland) and [Plasma](#plasma)
- **Panel**: Wayle (Rust/GTK4)
- **Terminal**: Alacritty + tmux
- **Editor**: Neovim / Zed
- **Launcher**: Rofi
- **Browser**: Zen Browser
- **Session**: SDDM, plain Hyprland session (not uwsm-managed)
- **GPU**: Intel iGPU + NVIDIA (nvidia-open, nvidia-prime, supergfxctl)
- **Audio**: PipeWire + WirePlumber
- **Lockscreen**: hyprlock
- **Wallpaper**: hyprpaper + Bing daily wallpaper script
- **Theme**: HyprEarth (`.config/colours.css`) for the desktop: Hyprland, Wayle, rofi, Plasma. Catppuccin Mocha for apps (Alacritty, opencode)

## Repo map

| Path | What it is |
|---|---|
| `.config/`, `.local/` | Dotfiles, linked into `$HOME` file by file by `symlink_config.sh` |
| `.config/hypr/` | Hyprland: `hyprland.lua` + `lua/` config, hyprlock, hypridle, Hyprland-only scripts |
| `.local/bin/` | Scripts that work in both sessions (screenshots, battery, updates, tmux) |
| `etc/` | System files, installed into `/etc` as root by `symlink_config.sh` |
| `packages/` | `pacman.txt` (official repos) and `aur.txt`, one package per line |
| `archinstall.yaml` | Base install; its package list mirrors `packages/pacman.txt` |
| `secure-boot/` | Secure Boot keys and a Windows direct-boot initramfs |
| `install.sh` | Packages, services, NVIDIA/hibernate setup, then `symlink_config.sh` |
| `symlink_config.sh` | Links `.config`/`.local`/home dotfiles, installs `etc/` |
| `doctor.sh` | Read-only health check; prints a fix for anything wrong |
| `plasma_sync.sh` | Applies (or dumps) the Plasma settings, see [docs/plasma.md](docs/plasma.md) |
| `docs/` | Longer write-ups |

## Fresh install

1. **Install Arch** with the included config:
   ```bash
   archinstall --config archinstall.yaml
   ```
2. **Clone** (with submodules):
   ```bash
   git clone --recurse-submodules https://github.com/AlexTrebs/dot-dot-dot.git ~/Workspace/dot-dot-dot
   cd ~/Workspace/dot-dot-dot
   ```
3. **Run the installer**, then run it once more from inside Hyprland: hyprpm can only build
   the plugins against a running compositor, so the first run skips them.
   ```bash
   ./install.sh symlink   # packages + services, then link configs into $HOME
   ./install.sh copy      # same, but copy instead of link
   ```
   It installs `packages/*.txt`, sets up NVIDIA hibernate (mkinitcpio, GRUB, nvidia power
   services), links the configs, installs `etc/` as root, and enables Bluetooth, CUPS,
   the battery listener, the daily personality timer and the hyprpm plugins.
4. **Check it**: `./doctor.sh`
5. **Manual steps**:
   - **Hibernate**: needs a swapfile big enough for the RAM image (30G `/swapfile` here). No
     `resume=` kernel parameter: systemd stores the swapfile location in an EFI variable when
     hibernating, and the `resume` hook that `install.sh` adds reads it at boot.
   - **Lock screen avatar**: replace `.config/hypr/avatar.png`.
   - **hyprcut** (keymap overlay) is built from source: put the binary at `~/.local/bin/hyprcut`.
   - **Logout fix**: see [docs/system-overrides.md](docs/system-overrides.md). Without it,
     logging out leaves a black TTY.

## Hyprland

The config is Lua (hyprlang is deprecated since Hyprland 0.55).
`.config/hypr/hyprland.lua` only `require`s one file per section:

| File | Holds |
|---|---|
| `lua/env.lua` | Env vars. Also loads `environment.d/*.conf`, since the session is not uwsm-managed |
| `lua/monitors.lua` | The generic fallback monitor rule |
| `lua/look.lua` | general, decoration, layouts, misc, cursor, group, xwayland |
| `lua/animations.lua` | Beziers and animations |
| `lua/input.lua` | Keyboard, touchpad, per-device layouts |
| `lua/binds.lua` | Keybinds |
| `lua/rules.lua` | Window and layer rules |
| `lua/autostart.lua` | Startup commands |
| `lua/plugins.lua` | hymission and borders-plus-plus settings and binds |
| `lua/hosts/<machine>.lua` | This machine's monitors and dock output, loaded last |

- **Check a change:** `Hyprland --verify-config --config ~/.config/hypr/hyprland.lua`, then `hyprctl reload`.
- **Per-machine settings** go in `lua/hosts/`, named after the hardware family
  (`/sys/class/dmi/id/product_family`, lower-cased with dashes), e.g. `rog-zephyrus-g16.lua`.
  The hostname is the stock `archlinux`, so it can't tell machines apart.
- **Scripts can't use `hyprctl keyword`.** Use `hyprctl eval 'hl.config({...})'` for options and
  `hl.monitor({...})` for monitors. `hyprctl dispatch` takes Lua: `hyprctl dispatch 'hl.dsp.exit()'`.
- **Plugins** come from hyprpm; `install.sh` adds the repos. After pacman upgrades Hyprland or its
  libraries, run `hyprpm update -f && hyprpm reload -n`. Without `-f` it can reuse stale headers,
  and plugins then fail with "Version mismatch".
- **`hyprland.conf`** is the old config, kept only for rollback. Hyprland ignores it while
  `hyprland.lua` exists.

### Keyboard layouts

- Built-in ASUS keyboard: UK (`gb`)
- NuPhy Air75 V2 (dongle, USB, Bluetooth): US (`us`). All its device names are listed in
  `lua/input.lua`; if a new one appears, check with `hyprctl devices | grep -i nuphy`.

## Scripts

- Hyprland-only scripts (they drive `hyprctl` or hyprlock) live in `.config/hypr/scripts/`.
- Scripts that also work under Plasma live in `.local/bin/`.
- Wayle's bar modules live in `.config/wayle/scripts/`.
- Names are kebab-case. CI runs `shellcheck` on every script and a Lua syntax check on the config.

## Packages

`packages/pacman.txt` lists official-repo packages and `packages/aur.txt` the AUR ones, one per
line with `#` comments. `archinstall.yaml` must list exactly the pacman set (archinstall cannot
install AUR packages). Check and fix with:

```bash
./sync_package_lists.sh
```

## Plasma

A KDE Plasma session runs alongside Hyprland with the same palette, font, cursor and keybinds.
`./plasma_sync.sh apply` pushes the settings live and `./plasma_sync.sh dump` reads them back.
Why it's a script rather than tracked config files, what is shared, what came from SteamOS, and
the manual steps: [docs/plasma.md](docs/plasma.md).

## Submodules

| Path | Repo |
|---|---|
| `.config/nvim` | [AlexTrebs/nvim-config](https://github.com/AlexTrebs/nvim-config) |
| `.config/tmux` | [AlexTrebs/tmux-config](https://github.com/AlexTrebs/tmux-config) |
| `.config/hypr/scripts/claude_personality_gen` | [AlexTrebs/claude-personality-gen](https://github.com/AlexTrebs/claude-personality-gen) |
