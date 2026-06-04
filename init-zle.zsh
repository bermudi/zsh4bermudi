#!/usr/bin/env zsh
# init-zle.zsh - Key normalization, ZLE widget registration, default bindkeys, named key map

# Named key map for human-readable bindkey
typeset -gA _z4b_key=(
  Tab                         '^I'
  Space                       ' '
  Enter                       '^M'
  Escape                      '^['
  Ctrl+/                      '^_'
  Ctrl+_                      '^_'
  Ctrl+Space                  '^ '
  Alt+Space                   '^[ '
  Shift+Tab                   '^[[Z'

  Up                          '^[[A'
  Down                        '^[[B'
  Right                       '^[[C'
  Left                        '^[[D'
  Home                        '^[[H'
  End                         '^[[F'
  Insert                      '^[[2~'
  Delete                      '^[[3~'
  PageUp                      '^[[5~'
  PageDown                    '^[[6~'
  Backspace                   '^?'

  Shift+Up                    '^[[1;2A'
  Shift+Down                  '^[[1;2B'
  Shift+Right                 '^[[1;2C'
  Shift+Left                  '^[[1;2D'
  Shift+Home                  '^[[1;2H'
  Shift+End                   '^[[1;2F'
  Shift+Insert                '^[[2;2~'
  Shift+Delete                '^[[3;2~'
  Shift+PageUp                '^[[5;2~'
  Shift+PageDown              '^[[6;2~'
  Shift+Backspace             '^?'

  Alt+Up                      '^[[1;3A'
  Alt+Down                    '^[[1;3B'
  Alt+Right                   '^[[1;3C'
  Alt+Left                    '^[[1;3D'
  Alt+Home                    '^[[1;3H'
  Alt+End                     '^[[1;3F'
  Alt+Insert                  '^[[2;3~'
  Alt+Delete                  '^[[3;3~'
  Alt+PageUp                  '^[[5;3~'
  Alt+PageDown                '^[[6;3~'
  Alt+Backspace               '^[^?'

  Alt+Shift+Up                '^[[1;4A'
  Alt+Shift+Down              '^[[1;4B'
  Alt+Shift+Right             '^[[1;4C'
  Alt+Shift+Left              '^[[1;4D'
  Alt+Shift+Home              '^[[1;4H'
  Alt+Shift+End               '^[[1;4F'
  Alt+Shift+Insert            '^[[2;4~'
  Alt+Shift+Delete            '^[[3;4~'
  Alt+Shift+PageUp            '^[[5;4~'
  Alt+Shift+PageDown          '^[[6;4~'
  Alt+Shift+Backspace         '^[^H'

  Ctrl+Up                     '^[[1;5A'
  Ctrl+Down                   '^[[1;5B'
  Ctrl+Right                  '^[[1;5C'
  Ctrl+Left                   '^[[1;5D'
  Ctrl+Home                   '^[[1;5H'
  Ctrl+End                    '^[[1;5F'
  Ctrl+Insert                 '^[[2;5~'
  Ctrl+Delete                 '^[[3;5~'
  Ctrl+PageUp                 '^[[5;5~'
  Ctrl+PageDown               '^[[6;5~'
  Ctrl+Backspace              '^H'

  Ctrl+Shift+Up               '^[[1;6A'
  Ctrl+Shift+Down             '^[[1;6B'
  Ctrl+Shift+Right            '^[[1;6C'
  Ctrl+Shift+Left             '^[[1;6D'
  Ctrl+Shift+Home             '^[[1;6H'
  Ctrl+Shift+End              '^[[1;6F'
  Ctrl+Shift+Insert           '^[[2;6~'
  Ctrl+Shift+Delete           '^[[3;6~'
  Ctrl+Shift+PageUp           '^[[5;6~'
  Ctrl+Shift+PageDown         '^[[6;6~'
  Ctrl+Shift+Backspace        '^?'

  Ctrl+Alt+Up                 '^[[1;7A'
  Ctrl+Alt+Down               '^[[1;7B'
  Ctrl+Alt+Right              '^[[1;7C'
  Ctrl+Alt+Left               '^[[1;7D'
  Ctrl+Alt+Home               '^[[1;7H'
  Ctrl+Alt+End                '^[[1;7F'
  Ctrl+Alt+Insert             '^[[2;7~'
  Ctrl+Alt+Delete             '^[[3;7~'
  Ctrl+Alt+PageUp             '^[[5;7~'
  Ctrl+Alt+PageDown           '^[[6;7~'
  Ctrl+Alt+Backspace          '^[^H'

  Ctrl+Alt+Shift+Up           '^[[1;8A'
  Ctrl+Alt+Shift+Down         '^[[1;8B'
  Ctrl+Alt+Shift+Right        '^[[1;8C'
  Ctrl+Alt+Shift+Left         '^[[1;8D'
  Ctrl+Alt+Shift+Home         '^[[1;8H'
  Ctrl+Alt+Shift+End          '^[[1;8F'
  Ctrl+Alt+Shift+Insert       '^[[2;8~'
  Ctrl+Alt+Shift+Delete       '^[[3;8~'
  Ctrl+Alt+Shift+PageUp       '^[[5;8~'
  Ctrl+Alt+Shift+PageDown     '^[[6;8~'
  Ctrl+Alt+Shift+Backspace    '^?'
)

typeset -grA _z4b_key

# Key normalization: map TTY, Urxvt, iTerm2, Tmux to xterm equivalents
local keymap
for keymap in emacs viins vicmd; do
  # TTY sends different key codes
  bindkey -M $keymap -s '^[[1~'    '^[[H'    # home
  bindkey -M $keymap -s '^[[4~'    '^[[F'    # end

  # Urxvt sends different key codes
  bindkey -M $keymap -s '^[[7~'    '^[[H'    # home
  bindkey -M $keymap -s '^[[8~'    '^[[F'    # end
  bindkey -M $keymap -s '^[Oa'     '^[[1;5A' # ctrl+up
  bindkey -M $keymap -s '^[Ob'     '^[[1;5B' # ctrl+down
  bindkey -M $keymap -s '^[Od'     '^[[1;5D' # ctrl+left
  bindkey -M $keymap -s '^[Oc'     '^[[1;5C' # ctrl+right
  bindkey -M $keymap -s '^[[7\^'   '^[[1;5H' # ctrl+home
  bindkey -M $keymap -s '^[[8\^'   '^[[1;5F' # ctrl+end
  bindkey -M $keymap -s '^[[3\^'   '^[[3;5~' # ctrl+delete
  bindkey -M $keymap -s '^[^[[A'   '^[[1;3A' # alt+up
  bindkey -M $keymap -s '^[^[[B'   '^[[1;3B' # alt+down
  bindkey -M $keymap -s '^[^[[D'   '^[[1;3D' # alt+left
  bindkey -M $keymap -s '^[^[[C'   '^[[1;3C' # alt+right
  bindkey -M $keymap -s '^[^[[7~'  '^[[1;3H' # alt+home
  bindkey -M $keymap -s '^[^[[8~'  '^[[1;3F' # alt+end
  bindkey -M $keymap -s '^[^[[3~'  '^[[3;3~' # alt+delete
  bindkey -M $keymap -s '^[[a'     '^[[1;2A' # shift+up
  bindkey -M $keymap -s '^[[b'     '^[[1;2B' # shift+down
  bindkey -M $keymap -s '^[[d'     '^[[1;2D' # shift+left
  bindkey -M $keymap -s '^[[c'     '^[[1;2C' # shift+right
  bindkey -M $keymap -s '^[[7$'    '^[[1;2H' # shift+home
  bindkey -M $keymap -s '^[[8$'    '^[[1;2F' # shift+end

  # Tmux sends different key codes
  bindkey -M $keymap -s '^[[1~'    '^[[H'    # home
  bindkey -M $keymap -s '^[[4~'    '^[[F'    # end
  bindkey -M $keymap -s '^[^[[A'   '^[[1;3A' # alt+up
  bindkey -M $keymap -s '^[^[[B'   '^[[1;3B' # alt+down
  bindkey -M $keymap -s '^[^[[D'   '^[[1;3D' # alt+left
  bindkey -M $keymap -s '^[^[[C'   '^[[1;3C' # alt+right
  bindkey -M $keymap -s '^[^[[1~'  '^[[1;3H' # alt+home
  bindkey -M $keymap -s '^[^[[4~'  '^[[1;3F' # alt+end
  bindkey -M $keymap -s '^[^[[3~'  '^[[3;3~' # alt+delete

  # iTerm2 sends different key codes
  bindkey -M $keymap -s '^[^[[A'   '^[[1;3A' # alt+up
  bindkey -M $keymap -s '^[^[[B'   '^[[1;3B' # alt+down
  bindkey -M $keymap -s '^[^[[D'   '^[[1;3D' # alt+left
  bindkey -M $keymap -s '^[^[[C'   '^[[1;3C' # alt+right
  bindkey -M $keymap -s '^[[1;9A'  '^[[1;3A' # alt+up
  bindkey -M $keymap -s '^[[1;9B'  '^[[1;3B' # alt+down
  bindkey -M $keymap -s '^[[1;9D'  '^[[1;3D' # alt+left
  bindkey -M $keymap -s '^[[1;9C'  '^[[1;3C' # alt+right
  bindkey -M $keymap -s '^[[1;9H'  '^[[1;3H' # alt+home
  bindkey -M $keymap -s '^[[1;9F'  '^[[1;3F' # alt+end
done

# Register ZLE widgets
zle -N z4b-accept-line
zle -N z4b-forward-word
zle -N z4b-kill-word
zle -N z4b-backward-word
zle -N z4b-backward-kill-word
zle -N z4b-forward-zword
zle -N z4b-backward-zword
zle -N z4b-expand
zle -N z4b-stash-buffer
zle -N z4b-beginning-of-buffer
zle -N z4b-end-of-buffer
zle -N z4b-fzf-history
zle -N z4b-fzf-dir-history
zle -N z4b-cd-down
zle -N z4b-cd-back
zle -N z4b-cd-forward
zle -N z4b-cd-up
zle -N z4b-fzf-complete

function z4b-beginning-of-buffer() { CURSOR=0 }
function z4b-end-of-buffer() { CURSOR=${#BUFFER} }

# Default bindings
# Move cursor one char backward/forward
bindkey '^[[D' backward-char                   # left
bindkey '^[[C' forward-char                    # right

# Move cursor one line up/down or fetch history
bindkey '^P'      up-line-or-beginning-search  # ctrl+p
bindkey '^[[A'    up-line-or-beginning-search  # up
bindkey '^N'      down-line-or-beginning-search # ctrl+n
bindkey '^[[B'    down-line-or-beginning-search # down

# Move cursor to beginning/end of line
bindkey '^[[H'    beginning-of-line            # home
bindkey '^[[F'    end-of-line                  # end

# Move cursor to beginning/end of buffer
bindkey '^[[1;5H' z4b-beginning-of-buffer      # ctrl+home
bindkey '^[[1;3H' z4b-beginning-of-buffer      # alt+home
bindkey '^[[1;5F' z4b-end-of-buffer            # ctrl+end
bindkey '^[[1;3F' z4b-end-of-buffer            # alt+end

# Delete character
bindkey '^D'      delete-char                  # ctrl+d
bindkey '^[[3~'   delete-char                  # delete

# Delete next word
bindkey '^[d'     z4b-kill-word                # alt+d
bindkey '^[D'     z4b-kill-word                # alt+D
bindkey '^[[3;5~' z4b-kill-word                # ctrl+del
bindkey '^[[3;3~' z4b-kill-word                # alt+del

# Delete previous word
bindkey '^W'      z4b-backward-kill-word       # ctrl+w
bindkey '^[^?'    z4b-backward-kill-word       # alt+bs
bindkey '^[^H'    z4b-backward-kill-word       # ctrl+alt+bs

# Move cursor one zsh word forward/backward
bindkey '^[[1;6C' z4b-forward-zword            # ctrl+shift+right
bindkey '^[[1;6D' z4b-backward-zword           # ctrl+shift+left

# Delete line before cursor / all lines
bindkey '^[k'     backward-kill-line           # alt+k
bindkey '^[K'     backward-kill-line           # alt+K
bindkey '^[j'     kill-buffer                  # alt+j
bindkey '^[J'     kill-buffer                  # alt+J

# Push buffer to ephemeral history
bindkey '^[o'     z4b-stash-buffer             # alt+o
bindkey '^[O'     z4b-stash-buffer             # alt+O

# Undo and redo
bindkey '^[[Z'    undo                         # shift+tab
bindkey '^[/'     redo                         # alt+/

# Expand alias/glob/parameter
bindkey '^ '      z4b-expand                   # ctrl+space

# Generic command completion
bindkey '^I'      expand-or-complete           # tab

# Show help for the command at cursor
bindkey '^[h'     run-help                     # alt+h
bindkey '^[H'     run-help                     # alt+H

# Do nothing
bindkey '^[[5~'   self-insert                  # pageup
bindkey '^[[6~'   self-insert                  # pagedown

# Move cursor one word backward/forward
bindkey '^[b'     z4b-backward-word            # alt+b
bindkey '^[B'     z4b-backward-word            # alt+B
bindkey '^[[1;3D' z4b-backward-word            # alt+left
bindkey '^[[1;5D' z4b-backward-word            # ctrl+left
bindkey '^[f'     z4b-forward-word             # alt+f
bindkey '^[F'     z4b-forward-word             # alt+F
bindkey '^[[1;3C' z4b-forward-word             # alt+right
bindkey '^[[1;5C' z4b-forward-word             # ctrl+right

# Clear screen
bindkey '^L'      clear-screen                 # ctrl+l

# fzf history and directory navigation
bindkey '^R'      z4b-fzf-history              # ctrl+r
bindkey '^[r'     z4b-fzf-dir-history          # alt+r
bindkey '^[[1;2B' z4b-cd-down                  # shift+down
bindkey '^[[1;3A' z4b-cd-back                  # alt+up (or alt+left for back)
bindkey '^[[1;3D' z4b-cd-back                  # alt+left
bindkey '^[[1;3C' z4b-cd-forward               # alt+right
bindkey '^[[1;2A' z4b-cd-up                    # shift+up
