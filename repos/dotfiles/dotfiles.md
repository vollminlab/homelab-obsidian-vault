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
- Windows side: `windows/terminal/install.ps1` installs a profile fragment running `ssh -t devsbx01.vollminlab.com ~/.local/bin/herdr`
- See [[Home]] for integration map
