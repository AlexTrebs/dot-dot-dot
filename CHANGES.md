# dot-dot-dot — Suggested Improvements
**Arch Linux / Hyprland / ASUS ROG · April 2026**

---

## Legend

| Tag | Meaning |
|---|---|
| `ADD` | New addition recommended for your use case |
| `MISSING` | Not in Gemini's suggestions but relevant to your workflow |
| `SKIP` | Already handled in install.sh or redundant with your stack |
| `FIX` | Bug or error in a suggested script |
| `REPO` | Issue found directly in the repo scripts or structure |

---

## 1  Hyprland config additions

Direct additions to `hyprland.conf`. All dependencies are already installed.

### `ADD` swaync autostart

No notification daemon is currently present. Essential for muting Discord pings while recording in OBS or making music.

```
exec-once = swaync
```

### `SKIP` Hardware key binds

Already present in `hyprland.conf` lines 311-316 using `bindel`. Volume mute and mic mute also bound.

### `SKIP` Media key binds

Already present in `hyprland.conf` lines 320-323 using `bindl` for next/pause/play/prev.

### `ADD` PipeWire quantum toggle pair

For music production. A pair of binds lets you toggle low-latency mode on and off without restarting PipeWire.

```
bind = $mainMod, M,       exec, pw-metadata -n settings 0 clock.force-quantum 128
bind = $mainMod SHIFT, M, exec, pw-metadata -n settings 0 clock.force-quantum 0
```

### `ADD` VRR

Worth enabling if your ASUS display supports VRR/FreeSync — most do. The `no_direct_scanout` line Gemini included is already the default, omit it.

```
misc {
    vrr = 1
}
```

### `SKIP` Steam workspace rule

Already isolated: Steam has a `special:steam` workspace with toggle bind on `$mainMod G` (hyprland.conf lines 296-299, 346). Behaviour is equivalent.

### `SKIP` hyprsunset autostart

`exec-once = hyprsunset` is already in `hyprland.conf` (line 29). Temperature is adjusted live via `$mainMod F7/F8` binds (lines 305-306) using `hyprctl hyprsunset temperature` — better than a static-temp toggle.

### `SKIP` Discord Wayland screenshare fix

`ELECTRON_OZONE_PLATFORM_HINT=auto` already set in `.config/environment.d/wayland.conf` (tracked in repo).

### `MISSING` wf-recorder keybind

Script already exists at `.config/hypr/scripts/screen_record.sh` (tracked) — supports full-screen and slurp region selection. Missing only the keybind in `hyprland.conf`:

```
bind = $mainMod SHIFT, R, exec, ~/.config/hypr/scripts/screen_record.sh
```

---

## 2  New scripts

These scripts don't exist yet and address real gaps in your workflow.

### `MISSING` dock-toggle.sh

Handles the full monitor/peripheral handoff when plugging in at home. Detects whether an external display is connected and switches Hyprland layout, workspace assignment, and Mullvad LAN access accordingly.

```bash
#!/bin/bash
EXTERNAL="DP-5"  # confirmed from hyprland.conf — 1920x1080@144

if hyprctl monitors | grep -q "$EXTERNAL"; then
    # --- DOCKED ---
    hyprctl keyword monitor "$EXTERNAL,1920x1080@144,1924x0,1"
    hyprctl keyword monitor "eDP-1,2560x1600@240,0x0,1.33"
    for ws in 1 2 3 4 5; do
        hyprctl dispatch moveworkspacetomonitor "$ws $EXTERNAL"
    done
    mullvad lan set allow
    notify-send "Docked" "External monitor active, LAN allowed"
else
    # --- UNDOCKED ---
    hyprctl keyword monitor "eDP-1,2560x1600@240,0x0,1.33"
    for ws in 1 2 3 4 5; do
        hyprctl dispatch moveworkspacetomonitor "$ws eDP-1"
    done
    mullvad lan set block
    notify-send "Undocked" "Laptop only, LAN blocked"
fi
```

> External output name `DP-5` and mode `1920x1080@144` taken from the staged `hyprland.conf`. Verify with `hyprctl monitors` while docked.

### `MISSING` tmux-resurrect setup

The `supergfxctl-toggle.sh` script restarts SDDM which kills your entire session. Without resurrect, every GPU mode switch wipes your terminal layout. Add to your `tmux-config` submodule.

```
# In .tmux.conf
set -g @plugin 'tmux-plugins/tmux-resurrect'
set -g @plugin 'tmux-plugins/tmux-continuum'
set -g @continuum-restore 'on'
set -g @continuum-save-interval '5'
set -g @resurrect-capture-pane-contents 'on'
```

---

## 3  New packages

Add these to both `archinstall.yaml` and `install.sh` to keep them in sync.

| Package | Source | Reason |
|---|---|---|
| `swaync` | pacman | Notification daemon with DND. Required for `notify-send` calls from scripts to display. |
| `easyeffects` | pacman | NoiseTorch is abandoned. Current standard for system-wide audio effects and noise suppression with better PipeWire/JACK integration. |
| `timeshift` | AUR | Snapshot backups before updates. Use rsync mode on ext4, snapshot mode on BTRFS (much faster). |
| `starship` | pacman | Recommended if adopting the `.bashrc` improvements below. |

---

## 4  Missing tracked configs

These configs should be in the dotfiles repo but currently aren't. Each one is lost on a fresh install.

### `MISSING` .bashrc

Shell config is not tracked at all. Stock bash is a noticeable quality-of-life gap alongside an otherwise highly configured setup.

```bash
# History
HISTSIZE=10000
HISTFILESIZE=20000
HISTCONTROL=ignoredups:erasedups
shopt -s histappend

# Prompt — starship handles this if installed, otherwise:
PS1='\[\033[1;34m\]\w\[\033[0m\] $(git branch 2>/dev/null | grep "^*" | cut -c3-)\n\$ '

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ll='ls -lah --color=auto'

# Git
alias gs='git status'
alias gd='git diff'
alias gl='git log --oneline -20'

# tmux
alias t='tmux'
alias ta='tmux attach -t'
alias tn='tmux new -s'
alias tl='tmux list-sessions'

# Dotfiles
alias dots='cd ~/Workspace/dot-dot-dot'

# asdf shims (added by install-ruby-rails.sh — centralise here instead)
export PATH="$HOME/.asdf/shims:$PATH"
```

> Add `eval "$(starship init bash)"` at the end if using starship for the prompt.

### `MISSING` .gitconfig

Not in the repo at all. Annoying to redo on a fresh install. Track in the dotfiles root and symlink via `symlink_config.sh`.

```ini
[user]
    name  = Your Name
    email = your@email.com

[init]
    defaultBranch = main

[push]
    default = current
    autoSetupRemote = true

[pull]
    rebase = false

[core]
    editor = nvim

[diff]
    tool = vimdiff

[alias]
    st   = status
    co   = checkout
    lg   = log --oneline --graph --decorate -20
    undo = reset HEAD~1 --mixed
```

### `SKIP` .config/alacritty/alacritty.toml

Already tracked in repo at `.config/alacritty/alacritty.toml`.

### `MISSING` /etc/xdg/reflector/reflector.conf

`reflector` is installed but no config is tracked in your `etc/` directory. Without it, reflector uses defaults and may pick slow mirrors. Add alongside your other `etc/` files.

```
--save /etc/pacman.d/mirrorlist
--protocol https
--country GB,DE,FR
--latest 10
--sort rate
```

### `SKIP` .config/zed/settings.json

Already tracked in repo at `.config/zed/settings.json`.

---

## 5  Script fixes

Gemini provided two scripts. Both have bugs that cause silent failures or errors at runtime.

### `FIX` g16-power.sh

**Bug 1 — `auto-cpufreq` not in your stack.**
Your install uses `power-profiles-daemon`, which `asusctl` already talks to. The `sudo auto-cpufreq` calls will fail silently. Remove them — `asusctl profile` handles CPU frequency scaling on its own.

**Bug 2 — `sudo` in a keybind script.**
`sudo` in a Hyprland keybind will either silently fail or pop a password prompt mid-session. Removing `auto-cpufreq` eliminates the need for `sudo` entirely.

**Bug 3 — `asusctl aura` syntax.**
`led-mode static -c ff0000` is wrong for current `asusctl` versions. Use `asusctl aura static --colour ff0000`. Test in terminal first to confirm your version's exact syntax.

**Bug 4 — broken `notify-send` string.**
The `"60Hz | Silent Fans"` string is split across two lines in CONSERVE mode, causing a parse error.

```bash
#!/bin/bash
MONITOR="eDP-1"
RES_MAX="2560x1600@240"
RES_LOW="2560x1600@60"

CURRENT_PROFILE=$(asusctl profile -p | grep -oP '(?<=is ).*')

if [ "$CURRENT_PROFILE" = "Quiet" ]; then
    asusctl profile --profile Performance
    hyprctl keyword monitor "$MONITOR,$RES_MAX,0x0,1"
    hyprctl keyword decoration:blur:enabled yes
    asusctl aura static --colour ff0000
    notify-send -u critical "MODE: OVERKILL" "240Hz | Performance Fans"
else
    asusctl profile --profile Quiet
    hyprctl keyword monitor "$MONITOR,$RES_LOW,0x0,1"
    hyprctl keyword decoration:blur:enabled no
    asusctl aura static --colour 333333
    notify-send -u low "MODE: CONSERVE" "60Hz | Silent Fans"
fi
```

### `FIX` supergfxctl-toggle.sh

**Bug 1 — `systemctl` split across two lines.**
`sudo systemc` on one line and `tl restart sddm` on the next means neither command exists. The GPU mode switches but SDDM never restarts, so the change doesn't apply until the next manual logout.

**Bug 2 — output casing not normalised.**
If `supergfxctl -g` returns `"Integrated"` instead of `"integrated"` the comparison silently fails and always switches to integrated mode. Normalise before comparing.

```bash
#!/bin/bash
MODE=$(supergfxctl -g | tr '[:upper:]' '[:lower:]' | tr -d '[:space:]')

if [ "$MODE" = "integrated" ]; then
    notify-send "Switching to Hybrid Mode" "Session will restart in 3 seconds..."
    sleep 3
    supergfxctl -m hybrid
else
    notify-send "Switching to Integrated Mode" "Session will restart in 3 seconds..."
    sleep 3
    supergfxctl -m integrated
fi

sudo systemctl restart sddm
```

> Restarting SDDM kills your entire session. Make sure tmux-resurrect is configured (see Section 2) before relying on this script.

---

## 6  Repo script issues

Issues found directly in the existing repo scripts.

### `REPO` symlink_config.sh — weak hyprctl reload guard

Current guard is `command -v hyprctl &> /dev/null && hyprctl reload` — checks the binary exists but not whether a session is running. On a machine with hyprctl installed but no live session, this still fires and fails. Use the session signature instead:

```bash
# Replace the current guard with:
if [ -n "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
    hyprctl reload
fi
```

### `REPO` sync_package_lists.sh — asymmetric sync

When syncing, the script updates `archinstall.yaml` with the union of both lists but explicitly does not update `install.sh`. This means running it after adding a package to `archinstall.yaml` leaves `install.sh` stale. Either update both files or document the intentional one-way behaviour more clearly.

### `DONE` install-ruby-rails.sh — removed

Script deleted from repo. Follow-up: `asdf-vm` is still listed in `install.sh` (line 110, AUR packages) and `archinstall.yaml` (line 22). If nothing else uses asdf, remove it from both files.

### `REPO` install.sh — mkinitcpio runs unconditionally

`mkinitcpio -P` runs every time `install.sh` is called, even when nothing has changed. Gate it behind the condition that actually modified the initramfs config:

```bash
# Wrap the rebuild in a flag set earlier in the NVIDIA section:
INITRAMFS_CHANGED=false

if grep -q "^MODULES=()" /etc/mkinitcpio.conf; then
    sudo sed -i 's/^MODULES=()/MODULES=(simpledrm)/' /etc/mkinitcpio.conf
    INITRAMFS_CHANGED=true
fi
# ... other mkinitcpio edits, set INITRAMFS_CHANGED=true for each ...

if [ "$INITRAMFS_CHANGED" = true ]; then
    echo "Rebuilding initramfs..."
    sudo mkinitcpio -P
fi
```

### `REPO` install.sh — docker group without Docker package

`docker` is in the `usermod -aG` groups loop but Docker is not in your package list. Either add `docker` to packages or remove it from the groups loop to avoid confusion.

### `REPO` setup.sh — not referenced anywhere

`setup.sh` is 2 lines (`git submodule update --init --recursive`) and isn't called by `install.sh` or mentioned in the README. Either fold it into the start of `install.sh` or document when to use it. Currently someone doing a fresh clone could easily miss it and end up with broken submodules.

### `REPO` hyprland.conf — scale_monitor.sh bind references missing script

Staged `hyprland.conf` adds two binds:

```
bind = $mainMod SHIFT, equal, exec, ~/.config/hypr/scripts/scale_monitor.sh up
bind = $mainMod SHIFT, minus, exec, ~/.config/hypr/scripts/scale_monitor.sh down
```

`scale_monitor.sh` does not exist in `.config/hypr/scripts/`. These binds will silently do nothing until the script is created and tracked.

### `REPO` hyprpaper.conf — not tracked

`hyprpaper.conf` exists at `~/.config/hypr/hyprpaper.conf` and is referenced in `exec-once`, but it is not in the repo. Wallpaper layout and preload paths are lost on a fresh install.

### `REPO` .gitignore — too sparse

Only 3 entries. Missing coverage for:

```gitignore
# Backup files
*.bak

# Secrets / local overrides
.env
.env.local
*.secret

# Sensitive config that shouldn't be public
.config/gnome-keyring/
.config/chromium/
.config/BraveSoftware/
.ssh/

# Runtime/cache dirs that may end up here
.config/hypr/icons/
.config/discord/
```

The `.bak` files (`archinstall.yaml.bak`, `install.sh.bak`) are currently committed to the repo.

---

## 7  Skip these — already handled

Gemini suggested these, but they're already covered by your existing config or are redundant with your stack.

| Suggestion | Reason to skip |
|---|---|
| `/etc/modprobe.d/nvidia.conf` | `install.sh` already injects `nvidia_drm.modeset=1` and `nvidia_drm.fbdev=1` into GRUB. A `modprobe.d` file on top is a duplicate and may conflict. |
| `zram-generator` | Already in your package list. |
| `hypridle` autostart | Already in `exec-once`. |
| `udiskie` | Redundant with Thunar + gvfs + gvfs-mtp. Designed for setups without a file manager. |
| `supergfxctl` integrated/hybrid tip | Already installed and configured. Usage advice, not a dotfile change. |
| Hardware key binds | Already in `hyprland.conf` lines 311-316 (`bindel`). |
| Media key binds | Already in `hyprland.conf` lines 320-323 (`bindl`). |
| Steam workspace rule | Already isolated as `special:steam` workspace. |
| `hyprsunset` autostart + toggle | Already in `exec-once`; temperature adjusted via F7/F8 binds. |
| Discord Wayland screenshare fix | `ELECTRON_OZONE_PLATFORM_HINT=auto` already in `.config/environment.d/wayland.conf`. |
| `.config/alacritty/alacritty.toml` | Already tracked in repo. |
| `.config/zed/settings.json` | Already tracked in repo. |
| `record-toggle.sh` | Exists as `.config/hypr/scripts/screen_record.sh` (tracked); only missing the keybind. |

---

## 8  Repo housekeeping checklist

### hyprland.conf
- [x] Add `exec-once = swaync` to autostart block
- [x] Add `vrr = 1` to `misc {}` block
- [x] Add `bind = $mainMod SHIFT, R, exec, ~/.config/hypr/scripts/screen_record.sh`
- [x] Add PipeWire quantum toggle binds — `$mainMod M` (128 quantum) / `$mainMod SHIFT M` (reset)
- [x] Wire `g16-power.sh` to `$mainMod F11`, `dock-toggle.sh` to `$mainMod F12`

### Scripts
- [x] `g16-power.sh` → `.local/bin/g16-power.sh` (fixed all 4 bugs from section 5)
- [x] `supergfxctl-toggle.sh` → `.local/bin/supergfxctl-toggle.sh` (fixed casing + split-line bugs)
- [x] `dock-toggle.sh` → `.local/bin/dock-toggle.sh` (uses confirmed DP-5 / eDP-1 names)
- [x] `scale_monitor.sh` → `.config/hypr/scripts/scale_monitor.sh` (created, reads active monitor scale)

### Packages
- [x] `swaync`, `easyeffects`, `starship`, `timeshift` added to `install.sh` and `archinstall.yaml`
- [x] `asdf-vm` removed from both

### Tracked configs
- [x] `.bashrc` tracked in repo root — symlinked by `symlink_config.sh`
- [x] `.gitconfig` tracked in repo root — symlinked by `symlink_config.sh`
- [x] `etc/xdg/reflector/reflector.conf` added; `install.sh` copies it on run
- [x] `hyprpaper.conf` tracked in `.config/hypr/`
- [x] tmux-resurrect + tmux-continuum enabled in `.config/tmux/tmux.conf`; TPM auto-installs on first run

### Script fixes
- [x] `symlink_config.sh` — hyprctl reload now guarded by `$HYPRLAND_INSTANCE_SIGNATURE`
- [x] `symlink_config.sh` — now links/copies `.bashrc` and `.gitconfig` from repo root to `$HOME`
- [x] `sync_package_lists.sh` — now reports packages missing from `install.sh` after syncing (manual add required to preserve section structure)
- [x] `install.sh` — `mkinitcpio -P` now gated behind `INITRAMFS_CHANGED` flag
- [x] `install.sh` — `docker` removed from groups loop
- [x] `install.sh` — submodule init folded in at top; `setup.sh` is now redundant
- [x] `install.sh` — reflector config copy added

### Missing scripts / configs
- [x] `scale_monitor.sh` created
- [x] `hyprpaper.conf` tracked

### Repo hygiene
- [x] `.gitignore` expanded (`*.bak`, secrets, sensitive config dirs, cache dirs)
- [x] `.bak` files removed from repo and disk

---

*Reviewed against actual repo state April 2026. `hyprlock.conf`, `hypridle.conf`, `hyprpaper.conf`, and hyprpanel TypeScript config not yet reviewed — paste directly for analysis.*
