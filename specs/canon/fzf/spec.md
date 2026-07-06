# fzf

## Requirements

### Requirement: History Search

The system SHALL provide a `z4b-fzf-history` widget bound to Ctrl+R that opens fzf over deduplicated command history with bat preview (if bat is installed) and exact matching. The selected command SHALL replace the current buffer.

#### Scenario: Search and select from history

- **WHEN** the user presses Ctrl+R, types a query, and selects a command
- **THEN** the current buffer is replaced with the selected command and the cursor moves to the end

#### Scenario: Cancel history search

- **WHEN** the user presses Ctrl+R and then presses Escape
- **THEN** the original buffer is restored unchanged

#### Scenario: Bat preview

- **WHEN** bat is installed and the user opens history search
- **THEN** each candidate is previewed with bat syntax highlighting

### Requirement: Tab Completion with fzf

The system SHALL provide a `z4b-fzf-complete` widget bound to Tab. On first press, it MUST complete the common prefix. On second press (when multiple matches exist), it SHALL open fzf with all completion candidates. The system MUST intercept zsh's `compadd` to collect candidates before rendering.

#### Scenario: Single completion match

- **WHEN** the user types `ech` and presses Tab, and only `echo` matches
- **THEN** the buffer is completed to `echo `

#### Scenario: Multiple matches — common prefix

- **WHEN** the user types `git che` and presses Tab, and both `checkout` and `cherry-pick` match
- **THEN** the buffer remains `git che` (common prefix already typed), and a second Tab opens fzf with `checkout` and `cherry-pick`

#### Scenario: fzf selection

- **WHEN** fzf opens with multiple completion candidates and the user selects one
- **THEN** the selected candidate is inserted into the buffer at the cursor position

### Requirement: Directory History Search

The system SHALL provide a `z4b-fzf-dir-history` widget bound to Alt+R that opens fzf over the directory history. The selected directory SHALL become the current working directory.

#### Scenario: Search and cd

- **WHEN** the user presses Alt+R, types a query, and selects a directory
- **THEN** the current working directory changes to the selected directory

### Requirement: Child Directory Navigation

The system SHALL provide a `z4b-cd-down` widget bound to Shift+Down that opens fzf with child directories of the current working directory. The selected directory SHALL become the current working directory.

#### Scenario: Navigate into child

- **WHEN** the user presses Shift+Down and selects `src/`
- **THEN** the current working directory changes to `./src/`

#### Scenario: No child directories

- **WHEN** the user presses Shift+Down and the current directory has no subdirectories
- **THEN** nothing happens

### Requirement: Directory Stack Navigation

The system SHALL provide `z4b-cd-back` (Alt+Left), `z4b-cd-forward` (Alt+Right), and `z4b-cd-up` (Shift+Up) widgets. Back and forward navigate the directory stack (pushd). Up changes to the parent directory.

#### Scenario: Cd back and forward

- **WHEN** the user is in `/foo/bar`, previously was in `/foo/baz`, and presses Alt+Left
- **THEN** the current directory changes to `/foo/baz`

#### Scenario: Cd to parent

- **WHEN** the user is in `/foo/bar` and presses Shift+Up
- **THEN** the current directory changes to `/foo`
