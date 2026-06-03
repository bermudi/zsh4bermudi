# Backlog

Explicitly deferred from z4b initial implementation. These were evaluated during planning and deliberately excluded.

## Deferred

### tmux Integration
Screen save/restore, integrated/isolated tmux sessions, custom terminfo. Requires tmux as a runtime dependency and ~500 lines of escape code juggling. Revisit if tmux usage resumes.

### SSH Teleportation
Package the entire shell environment and teleport it to a remote host over SSH. ~800 lines, requires tar-based bundling and remote bootstrap. The crown jewel of z4h but complex and rarely needed.

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
