#!/usr/bin/env bash
# =============================================================
#  Verify the pi-os setup — configs parse, tools exist, links intact
# =============================================================
# Read-only: starts nothing persistent and changes no state.
# Exit code is the number of failures.
export WAYLAND_DISPLAY="${WAYLAND_DISPLAY:-wayland-0}"
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"

PASS=0; FAIL=0; WARN=0
ok()   { printf '  \033[32m✓\033[0m %s\n' "$1"; PASS=$((PASS+1)); }
bad()  { printf '  \033[31m✗\033[0m %s\n' "$1"; FAIL=$((FAIL+1)); }
warn() { printf '  \033[33m!\033[0m %s\n' "$1"; WARN=$((WARN+1)); }
head_() { printf '\n\033[1m%s\033[0m\n' "$1"; }

head_ "Binaries"
for c in alacritty tmux zsh starship fzf zoxide eza batcat fdfind rg nvim lazygit btop direnv procs dust wl-copy grim slurp swaylock; do
  command -v "$c" >/dev/null && ok "$c" || bad "$c missing"
done
for c in wofi notify-send; do
  command -v "$c" >/dev/null && ok "$c" || warn "$c missing — run pi-desktop-setup"
done

head_ "Symlinks resolve into the repo"
for p in ~/.zshrc ~/.gitconfig ~/.config/alacritty ~/.config/tmux ~/.config/starship.toml \
         ~/.config/gtk-3.0 ~/.config/gtk-4.0 ~/.gtkrc-2.0 ~/.config/qt5ct ~/.config/qt6ct \
         ~/.config/labwc/themerc-override ~/.config/wf-panel-pi/panel.css \
         ~/.local/bin/screenshot.sh ~/.local/bin/lock.sh; do
  if [ -L "$p" ] && [ -e "$p" ]; then ok "$(basename "$p")"
  elif [ -e "$p" ];             then warn "$(basename "$p") exists but is not a symlink"
  else                               bad "$(basename "$p") missing/broken"; fi
done

head_ "Config files parse"
# zsh: interactive startup must emit no errors (zle warnings are expected without a TTY)
zerr=$(zsh -i -c 'exit' 2>&1 | grep -v "can't change option: zle" | head -3)
[ -z "$zerr" ] && ok "zsh startup clean" || bad "zsh errors: $zerr"

# alacritty: has a real config check
if alacritty --print-events --help >/dev/null 2>&1 || true; then
  aerr=$(timeout 10 alacritty migrate --dry-run -c ~/.config/alacritty/alacritty.toml 2>&1 | grep -iE "^error|parse|invalid" | head -2)
  [ -z "$aerr" ] && ok "alacritty.toml parses" || bad "alacritty: $aerr"
fi

# tmux: load the config in a throwaway server on its own socket, then kill it
if tmux -L cfgtest -f ~/.config/tmux/tmux.conf new-session -d -s t 2>/tmp/tmuxerr; then
  terr=$(grep -viE "tpm|plugin|clone" /tmp/tmuxerr | head -2)
  tmux -L cfgtest kill-server 2>/dev/null
  [ -z "$terr" ] && ok "tmux.conf loads" || warn "tmux: $terr"
else
  bad "tmux.conf failed: $(head -2 /tmp/tmuxerr)"
fi
rm -f /tmp/tmuxerr

# labwc: XML well-formedness
if command -v xmllint >/dev/null 2>&1; then
  xmllint --noout ~/.config/labwc/rc.xml 2>/dev/null && ok "rc.xml well-formed" || bad "rc.xml malformed"
else
  python3 -c "import xml.etree.ElementTree as E;E.parse('$HOME/.config/labwc/rc.xml')" 2>/dev/null \
    && ok "rc.xml well-formed" || bad "rc.xml malformed"
fi

head_ "Theming"
fc-list -f '%{family[0]}\n' 2>/dev/null | grep -qx "JetBrainsMono Nerd Font" \
  && ok "JetBrainsMono Nerd Font installed" || bad "Nerd Font missing"
grep -q "css_path" ~/.config/wf-panel-pi/wf-panel-pi.ini && ok "panel css_path set" || bad "panel css_path missing"
grep -q "cornerRadius" ~/.config/labwc/rc.xml && ok "labwc cornerRadius set" || bad "cornerRadius missing"
grep -q "Adwaita-dark" ~/.config/gtk-3.0/settings.ini && ok "GTK3 dark theme" || bad "GTK3 theme unset"
grep -q "Adwaita-dark" ~/.config/gtk-4.0/settings.ini && ok "GTK4 dark theme" || bad "GTK4 theme unset"

head_ "Keybind targets exist"
while read -r cmd; do
  [ -z "$cmd" ] && continue
  bin=${cmd%% *}
  if [ -x "$bin" ] || command -v "$bin" >/dev/null 2>&1; then ok "keybind -> $bin"
  else warn "keybind -> $bin NOT found"; fi
done < <(grep -oP '(?<=command=")[^"]+' ~/.config/labwc/rc.xml | sort -u)

head_ "Appliance still intact"
[ -f ~/.config/labwc/rc.xml ] && ! [ -L ~/.config/labwc/rc.xml ] && ok "rc.xml is a real file (not symlinked)" || bad "rc.xml symlinked — risky"
grep -q "Goodix" ~/.config/labwc/rc.xml && ok "touchscreen mapping present" || bad "touch mapping LOST"
grep -q "hdmi-panel.sh" ~/.config/kanshi/config && ok "kanshi panel exec wired" || bad "kanshi exec missing"
systemctl is-active --quiet screen-control && ok "screen-control service active" || warn "screen-control not active"
[ "$(pgrep -c -x wf-panel-pi)" = "1" ] && ok "exactly one panel running" || warn "$(pgrep -c -x wf-panel-pi) panels running"
pgrep -x squeekboard >/dev/null && bad "squeekboard running (should be disabled)" || ok "squeekboard not running"

printf '\n\033[1mResult: %d passed, %d failed, %d warnings\033[0m\n' "$PASS" "$FAIL" "$WARN"
exit "$FAIL"
