# Out-of-repo system overrides

Files that live outside this repo (so `symlink_config.sh` does not manage them) but that
the setup depends on. Listed here because `/usr/local` shadows survive pacman upgrades
and are otherwise invisible.

## `/usr/local/bin/hyprland-session` + `/usr/local/share/wayland-sessions/hyprland.desktop`

Logging out of Hyprland leaves a black TTY instead of returning to SDDM.

`start-hyprland` (hyprland 0.56.0, still unfixed in master as of 2026-07-24) installs its
SIGTERM handler with an empty `sa_mask` (`start/src/main.cpp:29`), so at session teardown
the signal can land on the `waitpid` worker thread. The handler calls `forceQuit()`, which
does an unguarded `m_hlThread.join()` (`start/src/core/Instance.cpp:99`) — joining itself
(`EDEADLK`), or double-joining against `run()`'s join at `Instance.cpp:215` (`EINVAL`).
Either throws `std::system_error` out of a signal handler → `std::terminate` → SIGABRT.
SDDM reads the signal death as `ERROR_INTERNAL "Process crashed"` and never respawns the
greeter.

Hyprland itself has already exited and been reaped at that point, so the exit status is
noise. The wrapper keeps `start-hyprland` (env import, `hyprland-session.target`, watchdog)
and maps only exit `134` (128+SIGABRT) to `0`; real failures still propagate. The
`.desktop` in `/usr/local/share/wayland-sessions/` shadows the packaged one because
`/usr/local/share` precedes `/usr/share` in `XDG_DATA_DIRS`.

Recheck after each `hyprland` upgrade. Once upstream guards the join, remove both:

```bash
sudo rm /usr/local/bin/hyprland-session /usr/local/share/wayland-sessions/hyprland.desktop
```

Upstream context: [discussion #12697](https://github.com/hyprwm/Hyprland/discussions/12697)
fixed a *different* dtor path (commit `25250527`, 2025-12-24); this signal-handler path is
not covered.
