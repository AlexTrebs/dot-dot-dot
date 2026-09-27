#!/usr/bin/env bash
# Read-only health check for this setup. Changes nothing; exits 1 if any check fails.
# Each check is something that has actually broken before (see git log).
set -uo pipefail
cd "$(dirname "$0")" || exit 1
REPO="$PWD"

fails=0
ok()   { printf '  \e[32m✓\e[0m %s\n' "$1"; }
bad()  { printf '  \e[31m✗\e[0m %s\n' "$1"; [ -n "${2:-}" ] && printf '      %s\n' "$2"; fails=$((fails + 1)); }
skip() { printf '  \e[33m-\e[0m %s\n' "$1"; }
read_pkgs() { grep -vE '^[[:space:]]*(#|$)' "$1" | sed 's/[[:space:]]*#.*//'; }

echo "Repo"
missing_sub=$(git submodule status | grep '^-' | awk '{print $2}')
[ -z "$missing_sub" ] && ok "submodules checked out" || bad "submodules not checked out: $missing_sub" "git submodule update --init"
left=$(git grep -l 'hyprctl keyword' -- '*.sh' '*.lua' '*.toml' ':!doctor.sh' 2>/dev/null)
[ -z "$left" ] && ok "no 'hyprctl keyword' in scripts" || bad "'hyprctl keyword' is refused under hyprland.lua: $left" "use hyprctl eval 'hl.config({...})'"

echo "Packages"
installed=$(pacman -Qq | sort)
for list in pacman aur; do
    miss=$(comm -23 <(read_pkgs "packages/$list.txt" | sort -u) <(echo "$installed") | tr '\n' ' ')
    [ -z "$miss" ] && ok "$list.txt all installed" || bad "$list.txt missing: $miss" "./install.sh"
done

echo "Links"
loops=$(find ~/.config ~/.local -type l -printf '%p\t%l\n' 2>/dev/null | awk -F'\t' '$1 == $2 {print $1}')
[ -z "$loops" ] && ok "no self-looping symlinks" || bad "self-looping symlinks: $(wc -l <<< "$loops")" "delete them; first: $(head -1 <<< "$loops")"
dead=$(find ~/.config ~/.local -xtype l -lname "$REPO/*" 2>/dev/null)
[ -z "$dead" ] && ok "no dead links into the repo" || bad "dead links into the repo: $(wc -l <<< "$dead")" "./symlink_config.sh prunes them"

echo "/etc"
etc_bad=""
while IFS= read -r f; do
    t="/${f}"
    if [ ! -e "$t" ]; then etc_bad+=" $t(missing)"
    elif [ "$(stat -c %U:%G "$t")" != root:root ]; then etc_bad+=" $t(owner $(stat -c %U "$t"))"
    elif ! cmp -s "$f" "$t"; then etc_bad+=" $t(differs)"
    fi
done < <(git ls-files etc)
[ -z "$etc_bad" ] && ok "etc/ files installed, root-owned, unchanged" || bad "etc/ problems:$etc_bad" "./symlink_config.sh reinstalls them as root"

echo "Services"
for u in battery-listener.service claude-personality.timer; do
    systemctl --user is-enabled --quiet "$u" 2>/dev/null && ok "$u enabled" || bad "$u not enabled" "systemctl --user enable --now $u"
done

echo "Hyprland"
if [ -z "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]; then
    skip "not in a Hyprland session, skipped"
else
    errs=$(hyprctl configerrors | tr -d '\n')
    [ -z "$errs" ] && ok "no config errors" || bad "config errors: $errs"
    for p in hymission borders-plus-plus; do
        hyprctl plugin list | grep -q "^Plugin $p " && ok "plugin $p loaded" \
            || bad "plugin $p not loaded" "hyprpm update -f && hyprpm reload -n"
    done
    # This shell was started from Hyprland, so it shows what apps inherit
    miss_env=""
    for k in $(grep -hoE '^[A-Z_][A-Z0-9_]*' .config/environment.d/gpu.conf .config/environment.d/wayland.conf); do
        [ -n "${!k:-}" ] || miss_env+=" $k"
    done
    [ -z "$miss_env" ] && ok "environment.d vars reach apps" \
        || bad "env vars missing:$miss_env" "lua/env.lua loads environment.d; open a new terminal after hyprctl reload"
fi

echo
[ "$fails" -eq 0 ] && echo "All good." || echo "$fails problem(s)."
[ "$fails" -eq 0 ]
