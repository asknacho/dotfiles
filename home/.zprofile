# Login-shell only. Runs once per session before .zshrc.

# Homebrew (static — equivalent to `eval "$(brew shellenv)"` but no subprocess)
export HOMEBREW_PREFIX="/opt/homebrew"
export HOMEBREW_CELLAR="/opt/homebrew/Cellar"
export HOMEBREW_REPOSITORY="/opt/homebrew"
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin${PATH+:$PATH}"
[ -z "${MANPATH-}" ] || export MANPATH=":${MANPATH#:}"
export INFOPATH="/opt/homebrew/share/info:${INFOPATH:-}"

# Local secrets (not tracked by homeshick)
[[ -f "$HOME/.zprofile.local" ]] && source "$HOME/.zprofile.local"
