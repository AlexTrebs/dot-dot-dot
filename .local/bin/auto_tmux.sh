#!/bin/bash

TMUX_CONF="${XDG_CONFIG_HOME:-$HOME/.config}/tmux/tmux.conf"

# Always create a new session in home directory
tmux -f "$TMUX_CONF" new-session -c "$HOME"
