#!/usr/bin/env bash
# Make archinstall.yaml's package list match packages/pacman.txt.
# pacman.txt is the source of truth. AUR packages (packages/aur.txt) never go in
# archinstall.yaml: archinstall only installs from the official repos.
set -euo pipefail
cd "$(dirname "$0")"

read_pkgs() { grep -vE '^[[:space:]]*(#|$)' "$1" | sed 's/[[:space:]]*#.*//' | sort -u; }

want=$(read_pkgs packages/pacman.txt)
aur=$(read_pkgs packages/aur.txt)
have=$(jq -r '.packages[]' archinstall.yaml | sort -u)

add=$(comm -23 <(echo "$want") <(echo "$have"))
drop=$(comm -13 <(echo "$want") <(echo "$have"))
drop_aur=$(comm -12 <(echo "$drop") <(echo "$aur"))
drop_other=$(comm -23 <(echo "$drop") <(echo "$aur"))

echo "pacman.txt: $(grep -c . <<< "$want") packages, archinstall.yaml: $(grep -c . <<< "$have")"
[ -n "$add" ]        && { echo; echo "Would add to archinstall.yaml:"; sed 's/^/  + /' <<< "$add"; }
[ -n "$drop_aur" ]   && { echo; echo "Would drop (AUR, archinstall cannot install these):"; sed 's/^/  - /' <<< "$drop_aur"; }
[ -n "$drop_other" ] && { echo; echo "Would drop (not in pacman.txt; add them there to keep them):"; sed 's/^/  - /' <<< "$drop_other"; }

if [ -z "$add$drop" ]; then
    echo "In sync."
    exit 0
fi

echo
read -rp "Rewrite archinstall.yaml packages from pacman.txt? [y/N] " ans
[[ "$ans" =~ ^[Yy]$ ]] || { echo "Unchanged."; exit 0; }

jq --argjson pkgs "$(jq -R -s 'split("\n") | map(select(length > 0))' <<< "$want")" \
    '.packages = $pkgs' archinstall.yaml > archinstall.yaml.tmp
mv archinstall.yaml.tmp archinstall.yaml
echo "archinstall.yaml updated."
