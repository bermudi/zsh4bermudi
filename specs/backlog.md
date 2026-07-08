# Backlog

Features deferred and tradeoffs accepted during z4b's initial implementation. Evaluated during planning; tracked here so the rationale survives.

## Deferred

### tmux Integration
Screen save/restore, integrated/isolated tmux sessions, custom terminfo. Requires tmux as a runtime dependency and ~500 lines of escape code juggling. Revisit if tmux usage resumes.

### SSH Teleportation
Bundle the shell environment and ship it to a remote host over SSH. ~800 lines, tar-based bundling + remote bootstrap. z4h's largest feature; deferred for complexity and rare use.

### WSL Support
Windows Subsystem for Linux detection and integration (`-z4h-init-wsl`, Windows path detection). Platform-specific.

### iTerm2 Shell Integration
Semantic markup for iTerm2 (`-z4h-enable-iterm2-integration`). Platform-specific.

### direnv Integration
Automatic `.envrc` sourcing. Requires direnv as a dependency and hook management.

### vi Mode
z4b is emacs-mode only. Adding vi mode would double the bindkey surface area and conflict with the key normalization layer.

### POSIX sh Bootstrap
z4h's installer works in bare sh. z4b requires zsh. Trade readability for portability.

### Oh My Zsh Compatibility
No plan to support oh-my-zsh plugins or oh-my-zsh-specific APIs.

### Numeric Prefix on Word Widgets
z4h word widgets respect `$NUMERIC` (e.g., `2 Ctrl+Right` skips 2 words). Deliberately excluded — adds complexity with negligible daily value.

### macOS Option-as-Alt
z4h maps macOS Option key characters to their Alt equivalents. Platform-specific, adds ~50 lines of character mapping.

## Security tradeoffs

### compinit Insecure-Directory Check (`-u`)
`-z4b-compinit` runs `compinit -u`, skipping compinit's check for world/group-writable `fpath` entries. Default compinit prompts on those and, non-interactive, aborts without writing the dump — `|| true` masked the failure. `-u` also disables protection against a trojaned group-writable completion dir. Single-user, so acceptable; revisit if that threat matters (scope `-u` to non-interactive only, or audit `fpath` perms). See `44ac535`.
