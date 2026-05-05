# zsh completion for mux
_mux() {
  local config_dirs="${MUX_CONFIG_DIRS:-${MUX_CONFIG_DIR:-$HOME/.config/mux:$HOME/.config/mux.local}}"

  local -a sessions configs
  local -A seen
  local dir

  sessions=(${(f)"$(tmux ls -F '#{session_name}' 2>/dev/null)"})

  for dir in ${(s.:.)config_dirs}; do
    [[ -d "$dir" ]] || continue
    for f in $dir/*.sh(N:t:r); do
      [[ -z "${seen[$f]+x}" ]] || continue
      seen[$f]=1
      configs+=($f)
    done
  done

  case $CURRENT in
    2)
      if [[ $words[2] == -* ]]; then
        _alternative 'flags:flag:((-l\:"list sessions and configs" --list\:"list sessions and configs" -k\:"kill a session" --kill\:"kill a session" -h\:"show help" --help\:"show help"))'
      else
        _alternative \
          'sessions:running session:($sessions)' \
          'configs:config:($configs)'
      fi
      ;;
    3)
      case $words[2] in
        -k|--kill)
          _alternative 'sessions:running session:($sessions)'
          ;;
      esac
      ;;
  esac
}

compdef _mux mux
