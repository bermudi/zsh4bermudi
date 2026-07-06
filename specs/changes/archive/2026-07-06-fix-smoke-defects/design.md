# Design: fix-smoke-defects

## Context

No new behavior. These are compliance fixes: the `plugins` and `environment` specs already mandated the desired behavior, but the implementation drifted. See `proposal.md` for the defects and the container evidence.

## Defect 1 — Syntax highlighting never renders

Two sites reference the non-existent symbol `zsh_highlight`; the plugin's entry point is `_zsh_highlight`.

- `main.zsh` config block: change the guard `(( ${+functions[zsh_highlight]} ))` → `(( ${+functions[_zsh_highlight]} ))`. The body is unchanged (`HIGHLIGHTERS`, `MAXLENGTH`, comment style).
- `fn/-z4b-zle-line-pre-redraw`: change both the guard and the call from `zsh_highlight` → `_zsh_highlight`.

That single symbol correction restores both config application and live rendering, because z4b's redraw widget is the only thing driving the highlighter (z4b overrides the plugin's `zle-line-pre-redraw`).

## Defect 2 — History substring search not wired

`main.zsh` gates the wiring block on `${+functions[zsh_history_substring_search_up]}` (underscores). The plugin defines `history-substring-search-up` / `-down` (hyphens). Change the guard to check `${+functions[history-substring-search-up]}`. The body already references the correct hyphenated widget names in its `zle -N` / `bindkey` calls, so once the guard passes the wiring is correct. After the fix, Up binds to `history-substring-search-up` instead of zsh's default `up-line-or-beginning-search`.

## Defect 3 — Locale fix sets a non-existent locale

Replace the unconditional `LC_ALL=en_US.UTF-8` with availability-aware selection:

```zsh
if [[ "$LANG" != *UTF-8* ]] && [[ "$LC_ALL" != *UTF-8* ]]; then
  local _z4b_locale
  # Prefer C.UTF-8 (ubiquitous on modern glibc), then any available UTF-8 locale.
  for _z4b_locale in C.UTF-8 C.utf8 ${(f)"$(locale -a 2>/dev/null)"}; do
    if [[ "$_z4b_locale" == (*UTF-8*|*utf8*) ]] && locale -a 2>/dev/null | grep -Fxq -- "$_z4b_locale"; then
      export LC_ALL="$_z4b_locale" LANG="$_z4b_locale"
      break
    fi
  done
  # If nothing matched, leave the environment unchanged rather than forcing a bad locale.
fi
```

`locale -a` is invoked at most a couple of times during init. It is cheap (microseconds) and runs once; the cost is negligible against the ~30ms startup budget. The double check (name pattern + `grep -Fxq` against `locale -a`) guarantees we never set a locale the host cannot provide.

## Regression strategy

The zunit suite cannot catch these — it stubs the plugins and runs non-interactively, so symbol drift and locale availability are invisible. The container smoke test is the right home:

- `Containerfile.test` uses Fedora with only `C.utf8` available and no `en_US.UTF-8` — the ideal fixture for the locale case.
- Extend the eval script to assert: (a) no `setlocale` warning appears on boot, (b) with the highlighter installed, `ZSH_HIGHLIGHT_HIGHLIGHTERS` is `main brackets` and a typed line is colored, (c) Up binds to `history-substring-search-up`.
- Add a zunit test for the locale-selection logic where it can be exercised deterministically (a pure helper) so the unit layer also guards it.

## Risks

- `locale -a` availability/behavior varies across platforms (musl, macOS). Mitigation: swallow `locale -a` failures (`2>/dev/null`); if it errors or lists nothing, we set nothing and behave as before.
- Changing the redraw guard could affect users who have a plugin that genuinely defines `zsh_highlight`. None exists upstream; acceptable.
