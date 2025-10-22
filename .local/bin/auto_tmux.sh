#!/bin/bash

TMUX_CONF="${XDG_CONFIG_HOME:-$HOME/.config}/tmux/tmux.conf"

if tmux ls 2>/dev/null | grep -q .; then
    tmux attach-session -t "$(tmux ls | head -n 1 | cut -d: -f1)" -f "$TMUX_CONF"
else
    tmux -f "$TMUX_CONF"
fi
