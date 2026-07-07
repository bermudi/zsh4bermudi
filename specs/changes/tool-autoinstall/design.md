# Design: tool-autoinstall

## Shape

Three new internal helpers under `fn/` (autoloaded, `-z4b-*` convention), wired
into `z4b_init` where the stubs currently are.

### `-z4b-starship-asset` (pure, unit-tested)

Maps the running platform to a starship release asset name. No network — this is
the only piece worth unit-testing in isolation.

```
uname -m:  x86_64|amd64 → x86_64   | aarch64|arm64 → aarch64   | else → fail
uname -s:  Linux → unknown-linux-gnu | Darwin → apple-darwin     | else → fail
prints: starship-<arch>-<os>     (what the release URL path component is)
```

### `-z4b-install-starship`

`$(-z4b-starship-asset)` → build the `…/releases/latest/download/<asset>.tar.gz`
URL → `curl -fsSL` (fallback `wget -qO-`) piped to `tar -xzf - -C "$Z4B_ROOT/bin"`.

Errors (unsupported platform, no curl/wget, download/extract failure, no network)
print one line to stderr and `return 1`; they never abort init.

### `-z4b-install-fzf`

`git clone --depth 1 https://github.com/junegunn/fzf "$Z4B_ROOT/fzf"` then
`"$Z4B_ROOT/fzf/install" --bin`, which places the prebuilt binary at
`$Z4B_ROOT/fzf/bin/fzf` (the path canon requires). Same error discipline.

### Wiring in `main.zsh`

```
# fzf
if ! command -v fzf >/dev/null 2>&1; then
  [[ -z "$Z4B_NO_TOOL_INSTALL" && ! -x "$Z4B_ROOT/fzf/bin/fzf" ]] && -z4b-install-fzf
  path=("$Z4B_ROOT/fzf/bin" "$path[@]")
fi
...
# starship
if ! command -v starship >/dev/null 2>&1; then
  [[ -z "$Z4B_NO_TOOL_INSTALL" && ! -x "$Z4B_ROOT/bin/starship" ]] && -z4b-install-starship
  path=("$Z4B_ROOT/bin" "$path[@]")
fi
```

- `Z4B_NO_TOOL_INSTALL` is the general offline flag — set in
  `tests/_support/bootstrap` so the whole zunit suite runs offline. Tests that
  need to simulate a missing fzf strip its directory from `path` rather than
  relying on a production-side test hook.

## Startup impact

Install runs only when the binary is absent. Once present, both blocks short-
circuit on `command -v` and do no work, so steady-state interactive startup is
unchanged. First-boot cost is a one-time network fetch.

## Verification

- **zunit**: `-z4b-starship-asset` platform mapping (pure); the existing fzf
  integration tests updated for silent offline behavior + PATH add.
- **real run** (dev, network available): fresh temp `Z4B_ROOT`, `PATH` stripped
  of fzf/starship, run `z4b init`, assert both binaries land and `command -v`
  resolves. This is the only place the actual download is exercised.
- **container smoke** (existing): unchanged image already ships fzf+starship, so
  the install blocks are skipped — regression check that nothing broke.
