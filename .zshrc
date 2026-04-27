# ~/.zshrc

[[ $- != *i* ]] && return

# ── History ───────────────────────────────────────────────────
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history
setopt HIST_IGNORE_DUPS HIST_IGNORE_SPACE SHARE_HISTORY APPEND_HISTORY

# ── Completion ────────────────────────────────────────────────
autoload -Uz compinit && compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# ── Options ───────────────────────────────────────────────────
setopt AUTO_CD
setopt CORRECT

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

# ── tmux ──────────────────────────────────────────────────────
alias t='tmux'
alias ta='tmux attach -t'
alias tn='tmux new -s'
alias tl='tmux list-sessions'

# ── Dotfiles ──────────────────────────────────────────────────
alias dots='cd ~/Workspace/dot-dot-dot'

# ── App fixes ─────────────────────────────────────────────────
alias pavucontrol='GDK_BACKEND=x11 pavucontrol'

# ── PATH ──────────────────────────────────────────────────────
export PATH="$HOME/.local/bin:$PATH"
export PATH="/home/alextrebs/.opencode/bin:$PATH"

# ── pnpm ──────────────────────────────────────────────────────
export PNPM_HOME="$HOME/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# ── nvm (lazy-loaded) ─────────────────────────────────────────
export NVM_DIR="$HOME/.nvm"
_nvm_load() {
  unfunction nvm node npm npx 2>/dev/null
  [ -s "/usr/share/nvm/init-nvm.sh" ] && source /usr/share/nvm/init-nvm.sh
  [ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
}
nvm()  { _nvm_load; nvm  "$@"; }
node() { _nvm_load; node "$@"; }
npm()  { _nvm_load; npm  "$@"; }
npx()  { _nvm_load; npx  "$@"; }

# ── Cargo ─────────────────────────────────────────────────────
[ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"

# ── fzf ───────────────────────────────────────────────────────
[ -f /usr/share/fzf/key-bindings.zsh ] && source /usr/share/fzf/key-bindings.zsh
[ -f /usr/share/fzf/completion.zsh ] && source /usr/share/fzf/completion.zsh

# ── Plugins (install with: sudo pacman -S zsh-autosuggestions zsh-syntax-highlighting) ──
[ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ] && \
  source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
[ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ] && \
  source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# ── Bun ───────────────────────────────────────────────────────
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# ── Starship ──────────────────────────────────────────────────
command -v starship &>/dev/null && eval "$(starship init zsh)"
