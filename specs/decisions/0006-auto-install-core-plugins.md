# Decision: Auto-install core plugins

**Status**: Accepted
**Date**: 2026-06-02

## Context

Users need syntax highlighting, autosuggestions, history search, completions, and fzf. Making them manually install each is friction.

## Decision

Core plugins (zsh-syntax-highlighting, zsh-autosuggestions, zsh-history-substring-search, zsh-completions, fzf, starship) are treated as part of z4b. Installed automatically during `z4b init` if missing. Users can `z4b install` additional plugins.

## Consequences

- First `z4b init` has network I/O (downloads plugins)
- Subsequent starts are instant (plugins cached locally)
- Users don't need to list core plugins in `.zshrc`
- `z4b update` updates core plugins along with everything else
