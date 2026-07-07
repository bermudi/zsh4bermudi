# Tasks: tool-autoinstall

## Phase 1 — Install helpers

- [x] `fn/-z4b-starship-asset`: pure uname → `starship-<arch>-<os>`; fail cleanly on unsupported arch/OS (takes [arch] [os] args for testing)
- [x] `fn/-z4b-install-starship`: resolve asset, curl/wget + tar extract into `$Z4B_ROOT/bin`; one-line stderr on failure, return 1
- [x] `fn/-z4b-install-fzf`: shallow git clone junegunn/fzf into `$Z4B_ROOT/fzf`, run `install --bin`; same error discipline
- [x] Verify each helper returns 1 (not crash) on missing curl/git and unsupported platform

## Phase 2 — Wire into init

- [x] Replace the fzf stub block: install when missing + `Z4B_NO_TOOL_INSTALL` unset; always add `$Z4B_ROOT/fzf/bin` to PATH in the missing branch
- [x] Replace the starship stub block: install when missing + flag unset; add `$Z4B_ROOT/bin` to PATH
- [x] Set `Z4B_NO_TOOL_INSTALL=1` in `tests/_support/bootstrap` so zunit runs offline

## Phase 3 — Tests

- [x] zunit: `-z4b-starship-asset` maps x86_64-linux, aarch64-linux, aarch64-darwin, and fails on bogus arch/OS
- [x] Update `tests/integration.zunit` fzf tests: assert silent degradation offline + PATH add
- [x] Real run on dev: fresh temp `Z4B_ROOT`, stripped PATH, `z4b init` → both binaries installed and on PATH
- [x] Container smoke still 9/9 (tools preinstalled → blocks skipped)

## Phase 4 — Hygiene

- [x] Remove stray empty `bin/`, `fzf/`, `owner/` from the repo root; gitignore the install targets
- [x] `litespec validate tool-autoinstall` clean
- [x] Full `zunit` green
