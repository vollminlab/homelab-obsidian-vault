# Obsidian Vault Setup

← [[Home]]

How the vollminlab Obsidian vault is structured, synced, and kept consistent. Read this before adding a new repo.

## Overview

The vault is a **living documentation layer** across all homelab repos. It is not a wiki you edit directly — it is generated from the repos and kept in sync automatically.

```
~/repos/vollminlab/<repo>/docs/   ← source of truth (edit here)
~/obsidian/homelab/repos/<repo>/  ← vault mirror (generated, never edit directly)
~/obsidian/homelab/               ← vault-native docs (edit here)
```

Syncthing bridges the Linux vault to the Windows PC at:
`C:\Users\Scott\Documents\Obsidian Vault\homelab`

## Automation (runs every 5 minutes via cron)

Two cron jobs run on `devsbx01`:

| Script | What it does |
| --- | --- |
| `~/sync-docs-to-vault.sh` | Rsyncs each repo's `docs/` into the vault, renames collision filenames, strips `../` ghost links, injects `← [[repo]]` backlinks |
| `~/enforce-graph-colors.sh` | Ensures graph.json always has the repo color groups — re-applies if Obsidian overwrites them |

Check cron: `crontab -l`
Check sync log: `tail -f ~/sync-docs.log`
Check color log: `tail -f ~/graph-colors.log`

## Graph structure

The graph uses a hub-and-spoke model:

- **Home** (gold) — central hub, links to all repo index files and cross-repo docs
- **Repo index files** (colored by repo) — link up to Home, down to their docs
- **Docs** (same color as their repo) — link back to their repo via `← [[repo-name]]`
- **homelab-overview** (grey) — cross-repo integration map, connects to all repos
- **disaster-recovery, roadmap, architecture** (grey) — cross-repo/org-level docs

Cross-repo wikilinks between repo indexes are intentionally avoided — they collapse the graph. All cross-repo integration info lives in [[architecture/homelab-overview|Homelab Overview]] instead.

## Graph colors

Repo colors are enforced by `~/enforce-graph-colors.sh`. Obsidian stores them in `.obsidian/graph.json`. Since Obsidian overwrites this file on every interaction, the cron job re-applies them if they get wiped.

| Repo | Color | Hex |
| --- | --- | --- |
| k8s-vollminlab-cluster | Blue | #4169E1 |
| homelab-infrastructure | Green | #228B22 |
| VMDeployTools | Orange | #FF8C00 |
| pihole-flask-api | Purple | #9932CC |
| github-admin | Red | #DC143C |
| groupme_exporter | Teal | #20B2AA |
| Cross-repo docs | Silver | #C0C0C0 |
| Home / meta | Gold | #FFD700 |

## Filename collision rules

Obsidian resolves wikilinks by short filename. If two repos have a doc with the same name (e.g. `architecture.md`), one creates a ghost node. The sync script renames collisions on the way in.

Current rename map (in `~/sync-docs-to-vault.sh`):

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

### 1. Create a `docs/` folder in the repo

All documentation goes in `<repo>/docs/`. The sync script only mirrors `docs/` — nothing else is touched.

Any doc named the same as an existing doc across repos (e.g. `architecture.md`, `operations.md`, `overview.md`) must be added to the rename map.

### 2. Add the repo to `~/sync-docs-to-vault.sh`

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

Create `~/obsidian/homelab/repos/<new-repo-name>/<new-repo-name>.md`:

```markdown
# new-repo-name

← [[Home]]

One-line description of what this repo does.

## Docs

- [[repos/new-repo-name/docs/doc-name|Doc Title]] — description

## Key facts

- Key operational facts in plain text (no cross-repo wikilinks)
- See [[architecture/homelab-overview|Homelab Overview]] for integration map
```

### 4. Link from Home.md

Add to `~/obsidian/homelab/Home.md`:
```markdown
- [[new-repo-name]] — brief description
```

### 5. Add a graph color

Pick a hex color not already in use, get its decimal value:
```bash
python3 -c "print(int('FF6347', 16))"
```

Add to `~/enforce-graph-colors.sh`:
```json
{"query":"path:repos/new-repo-name/","color":{"a":1,"rgb":DECIMAL}},
```

Increment the threshold check:
```bash
if [ "$current_count" -lt 9 ]; then   # was 8, now 9
```

### 6. Update homelab-overview if the repo has runtime integrations

If the new repo calls or is called by other repos at runtime, add a row to the integration map table in [[architecture/homelab-overview|Homelab Overview]].

### 7. Run sync manually to verify

```bash
~/sync-docs-to-vault.sh
~/enforce-graph-colors.sh
```

Check the vault: docs should appear under `repos/new-repo-name/docs/`, each with a `← [[new-repo-name]]` backlink.

## Rules for writing docs in repos

- **Never add cross-repo wikilinks** inside synced docs — they collapse the graph. Use plain text for mentions of other repos.
- **No `../` relative links** — the sync script strips them, but they create ghost nodes before the next sync.
- **Standard markdown links to other docs in the same repo** (`[text](other-doc.md)`) are also stripped by the sync script if they use `../` paths. Use wikilinks for vault cross-references only in vault-native files.
- The `← [[repo-name]]` backlink is injected automatically — do not add it manually to repo docs.
