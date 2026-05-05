# ===========================================================
# History
# ===========================================================
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=10000
setopt extended_history       # record timestamp of command
setopt hist_expire_dups_first # delete duplicates first when HISTFILE exceeds HISTSIZE
setopt hist_ignore_dups       # ignore duplicated commands
setopt hist_ignore_space      # ignore commands that start with space
setopt hist_verify            # show command with history expansion before running
setopt share_history          # share history across all sessions

# ===========================================================
# Completion (cached — only regenerates once per day)
# ===========================================================
autoload -Uz compinit
if [[ -f ~/.zcompdump && $(date +'%j') == $(stat -f '%Sm' -t '%j' ~/.zcompdump 2>/dev/null) ]]; then
  compinit -C          # skip security check, use cache
else
  compinit             # full rebuild
fi

zmodload -i zsh/complist
autoload -U +X bashcompinit && bashcompinit

unsetopt menu_complete   # do not autoselect the first completion entry
unsetopt flowcontrol
setopt auto_menu         # show completion menu on successive tab press
setopt complete_in_word
setopt always_to_end

zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache
zstyle ':completion:*:*:*:*:*' menu select
zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' special-dirs true
zstyle ':completion:*' list-colors ''

# ===========================================================
# Key bindings
# ===========================================================
bindkey -e  # emacs mode

# Up/Down arrow: type partial command then filter history
autoload -U up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey '^[[A' up-line-or-beginning-search    # Up
bindkey '^[[B' down-line-or-beginning-search  # Down
if [[ -n "${terminfo[kcuu1]}" ]]; then
  bindkey "${terminfo[kcuu1]}" up-line-or-beginning-search
fi
if [[ -n "${terminfo[kcud1]}" ]]; then
  bindkey "${terminfo[kcud1]}" down-line-or-beginning-search
fi

# Home/End
[[ -n "${terminfo[khome]}" ]] && bindkey "${terminfo[khome]}" beginning-of-line
[[ -n "${terminfo[kend]}" ]]  && bindkey "${terminfo[kend]}"  end-of-line

# Shift-Tab: reverse menu
[[ -n "${terminfo[kcbt]}" ]] && bindkey "${terminfo[kcbt]}" reverse-menu-complete

# Delete
bindkey '^?' backward-delete-char
[[ -n "${terminfo[kdch1]}" ]] && bindkey "${terminfo[kdch1]}" delete-char

# Ctrl-Arrow word navigation
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word

# Ctrl-R history search
bindkey '^r' history-incremental-search-backward

# ===========================================================
# Prompt (robbyrussell-style via built-in vcs_info)
# ===========================================================
autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' stagedstr '%F{yellow}✗%f'
zstyle ':vcs_info:*' unstagedstr '%F{yellow}✗%f'
zstyle ':vcs_info:git:*' formats '%F{blue}git:(%F{red}%b%F{blue})%f %m%u%c'
zstyle ':vcs_info:git:*' actionformats '%F{blue}git:(%F{red}%b|%a%F{blue})%f %m%u%c'

precmd() { vcs_info }
setopt prompt_subst
PROMPT='%(?:%F{green}➜ :%F{red}➜ ) %F{cyan}%c%f ${vcs_info_msg_0_} '

# ===========================================================
# Git aliases (commonly used subset from oh-my-zsh git plugin)
# ===========================================================
alias g='git'
alias ga='git add'
alias gaa='git add --all'
alias gb='git branch'
alias gba='git branch --all'
alias gbd='git branch --delete'
alias gbD='git branch --delete --force'
alias gc='git commit --verbose'
alias gc!='git commit --verbose --amend'
alias gca='git commit --verbose --all'
alias gcam='git commit --all --message'
alias gcb='git checkout -b'
alias gcm='git checkout $(git_main_branch)'
alias gco='git checkout'
alias gcp='git cherry-pick'
alias gd='git diff'
alias gds='git diff --staged'
alias gf='git fetch'
alias gfa='git fetch --all --prune'
alias gl='git pull'
alias glg='git log --stat'
alias glog='git log --oneline --decorate --graph'
alias gm='git merge'
alias gp='git push'
alias gpf='git push --force-with-lease'
alias gpsup='git push --set-upstream origin $(git_current_branch)'
alias gr='git remote'
alias grb='git rebase'
alias grbi='git rebase --interactive'
alias grhh='git reset --hard'
alias gst='git status'
alias gss='git status --short'
alias gsta='git stash push'
alias gstp='git stash pop'
alias gstl='git stash list'
alias gsw='git switch'
alias gswc='git switch --create'

# Helper functions used by aliases above
git_current_branch() { git symbolic-ref --quiet --short HEAD 2>/dev/null }
git_main_branch() {
  local ref
  for ref in refs/heads/main refs/heads/master refs/remotes/origin/HEAD; do
    if git show-ref -q --verify "$ref" 2>/dev/null; then
      echo "${ref##*/}"
      return 0
    fi
  done
  echo main
}

# ===========================================================
# PATH
# ===========================================================
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
export PATH="$HOME/.opencode/bin:$PATH"

# ===========================================================
# Tool hooks
# ===========================================================
eval "$(direnv hook zsh)"

# mise — shims mode (near-instant, no eval hook)
export PATH="$HOME/.local/bin:$HOME/.local/share/mise/shims:$PATH"

# ===========================================================
# Aliases
# ===========================================================
source "$HOME/.local/bin/mux.zsh" 2>/dev/null || true

alias oc="$HOME/.local/bin/oc"

# ===========================================================
# homeshick — dotfile castle management
# ===========================================================
if [[ -f "$HOME/.homesick/repos/homeshick/homeshick.sh" ]]; then
  source "$HOME/.homesick/repos/homeshick/homeshick.sh"
  fpath=("$HOME/.homesick/repos/homeshick/completions" $fpath)
fi

# ===========================================================
# Local secrets (not tracked by homeshick)
# ===========================================================
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"
