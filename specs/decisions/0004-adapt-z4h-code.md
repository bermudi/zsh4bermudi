# Decision: Adapt z4h code rather than rewrite

**Status**: Accepted
**Date**: 2026-06-02

## Context

Word navigation, fzf-complete, and key normalization are battle-tested over years in z4h. Rewriting would introduce bugs for no benefit.

## Decision

Copy z4h code, rename `z4h` → `z4b`, strip tmux/SSH/screen-save code paths, keep core logic intact.

## Consequences

- Proven correctness for the hardest parts (word boundaries, compadd interception)
- Faster implementation than greenfield
- Carries forward z4h's coding style (global state, autoloaded functions) — consistent with zsh conventions
- Must maintain attribution per z4h's license
