# prompt

## ADDED Requirements

### Requirement: Starship Prompt

The system SHALL install and initialize starship as the default prompt. Starship MUST be initialized as the last step of `z4b init` (after all other plugins and ZLE widgets are set up) because it sets PROMPT and precmd/preexec hooks. Users configure starship via `~/.config/starship.toml`.

#### Scenario: Starship renders after init
- **WHEN** `z4b init` completes
- **THEN** the prompt is rendered by starship using the user's `starship.toml` config

#### Scenario: No starship.toml
- **WHEN** `~/.config/starship.toml` does not exist
- **THEN** starship uses its default theme

### Requirement: Starship Binary Management

The system SHALL install the starship binary if not found. The binary MUST be available in PATH after init.

#### Scenario: Starship not installed
- **WHEN** `z4b init` runs and starship is not in PATH
- **THEN** z4b downloads and installs starship to `$Z4B_ROOT/bin/`
