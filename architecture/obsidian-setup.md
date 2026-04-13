# Obsidian Vault Setup

How the vollminlab Obsidian vault is structured, synced, and kept consistent. Read this before adding a new repo.

## Overview

The vault is a **living documentation layer** across all homelab repos. It is not a wiki you edit directly — it is generated from the repos and kept in sync automatically.

```
~/repos/vollminlab/<repo>/docs/      ← source of truth for repo docs (edit here)
~/repos/vollminlab/<repo>/diagrams/  ← source of truth for repo diagrams (edit here)
~/repos/vollminlab/homelab-obsidian-vault/repos/<repo>/docs|diagrams/
                                     ← vault mirror (generated, never edit directly)
~/repos/vollminlab/homelab-obsidian-vault/architecture|roadmap|runbooks|diagrams/
                                     ← vault-native cross-repo docs (edit in repo, commit)
```

The repo IS the vault. Syncthing syncs the repo directly to Windows at:
`C:\Users\Scott\Documents\Obsidian Vault\homelab`
`.git/` is excluded from sync via `.stignore`. Mirrored docs (`repos/*/docs/`, `repos/*/diagrams/`) are gitignored but synced by Syncthing.

The vault is tracked as a git repo at [vollminlab/homelab-obsidian-vault](https://github.com/vollminlab/homelab-obsidian-vault).
See [[homelab-infrastructure/docs/syncthing|Syncthing Setup]] for the full sync architecture and troubleshooting.

## Automation (runs every 5 minutes via cron)

Both scripts live in the repo at `scripts/` and are referenced by cron via their full repo path.

| Script | What it does |
| --- | --- |
| `scripts/sync-docs-to-vault.sh` | Rsyncs each repo's `docs/` and `diagrams/` into the vault, renames collision filenames, strips `../` ghost links, injects backlinks, syncs vault-native dirs from repo |
| `scripts/enforce-graph-colors.sh` | Ensures graph.json always has the repo color groups — re-applies if Obsidian resets them |

Check cron: `crontab -l`
Check sync log: `tail -f ~/sync-docs.log`
Check color log: `tail -f ~/graph-colors.log`

## Graph structure

The graph uses a hub-and-spoke model:

- **Home** (gold) — single central hub, links to all repo index files, cross-repo docs, and full infrastructure reference
- **Repo index files** (red) — link up to Home, down to their docs
- **Docs/diagrams** (same color as their repo) — link back to their repo via `← [[repo-name]]`
- **architecture/, roadmap/, runbooks/, diagrams/** (brown, same as homelab-obsidian-vault) — cross-repo docs owned by the vault repo

Cross-repo wikilinks between repo index files are intentionally avoided — they collapse the graph. All cross-repo integration info lives in [[Home]] instead.

## Graph colors

Repo colors are enforced by `scripts/enforce-graph-colors.sh`. Obsidian stores them in `.obsidian/graph.json`. Since Obsidian resets this file on every interaction, the cron job re-applies them if they get wiped.

| Repo | Color | Hex |
| --- | --- | --- |
| k8s-vollminlab-cluster | Steel Blue | #1F77B4 |
| homelab-infrastructure | Green | #2CA02C |
| VMDeployTools | Orange | #FF7F0E |
| pihole-flask-api | Brown | #795548 |
| github-admin | Teal | #00897B |
| groupme_exporter | Cyan | #17BECF |
| masters-league | Amber | #F9A825 |
| shlink-ingress-controller | Pink | #EC407A |
| homelab-obsidian-vault + vault-native dirs | Deep Purple | #9C27B0 |
| Home / CLAUDE / memory | Gold | #FFD700 |
| **Repo index files (all repos)** | **Red** | **#FF0000** |

The repo index file group is last — it overrides path-based colors for parent nodes only, giving a clear gold → red → colored hierarchy in the graph.

## Filename collision rules

Obsidian resolves wikilinks by short filename. If two repos have a doc with the same name (e.g. `architecture.md`), one creates a ghost node. The sync script renames collisions on the way in.

Current rename map (in `scripts/sync-docs-to-vault.sh`):

| Original | Renamed to |
| --- | --- |
| pihole-flask-api/docs/architecture.md | pihole-architecture.md |
| pihole-flask-api/docs/operations.md | pihole-operations.md |
| VMDeployTools/docs/architecture.md | vmdeploytools-architecture.md |
| VMDeployTools/docs/configuration.md | vmdeploytools-configuration.md |
| VMDeployTools/docs/operations.md | vmdeploytools-operations.md |
| github-admin/docs/overview.md | github-admin-overview.md |
| github-admin/docs/adding-repos.md | github-admin-adding-repos.md |
| groupme_exporter/docs/architecture.md | groupme-architecture.md |
| k8s-vollminlab-cluster/docs/roadmap.md | cluster-roadmap.md |

When a new doc's filename collides with an existing one, add an entry to the `renames` array in the sync script.

## Adding a new repo — full checklist

### 1. Create `docs/` and optionally `diagrams/` in the repo

All documentation goes in `<repo>/docs/`. Diagrams (Excalidraw, etc.) go in `<repo>/diagrams/`. The sync script mirrors both — nothing else is touched.

Any doc named the same as an existing doc across repos must be added to the rename map.

### 2. Add the repo to `scripts/sync-docs-to-vault.sh`

```bash
repos=(
  ...
  new-repo-name   # add here
)
```

If any docs need renaming, add to the `renames` array:
```bash
["new-repo-name/docs/architecture.md"]="new-repo-architecture.md"
```

### 3. Create the vault index file

Create `repos/<new-repo-name>/<new-repo-name>.md` in this repo:

```markdown
# new-repo-name

← [[Home]]

One-line description of what this repo does.

## Docs

- [[repos/new-repo-name/docs/doc-name|Doc Title]] — description

## Key facts

- Key operational facts in plain text (no cross-repo wikilinks)
- See [[Home]] for integration map
```

### 4. Link from Home.md

Add to `Home.md` in this repo:
```markdown
- [[new-repo-name]] — brief description
```

### 5. Add a graph color

Pick a hex color not already in use, get its decimal value:
```bash
python3 -c "print(int('FF6347', 16))"
```

Add to `scripts/enforce-graph-colors.sh`:
```json
{"query":"path:repos/new-repo-name/","color":{"a":1,"rgb":DECIMAL}},
```

Increment the threshold check:
```bash
if [ "$current_count" -lt 11 ]; then   # was 10, now 11
```

### 6. Update Home.md integration map if the repo has runtime integrations

If the new repo calls or is called by other repos at runtime, add a row to the integration map table in [[Home]].

### 7. Commit, PR, merge — then run sync manually to verify

```bash
~/repos/vollminlab/homelab-obsidian-vault/scripts/sync-docs-to-vault.sh
~/repos/vollminlab/homelab-obsidian-vault/scripts/enforce-graph-colors.sh
```

Check the vault: docs should appear under `repos/new-repo-name/docs/`, each with a `← [[new-repo-name]]` backlink.

## Rules for writing docs in repos

- **Never add cross-repo wikilinks** inside synced docs — they collapse the graph. Use plain text for mentions of other repos.
- **No `../` relative links** — the sync script strips them, but they create ghost nodes before the next sync.
- The `← [[repo-name]]` backlink is injected automatically — do not add it manually to repo docs.
