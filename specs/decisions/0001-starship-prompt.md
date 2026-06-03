# Decision: Starship as default prompt

**Status**: Accepted
**Date**: 2026-06-02

## Context

Choosing between powerlevel10k (current, stewardship mode), pure (minimal), starship (feature-rich, Rust), and oh-my-posh (Go).

## Decision

Starship. Rust binary, TOML config, actively maintained, all segments available (git, language versions, k8s, aws), cross-shell.

## Consequences

- No instant prompt (starship doesn't support it — ~50-100ms delay visible on terminal open)
- Config lives in `~/.config/starship.toml`, not in `.zshrc`
- Starship binary must be downloaded during init (~3MB)
