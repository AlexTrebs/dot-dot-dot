# dot-dot-dot — `pi-os` branch

Terminal setup and theming for a **Raspberry Pi 5** running **Raspberry Pi OS Trixie**
(Debian 13) on **labwc / Wayland**.

This is a port of the Arch branch (`main`). It deliberately covers **only the terminal
stack and its theming** — the desktop side is left alone, because this Pi is also a
kiosk appliance and its compositor is completely different.

## What this branch does and doesn't touch

| | |
|---|---|
| ✅ Installs | Alacritty, tmux, zsh + plugins, starship, fzf/zoxide/eza/bat/fd/ripgrep, Neovim, JetBrainsMono Nerd Font |
| ❌ Leaves alone | labwc, kanshi, wf-panel-pi, `~/screen-control` (the kiosk appliance) |
| ❌ Dropped from `main` | Hyprland, Wayle, SDDM/uwsm, NVIDIA, GRUB/secure-boot, rofi, AUR/`yay` |

The Hyprland/Wayle/rofi configs still exist in `.config/` so the branch can be diffed
and merged against `main`, but `symlink_config.sh` uses an **explicit allowlist** and
never installs them.

## Install

```bash
git clone --recurse-submodules https://github.com/AlexTrebs/dot-dot-dot.git ~/dot-dot-dot
cd ~/dot-dot-dot && git checkout pi-os
./install.sh symlink
```

`symlink_config.sh` backs up anything it replaces to `<file>.pre-dotdotdot`.

## Debian vs Arch differences

These are the porting gotchas, all marked `[debian]` in `.zshrc`:

| Thing | Arch | Debian Trixie |
|---|---|---|
| `bat` binary | `bat` | **`batcat`** (aliased back) |
| `fd` binary | `fd` | **`fdfind`** (aliased back) |
| zsh plugins | `/usr/share/zsh/plugins/<name>/` | **`/usr/share/<name>/`** |
| fzf shell integration | `/usr/share/fzf/` | **`/usr/share/doc/fzf/examples/`** |
| `zsh-history-substring-search` | package | **not packaged** — vendored to `~/.local/share/zsh/plugins/` |
| `zsh-you-should-use` | AUR | **not packaged** — vendored |
| JetBrainsMono Nerd Font | `ttf-jetbrains-mono-nerd` | **not packaged** — fetched from nerd-fonts releases |
| `yazi` | package | **not in Debian** — omitted |
| Package manager | `pacman` + `yay` | `apt` |

## Stack

- **Terminal**: Alacritty (Catppuccin Mocha, JetBrainsMono Nerd Font SemiBold 10.5)
- **Multiplexer**: tmux — `C-Space` prefix, earth-palette status bar, `wl-copy` clipboard
- **Shell**: zsh + autosuggestions, syntax-highlighting, history-substring-search, you-should-use
- **Prompt**: starship (`λ` character, git branch/status)
- **Editor**: Neovim
- **Clipboard**: `wl-clipboard` (Wayland) + `xclip` (XWayland)

## Notes

- The kiosk's on-screen keyboard (squeekboard) is disabled via
  `~/.config/autostart/squeekboard.desktop` — unrelated to this repo, but it's why
  no keyboard pops up over terminals.
- Neovim on Trixie is **0.10.4**. If the `nvim` submodule config needs 0.11+, either
  unlink `~/.config/nvim` or install a newer Neovim outside apt.
- tmux plugins install themselves via TPM on first launch (`prefix + I`).
