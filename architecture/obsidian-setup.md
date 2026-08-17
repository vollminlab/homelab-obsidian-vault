# Obsidian Vault Setup

← [[homelab-obsidian-vault]]

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

The repo IS the vault. Syncthing syncs the repo directly to Windows (device `GLaDOS`) at:
`C:\Users\Scott\Documents\Obsidian Vault\homelab`
`.stignore` excludes both `.git` and `.obsidian` from the sync. Mirrored docs (`repos/*/docs/`, `repos/*/diagrams/`) are gitignored but synced by Syncthing.

Excluding `.obsidian` means the Windows install keeps its **own** `graph.json` that no cron job touches — a new repo's colour has to be added there by hand. This is deliberate: it breaks a conflict loop where the enforce script wrote colour groups on `devsbx01`, Obsidian on Windows overwrote them, and Syncthing pushed the Windows version straight back.

The vault is tracked as a git repo at [vollminlab/homelab-obsidian-vault](https://github.com/vollminlab/homelab-obsidian-vault).
See [[homelab-infrastructure/docs/syncthing|Syncthing Setup]] for the full sync architecture and troubleshooting.

## Automation (runs every 5 minutes via cron)

Both scripts live in the repo at `scripts/` and run from the `vollmin` crontab on **`devsbx01`**, by absolute path — cron has no working directory to inherit.

| Script | What it does |
| --- | --- |
| `scripts/sync-docs-to-vault.sh` | Fast-forwards each source repo, rsyncs its `docs/` and `diagrams/` into the vault, renames collision filenames, strips `../` ghost links, injects backlinks, rebuilds each index's `## Unlisted Docs` section |
| `scripts/enforce-graph-colors.sh` | Ensures graph.json always has the repo color groups — re-applies if Obsidian resets them |

Check cron: `crontab -l`
Check sync log: `tail -f ~/sync-docs.log`
Check color log: `tail -f ~/graph-colors.log`

### What the sync script actually does per repo

1. **Fast-forward** — `git fetch origin` then `git merge --ff-only` in the source repo, so the vault mirrors what was merged rather than what happens to be checked out. Only a fast-forward is ever performed; a detached HEAD, uncommitted tracked changes, a missing upstream or diverged history is reported and then left exactly as it was, and the sync proceeds against whatever is on disk. The vault repo itself is excluded — bash reads a script incrementally while running it, so fast-forwarding it mid-execution would change the file underneath the interpreter. It is pulled by hand after a merge; the script prints a warning when that is due.
2. **Mirror** — `rsync -a --delete <repo>/docs/ → repos/<repo>/docs/`. `--delete` means a doc removed upstream disappears from the vault too.
3. **Rename** — apply the `renames` map (see below).
4. **Strip** — an inline `python3` regex deletes `[text](../path)` and bare `../path`.
5. **Backlink** — prepend `← [[<repo>]]` two lines below the first heading.
6. **Index** — rebuild the `## Unlisted Docs` section of `repos/<repo>/<repo>.md`.
7. **Diagrams** — rsync + backlink for `<repo>/diagrams/` if present; no renames, no index entry.

Vault-native directories (`architecture/`, `roadmap/`, `runbooks/`, `diagrams/`) are handled first and separately. They are already in the working tree, so they get backlink injection **in place and no copy step at all** — nothing is copied "from" anywhere.

A failed rsync or git operation sets `sync_failed=1` and the script exits 1 at the end, but it does **not** abort mid-run: one unreadable repo must not stop every later repo from syncing.

### Unlisted Docs

`update_index()` deletes everything from `^## Unlisted Docs` to EOF, then re-appends an entry for every mirrored `.md` whose basename does not already appear somewhere in the index. Titles come from the file's first `^#` heading. `docs/superpowers/` is pruned from the scan — completed plans and design specs are archival records, not operational docs anyone needs to find from an index. They stay in the vault, the graph and search; they just do not earn an index entry.

## Graph structure

The graph uses a hub-and-spoke model:

- **Home** (gold) — single central hub, links to all repo index files, cross-repo docs, and full infrastructure reference
- **Repo index files** (red) — link up to Home, down to their docs
- **Docs/diagrams** (same color as their repo) — link back to their repo via `← [[repo-name]]`
- **architecture/, roadmap/, runbooks/, diagrams/** (deep purple, same as homelab-obsidian-vault) — cross-repo docs owned by the vault repo

Cross-repo wikilinks between repo index files are intentionally avoided — they collapse the graph. All cross-repo integration info lives in [[Home]] instead.

## Graph colors

Repo colors are enforced by `scripts/enforce-graph-colors.sh`, which rewrites `.obsidian/graph.json` with `jq`, setting `.colorGroups` to a fixed **13-entry** array and `.showOrphans` to `false`. Obsidian overwrites that file on interaction — and when it does, it replaces the `colorGroups` array with the integer `1000`, which is why the guard tests the JSON *type*, not just the length.

Groups are path queries, not file lists, so new docs pick up their repo's colour with no config change.

| Group | Repo / scope | Color | Hex |
| --- | --- | --- | --- |
| 1 | Home / CLAUDE / memory | Gold | #FFD700 |
| 2 | **Repo index files (all eleven repos)** | **Red** | **#FF0000** |
| 3 | k8s-vollminlab-cluster | Steel Blue | #1F77B4 |
| 4 | homelab-infrastructure | Green | #2CA02C |
| 5 | VMDeployTools | Orange | #FF7F0E |
| 6 | pihole-flask-api | Brown | #795548 |
| 7 | github-admin | Teal | #00897B |
| 8 | groupme_exporter | Cyan | #17BECF |
| 9 | masters-league | Amber | #F9A825 |
| 10 | shlink-ingress-controller | Pink | #EC407A |
| 11 | longhorn-rebalancing-controller | Blue Grey | #607D8B |
| 12 | vollmint | Olive | #BCBD22 |
| 13 | homelab-obsidian-vault + vault-native dirs | Deep Purple | #9C27B0 |

The repo index file group is listed ahead of the path-prefix groups it needs to override, giving a clear gold → red → colored hierarchy in the graph.

The script maintains the `devsbx01` copy of `graph.json` only — `.obsidian/` is excluded from Syncthing, so the Windows install's colours have to be updated by hand.

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
| longhorn-rebalancing-controller/docs/overview.md | longhorn-rebalancing-controller-overview.md |
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

The array currently holds **eleven** repos: `k8s-vollminlab-cluster`, `homelab-infrastructure`, `groupme_exporter`, `pihole-flask-api`, `github-admin`, `VMDeployTools`, `masters-league`, `shlink-ingress-controller`, `longhorn-rebalancing-controller`, `vollmint`, `homelab-obsidian-vault`.

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

Add to `Home.md` in this repo, under either `### Infrastructure` or `### Side projects`:
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

Add the new repo's index file to the **red** index-file query (group 2) as well:
```
OR path:repos/new-repo-name/new-repo-name
```

Then increment the threshold check:
```bash
if [ "$current_count" -lt 13 ] || [ "$current_orphans" = "true" ]; then   # was 12, now 13
```

**The threshold is the step people forget.** `-lt 13` is the current repo count (eleven) plus the gold and red groups. Adding a repo adds one group, so the comparison must be incremented in the same commit — otherwise the guard is satisfied by the old array and the new colour is never applied.

A repo in `repos=()` with no colour group syncs but renders in the graph's default grey; a colour group added without bumping the threshold is never applied at all. Both fail silently.

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
- **No `../` relative links** — they create ghost nodes until the next sync, and the strip is lossy: `[text](../path)` becomes bare `text` and the link is gone. Write the target as a wikilink or plain text instead.
- The `← [[repo-name]]` backlink is injected automatically — do not add it manually to repo docs.
