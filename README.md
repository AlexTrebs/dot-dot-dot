# dot-dot-dot

Arch Linux dotfiles and system setup for an ASUS laptop with Intel+NVIDIA hybrid GPU, Hyprland compositor, and hyprpanel.

## Stack

- **WM**: Hyprland (via uwsm)
- **Panel**: hyprpanel (AGS/TypeScript)
- **Terminal**: Alacritty + tmux
- **Editor**: Neovim / Zed
- **Launcher**: Rofi
- **Browser**: Zen Browser
- **Session**: uwsm + SDDM
- **GPU**: Intel iGPU + NVIDIA (nvidia-open, nvidia-prime, supergfxctl)
- **Audio**: PipeWire + WirePlumber
- **Lockscreen**: hyprlock
- **Wallpaper**: hyprpaper + Bing daily wallpaper script

## Fresh Install

### 1. Boot and install Arch

Use `archinstall.yaml` with the `archinstall` tool:

```bash
archinstall --config archinstall.yaml
```

### 2. Clone this repo

```bash
git clone --recurse-submodules https://github.com/AlexTrebs/dot-dot-dot.git ~/Workspace/dot-dot-dot
cd ~/Workspace/dot-dot-dot
```

### 3. Run install script

```bash
./install.sh symlink   # installs packages, symlinks configs
# or
./install.sh copy      # installs packages, copies configs
```

This will:
- Install all pacman and AUR packages
- Configure NVIDIA hibernate support (mkinitcpio, GRUB, nvidia power services)
- Symlink/copy `.config/` and `.local/` to `$HOME`
- Copy `etc/` files to `/etc/` (requires sudo)
- Enable Bluetooth

### 4. Manual steps after install

- **Hibernate**: Set `resume=` and `resume_offset=` in `/etc/default/grub` after configuring swap:
  ```bash
  ROOT_UUID=$(findmnt / -o UUID -n)
  SWAP_OFFSET=$(sudo filefrag -v /swapfile | awk 'NR==4 {print $4}' | sed 's/\.\.//')
  # Add to GRUB_CMDLINE_LINUX_DEFAULT, then:
  sudo grub-mkconfig -o /boot/grub/grub.cfg
  ```
- **Lock screen avatar**: Copy your profile picture to `~/.config/hypr/avatar.png`
- **NuPhy wired keyboard**: Run `hyprctl devices | grep -i nuphy` while plugged in via USB and update the `TODO-nuphy-wired-device-name` device block in `hyprland.conf`
- **Zed**: Installed separately via `curl -fsSL https://zed.dev/install.sh | ZED_CHANNEL=preview sh` (handled by install.sh)

## Submodules

| Path | Repo |
|---|---|
| `.config/nvim` | [AlexTrebs/nvim-config](https://github.com/AlexTrebs/nvim-config) |
| `.config/tmux` | [AlexTrebs/tmux-config](https://github.com/AlexTrebs/tmux-config) |
| `claude-personality-gen` | [AlexTrebs/claude-personality-gen](https://github.com/AlexTrebs/claude-personality-gen) |

## Keyboard Layouts

- Built-in ASUS keyboard: UK (`gb`)
- NuPhy Air75 V2 (dongle): US (`us`)
- NuPhy Air75 V2 (USB): US (`us`) — update device name in `hyprland.conf`

## Package List Sync

`archinstall.yaml` and `install.sh` should have matching package lists. To check and sync:

```bash
./sync_package_lists.sh
```
