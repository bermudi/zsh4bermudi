# z4b Design

## Architecture

z4b follows z4h's startup pattern with significant simplification:

```
.zshenv  →  z4b.zsh (bootstrap)  →  .zshrc (user config)  →  z4b init (main.zsh)
```

### File Layout

```
~/.cache/zsh4bermudi/            # $Z4B_ROOT
  z4b.zsh                         # Bootstrap loader (sourced by .zshenv)
  main.zsh                        # Core init: env setup, plugin wiring, ZLE, completion, starship
  install.zsh                     # Package management functions (z4b install, z4b update)
  init-zle.zsh                    # Key normalization, default bindkeys, ZLE widget registration
  setup.zsh                       # Installer script (run directly, not sourced)
  fn/                             # Autoloaded functions
    z4b-accept-line
    z4b-forward-word
    z4b-backward-word
    z4b-forward-zword
    z4b-backward-zword
    -z4b-move-and-kill
    z4b-expand
    z4b-stash-buffer
    z4b-fzf-history
    z4b-fzf-complete
    z4b-fzf-dir-history
    z4b-cd-down
    z4b-cd-back
    z4b-cd-forward
    z4b-cd-up
    -z4b-cd-rotate
    -z4b-autosuggest-fetch
    -z4b-comp-files
    -z4b-comp-words
    -z4b-compinit
    -z4b-compile
    -z4b-find
    -z4b-present-files
    -z4b-fzf
    -z4b-get-cursor-pos
    -z4b-init
    -z4b-install-many
    -z4b-install-one
    -z4b-is-valid-list
    -z4b-main-complete
    -z4b-prompt-length
    -z4b-redraw-buffer
    -z4b-redraw-prompt
    -z4b-sanitize-word-prefix
    -z4b-set-list-colors
    -z4b-string-diff
    -z4b-update-dir-history
    -z4b-with-local-history
    -z4b-zle-line-init
    -z4b-zle-line-finish
    -z4b-zle-line-pre-redraw
  cache/                          # Generated at runtime
    zcompdump-*
    zcompcache-*
  fzf/                            # fzf binary + man
  starship/                       # starship binary (or use $Z4B_ROOT/bin/)
  zsh-syntax-highlighting/        # Cloned plugins
  zsh-autosuggestions/
  zsh-history-substring-search/
  zsh-completions/
```

### Startup Sequence

1. **`.zshenv`** — Sets `Z4B_ROOT=~/.cache/zsh4bermudi`, sources `$Z4B_ROOT/z4b.zsh`
2. **`z4b.zsh`** — Sets `WORDCHARS=''`, `KEYTIMEOUT=20`, recovery-mode bindkeys, essential options. Validates `Z4B_ROOT`. Falls back to recovery prompt on failure.
3. **`.zshrc`** — User calls `z4b install` for plugins, then `z4b init || return`, then bindkeys/options/aliases
4. **`z4b init`** (`main.zsh`):
   - Load zsh modules (zsh/datetime, zsh/system, zsh/terminfo, zsh/zutil, etc.)
   - Set up fpath, PATH, manpath, infopath (Homebrew detection)
   - Autoload all `fn/` functions
   - Install core plugins if missing (fzf, syntax-highlighting, autosuggestions, history-substring-search, completions, starship)
   - Set environment variables (LESS, PAGER, LS_COLORS, etc.)
   - Source `init-zle.zsh`: register ZLE widgets, normalize keys, set default bindkeys, wire up named key map
   - Configure completion (zstyles, lazy compinit scheduling)
   - Wire up plugins (syntax highlighting, autosuggestions with widget overrides, history substring search)
   - Initialize starship (last — sets PROMPT and hooks)

### State Management

Minimal global state, following z4h's convention with `z4b` prefix:
- `Z4B_ROOT` — installation directory
- `_z4b_zle` — whether ZLE is active (interactive shell)
- `_z4b_exe` — path to zsh binary
- `_z4b_key` — named key → escape sequence map (assoc array)
- `_z4b_install_queue` — plugins queued for installation

No zstyle. Configuration is positional in `.zshrc`.

## Decisions

### Decision: zsh-only installer (not POSIX sh)

z4h's installer is written in portable sh with heavy quoting to avoid needing zsh. z4b requires zsh upfront — the installer is a zsh script. This trades portability (can't install from bash) for readability and maintainability. Acceptable because zsh is the target, and any machine that will run z4b needs zsh anyway.

### Decision: Adapt z4h code rather than rewrite

The word navigation, fzf-complete, and key normalization are battle-tested over years. Rewriting them would introduce bugs for no benefit. The approach is: copy, rename `z4h` → `z4b`, strip tmux/SSH/screen-save code paths, keep the core logic intact.

### Decision: Starship as prompt (not pure or p10k)

p10k is in stewardship mode. Pure is too minimal for a polyglot developer. Starship is actively maintained, fast (Rust binary), configurable via TOML, and provides all segments (git, language versions, etc.) without needing zsh-specific code. No instant prompt is the accepted tradeoff.

### Decision: No screen save/restore

Requires tmux or SSH teleportation infrastructure. Without tmux, this is dead code. fzf operations clear the screen normally. The visual difference is cosmetic.

### Decision: No zstyle for configuration

zstyle is zsh-specific, implicit (order-dependent lookup), and hard to debug. z4b uses explicit function calls in `.zshrc` — the user can see exactly what's configured and in what order.

### Decision: Lazy compinit

Running compinit synchronously at startup is the single biggest source of zsh startup latency. z4b schedules it to run after the first prompt renders (via `zle -F` on a dummy fd), following z4h's approach. The user sees the prompt immediately; completions become available a few milliseconds later.

### Decision: Core plugins installed automatically

fzf, zsh-syntax-highlighting, zsh-autosuggestions, zsh-history-substring-search, zsh-completions, and starship are treated as part of z4b itself. They're installed during `z4b init` if missing. Users don't need to `z4b install` them explicitly (though they can).

## File Changes

### Created files

| File | Purpose | Source |
|------|---------|--------|
| `z4b.zsh` | Bootstrap loader | Adapted from z4h's `z4h.zsh`, stripped POSIX quoting, stripped tmux/bootstrap download |
| `main.zsh` | Core initialization | Adapted from z4h's `main.zsh`, stripped SSH teleportation, tmux, iTerm2, direnv |
| `init-zle.zsh` | ZLE setup, key normalization, default bindkeys | Adapted from z4h's `fn/-z4h-init-zle`, stripped tmux key mappings, macOS option-as-alt |
| `install.zsh` | Package management | Adapted from z4h's `fn/-z4h-install-one`/`-z4h-install-many`/`-z4h-cmd-update` |
| `setup.zsh` | Installer script | New — simpler than z4h's `install` (zsh-only, no POSIX) |
| `fn/z4b-accept-line` | Smart Enter | Direct adaptation of z4h's `fn/z4h-accept-line` |
| `fn/z4b-forward-word` | Shell word forward | Direct adaptation of z4h's `fn/z4h-forward-word` |
| `fn/z4b-backward-word` | Shell word backward | Direct adaptation of z4h's `fn/z4h-backward-word` |
| `fn/z4b-forward-zword` | Tokenizer word forward | Direct adaptation of z4h's `fn/z4h-forward-zword` |
| `fn/z4b-backward-zword` | Tokenizer word backward | Direct adaptation of z4h's `fn/z4h-backward-zword` |
| `fn/-z4b-move-and-kill` | Kill-word with ring | Direct adaptation of z4h's `fn/-z4h-move-and-kill` |
| `fn/z4b-expand` | Expand alias/glob/param | Direct adaptation of z4h's `fn/z4h-expand` |
| `fn/z4b-stash-buffer` | Stash to ephemeral history | Direct adaptation of z4h's `fn/z4b-stash-buffer` |
| `fn/z4b-fzf-history` | fzf history search | Adapted from z4h's `fn/z4h-fzf-history`, stripped screen save/restore |
| `fn/z4b-fzf-complete` | fzf tab completion | Direct adaptation of z4h's `fn/z4h-fzf-complete`, stripped screen save/restore |
| `fn/z4b-fzf-dir-history` | fzf dir history | Adapted from z4h's `fn/z4h-fzf-dir-history`, stripped screen save/restore |
| `fn/z4b-cd-down` | fzf child dir navigation | Adapted from z4h's `fn/z4h-cd-down`, stripped screen save/restore |
| `fn/z4b-cd-back` | Dir stack back | Direct adaptation of z4h's `fn/z4h-cd-back` |
| `fn/z4b-cd-forward` | Dir stack forward | Direct adaptation of z4h's `fn/z4h-cd-forward` |
| `fn/z4b-cd-up` | Cd to parent | Direct adaptation of z4h's `fn/z4h-cd-up` |
| `fn/-z4b-compinit` | Lazy compinit | Adapted from z4h's `fn/-z4h-compinit` |
| `fn/-z4b-with-local-history` | Local/global history toggle | Direct adaptation of z4h's `fn/-z4h-with-local-history` |
| `fn/-z4b-is-valid-list` | Parse validation for smart enter | Direct adaptation of z4h's `fn/-z4h-is-valid-list` |
| Various helpers | Internal functions | Adapted from z4h equivalents |

### Not ported from z4h

| z4h file | Reason |
|----------|--------|
| `fn/-z4h-save-screen`, `fn/-z4h-restore-screen` | No tmux |
| `fn/-z4h-cmd-ssh`, `sc/ssh-bootstrap`, `sc/install-tmux` | No SSH teleportation |
| `fn/-z4h-init-wsl` | No WSL |
| `fn/-z4h-enable-iterm2-integration` | No iTerm2 integration |
| `fn/-z4h-direnv-*` | No direnv |
| `fn/-z4h-postinstall-systemd` | No systemd |
| `fn/-z4h-start-ssh-agent` | No SSH agent |
| `sc/exec-zsh-i` | No bundled zsh |
| `zb/` | No bundled zsh |
