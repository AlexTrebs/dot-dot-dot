#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# ── History ───────────────────────────────────────────────────
HISTSIZE=10000
HISTFILESIZE=20000
HISTCONTROL=ignoredups:erasedups
shopt -s histappend

# ── Prompt (starship overrides this if installed) ─────────────
PS1='\[\033[1;34m\]\w\[\033[0m\] $(git branch 2>/dev/null | grep "^*" | cut -c3-)\n\$ '

# ── Navigation ────────────────────────────────────────────────
alias ..='cd ..'
alias ...='cd ../..'
alias ll='ls -lah --color=auto'
alias ls='ls --color=auto'
alias grep='grep --color=auto'

# ── Git ───────────────────────────────────────────────────────
alias gs='git status'
alias gd='git diff'
alias gl='git log --oneline -20'

# ── tmux ─────────────────────────────────────────────────────
alias t='tmux'
alias ta='tmux attach -t'
alias tn='tmux new -s'
alias tl='tmux list-sessions'

# ── Dotfiles ─────────────────────────────────────────────────
alias dots='cd ~/Workspace/dot-dot-dot'

# ── App fixes ────────────────────────────────────────────────
alias pavucontrol='GDK_BACKEND=x11 pavucontrol'

# ── PATH ─────────────────────────────────────────────────────
export PATH="$HOME/.local/bin:$PATH"
export PATH="/home/alextrebs/.opencode/bin:$PATH"

# ── pnpm ─────────────────────────────────────────────────────
export PNPM_HOME="$HOME/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# ── nvm ──────────────────────────────────────────────────────
export NVM_DIR="$HOME/.nvm"
[ -s "/usr/share/nvm/init-nvm.sh" ] && source /usr/share/nvm/init-nvm.sh
[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && source "$NVM_DIR/bash_completion"

# ── Cargo ────────────────────────────────────────────────────
[ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"

# ── fzf ──────────────────────────────────────────────────────
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# ── Starship prompt (overrides PS1 above if installed) ───────
command -v starship &>/dev/null && eval "$(starship init bash)"
