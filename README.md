# dotfiles

Personal dotfiles managed with [homeshick](https://github.com/andsens/homeshick).

Repo: [git@github.com:asknacho/dotfiles.git](https://github.com/asknacho/dotfiles)

## Install on a new machine

One-liner:

```sh
curl -fsSL https://raw.githubusercontent.com/asknacho/dotfiles/main/bin/install | bash
```

Or, after cloning manually:

```sh
git clone git@github.com:asknacho/dotfiles.git ~/.homesick/repos/dotfiles
bash ~/.homesick/repos/dotfiles/bin/install
```

### What `bin/install` does

1. Verifies `git` and `curl` are available (mandatory)
2. Installs [homeshick](https://github.com/andsens/homeshick) under `~/.homesick/repos/homeshick`
3. Clones (or pulls) the dotfiles castle and force-links it into `$HOME`
4. Optionally clones + links a private **secrets castle** (see below)
5. On macOS, runs `brew bundle` against the repo's `Brewfile` (and the secrets castle's `Brewfile`, if present)
6. Warns about missing optional tools (`nvim`, `tmux`, `fzf`, `ripgrep`, `mise`, `direnv`, `tree-sitter`)
7. Leaves tmux (TPM) and Neovim (lazy.nvim) plugin install to first launch — both bootstrap themselves

The script is idempotent: re-run any time to pull the latest castle content, re-link, and re-bundle brew packages.

### Flags

```sh
bin/install --with-secrets git@github.com:asknacho/dotfiles-secrets.git
bin/install --skip-brew                          # don't run brew bundle
bin/install --help
```

### Private secrets castle

Anything machine-specific or work-confidential lives in a **separate private homeshick castle** — never in this repo.

A typical secrets castle ships:

- `home/.zprofile.local` — login-shell env (work CA bundles, VPN flags, work-only PATHs)
- `home/.zshrc.local` — interactive-shell env (work aliases, exports like `EJSON_KEYDIR`, `OPENCODE_CONFIG=...`)
- `home/.gitconfig.local` — work email, `http.sslCAInfo`, `safe.directory` entries (this repo's `.gitconfig` does `[include] path = ~/.gitconfig.local`)
- `home/.config/opencode/opencode.secrets.json` — work-specific opencode providers + MCP servers; activated by exporting `OPENCODE_CONFIG=$HOME/.config/opencode/opencode.secrets.json` from `.zshrc.local` (opencode deep-merges it on top of the public `opencode.json`)
- `home/.config/mux.local/<project>.sh` — work-specific mux session layouts (picked up automatically, see [mux config discovery](#mux))
- `Brewfile` — work-specific brew packages (run automatically by `bin/install`)

Bootstrap with both castles:

```sh
bash bin/install --with-secrets git@github.com:asknacho/dotfiles-secrets.git
```

### Common homeshick commands

```sh
homeshick list                    # list all castles
homeshick check                   # check for upstream updates
homeshick pull                    # pull latest from all castles
homeshick link                    # (re)create symlinks
homeshick track dotfiles <file>   # start tracking a new file
homeshick cd dotfiles             # jump into the castle repo
```

## What's configured

### Shell (zsh)

Two files, `.zprofile` (login) and `.zshrc` (interactive). No oh-my-zsh.

**`.zprofile`** — runs once per login session:
- Static Homebrew env (faster than `eval "$(brew shellenv)"` — no subprocess)
- Sources `~/.zprofile.local` if present (secrets castle hook)

**`.zshrc`** — runs every interactive shell:
- History tuning (50k entries, dedup, shared across sessions)
- Cached `compinit` (regenerates once per day for fast startup)
- `vcs_info`-based prompt with git branch + dirty indicators
- Curated git aliases (the commonly-used subset of oh-my-zsh's git plugin: `g`, `ga`, `gc`, `gcb`, `gco`, `gd`, `gst`, `gpsup`, `glog`, ...)
- `direnv` and `mise` (shims mode) hooks
- PATH wiring for Homebrew Ruby, `~/.local/bin`, opencode
- Sources `~/.zshrc.local` at the end if present (secrets castle hook)

### Git (`.gitconfig`, `.gitignore`)

Global git config and the global gitignore. The public `.gitconfig` only sets `user.name` and `push.autoSetupRemote`, then `[include]`s `~/.gitconfig.local` for the email, `http.sslCAInfo`, and any `safe.directory` entries (shipped via the secrets castle).

### Neovim (`~/.config/nvim`)

Lua config built on [lazy.nvim](https://github.com/folke/lazy.nvim). Plugins include:

- **LSP & completion**: `lsp.lua`, `cmp.lua`, GitHub Copilot
- **Navigation**: telescope, oil, nerdtree, aerial, vim-tmux-navigator
- **Git**: fugitive, gitsigns
- **Editing**: nerdcommenter, abolish, vim-argwrap, indent-blankline, treesitter, undotree
- **Testing**: vim-test + vimux
- **UI**: gruvbox theme, noice, which-key, render-markdown, markdown-preview
- **AI**: opencode.nvim integration

lazy.nvim self-installs on first `nvim` launch.

### tmux (`~/.config/tmux`)

- Prefix remapped to `C-Space`, vi mode in copy
- Mouse + scroll-wheel auto copy-mode
- Splits/new windows inherit current pane's CWD (`|`, `_`, `c`)
- TPM-managed plugins: `tmux-yank`, `tmux-sessionist`, `tmux-logging`, `vim-tmux-navigator`, `tmux-paste-image`
- Popup bindings:
  - `prefix m` → `mux` session picker
  - `prefix N` → `spike` (dated scratch workspace)
  - `prefix t` → session tree

TPM self-installs on first `tmux` launch.

### opencode (`~/.config/opencode`)

`opencode.json`, `oh-my-openagent.json`, `AGENTS.md` (global rules), and a `skills/` library covering: `caveman`, `datadog`, `diagnose`, `elixir-test-coverage-quality`, `git-review-deepdiff`, `git-rewrite-reviewable`, `grill-me`, `grill-with-docs`, `improve-codebase-architecture`, `kafka`, `refactor`, `streaming-tracking-architecture-reasoner`, `tdd`, `ubiquitous-language`, `write-a-skill`, `zoom-out`.

Public `opencode.json` ships only generic plugins + MCP servers (`github`, `datadog`, `playwright`). Work-specific providers (LiteLLM proxy, model catalogs) and MCP servers (Atlassian, internal tools) live in `~/.config/opencode/opencode.secrets.json` shipped by the secrets castle, activated via `OPENCODE_CONFIG` (set in `.zshrc.local`). opencode deep-merges the two files.

### Custom scripts (`~/.local/bin`)

- **`oc`** — opencode shared-server ergonomics wrapper
- **`awshelp`** — AWS DB + Kubernetes utility helper
- **`spike`** — creates a dated scratch workspace and opens it
- **`from_ts` / `to_ts`** — unix timestamp ↔ ISO 8601 conversion
- **`_opencode_common.sh`** — shared helpers sourced by opencode scripts

## mux

`mux` reads session configs from a colon-separated list of directories, searched in order:

```sh
MUX_CONFIG_DIRS="$HOME/.config/mux:$HOME/.config/mux.local"   # default
```

This means:

- **`~/.config/mux/`** ships in this repo — generic, shareable layouts
- **`~/.config/mux.local/`** ships in the **secrets castle** — work/private layouts

The first matching `<name>.sh` wins, so a `mux.local/` config can override a public one if needed. `MUX_CONFIG_DIR` (singular, legacy) is still honored if set.

The configs that live in this public repo:

- `dotfiles.sh` — vim + opencode at `~/.homesick/repos`
- `workspace.sh` — vim + opencode at `~/Developer`
- `showoff.sh` — fun synchronized-panes layout running `genact`
