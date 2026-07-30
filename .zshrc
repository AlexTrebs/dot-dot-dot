# ~/.zshrc  —  Raspberry Pi OS (Debian Trixie) edition
#
# Ported from the Arch branch. Debian differences are marked [debian]:
#   - zsh plugins live in /usr/share/<plugin>/, not /usr/share/zsh/plugins/<plugin>/
#   - fzf shell integration ships under /usr/share/doc/fzf/examples/
#   - bat and fd are renamed to batcat / fdfind (binary name clashes)
#   - zsh-history-substring-search and zsh-you-should-use aren't packaged,
#     so they're vendored into ~/.local/share/zsh/plugins/

export PATH="$PATH:$HOME/.dotnet/tools"

[[ $- != *i* ]] && return

export EDITOR=nvim
export VISUAL=nvim

# ── History ───────────────────────────────────────────────────
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history
setopt HIST_IGNORE_DUPS HIST_IGNORE_SPACE HIST_EXPIRE_DUPS_FIRST SHARE_HISTORY APPEND_HISTORY

# ── Completion ────────────────────────────────────────────────
autoload -Uz compinit
[[ ~/.zcompdump(#qN.mh+24) ]] && compinit || compinit -C
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# ── Options ───────────────────────────────────────────────────
setopt AUTO_CD
setopt CORRECT

# ── Navigation ────────────────────────────────────────────────
alias ..='cd ..'
alias ...='cd ../..'
if command -v eza &>/dev/null; then
  alias ls='eza --color=auto --group-directories-first'
  alias ll='eza -lah --color=auto --group-directories-first'
  alias lt='eza --tree --color=auto'
else
  alias ls='ls --color=auto'
  alias ll='ls -lah --color=auto'
fi
alias grep='grep --color=auto'

# [debian] Debian renames these binaries to avoid clashes; alias them back so
# muscle memory (and anything expecting `bat`/`fd`) keeps working.
command -v batcat &>/dev/null && alias bat='batcat'
command -v fdfind &>/dev/null && alias fd='fdfind'

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
# [debian] cloned to ~/dot-dot-dot on this box, not ~/Workspace/dot-dot-dot
alias dots='cd ~/dot-dot-dot'

# ── Pi appliance ──────────────────────────────────────────────
alias screenctl='sudo systemctl restart screen-control'
alias kiosklog='journalctl -u screen-control -f'

# ── PATH ──────────────────────────────────────────────────────
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/bin:$PATH"
export PATH="$HOME/.opencode/bin:$PATH"

# ── pnpm ──────────────────────────────────────────────────────
export PNPM_HOME="$HOME/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# ── nvm (lazy-loaded) ─────────────────────────────────────────
# [debian] no /usr/share/nvm package; uses the git-installed $NVM_DIR only
export NVM_DIR="$HOME/.nvm"
_nvm_load() {
  unfunction nvm node npm npx 2>/dev/null
  [ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
}
nvm()  { _nvm_load; nvm  "$@"; }
node() { _nvm_load; node "$@"; }
npm()  { _nvm_load; npm  "$@"; }
npx()  { _nvm_load; npx  "$@"; }

# ── Cargo ─────────────────────────────────────────────────────
[ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"

# ── fzf ───────────────────────────────────────────────────────
# [debian] shipped under /usr/share/doc/fzf/examples/ instead of /usr/share/fzf/
[ -f /usr/share/doc/fzf/examples/key-bindings.zsh ] && \
  source /usr/share/doc/fzf/examples/key-bindings.zsh
[ -f /usr/share/doc/fzf/examples/completion.zsh ] && \
  source /usr/share/doc/fzf/examples/completion.zsh

# ── Plugins ───────────────────────────────────────────────────
# [debian] apt-packaged plugins sit directly in /usr/share/<name>/
[ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ] && \
  source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# [debian] vendored — not in Debian's archive
ZSH_VENDOR="$HOME/.local/share/zsh/plugins"
if [ -f "$ZSH_VENDOR/zsh-history-substring-search/zsh-history-substring-search.zsh" ]; then
  source "$ZSH_VENDOR/zsh-history-substring-search/zsh-history-substring-search.zsh"
  bindkey '^[[A' history-substring-search-up
  bindkey '^[[B' history-substring-search-down
fi
[ -f "$ZSH_VENDOR/zsh-you-should-use/you-should-use.plugin.zsh" ] && \
  source "$ZSH_VENDOR/zsh-you-should-use/you-should-use.plugin.zsh"

# syntax-highlighting must be sourced LAST of the plugins
[ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ] && \
  source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# ── Bun ───────────────────────────────────────────────────────
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# ── Direnv (per-directory env vars) ──────────────────────────
command -v direnv &>/dev/null && eval "$(direnv hook zsh)"

# ── Zoxide (smart cd) ─────────────────────────────────────────
command -v zoxide &>/dev/null && eval "$(zoxide init zsh)"

# ── Starship ──────────────────────────────────────────────────
command -v starship &>/dev/null && eval "$(starship init zsh)"
