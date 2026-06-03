# history

## ADDED Requirements

### Requirement: Infinite Shared History

The system SHALL set `HISTSIZE=1000000000`, `SAVEHIST=1000000000`, and enable `share_history` so that command history is shared across all running zsh sessions in real time. `HISTFILE` MUST default to `~/.zsh_history` unless the user has set it before init.

#### Scenario: History shared across terminals
- **WHEN** the user runs `echo hello` in terminal A and then opens terminal B
- **THEN** `echo hello` is available in terminal B's history

### Requirement: Local vs Global History Toggle

The system SHALL provide local and global history search modes. Up/Down and Ctrl+P/Ctrl+N SHALL search local session history. Ctrl+Up/Ctrl+Down SHALL search the global (shared) history. This is implemented via `set-local-history` toggling.

#### Scenario: Local history search
- **WHEN** the user runs `cmd_a` in the current session, `cmd_b` was run in another session, and the user types `cmd` and presses Up
- **THEN** only `cmd_a` appears (local session history) as a substring match

#### Scenario: Global history search
- **WHEN** the same scenario as above but the user presses Ctrl+Up
- **THEN** both `cmd_a` and `cmd_b` appear as substring matches from the global shared history

### Requirement: History Deduplication

The system SHALL enable `hist_ignore_dups`, `hist_ignore_space`, `hist_save_no_dups`, and `hist_expire_dups_first` to keep history clean.

#### Scenario: Duplicate commands
- **WHEN** the user runs `ls` twice in a row
- **THEN** only one `ls` entry is saved to history
