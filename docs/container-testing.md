# Container testing

z4b's zunit suite runs **non-interactively with stubbed plugins**. That makes it
fast and deterministic, but it has a structural blind spot: it can never see
whether the shell actually boots on a real OS, whether the real plugins resolve
their symbols, whether keybindings land against a real terminal, or whether a
locale the code assumes actually exists. Container testing exists to cover that
gap.

This is not theoretical. Three defects shipped marked-complete and green under
zunit (169 passing) yet were broken on a real system — see
[What this caught](#what-this-caught). Every one was invisible to the stub suite.

## The fixture

`Containerfile.test` builds a minimal Fedora image:

- **Tools:** zsh, git, curl, fzf, bat, starship.
- **Minimal locale:** only `C.utf8` is available — deliberately *no* `en_US.UTF-8`.
  This is the fixture that exposes locale-assumption bugs.
- **Baked install:** the repo is copied into `Z4B_ROOT` (`/root/.cache/zsh4bermudi`)
  and `/root/zsh4bermudi`, and `~/.zshenv` + `~/.zshrc` are written exactly as the
  real installer would. What boots in the container is what boots on a fresh machine.

## Three layers

### 1. Build-time smoke (in `Containerfile.test`)

Two `RUN` steps fail the **build** if init is broken:

```
RUN zsh -c 'source /root/.zshenv && echo "BOOTSTRAP_OK" && ...'   # bootstrap sources
RUN zsh -c 'source /root/.zshenv && source /root/.zshrc && ...'   # full z4b init
```

If `z4b init` errors, `podman build` fails. This is the cheapest gate.

### 2. Runtime smoke (`container-smoke.zsh`)

A plain zsh script (not a zunit file) that asserts real-system behavior after a
real boot with real plugins installed. Run it after building:

```sh
podman build -t z4b-test -f Containerfile.test .
podman run --rm z4b-test zsh /root/zsh4bermudi/container-smoke.zsh
# or: make container-test
```

It checks the things zunit cannot:

- **Locale:** `LC_ALL` ends up UTF-8, is actually in `locale -a`, and no subprocess
  emits a `setlocale` warning.
- **Syntax highlighting:** with `zsh-syntax-highlighting` installed, the config
  actually applied — `HIGHLIGHTERS=main brackets`, `MAXLENGTH=1024`,
  `comment=fg=96`, and `_zsh_highlight` is present.
- **Substring search:** with `zsh-history-substring-search` installed, `Up` and
  `Ctrl-P` bind to `history-substring-search-up` (not zsh's default).

### 3. Interactive PTY (manual)

Some features need a real terminal and can't be asserted from a script: live
syntax coloring, the `Ctrl-R` fzf history popup, the `Tab` completion menu,
autosuggestion ghost text. Drop into the container and drive them by hand:

```sh
podman run -it --rm z4b-test
```

then install a plugin, re-init, and exercise the keys:

```zsh
z4b install zsh-users/zsh-syntax-highlighting
exec zsh                         # re-init so the plugin wires
echo hello                       # ← echo should be colored
```

**Driving it from a terminal multiplexer** (optional). When you want the
interaction scripted rather than manual — e.g. to capture colored output for a
regression check — run the container in a split pane and send keystrokes. With
[herdr](https://herdr.dev) for example:

```sh
herdr pane split <pane> --direction down --no-focus
herdr pane run   <new> 'podman run -it --rm z4b-test'
# install + re-init, then type and capture
herdr pane send-text <new> 'echo hello'
herdr pane read    <new> --ansi | tail -2 | cat -v   # look for color escapes on 'echo'
```

Gotchas that cost time here:

- `Ctrl-R` is not a named key in most `send-keys` APIs — send the raw byte:
  `herdr pane send-text <pane> $'\x12'`.
- Read with `--ansi` and pipe through `cat -v` to see whether the typed text
  actually picked up color codes.
- A paste (`send-text`) may not trigger per-keystroke redraw; nudge the cursor
  (`send-keys Right`) to force a redraw before reading.

## When to add what

- **Pure logic** (parsing, word boundaries, the kill ring, locale selection) →
  add a zunit test. Fast, deterministic, no dependencies.
- **Real-system integration** (plugin symbol resolution, keybinding wiring
  against real terminfo, locale/PATH availability, anything that "boots") → add
  an assertion to `container-smoke.zsh`. If it needs a PTY (rendering, popups),
  it stays a manual check in layer 3 — document the steps so it's repeatable.

## What this caught

The `fix-smoke-defects` change was found entirely by this method, none of it by
zunit:

1. **Syntax highlighting never rendered.** Two call sites referenced the
   non-existent symbol `zsh_highlight`; the plugin's entry point is
   `_zsh_highlight`. zunit's stub defined `zsh_highlight`, so the unit test
   "passed" while the real plugin did nothing.
2. **History substring search wasn't wired.** The guard checked the underscored
   `zsh_history_substring_search_up`; the plugin defines the hyphenated
   `history-substring-search-up`. `Up` silently fell back to
   `up-line-or-beginning-search`.
3. **Locale fix forced a non-existent locale.** `en_US.UTF-8` was hardcoded; the
   container only has `C.utf8`, so every subprocess warned.

All three were compliance defects — the specs already mandated the correct
behavior. See `specs/changes/archive/2026-07-06-fix-smoke-defects/`.
