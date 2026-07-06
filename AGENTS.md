# AGENTS.md

## What this is

zsh4bermudi (z4b) — a personal zsh framework replacing zsh4humans. Single-user, emacs-mode only, optimized for fast (~30ms) interactive startup.

## Architecture

z4h-style bootstrap, all state under `Z4B_ROOT` (defaults to `~/.cache/zsh4bermudi`):

```
.zshenv  →  z4b.zsh (sets options/fpath, sources main.zsh)  →  .zshrc (z4b init)
```

Four entry points at the root — the rest of the layout is `ls`-discoverable:
`z4b.zsh` (bootstrap), `main.zsh` (CLI dispatcher + `z4b_init`), `init-zle.zsh` (ZLE/widgets/bindkeys), `setup.zsh` (installer). Autoloaded functions live in `fn/`.

## Conventions

- **Naming**: `z4b-*` = public widgets/commands; `-z4b-*` = internal helpers.
- **Autoload**: `z4b init` autoloads everything in `fn/` — both `z4b-*` (public) and `-z4b-*` (internal). Both must be autoloaded to be callable via fpath; the `-z4b-*` distinction is naming/convention only.
- **No `NO_RCS`**: `.zshrc` must load normally.
- **Changes are spec'd first** under `specs/changes/` (litespec), archived to `specs/changes/archive/` when done. Deliberate exclusions and rationale live in `specs/backlog.md`.

## Workflow

```sh
zunit                        # full suite
zunit tests/widgets.zunit    # one file
```

Container smoke test (fresh install):
```sh
podman build -t z4b-test -f Containerfile.test .
podman run -it --rm z4b-test
```

## Constraints

- **Startup time is a first-class target (~30ms).** Don't add work to the init path or autoload-at-source without measuring the impact.

## Zsh gotchas

Hard-won. Read before touching ZLE or tests.

- `${var:offset:CURSOR}` is a **bug** — zsh reads `CURSOR` as a modifier. Always `${var:offset:${CURSOR}}`.
- `$history` assoc is only populated by `fc -R` in non-interactive zsh, not `print -s`.
- `LBUFFER`/`RBUFFER` are ZLE-only — derive from `BUFFER`/`CURSOR` in tests.
- `autoload -Uz` before using `add-zsh-hook`.
- `{/dev/null}` is a glob, not a redirect. Use `</dev/null`.

## Scoped out

tmux, SSH teleportation, WSL, vi mode, POSIX sh, oh-my-zsh compat — deliberately. See `specs/backlog.md`.
