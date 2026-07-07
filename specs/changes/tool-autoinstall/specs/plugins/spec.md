# plugins

## MODIFIED Requirements

### Requirement: fzf Binary

The system SHALL manage the fzf binary and man pages. fzf MUST be available at
`$Z4B_ROOT/fzf/bin/fzf` and added to PATH.

When fzf is not already available, the system SHALL install it once by cloning
`https://github.com/junegunn/fzf` (shallow) into `$Z4B_ROOT/fzf` and running its
`install --bin`, which places the prebuilt binary at `$Z4B_ROOT/fzf/bin/fzf`.
Installation MUST be idempotent: skipped when fzf is already on PATH or already
present at that path. Installation MUST be skipped (and fzf left unconfigured)
when `Z4B_NO_TOOL_INSTALL` is set, so offline/sandboxed/test environments do not
hit the network; in that case init proceeds silently.

#### Scenario: fzf available
- **WHEN** `z4b init` completes and fzf is installed
- **THEN** the `fzf` command is available in PATH

#### Scenario: fzf installed on first init
- **WHEN** fzf is not on PATH and `Z4B_NO_TOOL_INSTALL` is unset
- **THEN** z4b clones and installs fzf so `$Z4B_ROOT/fzf/bin/fzf` exists

#### Scenario: install skipped offline
- **WHEN** fzf is not on PATH and `Z4B_NO_TOOL_INSTALL=1`
- **THEN** z4b does not attempt installation and prints no per-boot message
