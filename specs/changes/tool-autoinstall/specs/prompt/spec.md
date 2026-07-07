# prompt

## MODIFIED Requirements

### Requirement: Starship Binary Management

The system SHALL install the starship binary if not found. The binary MUST be
downloaded from `https://github.com/starship/starship/releases/latest/download/starship-x86_64-unknown-linux-gnu.tar.gz`
(or the appropriate platform variant) and extracted to `$Z4B_ROOT/bin/`. On
macOS ARM64, use `starship-aarch64-apple-darwin`. z4b always fetches the latest
release (no version pinning).

Installation MUST be idempotent: skipped when starship is already on PATH or
already present at `$Z4B_ROOT/bin/starship`. The platform variant MUST be derived
from `uname`; unsupported platforms refuse with a single stderr line and do not
abort init. Installation MUST be skipped (and the default starship prompt left
uninitialized) when `Z4B_NO_TOOL_INSTALL` is set, so offline/sandboxed/test
environments do not hit the network; in that case init proceeds silently with no
per-boot message.

#### Scenario: Starship not installed
- **WHEN** starship is not on PATH and `Z4B_NO_TOOL_INSTALL` is unset
- **THEN** z4b downloads and extracts the platform-appropriate binary so
  `$Z4B_ROOT/bin/starship` exists and the prompt is initialized

#### Scenario: Starship already installed
- **WHEN** starship is on PATH or present at `$Z4B_ROOT/bin/starship`
- **THEN** z4b performs no download

#### Scenario: install skipped offline
- **WHEN** starship is not on PATH and `Z4B_NO_TOOL_INSTALL=1`
- **THEN** z4b does not attempt installation, prints no per-boot message, and
  the prompt is not initialized by starship
