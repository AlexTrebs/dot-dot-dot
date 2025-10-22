current_dir="$(tmux display-message -p -F "#{pane_current_path}")"
if tmux list-windows -a | grep -E -q '^[^:]+:[0-9]+:[[:space:]]+explorer[*-]?'; then
  # Extract the session name that has it
  session_name="$(tmux list-windows -a | grep -E '^[^:]+:[0-9]+:[[:space:]]+explorer[*-]?' | head -n1 | cut -d: -f1)"

  # Change its directory and switch to it
  tmux switch-client -t "$session_name"
  tmux select-window -t "${session_name}:explorer"
else
  # Create new explorer window in current session, current dir
  tmux new-window -n explorer -c "$current_dir" "~/.local/bin/tmux_explorer.sh"
fi
