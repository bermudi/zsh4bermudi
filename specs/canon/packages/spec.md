# packages

## Requirements

### Requirement: Plugin Installation

The system SHALL provide `z4b install <owner/repo>` that clones a GitHub repository into `$Z4B_ROOT/<owner>/` and optionally runs a postinstall hook. If the cloned repo contains a file named `postinstall.zsh`, it SHALL be sourced with `REPO_ROOT` set to the plugin directory. The hook MUST run with `emulate -L zsh`. A non-zero exit from the hook SHALL print a warning but not fail the install. Core plugins (syntax-highlighting, autosuggestions, history-substring-search, completions, fzf) SHALL be installed automatically during `z4b init` if missing.

#### Scenario: Install a plugin

- **WHEN** the user calls `z4b install zsh-users/zsh-syntax-highlighting` before `z4b init`
- **THEN** the repo is cloned to `$Z4B_ROOT/zsh-users/zsh-syntax-highlighting/`

#### Scenario: Plugin already installed

- **WHEN** the user calls `z4b install` for an already-cloned repo
- **THEN** nothing happens (idempotent)

#### Scenario: Plugin with postinstall hook

- **WHEN** the user calls `z4b install user/plugin` and the repo contains `postinstall.zsh`
- **THEN** `postinstall.zsh` is sourced with `REPO_ROOT` set to the plugin directory

#### Scenario: Postinstall hook fails

- **WHEN** `postinstall.zsh` exits with non-zero
- **THEN** a warning is printed but the install is considered successful

### Requirement: Plugin Update

The system SHALL provide `z4b update` that pulls the latest changes for all installed plugins and for z4b itself.

#### Scenario: Update all plugins

- **WHEN** the user runs `z4b update`
- **THEN** each installed plugin is updated via `git pull`, and z4b itself is updated

### Requirement: Plugin Loading

The system SHALL provide `z4b load <owner/repo>` that adds a plugin's functions directory to fpath, autoloading its functions, and sourcing its init file (`init.zsh` or `plugin.zsh`).

#### Scenario: Load a zsh plugin

- **WHEN** the user calls `z4b load zsh-users/zsh-completions`
- **THEN** the plugin's functions are autoloaded and its init file is sourced
