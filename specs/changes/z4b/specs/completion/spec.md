# completion

## ADDED Requirements

### Requirement: Lazy Compinit with Dump Caching

The system SHALL run `compinit` lazily after the first prompt renders. It MUST cache the completion dump at `$Z4B_ROOT/cache/zcompdump-$EUID-$ZSH_VERSION` and invalidate it only when completion function files change (detected by mtime signature comparison).

#### Scenario: First startup (no cache)
- **WHEN** z4b starts for the first time and no dump cache exists
- **THEN** compinit runs, generates the dump, compiles it to .zwc, and subsequent startups use the cache

#### Scenario: Cached startup
- **WHEN** z4b starts and the dump cache signature matches
- **THEN** compinit runs with `-C` (skip rebuild), loading from the cached dump

### Requirement: Bash Completion Compatibility

The system SHALL load `bashcompinit` to support completion functions written for bash.

#### Scenario: Terraform completion
- **WHEN** terraform is installed and the user tab-completes after `terraform`
- **THEN** bash-based terraform completions work

### Requirement: Language-Specific Completion Wiring

The system SHALL wire up completions for installed tools: cargo, gh, kubectl, helm, kitty, oc, rustup (via custom completion functions), and terraform, vault, packer, gcloud, aws (via their native bash completions). Wiring MUST only happen when the tool is actually installed.

#### Scenario: kubectl completion
- **WHEN** kubectl is installed and the user tab-completes after `kubectl get`
- **THEN** kubectl completions appear

#### Scenario: Tool not installed
- **WHEN** kubectl is not installed
- **THEN** no kubectl completion wiring is attempted

### Requirement: Completion Styling

The system SHALL configure completion to: ignore case (`m:{a-z}={A-Z}`), squeeze slashes, not list types, cache results, and ignore internal parameters (`_*` patterns). `ZLE_REMOVE_SUFFIX_CHARS` SHALL be empty to prevent space removal after `|` on tab-complete.

#### Scenario: Case-insensitive completion
- **WHEN** the user types `git sta` and presses Tab
- **THEN** `stash` and `stage` are both offered regardless of case

#### Scenario: Space preserved after pipe
- **WHEN** the user types `echo foo |` and presses Tab, completing a command
- **THEN** the space after `|` is preserved
