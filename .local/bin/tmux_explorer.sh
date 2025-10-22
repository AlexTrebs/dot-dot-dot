#!/usr/bin/env bash
# tmux-folder-explorer — unified version with reusable session logic

set -euo pipefail

# ────────────────────────────────
# CONFIG
# ────────────────────────────────
CONFIG_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/tmux-folder-explorer.conf"
[[ -f "$CONFIG_FILE" ]] && source "$CONFIG_FILE"

BASE_DIR="${BASE_DIR:-$HOME}"
SHOW_HIDDEN="${SHOW_HIDDEN:-true}"
TMUX_BIN="${TMUX_BIN:-tmux}"

# ────────────────────────────────
# HELPERS
# ────────────────────────────────
list_entries() {
  local current_dir="$1"
  current_dir="$(realpath -m "$current_dir")"

  local entries
  if command -v fd >/dev/null 2>&1; then
    entries=$(fd -a '' "$current_dir" \
      --max-depth 1 \
      --hidden \
      --no-ignore \
      --color never)
  else
    entries=$(find "$current_dir" -mindepth 1 -maxdepth 1 -print 2>/dev/null)
  fi

  entries=$(echo "$entries" | grep -v "^$current_dir$" || true)

  if [[ "$current_dir" == "$BASE_DIR"* ]]; then
    while IFS= read -r e; do
      [[ -z "$e" ]] && continue
      echo "${e#$BASE_DIR/}"
    done <<<"$entries"
  else
    echo "$entries"
  fi
}

preview_entry() {
  local path="$1"
  [[ "$path" != /* ]] && path="$BASE_DIR/$path"
  if [[ -d "$path" ]]; then
    local entries
    if command -v fd >/dev/null 2>&1; then
      entries=$(fd -a '' "$path" --max-depth 1 --hidden --no-ignore --color never)
    else
      entries=$(find "$path" -mindepth 1 -maxdepth 1 -print 2>/dev/null)
    fi
    [[ -z "$entries" ]] && { echo "(empty folder)"; return; }
    while IFS= read -r entry; do
      [[ -z "$entry" ]] && continue
      if [[ -d "$entry" ]]; then
        printf "%s/\n" "$(basename "$entry")"
      else
        printf "%s\n" "$(basename "$entry")"
      fi
    done <<<"$entries" | sort
  else
    bat --color=always --style=plain --line-range=:200 "$path" 2>/dev/null || head -200 "$path"
  fi
}

# ────────────────────────────────
# SHARED TMUX LOGIC
# ────────────────────────────────
open_in_tmux() {
  local target="$1"
  target="$BASE_DIR/$target"
  target="$(realpath -m "$target")"

  local target_dir session
  if [[ -d "$target" ]]; then
    target_dir="$target"
  else
    target_dir="$(dirname "$target")"
  fi

  session="$(basename "$target_dir")"
  session="${session//./_}"
  session="${session// /_}"

  # inside tmux: avoid nesting
  if [[ -n "${TMUX:-}" ]]; then
    if $TMUX_BIN has-session -t "$session" 2>/dev/null; then
      $TMUX_BIN switch-client -t "$session"
    else
      $TMUX_BIN new-session -ds "$session" -c "$target_dir"
      $TMUX_BIN switch-client -t "$session"
    fi
  else
    $TMUX_BIN new-session -A -s "$session" -c "$target_dir"
  fi

  # if it's a file → open it in nvim
  if [[ -f "$target" ]]; then
    $TMUX_BIN send-keys -t "$session" "nvim '$target'" C-m
  fi
}

# ────────────────────────────────
# ACTIONS
# ────────────────────────────────
LEFT() {
  local parent
  parent="$(dirname "$current_dir")"
  parent="$(realpath -m "$parent")"

  current_dir="$parent"
}

RIGHT() {
  [[ -z "$selection" ]] && return
  local path="$selection"
  [[ "$path" != /* ]] && path="$BASE_DIR/$path"
  [[ -d "$path" ]] && current_dir="$path"
}

ENTER() {
  open_in_tmux "$selection"
}

FILES() {
  local file
  file=$(fd -t f --hidden --no-ignore --color never . "$current_dir" |
         fzf --ansi --reverse --header "📄 Fuzzy find file in: $current_dir" \
             --preview 'bat --color=always --style=plain --line-range=:200 {} 2>/dev/null || head -200 {}')
  [[ -z "$file" ]] && return
  open_in_tmux "$file"
}

GREP() {
  local term file line
  read -rp "🔍 Search term: " term
  [[ -z "$term" ]] && return

  IFS=: read -r file line _ < <(
    rg --hidden --no-ignore --color=always -n "$term" "$current_dir" 2>/dev/null |
    fzf --ansi --delimiter : \
        --header "Matches for '$term' in $current_dir" \
        --preview 'bat --style=plain --color=always --highlight-line {2} {1} 2>/dev/null || head -200 {1}'
  )
  [[ -z "$file" ]] && return

  open_in_tmux "$file"
  [[ -n "$line" ]] && $TMUX_BIN send-keys ":+$line" C-m
}

# ────────────────────────────────
# MAIN LOOP
# ────────────────────────────────
explore() {
  current_dir="$(pwd)"

  export -f preview_entry
  export current_dir BASE_DIR

  while true; do
    mapfile -t out < <(
      list_entries "$current_dir" |
      fzf --ansi --reverse \
          --expect=right,left,enter,ctrl-f,ctrl-g \
          --header "📁 $current_dir — [→] enter | [←] up | [Enter] open | [Ctrl+F] fuzzy | [Ctrl+G] grep" \
          --preview "bash -c 'preview_entry {}'" \
          --preview-window=right:50%:wrap
    ) || break

    key="${out[0]}"
    selection="${out[1]}"

    case "$key" in
      right) RIGHT ;;
      left)  LEFT ;;
      enter) ENTER ;;
      ctrl-f) FILES ;;
      ctrl-g) GREP ;;
      *) [[ -n "$selection" && -d "$selection" ]] && current_dir="$selection" ;;
    esac
  done
}

explore
