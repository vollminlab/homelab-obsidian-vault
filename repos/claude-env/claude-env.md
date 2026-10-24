# claude-env

← [[Home]]

Master copy of the Claude Code environment: `~/.claude` on any box is a deployment of this repo.

## Docs

- [[repos/claude-env/docs/claude-env-layout|Layout and decisions]] — what is mastered, deploy-by-copy, plugins, herdr hook

## Key facts

- Private repo; `home/` maps 1:1 onto `~/.claude/` (CLAUDE.md, settings.json, mcp.json, agents, commands, skills, superpowers plugin, claude-hud status line)
- `claude-env diff | deploy | capture | plugins | install` — deploy copies (never symlinks) because Claude Code rewrites settings.json in place
- Runtime state (transcripts, history, caches, plugin checkouts) and the herdr-owned hook script are never versioned
- Bootstrap order on a fresh box: dotfiles first (installs herdr), then `claude-env install`
- See [[Home]] for integration map
