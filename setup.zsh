#!/usr/bin/env zsh
# setup.zsh - Installer script for zsh4bermudi
# Run directly, not sourced.

set -e

# Color output
local RED='\033[0;31m'
local GREEN='\033[0;32m'
local YELLOW='\033[1;33m'
local NC='\033[0m' # No Color

print_status() {
  print -P "${GREEN}==>${NC} $1"
}

print_error() {
  print -P "${RED}Error:${NC} $1" >&2
}

print_warning() {
  print -P "${YELLOW}Warning:${NC} $1"
}

# Check dependencies
check_dependencies() {
  local missing=()
  
  if ! command -v zsh >/dev/null 2>&1; then
    missing+=("zsh")
  fi
  
  if ! command -v git >/dev/null 2>&1; then
    missing+=("git")
  fi
  
  if ! command -v curl >/dev/null 2>&1 && ! command -v wget >/dev/null 2>&1; then
    missing+=("curl or wget")
  fi
  
  if [[ ${#missing[@]} -gt 0 ]]; then
    print_error "Missing required dependencies: ${missing[*]}"
    print_error "Please install them before running this script."
    exit 1
  fi
  
  print_status "All dependencies are satisfied."
}

# Clone or update repository
setup_repository() {
  local target_dir="${HOME}/.cache/zsh4bermudi"
  
  if [[ -d "$target_dir" ]]; then
    print_status "Updating existing installation at $target_dir"
    (cd "$target_dir" && git pull --rebase --autostash)
  else
    print_status "Cloning zsh4bermudi to $target_dir"
    mkdir -p "${target_dir:h}"
    git clone https://github.com/bermudi/zsh4bermudi.git "$target_dir"
  fi
}

# Write ~/.zshenv
setup_zshenv() {
  local zshenv="${HOME}/.zshenv"
  local z4b_root_line="export Z4B_ROOT=\${Z4B_ROOT:-\$HOME/.cache/zsh4bermudi}"
  local source_line="[[ -f \"\$Z4B_ROOT/z4b.zsh\" ]] && source \"\$Z4B_ROOT/z4b.zsh\""
  
  if [[ -f "$zshenv" ]]; then
    if grep -q "Z4B_ROOT" "$zshenv" && grep -q "z4b.zsh" "$zshenv"; then
      print_status "~/.zshenv already contains z4b configuration."
      return 0
    fi
    
    print_warning "~/.zshenv exists but does not contain z4b configuration."
    print_status "Appending z4b configuration to ~/.zshenv"
    print -P "\n$z4b_root_line\n$source_line" >> "$zshenv"
  else
    print_status "Creating ~/.zshenv with z4b configuration."
    print -P "$z4b_root_line\n$source_line" > "$zshenv"
  fi
}

# Create ~/.zshrc template if it doesn't exist
setup_zshrc() {
  local zshrc="${HOME}/.zshrc"
  
  if [[ ! -f "$zshrc" ]]; then
    print_status "Creating ~/.zshrc template."
    cat << 'EOF' > "$zshrc"
# zsh4bermudi configuration template

# 1. Install extra plugins (core plugins are auto-installed by init)
# z4b install user/some-plugin

# 2. Initialize everything (installs core plugins if missing, sets up env, ZLE, completion, starship)
z4b init || return

# 3. Key bindings (examples using named keys)
# z4b bindkey z4b-backward-kill-word  Ctrl+Backspace
# z4b bindkey z4b-backward-kill-zword Ctrl+Alt+Backspace
# z4b bindkey undo Ctrl+/ Shift+Tab
# z4b bindkey redo Alt+/

# 4. User options
# setopt glob_dots
# setopt no_auto_menu

# 5. User environment and aliases (sourced after init to control ordering)
# [ -f ~/.env.zsh ] && source ~/.env.zsh
# [ -f ~/.shrc ] && source ~/.shrc

# 6. fzf navigation bindings (already set by default, but can be customized)
# bindkey '^R' z4b-fzf-history              # ctrl+r: history search
# bindkey '^[r' z4b-fzf-dir-history         # alt+r: directory history
# bindkey '^[[1;2B' z4b-cd-down             # shift+down: child directory picker
# bindkey '^[[1;3D' z4b-cd-back             # alt+left: directory stack back
# bindkey '^[[1;3C' z4b-cd-forward          # alt+right: directory stack forward
# bindkey '^[[1;2A' z4b-cd-up               # shift+up: parent directory
EOF
  else
    print_status "~/.zshrc already exists. Skipping template creation."
  fi
}

# Main execution
main() {
  print_status "Starting zsh4bermudi installation..."
  
  check_dependencies
  setup_repository
  setup_zshenv
  setup_zshrc
  
  print_status "Installation complete!"
  print_status "Please restart your shell or run: source ~/.zshenv && z4b init"
}

main "$@"
