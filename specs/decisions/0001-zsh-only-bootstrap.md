# Decision: zsh-only bootstrap

**Status**: Accepted
**Date**: 2026-06-02

## Context

z4h's installer is written in portable POSIX sh to work without zsh installed. This requires heavy quoting (every command is quoted like `'emulate' 'zsh'`) and limits expressiveness.

## Decision

z4b's installer and bootstrap are zsh-only. zsh is a hard requirement.

## Consequences

- Cannot install from bash — must have zsh first
- Installer code is readable and maintainable
- Any machine that runs z4b needs zsh anyway (chicken-and-egg only matters for first install)
