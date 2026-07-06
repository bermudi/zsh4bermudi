# zsh4bermudi (z4b)

A personal zsh framework. ~1,700 lines, ~28ms startup.

Replaces zsh4humans with something smaller, auditable, and fast.

## What it does

- Bootstrap via `~/.zshenv` → `z4b.zsh` (sets options, sources `main.zsh`)
- Init via `~/.zshrc` → `z4b init` (plugins, completion, starship, keybindings)
- Smart word navigation, kill ring, directory stack, fzf history, autosuggestions
- Lazy `compinit` on first prompt
- Key normalization across terminals (xterm/Tmux/iTerm2/Urxvt)

## Architecture

```
z4b.zsh          # Bootstrap: options, fpath, sources main.zsh
main.zsh         # CLI dispatcher (init/install/load/source/update/bindkey)
init-zle.zsh     # ZLE widgets, key maps, bindkeys
setup.zsh        # First-run setup (env, PATH, tools)
fn/              # ~45 autoloaded functions (public + internal)
```

## Try it

Build and run in a container:

```sh
podman build -t z4b-test -f Containerfile.test .
podman run -it --rm z4b-test
```

Live-edit your checkout inside the container:

```sh
podman run -it --rm -v $(pwd):/root/.cache/zsh4bermudi z4b-test
```

## Install

Point `Z4B_ROOT` at this repo and source the bootstrap:

```sh
# ~/.zshenv
export Z4B_ROOT="${Z4B_ROOT:-$HOME/.cache/zsh4bermudi}"
[[ -f "$Z4B_ROOT/z4b.zsh" ]] && source "$Z4B_ROOT/z4b.zsh"
```

```sh
# ~/.zshrc
z4b init || return
```

See `zshrc.template` for keybinding and option examples.

## Test

Requires [zunit](https://github.com/zunit-zsh/zunit) and [revolver](https://github.com/zunit-zsh/revolver):

```sh
zunit                          # run all tests
zunit tests/widgets.zunit      # single file
```

The zunit suite is non-interactive with stubbed plugins, so it can't catch
real-system integration bugs. For that, use the container smoke test:

```sh
make container-test            # build image + run container-smoke.zsh
```

See [`docs/container-testing.md`](docs/container-testing.md) for the full
methodology, including interactive PTY checks for live highlighting, fzf
history, and completion.

## Dependencies

- zsh 5.9+
- git
- fzf
- starship prompt

## Not in scope

tmux, SSH teleportation, WSL, vi mode, oh-my-zsh compat. See `specs/backlog.md`.
