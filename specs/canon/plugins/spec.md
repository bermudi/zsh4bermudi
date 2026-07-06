# plugins

## Requirements

### Requirement: Syntax Highlighting

The system SHALL wire up `zsh-syntax-highlighting` from `zsh-users/zsh-syntax-highlighting`. Comments SHALL be styled with `fg=96` on 256+ color terminals. Highlighting MUST be capped at 1024 characters (`ZSH_HIGHLIGHT_MAXLENGTH=1024`). Highlighters SHALL be `main` and `brackets`.

Because z4b installs its own `zle-line-pre-redraw` widget (overriding the plugin's), the redraw widget MUST invoke the plugin's actual entry symbol `_zsh_highlight` so the line is recolored on every redraw. The configuration and redraw sites MUST NOT reference the non-existent symbol `zsh_highlight`. Configuration MUST be gated on `${+functions[_zsh_highlight]}`.

#### Scenario: Syntax highlighting active

- **WHEN** the user types `echo hello`
- **THEN** `echo` is highlighted as a command, `hello` as an argument

#### Scenario: Comment color

- **WHEN** the user types `# this is a comment` on a 256-color terminal
- **THEN** the comment is colored with `fg=96`

#### Scenario: Highlighter config applied after plugin load

- **WHEN** `zsh-syntax-highlighting` is installed and `z4b init` runs
- **THEN** `ZSH_HIGHLIGHT_HIGHLIGHTERS` is `main brackets`, `ZSH_HIGHLIGHT_MAXLENGTH` is `1024`, and `ZSH_HIGHLIGHT_STYLES[comment]` is `fg=96`

#### Scenario: Redraw widget drives the highlighter

- **WHEN** the redraw widget fires with the plugin loaded
- **THEN** `_zsh_highlight` is invoked (the line is colored), not the non-existent `zsh_highlight`

### Requirement: Autosuggestions

The system SHALL wire up `zsh-autosuggestions` from `zsh-users/zsh-autosuggestions`. The suggestion style MUST be `fg=244` on 256+ color terminals. The right arrow key SHALL accept the entire suggestion. The system MUST override autosuggestion widgets to control accept/partial-accept behavior and integrate with custom word navigation widgets.

#### Scenario: Ghost suggestion appears

- **WHEN** the user types `git ch` and a previous command `git checkout main` exists in history
- **THEN** a gray ghost text `eckout main` appears after the cursor

#### Scenario: Right arrow accepts suggestion

- **WHEN** there is ghost text after the cursor and the user presses Right
- **THEN** the entire suggestion is accepted into the buffer

### Requirement: History Substring Search

The system SHALL wire up `zsh-history-substring-search` from `zsh-users/zsh-history-substring-search`. Up/Down SHALL search local history by substring prefix. Ctrl+Up/Ctrl+Down SHALL search global history. The system MUST integrate highlighting with syntax highlighting's `region_highlight`.

The wiring MUST reference the plugin's actual widget function names — `history-substring-search-up` and `history-substring-search-down` (hyphenated) — both when registering them as ZLE widgets and when binding keys. The configuration MUST NOT be gated on the non-existent underscored symbol `zsh_history_substring_search_up`.

#### Scenario: Substring search up

- **WHEN** the user types `git` and presses Up
- **THEN** the most recent command containing `git` appears

#### Scenario: Global history search

- **WHEN** the user types `git` and presses Ctrl+Up
- **THEN** the most recent command containing `git` from the global (shared) history appears

#### Scenario: Up bound to substring search

- **WHEN** `zsh-history-substring-search` is installed and `z4b init` runs
- **THEN** the Up key is bound to `history-substring-search-up` (not zsh's `up-line-or-beginning-search`)

### Requirement: Extra Completions

The system SHALL wire up `zsh-completions` from `zsh-users/zsh-completions` to provide additional completion definitions beyond zsh's built-in set.

#### Scenario: Extra completions available

- **WHEN** the user tabs-completes a command that has a completion definition in zsh-completions but not in zsh's built-in completions
- **THEN** the completion works correctly

### Requirement: fzf Binary

The system SHALL manage the fzf binary and man pages. fzf MUST be available at `$Z4B_ROOT/fzf/bin/fzf` and added to PATH.

#### Scenario: fzf available

- **WHEN** `z4b init` completes
- **THEN** the `fzf` command is available in PATH
