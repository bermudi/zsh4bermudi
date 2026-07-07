# Proposal: tool-autoinstall

## Motivation

The fzf and starship install paths are non-compliant stubs. The canon specs
already mandate real installation:

- `prompt` / "Starship Binary Management": SHALL download from the GitHub
  release URL (platform variant) and extract to `$Z4B_ROOT/bin/`.
- `plugins` / "fzf Binary": SHALL manage fzf so it is available at
  `$Z4B_ROOT/fzf/bin/fzf` and on PATH.

The implementation instead prints "installing…" / "installation stub" messages
and `mkdir -p`s directories it never fills. Worse, the starship stub guards on
a *file* it never creates (`$Z4B_ROOT/bin/starship`), so the two messages print
on **every** boot — noise on fresh systems and inflated perceived startup.
Running `z4b init` with `Z4B_ROOT` pointed at the checkout also litters the tree
with empty untracked `bin/`, `fzf/`, `owner/` dirs.

## Scope

Implement the deferred auto-install to comply with canon:

- **starship**: platform-aware download from the spec'd GitHub release URL,
  extract the `starship` binary to `$Z4B_ROOT/bin/`.
- **fzf**: `git clone --depth 1` junegunn/fzf into `$Z4B_ROOT/fzf`, then run its
  `install --bin` so the prebuilt binary lands at `$Z4B_ROOT/fzf/bin/fzf`.
- Both gated by `command -v` **and** an already-installed check, so install runs
  once; steady-state startup is unaffected.
- Add `Z4B_NO_TOOL_INSTALL=1` so offline / sandboxed / test environments skip the
  network step (zunit sets this). Missing tools then degrade silently.
- Replace the two noisy stub blocks; clean up the polluted working-tree dirs and
  gitignore the install targets so dev-with-`Z4B_ROOT=checkout` stays clean.

## Out of Scope

- Version pinning — canon says always latest.
- Windows / non-Linux-non-Darwin targets (helpers detect and refuse cleanly).
- fzf man-page wiring beyond what `install --bin` provides.
