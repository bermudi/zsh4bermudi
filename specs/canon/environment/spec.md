# environment

## Requirements

### Requirement: Essential Shell Options

The system SHALL set the following zsh options during bootstrap: `WORDCHARS=''`, `KEYTIMEOUT=20`, and all options necessary for the ZLE widgets to function correctly.

#### Scenario: Word boundaries work

- **WHEN** `z4b init` completes
- **THEN** `WORDCHARS` is empty and word navigation treats only alphanums as word characters

#### Scenario: Escape key timing

- **WHEN** `z4b init` completes
- **THEN** `KEYTIMEOUT` is 20 (200ms) for responsive escape key handling

### Requirement: PATH and fpath Setup

The system SHALL configure PATH, fpath, manpath, and infopath. It MUST detect Homebrew (Linux and macOS) and add its paths. Standard paths (`~/bin`, `~/.local/bin`, `~/.cargo/bin`, `/usr/local/bin`, etc.) MUST be added if they exist.

#### Scenario: Homebrew detected

- **WHEN** Homebrew is installed at `/home/linuxbrew/.linuxbrew`
- **THEN** its bin, sbin, share/zsh/site-functions, share/man, and share/info are added to the respective paths

### Requirement: Locale Fix

The system SHALL detect if the current locale is not UTF-8 and attempt to fix it by choosing a UTF-8 locale that is actually available on the host. It MUST NOT set a locale that the system cannot provide, since doing so causes every subprocess to emit `setlocale: cannot change locale` warnings.

Selection order: prefer `C.UTF-8` (also matched as `C.utf8`); otherwise pick any locale from `locale -a` whose name contains `UTF-8` or `utf8`; only as a last resort, when no UTF-8 locale is available at all, set nothing (or set `C`) and leave the environment untouched rather than forcing a non-existent locale. The chosen locale MUST be set in both `LC_ALL` and `LANG`.

#### Scenario: Non-UTF-8 locale

- **WHEN** the system locale is `POSIX` or `C`
- **THEN** z4b sets `LC_ALL=C.UTF-8` or falls back to another available UTF-8 locale

#### Scenario: Preferred locale unavailable

- **WHEN** the system locale is non-UTF-8 and only `C.utf8` is available (no `en_US.UTF-8`)
- **THEN** z4b sets `LC_ALL=C.utf8` and does not set `en_US.UTF-8`, and no subprocess emits a locale warning

#### Scenario: No UTF-8 locale available

- **WHEN** the system locale is non-UTF-8 and `locale -a` lists no UTF-8 locale
- **THEN** z4b sets no locale (leaving the environment unchanged) rather than forcing a non-existent one

### Requirement: Terminal Title

The system SHALL set the terminal title to show the running command during execution and the current directory when idle. In SSH sessions, the title MUST include `user@host`.

#### Scenario: Command running

- **WHEN** the user executes `sleep 10`
- **THEN** the terminal title shows `sleep 10`

#### Scenario: Command running over SSH

- **WHEN** `SSH_CONNECTION` is set and the user executes `sleep 10`
- **THEN** the terminal title shows `user@host: sleep 10`

#### Scenario: Idle prompt

- **WHEN** no command is running
- **THEN** the terminal title shows the current directory path

#### Scenario: Idle prompt over SSH

- **WHEN** `SSH_CONNECTION` is set and no command is running
- **THEN** the terminal title shows `user@host: ~/current/path`

### Requirement: Default Environment Variables

The system SHALL set: `LESS='-iRFXMx4'`, `PAGER=less` (if less is installed), `LS_COLORS` for GNU ls and `LSCOLORS` for BSD ls, `DIRSTACKSIZE=10000`, and `VIRTUAL_ENV_DISABLE_PROMPT=1`.

#### Scenario: Less configured

- **WHEN** the user runs `less somefile`
- **THEN** less uses case-insensitive search, color, exits if one page, keeps content on screen, shows more info, and uses 4-space tabs

#### Scenario: Virtualenv prompt disabled

- **WHEN** the user activates a Python virtualenv
- **THEN** the prompt is not modified by the virtualenv (starship handles display instead)

### Requirement: UTF-8 Detection

The system SHALL set `COLORTERM=truecolor` when the terminal reports 256+ color support and `COLORTERM` is unset.

#### Scenario: True color terminal

- **WHEN** the terminal supports 256+ colors (`terminfo[Tc] == yes`) and `COLORTERM` is not set
- **THEN** `COLORTERM` is set to `truecolor`
