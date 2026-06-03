# z4b.zsh - Bootstrap loader for zsh4bermudi
# Sourced by ~/.zshenv

# Ensure we are running in zsh
if [[ -z "$ZSH_VERSION" ]]; then
  print -u2 "z4b: This framework requires zsh."
  return 1
fi

# Validate Z4B_ROOT
if [[ -z "$Z4B_ROOT" ]]; then
  print -u2 "z4b: Z4B_ROOT is not set. Please set it in ~/.zshenv before sourcing z4b.zsh."
  return 1
fi

if [[ ! -d "$Z4B_ROOT" ]]; then
  print -u2 "z4b: Z4B_ROOT directory does not exist: $Z4B_ROOT"
  return 1
fi

# Essential options
setopt NO_GLOBAL_RCS        # Disable /etc/zshrc and /etc/zshenv
setopt NO_SH_WORD_SPLIT     # Standard zsh word splitting
setopt EXTENDED_GLOB        # Enable extended globbing

# Foundation of word system
WORDCHARS=''

# 200ms escape key lag
KEYTIMEOUT=20

# Recovery mode: minimal bindings in case of failure
if [[ -z "$_z4b_recovery" ]]; then
  bindkey -e
  bindkey '^C' kill-whole-line
  bindkey '^D' delete-char-or-list
fi

# Source main.zsh to make the z4b command available
[[ -f "$Z4B_ROOT/main.zsh" ]] && source "$Z4B_ROOT/main.zsh"

# Mark as sourced
_z4b_bootstrapped=1
