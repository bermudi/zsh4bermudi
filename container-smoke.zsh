#!/usr/bin/env zsh
# Container regression smoke test. Run inside the z4b-test image, e.g.:
#   podman build -t z4b-test -f Containerfile.test .
#   podman run --rm z4b-test zsh /root/zsh4bermudi/container-smoke.zsh
#
# The repo is COPY'd to /root/zsh4bermudi during the image build. This script
# exercises the fixes for change `fix-smoke-defects` on a real Fedora system
# that has only C.utf8 (no en_US.UTF-8) — the fixture that exposed the bugs:
#   1. locale: never force a locale the host cannot provide
#   2. syntax highlighting: config actually applied after plugin load
#   3. history substring search: Up bound to the plugin widget
#
# These behaviors are invisible to the stub-based zunit suite, which is why
# they live here instead of in tests/*.zunit.

emulate -L zsh
setopt extended_glob
pass=0; fail=0
ok()  { print -P "%F{green}PASS%f $1"; (( pass++ )); }
bad() { print -P "%F{red}FAIL%f $1${2:+ — $2}"; (( fail++ )); }

echo "=== 1. Locale: choose an available UTF-8 locale, emit no warnings ==="
lc=$(zsh -i -c 'print -rn -- "$LC_ALL"' 2>/tmp/z4b_locerr)
warn=$(cat /tmp/z4b_locerr 2>/dev/null)
if [[ "$lc" == (*UTF-8*|*utf8*) ]]; then ok "LC_ALL is UTF-8 ($lc)"; else bad "LC_ALL not UTF-8" "$lc"; fi
if [[ -z "$warn" ]]; then ok "no setlocale warning on boot"; else bad "locale warning present" "$warn"; fi
if locale -a 2>/dev/null | grep -Fxq -- "$lc"; then ok "chosen locale exists in locale -a"; else bad "chosen locale not in locale -a" "$lc"; fi

echo; echo "=== 2 & 3. Plugins: highlighter config + substring-search binding ==="
# Install both plugins, then re-init so z4b_init wires them, and probe in one go.
probe=$(zsh -i -c '
  z4b install zsh-users/zsh-syntax-highlighting >/dev/null 2>&1
  z4b install zsh-users/zsh-history-substring-search >/dev/null 2>&1
  exec zsh -i -c "
    print HL=\${ZSH_HIGHLIGHT_HIGHLIGHTERS[*]}
    print ML=\${ZSH_HIGHLIGHT_MAXLENGTH:-unset}
    print CS=\${ZSH_HIGHLIGHT_STYLES[comment]:-unset}
    print FN=\${+functions[_zsh_highlight]}
    print UP=\$(bindkey \"^[[A\" 2>/dev/null)
    print CP=\$(bindkey \"^P\" 2>/dev/null)
  "
' 2>/dev/null)

hl=$(print -r -- "$probe" | sed -n 's/^HL=//p')
ml=$(print -r -- "$probe" | sed -n 's/^ML=//p')
cs=$(print -r -- "$probe" | sed -n 's/^CS=//p')
fn=$(print -r -- "$probe" | sed -n 's/^FN=//p')
up=$(print -r -- "$probe" | sed -n 's/^UP=//p')
cp=$(print -r -- "$probe" | sed -n 's/^CP=//p')

[[ "$hl" == *main* && "$hl" == *brackets* ]] && ok "highlighters main+brackets ($hl)" || bad "highlighters wrong" "$hl"
[[ "$ml" == "1024" ]] && ok "ZSH_HIGHLIGHT_MAXLENGTH=1024" || bad "MAXLENGTH wrong" "$ml"
[[ "$cs" == "fg=96" ]] && ok "comment style fg=96" || bad "comment style wrong" "$cs"
[[ "$fn" == "1" ]] && ok "_zsh_highlight present" || bad "_zsh_highlight missing"
[[ "$up" == *history-substring-search-up* ]] && ok "Up → history-substring-search-up" || bad "Up not bound to substring search" "$up"
[[ "$cp" == *history-substring-search-up* ]] && ok "Ctrl-P → history-substring-search-up" || bad "Ctrl-P not bound to substring search" "$cp"

echo; echo "========================================"
print -P "RESULT: %F{green}$pass passed%f, %F{red}$fail failed%f"
exit $(( fail > 0 ))
