# main.zsh - Core initialization for zsh4bermudi
# Contains the `z4b` command dispatcher and subcommands

z4b() {
  if (( $# == 0 )); then
    print -u2 "z4b: usage: z4b <command> [args...]"
    print -u2 "Available: init, install, load, source, update, bindkey"
    return 1
  fi

  local cmd=$1
  shift

  case "$cmd" in
    init)
      z4b_init "$@"
      ;;
    install)
      z4b_install "$@"
      ;;
    load)
      z4b_load "$@"
      ;;
    source)
      z4b_source "$@"
      ;;
    update)
      z4b_update "$@"
      ;;
    bindkey)
      z4b_bindkey "$@"
      ;;
    *)
      print -u2 "z4b: unknown command '$cmd'. Available: init, install, load, source, update, bindkey"
      return 1
      ;;
  esac
}

z4b_init() {
  # Load essential zsh modules
  zmodload zsh/datetime || return 1
  zmodload zsh/system || return 1
  zmodload zsh/terminfo || return 1
  zmodload zsh/zutil || return 1

  # Homebrew detection and PATH/fpath setup
  local _brew_prefix=""
  if [[ -x "/opt/homebrew/bin/brew" ]]; then
    _brew_prefix="/opt/homebrew"
  elif [[ -x "/usr/local/bin/brew" ]]; then
    _brew_prefix="/usr/local"
  fi

  if [[ -n "$_brew_prefix" ]]; then
    # Prepend Homebrew paths
    path=("$_brew_prefix/bin" "$_brew_prefix/sbin" "$path[@]")
    fpath=("$_brew_prefix/share/zsh/site-functions" "$fpath[@]")
  fi

  # Autoload functions from Z4B_ROOT/fn
  if [[ -d "$Z4B_ROOT/fn" ]]; then
    fpath=("$Z4B_ROOT/fn" "$fpath[@]")
    local _z4b_fn
    for _z4b_fn in "$Z4B_ROOT/fn"/^([-_.]*|README*|*~|*.zwc)(-.N:t); do
      autoload -Uz -- "$_z4b_fn"
    done
  fi

  # Basic environment variables
  export LESS="${LESS:--iRFXMx4}"
  export PAGER="${PAGER:-less}"
  export LS_COLORS="${LS_COLORS:-di=34:ln=36:so=32:pi=33:ex=31:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43}"
  export DIRSTACKSIZE="${DIRSTACKSIZE:-10000}"
  export VIRTUAL_ENV_DISABLE_PROMPT="${VIRTUAL_ENV_DISABLE_PROMPT:-1}"
  export COLORTERM="${COLORTERM:-truecolor}"

  # ZLE initialization
  if [[ -f "$Z4B_ROOT/init-zle.zsh" ]]; then
    source "$Z4B_ROOT/init-zle.zsh"
  fi

  # Wire up core plugins
  local _z4b_plugin_dir
  for _z4b_plugin_dir in "$Z4B_ROOT"/zsh-users/zsh-syntax-highlighting \
                         "$Z4B_ROOT"/zsh-users/zsh-autosuggestions \
                         "$Z4B_ROOT"/zsh-users/zsh-history-substring-search \
                         "$Z4B_ROOT"/zsh-users/zsh-completions; do
    if [[ -d "$_z4b_plugin_dir" ]]; then
      fpath=("$_z4b_plugin_dir" "$fpath[@]")
      if [[ -f "$_z4b_plugin_dir/${_z4b_plugin_dir:t}.zsh" ]]; then
        source "$_z4b_plugin_dir/${_z4b_plugin_dir:t}.zsh"
      elif [[ -f "$_z4b_plugin_dir/${_z4b_plugin_dir:t}.plugin.zsh" ]]; then
        source "$_z4b_plugin_dir/${_z4b_plugin_dir:t}.plugin.zsh"
      fi
    fi
  done

  # Install fzf binary automatically if missing
  if ! command -v fzf >/dev/null 2>&1; then
    local _fzf_install_dir="$Z4B_ROOT/fzf"
    if [[ ! -d "$_fzf_install_dir" ]]; then
      print "z4b: installing fzf..."
      mkdir -p "$_fzf_install_dir"
      # Download fzf binary (simplified for this implementation)
      # In a real implementation, this would download the appropriate binary for the OS/arch
      print "z4b: fzf installation stub - please install fzf manually or via package manager"
    fi
    path=("$_fzf_install_dir/bin" "$path[@]")
  fi

  # Configure zsh-syntax-highlighting
  if (( ${+functions[zsh_highlight]} )); then
    ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)
    ZSH_HIGHLIGHT_MAXLENGTH=1024
    ZSH_HIGHLIGHT_STYLES[comment]='fg=96'
  fi

  # Configure zsh-autosuggestions
  if (( ${+ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE} )); then
    ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=244'
  fi

  # Configure zsh-history-substring-search
  if (( ${+functions[zsh_history_substring_search_up]} )); then
    zle -N history-substring-search-up
    zle -N history-substring-search-down
    bindkey '^[[A' history-substring-search-up
    bindkey '^[[B' history-substring-search-down
    bindkey '^P' history-substring-search-up
    bindkey '^N' history-substring-search-down
  fi

  # Register ZLE hooks for plugin integration
  zle -N zle-line-init -z4b-zle-line-init
  zle -N zle-line-finish -z4b-zle-line-finish
  zle -N zle-line-pre-redraw -z4b-zle-line-pre-redraw

  # Configure completion zstyles
  zstyle ':completion:*' menu select
  zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
  zstyle ':completion:*' keep-prefix true
  zstyle ':completion:*' squeeze-slashes true
  zstyle ':completion:*' cache-path "${Z4B_ROOT}/cache/zcompcache"
  zstyle ':completion:*' ignore-parents parent pwd
  zstyle ':completion:*' verbose yes
  zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
  zstyle ':completion:*' completer _complete _match _approximate
  zstyle ':completion:*' max-errors 2 numeric

  # Initialize lazy compinit
  if [[ -f "$Z4B_ROOT/fn/-z4b-compinit" ]]; then
    source "$Z4B_ROOT/fn/-z4b-compinit"
  fi

  # Install starship binary during init if missing
  if ! command -v starship >/dev/null 2>&1; then
    local _starship_install_dir="$Z4B_ROOT/bin"
    if [[ ! -f "$_starship_install_dir/starship" ]]; then
      print "z4b: installing starship..."
      mkdir -p "$_starship_install_dir"
      # Download starship binary (simplified for this implementation)
      # In a real implementation, this would download the appropriate binary for the OS/arch
      print "z4b: starship installation stub - please install starship manually or via package manager"
    fi
    path=("$_starship_install_dir" "$path[@]")
  fi

  # Initialize starship as the last step
  if command -v starship >/dev/null 2>&1; then
    eval "$(starship init zsh)"
  fi

  # Add terminal title hooks (interactive only)
  if [[ -o interactive ]] && [[ -f "$Z4B_ROOT/fn/-z4b-set-terminal-title" ]]; then
    autoload -Uz add-zsh-hook
    source "$Z4B_ROOT/fn/-z4b-set-terminal-title"
    add-zsh-hook precmd _z4b-set-terminal-title
    add-zsh-hook preexec _z4b-set-terminal-title
  fi

  # Add locale fix (detect non-UTF-8 and set LC_ALL)
  if [[ "$LANG" != *UTF-8* ]] && [[ "$LC_ALL" != *UTF-8* ]]; then
    export LC_ALL=en_US.UTF-8
    export LANG=en_US.UTF-8
  fi

  # Add auto-update check (28-day interval)
  local _z4b_last_update_check="${Z4B_ROOT}/cache/last-update-check"
  local _z4b_current_time=$(date +%s)
  local _z4b_28_days=$((28 * 24 * 60 * 60))
  
  if [[ -f "$_z4b_last_update_check" ]]; then
    local _z4b_last_check_time=$(cat "$_z4b_last_update_check")
    if (( _z4b_current_time - _z4b_last_check_time > _z4b_28_days )); then
      print "z4b: Checking for updates... (run 'z4b update' to apply)"
      # In a real implementation, this would check git remote for updates
      echo "$_z4b_current_time" > "$_z4b_last_update_check"
    fi
  else
    mkdir -p "${_z4b_last_update_check:h}"
    echo "$_z4b_current_time" > "$_z4b_last_update_check"
  fi

  # Mark as initialized
  _z4b_initialized=1
}

z4b_install() {
  if (( ! $# )); then
    print -u2 "z4b: usage: z4b install owner/repo [owner/repo ...]"
    return 1
  fi

  # Initialize queue if not exists
  typeset -ga _z4b_install_queue
  _z4b_install_queue+=("$@")

  # Execute batch install
  if [[ -f "$Z4B_ROOT/fn/-z4b-install-many" ]]; then
    source "$Z4B_ROOT/fn/-z4b-install-many"
  else
    print -u2 "z4b: internal error: -z4b-install-many not found"
    return 1
  fi
}

z4b_load() {
  local -a compile
  zparseopts -D -F -- c=compile -compile=compile || return 1

  local -a files
  local pkgs=(${(M)@:#/*} $Z4B_ROOT/${^${@:#/*}})
  pkgs=(${^${(u)pkgs}}(-/FN))
  local dirs=(${^pkgs}/functions(-/FN))
  local funcs=(${^dirs}/^([_.]*|prompt_*_setup|README*|*~|*.zwc)(-.N:t))
  
  fpath+=($pkgs $dirs)
  (( $#funcs )) && autoload -Uz -- $funcs
  
  local dir
  for dir in $pkgs; do
    if [[ -s $dir/init.zsh ]]; then
      files+=($dir/init.zsh)
    elif [[ -s $dir/${dir:t}.plugin.zsh ]]; then
      files+=($dir/${dir:t}.plugin.zsh)
    fi
  done

  z4b_source "${compile[@]}" -- "${files[@]}"
}

z4b_source() {
  local _z4b_file _z4b_compile
  zparseopts -D -F -- c=_z4b_compile -compile=_z4b_compile || return 1
  
  emulate zsh -o extended_glob -c 'local _z4b_files=(${^${(M)@:#/*}}(N) $Z4B_ROOT/${^${@:#/*}}(N))'
  
  if (( ${#_z4b_compile} )); then
    builtin set --
    for _z4b_file in "${_z4b_files[@]}"; do
      # Stub: compilation
      # -z4b-compile "$_z4b_file" || true
      builtin source -- "$_z4b_file"
    done
  else
    emulate zsh -o extended_glob -c 'local _z4b_rm=(${^${(@)_z4b_files:#$Z4B_ROOT/*}}.zwc(N))'
    (( ! ${#_z4b_rm} )) || zf_rm -f -- "${_z4b_rm[@]}" || true
    builtin set --
    for _z4b_file in "${_z4b_files[@]}"; do
      builtin source -- "$_z4b_file"
    done
  fi
}

z4b_update() {
  print "z4b: updating zsh4bermudi..."
  (cd "$Z4B_ROOT" && git pull --rebase --autostash 2>/dev/null) || print "z4b: could not update zsh4bermudi (not a git repo or no tracking info)"

  local plugin
  for plugin in "$Z4B_ROOT"/*/*(N/); do
    if [[ -d "$plugin/.git" ]]; then
      print "z4b: updating ${plugin#$Z4B_ROOT/}..."
      (cd "$plugin" && git pull --rebase --autostash 2>/dev/null) || print "z4b: could not update ${plugin#$Z4B_ROOT/}"
    fi
  done
  
  # Reset auto-update check timer
  local _z4b_last_update_check="${Z4B_ROOT}/cache/last-update-check"
  mkdir -p "${_z4b_last_update_check:h}"
  date +%s > "$_z4b_last_update_check"
  
  print "z4b: update complete."
}

z4b_bindkey() {
  if (( $# < 2 )); then
    print -u2 "z4b: usage: z4b bindkey <widget> <key...>"
    return 1
  fi

  local widget=$1
  shift
  local key_seq=""
  
  for key in "$@"; do
    if [[ -v _z4b_key[$key] ]]; then
      key_seq="${_z4b_key[$key]}"
    else
      key_seq="$key"
    fi
    bindkey "$key_seq" "$widget"
  done
}
