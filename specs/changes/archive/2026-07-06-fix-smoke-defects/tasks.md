# Tasks: fix-smoke-defects

## Phase 1 — Plugin integration symbol drift (plugins)

- [x] Fix `main.zsh` syntax-highlighting config guard: `${+functions[zsh_highlight]}` → `${+functions[_zsh_highlight]}`
- [x] Fix `fn/-z4b-zle-line-pre-redraw`: guard and call `zsh_highlight` → `_zsh_highlight`
- [x] Fix `main.zsh` history-substring-search guard: `${+functions[zsh_history_substring_search_up]}` → `${+functions[history-substring-search-up]}`
- [x] Verify: with all three plugins installed, `ZSH_HIGHLIGHT_HIGHLIGHTERS` is `main brackets`, `ZSH_HIGHLIGHT_MAXLENGTH` is `1024`, `ZSH_HIGHLIGHT_STYLES[comment]` is `fg=96`
- [x] Verify: typing `echo hello` in an interactive shell colors `echo`/`hello`
- [x] Verify: Up is bound to `history-substring-search-up` (not `up-line-or-beginning-search`)

## Phase 2 — Locale availability detection (environment)

- [x] Replace hardcoded `en_US.UTF-8` in `main.zsh` with availability-aware selection (prefer `C.UTF-8`/`C.utf8`, then any UTF-8 locale from `locale -a`, else leave unchanged)
- [x] Verify in `z4b-test` container: `LC_ALL` is `C.utf8` (not `en_US.UTF-8`) and no `setlocale` warning appears on boot

## Phase 3 — Regression coverage

- [x] Add a zunit test for the locale-selection helper covering: UTF-8 already set (no-op), only `C.utf8` available, no UTF-8 locale available (no-op)
- [x] Extend the container eval to assert: no locale warning, highlighter config applied, Up bound to substring-search widget
- [x] Run full `zunit` suite green
- [x] Rebuild and rerun the container smoke + eval; all assertions pass

## Phase 4 — Close out

- [x] `litespec validate fix-smoke-defects` clean
- [x] Update `AGENTS.md` only if a durable convention changed (likely none)
