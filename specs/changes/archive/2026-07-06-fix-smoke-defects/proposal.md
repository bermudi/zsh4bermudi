# Proposal: fix-smoke-defects

## Motivation

Container smoke testing (fresh Fedora image, real plugins, interactive PTY) surfaced three defects where the implementation does not comply with specs that were already correct. All three are invisible to the stub-based zunit suite — the plugins are stubbed and the tests run non-interactively — which is why they shipped marked-complete.

1. **Live syntax highlighting never renders.** `zsh-syntax-highlighting` loads, but z4b never drives it. Two call sites gate on `${+functions[zsh_highlight]}` — a symbol that does not exist. The plugin's entry point is `_zsh_highlight`. Consequence: the `main`+`brackets` config, `fg=96` comment style, and `MAXLENGTH=1024` are never applied (`main.zsh`), and the `zle-line-pre-redraw` hook never invokes the highlighter, so the line stays uncolored.

2. **History substring search is not wired.** `main.zsh` gates the wiring block on `${+functions[zsh_history_substring_search_up]}` (underscores), but the plugin defines `history-substring-search-up` (hyphens). The block never runs, so Up/Down are left bound to zsh's `up-line-or-beginning-search` rather than the substring-search widget.

3. **Locale fix sets a locale that may not exist.** When the current locale is non-UTF-8, z4b forces `LC_ALL=en_US.UTF-8` without checking availability. On minimal systems (containers, many servers) only `C.UTF-8` exists, so every subprocess emits `setlocale: cannot change locale (en_US.UTF-8)`.

## Root Cause

Symbol-name drift in the plugin-integration glue (`zsh_highlight` vs `_zsh_highlight`; `zsh_history_substring_search_up` vs `history-substring-search-up`), plus an oversimplified locale fix that assumed `en_US.UTF-8` exists. None are spec changes — the `plugins` and `environment` specs were right; the code didn't comply.

## Scope

- **Code fixes (compliance):**
  - `main.zsh`: correct the syntax-highlighting config guard to `_zsh_highlight`; correct the history-substring-search guard to the hyphenated widget name; replace the hardcoded locale with availability-aware selection.
  - `fn/-z4b-zle-line-pre-redraw`: correct the guard and call to `_zsh_highlight`.
- **Spec deltas (lock-down):** pin the integration symbols in `plugins` (so drift is a visible contract break) and make locale availability explicit in `environment`.
- **Regression:** a zunit test for locale selection, and container smoke assertions for all three fixes (no locale warning, highlighter config applied, Up bound to substring-search widget).

## Out of Scope

- Archiving the `z4b` change — separate human decision.
- Startup-latency tuning (~46ms observed vs 30ms target) — separate concern, not a compliance defect.
- The autosuggestions config guard (`${+ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE}`) — verified working, untouched.
- Dead/no-op guards (e.g. the `_zsh_highlight_widget_history-substring-search-up` check in `-z4b-zle-line-pre-redraw`) — cosmetic, not compliance defects.
