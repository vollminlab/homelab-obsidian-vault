# dotfiles

← [[Home]]

Shell and terminal setup for devsbx01: bash/ble.sh/fzf, git, herdr, the herdr session-snapshot backstop, and the Windows Terminal profile.

## Docs

- [[repos/dotfiles/docs/dotfiles-layout|Layout and decisions]] — what is deployed where, bootstrap, HERDR_AUTORUN, copy-not-symlink
- [[repos/dotfiles/docs/herdr-snapshot|herdr session snapshot]] — 10-minute timer, restore.sh, herdr-restore

## Key facts

- Private repo; `./dotfiles diff | deploy | capture`, `./bootstrap.sh` for a fresh Debian/Ubuntu box
- herdr replaced tmux on 2026-10-24; `claude-yolo` / `claude-resume` open herdr workspaces
- `herdr-snapshot.timer` (systemd user, linger on) captures every live herdr session every 10 minutes to `~/.herdr-snapshots/`
- Windows side: `windows/setup.ps1` sets up a laptop in one run. It pins the devsbx01 ssh key (1Password agent), installs the 🐑 devsbx01 (herdr) Terminal profile (ssh with auto-reconnect; mosh corrupted the herdr screen) and sets Terminal's startup restore
- New laptop and new devsbx01 checklists are in the repo README
- See [[Home]] for integration map
