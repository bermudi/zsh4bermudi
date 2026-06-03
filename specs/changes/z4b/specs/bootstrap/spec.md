# bootstrap

## ADDED Requirements

### Requirement: Installation Script

The system SHALL provide a zsh-based installation script that clones the z4b repository to `~/.cache/zsh4bermudi/`, writes a minimal `~/.zshenv`, and creates a `~/.zshrc` from template if none exists. The installer MUST require only zsh, git, and curl or wget.

#### Scenario: Fresh install on a machine with zsh and curl
- **WHEN** the user runs the install script and `~/.cache/zsh4bermudi/` does not exist
- **THEN** the script clones the z4b repo, writes `~/.zshenv` with `Z4B_ROOT` pointing to the clone, and creates `~/.zshrc` from the default template

#### Scenario: Existing .zshrc
- **WHEN** the user runs the install script and `~/.zshrc` already exists
- **THEN** the script backs up the existing `.zshrc` to `.zshrc.z4b-backup` and writes the new one

#### Scenario: Missing zsh
- **WHEN** zsh is not found on the system
- **THEN** the installer prints an error message telling the user to install zsh and exits with code 1

#### Scenario: Missing git
- **WHEN** git is not found on the system
- **THEN** the installer prints an error message telling the user to install git and exits with code 1

#### Scenario: Missing curl and wget
- **WHEN** neither curl nor wget is found on the system
- **THEN** the installer prints an error message telling the user to install curl or wget and exits with code 1

### Requirement: Bootstrap Loader

The `~/.zshenv` file SHALL set `Z4B_ROOT` and source `$Z4B_ROOT/z4b.zsh`. The bootstrap loader MUST set essential zsh options and provide a recovery prompt if the full init fails.

#### Scenario: Normal startup
- **WHEN** zsh starts and sources `.zshenv`
- **THEN** `Z4B_ROOT` is set, `z4b.zsh` is sourced, shell options are configured, and control passes to `.zshrc`

#### Scenario: Bootstrap failure
- **WHEN** `z4b.zsh` sources successfully but `z4b init` (called from `.zshrc`) fails
- **THEN** a recovery prompt is displayed with instructions to edit `.zshrc` or re-run the installer

### Requirement: Auto-Update

The system SHALL check for updates periodically on startup. The check interval MUST default to 28 days. Users can trigger a manual update via `z4b update`.

#### Scenario: Periodic update check
- **WHEN** zsh starts and the last update check was more than 28 days ago
- **THEN** z4b prints a message asking the user if they want to update, and updates if confirmed

#### Scenario: Manual update
- **WHEN** the user runs `z4b update`
- **THEN** z4b updates itself and all installed plugins
