# Vollminlab Homelab — Obsidian Vault

← [[Home]]

This vault is the living documentation layer for the vollminlab homelab. It mirrors and synthesises documentation from all active repos.

**Working directory for repo sessions:** `~/repos/vollminlab/<repo>/`
**Vault root on Linux:** `~/obsidian/homelab/`
**Synced to Windows:** `C:\Users\Scott\Documents\Obsidian Vault\homelab`

## Repos

| Repo | Purpose | Docs |
|------|---------|------|
| `k8s-vollminlab-cluster` | GitOps-managed K8s cluster (Flux CD) | `docs/`, `docs/runbooks/`, `docs/incidents/` |
| `homelab-infrastructure` | Terraform, VM provisioning, network infra | `docs/` |
| `pihole-flask-api` | Pi-hole DNS management REST API | `docs/` |
| `github-admin` | GitHub org config, repos, teams | `docs/` |
| `VMDeployTools` | VM deployment automation | `docs/` |
| `groupme_exporter` | GroupMe chat export tool | `docs/` |
| `masters-league` | Fantasy golf league tools | `docs/` |
| `shlink-ingress-controller` | K8s ingress controller for Shlink | `docs/` |
| `homelab-obsidian-vault` | This vault | `scripts/`, `architecture/`, `roadmap/`, `runbooks/`, `diagrams/` |

## Vault structure

```
repos/<repo-name>/           — vault index file (<repo>.md) + mirrored docs/ and diagrams/
architecture/                — cross-repo architecture docs (source: this repo)
roadmap/                     — planned work across the homelab (source: this repo)
runbooks/                    — cross-repo operational procedures (source: this repo)
diagrams/                    — cross-repo diagrams (source: this repo)
scripts/                     — cron scripts driving vault sync and graph enforcement
CLAUDE.md                    — this file
memory.md                    — cross-session continuity log
Home.md                      — central hub and infrastructure reference
```

## How the vault is maintained

**Two cron jobs run every 5 minutes on devsbx01:**

1. `scripts/sync-docs-to-vault.sh` — rsyncs each repo's `docs/` and `diagrams/` into the vault, handles filename collision renames, strips `../` ghost links, injects backlinks, syncs vault-native dirs from this repo
2. `scripts/enforce-graph-colors.sh` — ensures graph.json always has the repo color groups

**Syncthing** propagates all changes to Windows automatically.

**Never edit files under `repos/<repo>/docs/` or `repos/<repo>/diagrams/` in the vault** — they are overwritten on the next cron sync. Source of truth is always the repo's own `docs/` or `diagrams/` folder.

**Vault-native dirs** (`architecture/`, `roadmap/`, `runbooks/`, `diagrams/`) are sourced from this repo — edit them here and commit, the sync script deploys to the vault.

## Adding a new repo

Follow the full checklist in [[architecture/obsidian-setup|Obsidian Setup]]. Summary:

1. Repo has a `docs/` folder (and optionally `diagrams/`)
2. Add repo to `repos=()` array in `scripts/sync-docs-to-vault.sh`
3. Add any filename collision renames to the `renames` array
4. Create `repos/<repo>/<repo>.md` vault index file
5. Add `[[new-repo]]` to `Home.md`
6. Add graph color entry to `scripts/enforce-graph-colors.sh` + increment threshold
7. Add runtime integrations to `Home.md` integration map if applicable
8. Commit, PR, merge — then run sync manually to verify

**Vault index file template:**
```markdown
# repo-name

← [[Home]]

One-line description.

## Docs

- [[repos/repo-name/docs/doc-name|Title]] — description

## Key facts

- Facts in plain text — NO cross-repo wikilinks here
- See [[Home]] for integration map
```

## Doc naming conventions

**No dates in filenames.** The date belongs in the document body, not the filename.

| Type | Filename format | Date in doc |
|------|----------------|-------------|
| Design / spec | `feature-name-design.md` | `**Date:** YYYY-MM-DD` near top |
| Implementation plan | `feature-name.md` | `**Date:** YYYY-MM-DD` near top |
| Runbook | `topic.md` | n/a |
| **Incident postmortem** | `YYYY-MM-DD-description.md` | Date is part of the identifier — exception to the rule |

Incidents are the only exception: the date in the filename is the primary identifier for the event.

## Hard constraints

- Never commit vault files into repo git history — vault lives outside repos
- `repos/<repo>/docs/` and `repos/<repo>/diagrams/` in the vault are mirrors only — never edit directly
- `architecture/`, `roadmap/`, `runbooks/`, `diagrams/`, and `repos/<repo>/<repo>.md` are vault-native — source of truth is this repo
- Never add cross-repo wikilinks inside synced repo docs — they collapse the graph
- `← [[repo-name]]` backlinks are injected automatically by the sync script — do not add manually
- No `../` relative links in repo docs — stripped by sync but create transient ghost nodes
- Keep `memory.md` updated at the end of cross-repo sessions

## Active context

- Cluster is production (vollminlab.com) — treat all changes as prod
- K8s cluster uses Flux CD GitOps — all cluster changes go through PRs
- External DNS backed by shared Pi-hole — `upsert-only` policy enforced, never `sync`
- Current focus: observability stack (post-optimization, pre-Cilium migration)
