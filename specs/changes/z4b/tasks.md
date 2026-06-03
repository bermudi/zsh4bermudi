# z4b Tasks

## Phase 1: Bootstrap Skeleton

Create the minimum viable startup chain: `.zshenv` → `z4b.zsh` → `.zshrc` → `z4b init` that gets you to a basic prompt. Plugin install, ZLE, completions, and starship are stubs at this phase.

- [x] Create `z4b.zsh` — bootstrap loader that sets `WORDCHARS=''`, `KEYTIMEOUT=20`, essential options, validates `Z4B_ROOT`, provides recovery prompt on failure
- [x] Create `main.zsh` — `z4b init` function that loads zsh modules, sets up fpath/PATH (Homebrew detection), autoloading, and basic environment variables (LESS, PAGER, LS_COLORS, DIRSTACKSIZE, VIRTUAL_ENV_DISABLE_PROMPT, COLORTERM). Plugin install, ZLE, completions, and starship are stubbed as no-ops at this phase
- [x] Create `setup.zsh` — installer script that clones repo to `~/.cache/zsh4bermudi/`, writes `~/.zshenv`, creates `~/.zshrc` from template. Checks for zsh, git, curl/wget with clear error messages
- [x] Create `.zshrc` template with `z4b init || return` and placeholder sections
- [x] Verify: `Z4B_ROOT` is set and `z4b.zsh` sources without error. `z4b init` reaches a basic prompt (starship stubbed) without errors

## Phase 2: Package Management

- [x] Create `fn/-z4b-install-one` — clone a single GitHub repo to `$Z4B_ROOT/owner/repo/`, adapted from z4h's `-z4h-install-one`
- [x] Create `fn/-z4b-install-many` — batch install from queue, adapted from z4h's `-z4h-install-many`
- [x] Create `z4b install` command — `z4b install owner/repo` queues and installs
- [x] Create `z4b load` command — add plugin's functions to fpath, autoload, source init file (adapt from z4h's `-z4h-cmd-load`)
- [x] Create `z4b source` command — source a file with optional compilation (adapt from z4h's `-z4h-cmd-source`)
- [x] Create `z4b update` command — `git pull` for z4b + all installed plugins
- [x] Verify: `z4b install zsh-users/zsh-syntax-highlighting` clones the repo, `z4b load zsh-users/zsh-completions` sources it, and `z4b update` updates it

## Phase 3: Core ZLE Widgets

Port the two-flavor word navigation, kill-word, smart enter, and QoL widgets.

- [x] Create `fn/z4b-forward-word` — shell word forward (adapt from z4h's `fn/z4h-forward-word`)
- [x] Create `fn/z4b-backward-word` — shell word backward (adapt from z4h's `fn/z4h-backward-word`)
- [x] Create `fn/z4b-forward-zword` — tokenizer word forward (adapt from z4h's `fn/z4h-forward-zword`)
- [x] Create `fn/z4b-backward-zword` — tokenizer word backward (adapt from z4h's `fn/z4h-backward-zword`)
- [x] Create `fn/-z4b-move-and-kill` — kill-word engine: move cursor via widget arg, extract killed text, accumulate in kill ring (adapt from z4h)
- [x] Create `fn/z4b-kill-word` — ZLE widget wrapper that calls `-z4b-move-and-kill z4b-forward-word`
- [x] Create `fn/z4b-backward-kill-word` — ZLE widget wrapper that calls `-z4b-move-and-kill z4b-backward-word`
- [x] Create `fn/z4b-accept-line` — smart enter (adapt from z4h)
- [x] Create `fn/-z4b-is-valid-list` — parse validation helper (adapt from z4h)
- [x] Create `fn/z4b-expand` — expand alias/glob/parameter
- [x] Create `fn/z4b-stash-buffer` — ephemeral history stash
- [x] Create helper functions: `-z4b-get-cursor-pos`, `-z4b-prompt-length`, `-z4b-redraw-buffer`, `-z4b-redraw-prompt`, `-z4b-string-diff` (diff two strings for completion prefix matching)
- [x] Verify: Ctrl+Left/Right jumps by shell words, Ctrl+Shift+Left/Right by tokenizer words, Ctrl+W accumulates kill ring, Enter inserts newline on parse error

## Phase 4: Key Normalization and Bindings

- [x] Create `init-zle.zsh` — key normalization (xterm/TTY/urxvt/iTerm2 → canonical), ZLE widget registration, default bindkeys, named key map (adapt from z4h's `fn/-z4h-init-zle`, strip tmux/macOS-option mappings)
- [x] Create `z4b bindkey` command — parse human-readable key names via `_z4b_key` map and delegate to zsh `bindkey`
- [x] Wire up all default bindings (Home/End/Delete, Ctrl+arrow, Shift+arrow, Ctrl+R, Tab, Ctrl+L, undo/redo, etc.)
- [x] Verify: Home/End/Delete work, Ctrl+arrow navigates words, Alt+K/J kill line/buffer

## Phase 5: Plugins — Syntax Highlighting, Autosuggestions, History Substring Search

- [x] Wire up `zsh-syntax-highlighting` with `fg=96` comment style, `ZSH_HIGHLIGHT_MAXLENGTH=1024`, `main` + `brackets` highlighters
- [x] Wire up `zsh-autosuggestions` with `fg=244` suggestion style, right-arrow accepts entire suggestion, custom widget overrides for accept/partial-accept/clear/execute (adapt from z4h's overrides in `fn/-z4h-init-zle`)
- [x] Create `fn/-z4b-autosuggest-fetch` — smart suggestion caching (adapt from z4h)
- [x] Wire up `zsh-history-substring-search` with local/global history toggle
- [x] Create `fn/-z4b-with-local-history` — toggle `set-local-history` (adapt from z4h)
- [x] Create `fn/-z4b-zle-line-init`, `-z4b-zle-line-finish`, `-z4b-zle-line-pre-redraw` — integrate highlight regions from all three plugins (adapt from z4h)
- [x] Verify: typing shows syntax colors, ghost suggestions appear and right-arrow accepts, Up/Down searches local history by substring, Ctrl+Up/Down searches global

## Phase 6: fzf Integration — History and Directory Navigation

- [x] Install fzf binary automatically during init
- [x] Create `fn/z4b-fzf-history` — fzf history search with dedup and bat preview (adapt from z4h, strip screen save/restore)
- [x] Create `fn/z4b-fzf-dir-history` — fzf directory history (adapt from z4h, strip screen save/restore)
- [x] Create `fn/z4b-cd-down` — fzf child directory navigation (adapt from z4h, strip screen save/restore)
- [x] Create `fn/z4b-cd-back`, `fn/z4b-cd-forward`, `fn/z4b-cd-up`, `fn/-z4b-cd-rotate` — directory stack navigation (adapt from z4h)
- [x] Create helpers: `fn/-z4b-find`, `fn/-z4b-present-files`, `fn/-z4b-set-list-colors`
- [x] Create `fn/-z4b-update-dir-history`, `fn/-z4b-read-dir-history`, `fn/-z4b-write-dir-history`
- [x] Verify: Ctrl+R opens history search with preview, Alt+R opens dir history, Shift+Down opens child dir picker, Alt+Left/Right navigates dir stack

## Phase 7: fzf Tab Completion

The most complex piece — intercept zsh's completion system to feed candidates to fzf.

- [x] Create `fn/z4b-fzf-complete` — tab completion with fzf fallback (adapt from z4h's `fn/z4h-fzf-complete`, strip screen save/restore). Must shadow `compadd`, `_path_files`, `_multi_parts`, `_setup`, `zstyle` to intercept candidates
- [x] Create `fn/-z4b-comp-files` — file path completion with fzf (adapt from z4h)
- [x] Create `fn/-z4b-comp-words` — non-file completion with fzf (adapt from z4h)
- [x] Create `fn/-z4b-comp-insert-all` — insert completion result (adapt from z4h)
- [x] Create `fn/-z4b-sanitize-word-prefix` — clean up completion prefix (adapt from z4h)
- [x] Create `fn/-z4b-main-complete` — shadow `_main_complete` (adapt from z4h)
- [x] Verify: first Tab completes common prefix, second Tab opens fzf with all matches, selecting a match inserts it

## Phase 8: Completions Infrastructure

- [x] Create `fn/-z4b-compinit` — lazy compinit with dump caching via mtime signature (adapt from z4h)
- [x] Create `fn/-z4b-compile` — zcompile helper
- [x] Configure completion zstyles (case-insensitive, squeeze-slashes, cache, ignored patterns)
- [x] Wire up bashcompinit
- [x] Wire up language-specific completions (cargo, gh, kubectl, helm, terraform, vault, gcloud, aws) where installed
- [x] Schedule compinit to run after first prompt via `zle -F`
- [x] Verify: tab completion works for standard commands, tools like kubectl have completions if installed, dump cache speeds up subsequent startups

## Phase 9: Starship and Final Wiring

- [x] Install starship binary during init if missing
- [x] Initialize starship as the last step of `z4b init` via `eval "$(starship init zsh)"`
- [x] Add terminal title hooks (preexec/precmd for command/cwd display, include `user@host` prefix when `SSH_CONNECTION` is set)
- [x] Add locale fix (detect non-UTF-8 and set `LC_ALL`)
- [x] Add auto-update check (28-day interval, prompt user)
- [x] Verify: starship prompt renders, terminal title shows cwd when idle and command name when running, `z4b update` checks for updates

## Phase 10: Polish and Verification

- [x] Write a test `.zshrc` that exercises all features and verify on a clean zsh instance
- [x] Verify startup time is < 200ms (measure with `hyperfine 'zsh -i -c exit'`)
- [x] Clean up: remove any dead code paths, ensure consistent naming (`z4b` prefix throughout)
- [x] Update the `.zshrc` template with documented examples for all features
- [x] Test on a fresh machine (or Docker container) via the installer
