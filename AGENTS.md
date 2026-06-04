# AGENTS.md

## What this is

zsh4bermudi (z4b) — a personal zsh framework replacing zsh4humans. ~1,700 lines of zsh, ~28ms startup, 137 tests.

## File layout

| Path | Purpose |
|---|---|
| `z4b.zsh` | Bootstrap: options, fpath, sources `main.zsh`. Sourced from `~/.zshenv`. |
| `main.zsh` | CLI dispatcher (`z4b init/install/load/source/update/bindkey`) + `z4b_init()` |
| `init-zle.zsh` | ZLE widgets, `_z4b_key` map, key normalization, bindkeys |
| `setup.zsh` | First-run setup (env, PATH, Homebrew, tools) |
| `fn/` | ~45 autoloaded functions. Public (`z4b-*`), internal (`-z4b-*`) |
| `fn/-z4b-*` | Internal helpers — excluded from explicit autoload, loaded on demand via fpath |
| `tests/` | zunit tests. Run with `zunit` from project root. |

## Key conventions

- **`Z4B_ROOT`** defaults to `~/.cache/zsh4bermudi`. All state lives there.
- **Bootstrap flow**: `.zshenv` → `z4b.zsh` (sets options, sources `main.zsh`) → `.zshrc` (`z4b init`)
- **Function naming**: `z4b-*` = public widgets/commands, `-z4b-*` = internal helpers
- **Autoload**: only `z4b-*` functions in `fn/` are explicitly autoloaded. `-z4b-*` are on fpath but load on demand.
- **No `NO_RCS`**: `.zshrc` must load normally.

## Testing

```sh
zunit                        # all 137 tests
zunit tests/widgets.zunit    # specific file
```

Container smoke test:
```sh
podman build -t z4b-test -f Containerfile.test .
podman run -it --rm z4b-test
```

## Zsh gotchas

- `${var:offset:CURSOR}` is a **bug** — zsh interprets `CURSOR` as a modifier. Always `${var:offset:${CURSOR}}`.
- `$history` assoc is only populated by `fc -R` in non-interactive zsh, not `print -s`.
- `LBUFFER`/`RBUFFER` are ZLE-only — must be derived from `BUFFER`/`CURSOR` in tests.
- `autoload -Uz` before using `add-zsh-hook`.
- `{/dev/null}` is a glob, not a redirect. Use `</dev/null`.

## Scoped out

tmux, SSH teleportation, WSL, vi mode, POSIX sh, oh-my-zsh compat. See `specs/backlog.md`.
