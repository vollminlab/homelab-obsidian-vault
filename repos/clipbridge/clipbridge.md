# clipbridge

← [[Home]]

Puts a Windows screenshot in front of a Claude Code session running on devsbx01 — one keypress, no `scp`.

## Docs

- [[repos/clipbridge/docs/clipbridge-architecture|Architecture]] — the three components, why targeting is by window focus, verification results

## Key facts

- `Ctrl+V` in Windows Terminal: image on the clipboard is streamed to devsbx01 over the existing sshd and its path typed into the focused prompt. Text pastes normally; every failure falls through to an ordinary paste
- Targeting is by **window focus**, not tmux. Server-side `tmux send-keys` was verified working and rejected anyway — "last pane typed in" is not "pane on screen" when several Claude sessions run in parallel
- The last step needs no cooperation: Claude Code auto-attaches a locally-existing image path found in prompt text
- Three parts: a POSIX sh receiver on devsbx01, a PowerShell grabber on the laptop, an AutoHotkey hotkey. All logic lives in the two testable halves; the AHK script only runs, reads, and types
- SSH credential is restricted with `restrict,command=` so it cannot open a shell — verified: a requested command is ignored
- Tests run under `dash` and `busybox ash` for the shell half, and under both Windows PowerShell 5.1 and PowerShell 7 for the Windows half
- See [[Home]] for integration map
