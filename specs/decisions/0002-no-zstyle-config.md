# Decision: No zstyle for configuration

**Status**: Accepted
**Date**: 2026-06-02

## Context

z4h uses `zstyle` for all configuration. zstyle is zsh-specific, order-dependent in lookup, and hard to debug.

## Decision

z4b uses explicit function calls in `.zshrc`. No zstyle.

## Consequences

- Configuration is visible and ordered in `.zshrc`
- No implicit lookup chains
- Slightly more verbose than `zstyle ':z4h:' auto-update 'no'`
- Easy to debug — grep `.zshrc`
