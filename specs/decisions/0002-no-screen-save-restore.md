# Decision: No screen save/restore

**Status**: Accepted
**Date**: 2026-06-02

## Context

z4h can snapshot terminal contents and restore them after fzf operations, so fzf overlays feel "in-place." This requires tmux (`capture-pane`) or SSH teleportation infrastructure.

## Decision

No screen save/restore. fzf operations clear the screen normally.

## Consequences

- After Ctrl+R or Tab completion, previous output is gone (screen clears)
- Eliminates ~200 lines of terminal escape code wrangling
- Requires no tmux dependency
- The visual difference is cosmetic — the selected result is still correct
