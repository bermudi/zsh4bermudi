# zle

## Requirements

### Requirement: Smart Enter

The system SHALL provide a `z4b-accept-line` widget that inserts a newline when the buffer contains a parse error and executes the command when the buffer is syntactically valid.

#### Scenario: Complete command

- **WHEN** the user presses Enter with a valid command like `echo hello`
- **THEN** the command executes

#### Scenario: Incomplete command

- **WHEN** the user presses Enter with `for i in 1 2 3;`
- **THEN** a newline is inserted, allowing the user to continue typing the loop body

### Requirement: Two-Flavor Word Navigation

The system SHALL provide two distinct word-navigation flavors. Both MUST operate with `WORDCHARS=''` (only alphanums are word characters).

**Shell words** (`z4b-forward-word` / `z4b-backward-word`): Skip runs of alphanumeric characters or runs of non-whitespace non-alphanumeric characters as single units. Bound to Ctrl+Left/Ctrl+Right and Alt+F/Alt+B.

**Tokenizer words** (`z4b-forward-zword` / `z4b-backward-zword`): Navigate by zsh tokenizer boundaries using `${(Z:n:)}`. Bound to Ctrl+Shift+Left/Ctrl+Shift+Right.

#### Scenario: Shell word forward through a flag

- **WHEN** the cursor is before `--verbose` and the user presses Ctrl+Right
- **THEN** the cursor jumps over `--` (first press) and then over `verbose` (second press)

#### Scenario: Shell word forward through a path

- **WHEN** the cursor is before `src/my-project/foo.c` and the user presses Ctrl+Right
- **THEN** the cursor jumps over `src`, then `/`, then `my`, then `-`, then `project`, then `/`, then `foo`, then `.`, then `c`

#### Scenario: Tokenizer word forward through pipe

- **WHEN** the cursor is before `echo foo | grep bar` and the user presses Ctrl+Shift+Right
- **THEN** the cursor jumps over `echo`, then `foo`, then `|`, then `grep`, then `bar`

### Requirement: Kill-Word with Ring Accumulation

The system SHALL provide `z4b-kill-word` and `z4b-backward-kill-word` widgets that use the two-flavor word boundary logic and accumulate killed text into the kill ring. Consecutive kills MUST prepend or append to `CUTBUFFER` rather than replacing it.

#### Scenario: Consecutive backward kills

- **WHEN** the user presses Ctrl+W twice on `echo hello world` with cursor at end
- **THEN** both `world ` and `hello ` are accumulated in the kill ring, and Ctrl+Y pastes them both back

### Requirement: Expand Alias/Glob/Parameter

The system SHALL provide a `z4b-expand` widget bound to Ctrl+Space that expands the word under the cursor — first trying alias expansion, then glob/parameter expansion.

#### Scenario: Expand alias

- **WHEN** the cursor is on `ls` (aliased to `eza -la`) and the user presses Ctrl+Space
- **THEN** `ls` is replaced with `eza -la`

### Requirement: Stash Buffer

The system SHALL provide a `z4b-stash-buffer` widget bound to Alt+O that pushes the current buffer contents to ephemeral history and clears the line. The stashed text MUST NOT be written to `HISTFILE`.

#### Scenario: Stash and recall

- **WHEN** the user types a partial command, presses Alt+O, then later navigates history
- **THEN** the stashed command appears in history but is not persisted across sessions

### Requirement: Quick Kill Widgets

The system SHALL bind Alt+K to `backward-kill-line` (kill everything before cursor on current line) and Alt+J to `kill-buffer` (kill entire buffer).

#### Scenario: Kill line before cursor

- **WHEN** the user presses Alt+K
- **THEN** all text before the cursor on the current line is deleted and placed in the kill ring

### Requirement: Accept Autosuggestion

The system SHALL provide `z4b-autosuggest-accept` bound to Alt+M that accepts the entire autosuggestion ghost text.

#### Scenario: Accept suggestion

- **WHEN** there is ghost text after the cursor and the user presses Alt+M
- **THEN** the ghost text is accepted into the buffer

### Requirement: Key Normalization

The system SHALL normalize keycodes from TTY, urxvt, and iTerm2 to xterm canonical form for all keymaps (emacs, viins, vicmd). Tmux-specific mappings are excluded.

#### Scenario: TTY Home key

- **WHEN** a TTY sends `^[[1~` for the Home key
- **THEN** it is translated to `^[[H` so the `beginning-of-line` binding works

### Requirement: Named Key Abstraction

The system SHALL provide a `z4b bindkey` command that accepts human-readable key names and maps them to terminal escape sequences internally. Key name grammar: one or more modifiers (`Ctrl`, `Alt`, `Shift`) joined with `+`, followed by `+` and a key name. Key names are: `Backspace`, `Delete`, `Insert`, `Home`, `End`, `PageUp`, `PageDown`, `Up`, `Down`, `Left`, `Right`, `Tab`, `Space`, `Enter`, `Escape`, `F1`–`F12`, or a single printable character. Modifiers can be combined (e.g., `Ctrl+Shift+Left`). Order does not matter (`Ctrl+Alt+Delete` equals `Alt+Ctrl+Delete`).

#### Scenario: Bind custom key

- **WHEN** the user writes `z4b bindkey z4b-backward-kill-word Ctrl+Backspace` in their `.zshrc`
- **THEN** Ctrl+Backspace triggers the `z4b-backward-kill-word` widget

### Requirement: Standard Bindings

The system SHALL set up the following default key bindings:
- Home → `beginning-of-line`, End → `end-of-line`
- Delete → `delete-char`, Ctrl+D → `delete-char`
- Ctrl+P/Ctrl+N or Up/Down → history substring search (local)
- Ctrl+Up/Ctrl+Down → history search (global)
- Ctrl+R → fzf history search
- Tab → fzf completion
- Ctrl+L → clear screen
- Ctrl+/ and Shift+Tab → undo, Alt+/ → redo
- Alt+H → run-help

#### Scenario: Default bindings present after init

- **WHEN** `z4b init` completes
- **THEN** all standard bindings are active without any user configuration

### Requirement: User Bindings Survive Init

User `z4b bindkey` calls in `.zshrc` SHALL take effect after `z4b init`, overriding any defaults.

#### Scenario: Override default binding

- **WHEN** the user calls `z4b bindkey undo Ctrl+/` after `z4b init`
- **THEN** Ctrl+/ triggers undo
