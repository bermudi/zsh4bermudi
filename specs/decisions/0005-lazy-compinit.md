# Decision: Lazy compinit

**Status**: Accepted
**Date**: 2026-06-02

## Context

Running compinit synchronously at startup is the single biggest source of zsh startup latency. z4h defers it via `zle -F` on a dummy fd.

## Decision

Schedule compinit to run after the first prompt renders via `zle -F`. Completions become available a few milliseconds after the prompt appears.

## Consequences

- Prompt appears instantly; completions work ~50-100ms later
- Tab pressed before compinit completes falls back to standard zsh completion (graceful degradation)
- Cache invalidation via mtime signature on completion function files
