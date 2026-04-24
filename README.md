# dotfiles

Personal dotfiles managed with [homeshick](https://github.com/andsens/homeshick).

## What's here

- **Shell**: `.zshrc`, `.zprofile`, `.bash_profile`, `.bashrc`, `.profile`
- **Git**: `.gitconfig`, `.gitignore` (the global one used by git)
- **`~/.config/nvim`**: Neovim config
- **`~/.config/tmux`**: tmux config
- **`~/.config/mux`**: `mux` session manager configs
- **`~/.config/opencode`**: opencode config, agents, skills
- **`~/.local/bin`**: custom scripts (`mux`, `oc`, `awshelp`, `spike`, `from_ts`, `to_ts`, `env`, `env.fish`, `_opencode_common.sh`)

## Install on a new machine

```sh
git clone https://github.com/andsens/homeshick.git ~/.homesick/repos/homeshick
git clone <this-repo-url> ~/.homesick/repos/dotfiles
~/.homesick/repos/homeshick/bin/homeshick link dotfiles
```

Then add to your shell rc (the castle's `.zshrc` already does this):

```sh
source "$HOME/.homesick/repos/homeshick/homeshick.sh"
```

## Common commands

```sh
homeshick list              # show all castles
homeshick check             # any castle updates upstream?
homeshick pull              # update all castles
homeshick link              # create/refresh symlinks
homeshick track dotfiles <file>   # start tracking a new file
homeshick cd dotfiles       # jump into the castle repo
```
