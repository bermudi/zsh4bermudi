# z4b — Personal Zsh Framework

Replace zsh4humans with a maintained, minimal personal zsh framework. No POSIX sh gymnastics, no tmux, no SSH teleportation, no vi mode. Just the daily-driver features bermudi actually uses.

## Why

z4h is in stewardship mode — bug fixes only, no new features. It's a monolithic 10K-line codebase with deep coupling to romkatv's style. z4b extracts the subset that gets used daily and modernizes the rest.

## Scope

### Core ZLE & Editing

- **Smart Enter** — inserts `\n` on parse error, executes otherwise (from `z4h-accept-line`)
- **Two-flavor word navigation** — shell words (Ctrl+arrow) + zsh tokenizer words (Ctrl+Shift+arrow). Copy z4h's `WORDCHARS=''` approach and boundary logic verbatim
- **Kill-word with ring accumulation** — `-z4h-move-and-kill` pattern: move cursor, extract killed text, accumulate in kill ring
- **Ctrl+Space expand** — expand alias/glob/parameter
- **Alt+O stash buffer** — push current line to ephemeral history (not saved to HISTFILE)
- **Alt+K kill-before-cursor, Alt+J kill-buffer** — quick line editing
- **Alt+M accept autosuggestion** — accept full ghost text

### Key Normalization & Binding

- **Cross-terminal key normalization** — map xterm/TTY/urxvt/iTerm2 keycodes to canonical form (no tmux needed)
- **Named key abstraction** — `z4b bindkey widget Ctrl+Backspace` with human-readable key names
- **Standard bindings** — Home/End/Delete, Ctrl+arrow word nav, Shift+arrow cd navigation, Ctrl+R fzf history, Tab fzf completion, Ctrl+L clear screen, undo/redo

### fzf Integration

- **Ctrl+R history search** — deduplicated history with bat preview, no screen save/restore (no tmux)
- **Tab → fzf completion** — first Tab completes common prefix, second Tab opens fzf with all matches. Adapt z4h's compadd interception (`z4h-fzf-complete` + shadow functions)
- **Alt+R directory history** — fzf over visited directories
- **Shift+Down cd into child** — fzf-powered child directory picker
- **Alt+Left/Right cd history** — pushd-based directory rotation
- **Shift+Up cd ..** — parent directory

### Plugins (wired up, not reimplemented)

- **zsh-syntax-highlighting** — with custom comment style (fg=96)
- **zsh-autosuggestions** — with z4h-style widget overrides for accept/partial-accept control. Right arrow accepts entire suggestion
- **zsh-history-substring-search** — with local/global history toggle
- **zsh-completions** — extra completion definitions
- **fzf** — binary + man pages, managed by z4b

### History

- `share_history` + infinite `HISTSIZE`/`SAVEHIST` — real-time history sharing across terminals
- **Local vs global history** — Up/Down searches local (per-session), Ctrl+Up/Down searches global
- `HISTFILE` at `~/.zsh_history`

### Completions Infrastructure

- Lazy compinit with dump caching (signature-based invalidation)
- `bashcompinit` for bash completion compat
- Language-specific completion wiring: cargo, gh, kubectl, helm, terraform, vault, gcloud, aws where installed
- `glob_dots` — dotfiles in completions
- `no_auto_menu` — require extra TAB for menu
- `ZLE_REMOVE_SUFFIX_CHARS=''` — don't eat space after `|` on tab-complete

### Prompt

- **Starship** — Rust binary, TOML config, maintained, all segments available
- z4b installs and initializes starship, user configures via `~/.config/starship.toml`
- No instant prompt (starship doesn't support it — acceptable tradeoff)

### Environment Setup

- `WORDCHARS=''` — foundation of word system
- `KEYTIMEOUT=20` — 200ms escape key lag
- Homebrew detection (Linux + macOS)
- PATH/fpath/manpath/infopath setup
- Locale fix (enforce UTF-8)
- Terminal title — running command while executing, cwd when idle
- `LS_COLORS` / `LSCOLORS` setup
- Default `LESS` options (`-iRFXMx4`)
- Default `PAGER=less`
- `DIRSTACKSIZE=10000`

### Package Management

- `z4b install user/repo` — clone from GitHub, optional postinstall hooks
- Core plugins (syntax-highlighting, autosuggestions, fzf, etc.) managed automatically
- `z4b update` — update all installed plugins + self

### Bootstrap / Install

- zsh script (not POSIX sh). Requires zsh + git + curl/wget
- Clones repo to `~/.cache/zsh4bermudi/`
- Writes `~/.zshenv` (minimal — sets `Z4B_ROOT`, sources bootstrap)
- Creates `~/.zshrc` from template if none exists
- User sources `~/.shrc` and `~/.env.zsh` in their `.zshrc` after `z4b init`

### Configuration

- `.zshrc` with function calls — no zstyle
- `z4b install` calls must come **before** `z4b init` — init is the point where I/O stops and plugins get wired up
- User sources `~/.env.zsh` and `~/.shrc` themselves after init, so they control ordering
- Example:

```zsh
# Install extra plugins (core plugins are auto-installed by init)
# z4b install user/some-plugin

# Initialize everything (installs core plugins if missing, sets up env, ZLE, completion, starship)
z4b init || return

# Key bindings
z4b bindkey z4b-backward-kill-word  Ctrl+Backspace
z4b bindkey z4b-backward-kill-zword Ctrl+Alt+Backspace
z4b bindkey undo Ctrl+/ Shift+Tab
z4b bindkey redo Alt+/

# User options
setopt glob_dots
setopt no_auto_menu

# User env and aliases
[ -f ~/.env.zsh ] && source ~/.env.zsh
[ -f ~/.shrc ] && source ~/.shrc
```

## Explicitly Out of Scope

- SSH teleportation
- tmux integration / screen save/restore
- iTerm2 shell integration
- WSL support
- direnv integration
- vi mode
- POSIX sh bootstrap
- Numeric prefix support on word widgets
- Oh My Zsh

## Architecture

```
~/.cache/zsh4bermudi/
  z4b.zsh              # bootstrap (sourced by .zshenv)
  main.zsh             # core init, environment setup, plugin wiring
  fn/                   # autoloaded functions
    z4b-forward-word
    z4b-backward-word
    z4b-forward-zword
    z4b-backward-zword
    z4b-move-and-kill
    z4b-accept-line
    z4b-fzf-history
    z4b-fzf-complete
    z4b-fzf-dir-history
    z4b-cd-down
    z4b-cd-back / z4b-cd-forward / z4b-cd-up
    z4b-stash-buffer
    z4b-expand
    ...
  init-zle.zsh         # key normalization, bindkey setup, ZLE widgets
  install.zsh          # package management (install, update)
  setup.zsh            # bootstrap/install script

~/.zshenv              # minimal: sets Z4B_ROOT, sources z4b.zsh
~/.zshrc               # user config: z4b calls, aliases, functions
~/.shrc                # shell-agnostic aliases/functions (sourced by user in .zshrc)
~/.env.zsh             # zsh-specific env vars (sourced by user in .zshrc)
~/.config/starship.toml # prompt config
```

## Startup Order

1. `.zshenv` — set `Z4B_ROOT`, source `z4b.zsh`
2. `z4b.zsh` — set options, bindkeys (recovery mode), check/bootstrap `Z4B_ROOT`
3. `.zshrc` — user calls `z4b init`, `z4b install`, `z4b bindkey`, etc.
4. `z4b init` — install core plugins, set up environment, initialize ZLE, wire up completion, init starship **last** (it sets PROMPT and precmd/preexec hooks)
5. `.zshrc` continues — user bindkeys, options, aliases, source `~/.env.zsh`, source `~/.shrc`

## Source

Primary reference: zsh4humans v5 (`../zsh4humans/`). Large portions of word navigation, fzf-complete, and ZLE initialization will be adapted directly from z4h code with renaming and cleanup.

## Open Questions

None remaining. All resolved through grilling session.
