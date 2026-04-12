# Vollminlab Homelab — Obsidian Vault

← [[Home]]

This vault is the living documentation layer for the vollminlab homelab. It mirrors and synthesises documentation from all active repos.

**Working directory for repo sessions:** `~/repos/vollminlab/<repo>/`
**Vault root on Linux:** `~/obsidian/homelab/`
**Synced to Windows:** `C:\Users\Scott\Documents\Obsidian Vault\homelab`

## Repos

| Repo | Purpose | Docs |
|------|---------|------|
| `k8s-vollminlab-cluster` | GitOps-managed K8s cluster (Flux CD) | `docs/runbooks/`, `docs/cluster-reference.md` |
| `homelab-infrastructure` | Terraform, VM provisioning, network infra | `docs/` |
| `pihole-flask-api` | Pi-hole DNS management REST API | `docs/` |
| `github-admin` | GitHub org config, repos, teams | `docs/` |
| `VMDeployTools` | VM deployment automation | `docs/` |
| `groupme_exporter` | GroupMe chat export tool | `docs/` |

## Vault structure

```
repos/<repo-name>/           — vault index file (<repo>.md) + mirrored docs/
architecture/                — cross-repo architecture and integration docs
roadmap/                     — planned work across the homelab
runbooks/                    — cross-repo operational procedures
CLAUDE.md                    — this file (org-level Claude context)
memory.md                    — cross-session continuity log
Home.md                      — central hub, links to everything
```

## How the vault is maintained

**Two cron jobs run every 5 minutes on devsbx01:**

1. `~/sync-docs-to-vault.sh` — rsyncs each repo's `docs/` into the vault, handles filename collision renames, strips `../` ghost links, injects `← [[repo]]` backlinks into every synced doc
2. `~/enforce-graph-colors.sh` — ensures graph.json always has the repo color groups (Obsidian overwrites graph.json on every interaction)

**Syncthing** propagates all changes to Windows automatically.

**Never edit files under `repos/<repo>/docs/`** — they are overwritten on the next cron sync. Source of truth is always the repo's own `docs/` folder.

## Adding a new repo — Claude Code checklist

When asked to add a new repo to the vault, follow all steps in [[architecture/obsidian-setup|Obsidian Setup]] — "Adding a new repo" section. Summary:

1. Repo has a `docs/` folder with markdown docs
2. Add repo name to `repos=()` array in `~/sync-docs-to-vault.sh`
3. Add any filename collision renames to the `renames` array in that script
4. Create `repos/<repo>/<repo>.md` (vault index file) — template below
5. Add `[[new-repo]]` to `Home.md`
6. Add graph color entry to `~/enforce-graph-colors.sh` + increment threshold
7. Add runtime integrations to [[architecture/homelab-overview|Homelab Overview]] if applicable
8. Run `~/sync-docs-to-vault.sh && ~/enforce-graph-colors.sh` to verify

**Vault index file template:**
```markdown
# repo-name

← [[Home]]

One-line description.

## Docs

- [[repos/repo-name/docs/doc-name|Title]] — description

## Key facts

- Facts in plain text — NO cross-repo wikilinks here
- See [[architecture/homelab-overview|Homelab Overview]] for integration map
```

## Hard constraints

- Never commit vault files into repo git history — vault lives outside repos
- `repos/<repo>/docs/` in the vault is a mirror only — never edit directly
- `architecture/`, `roadmap/`, `runbooks/`, and `repos/<repo>/<repo>.md` are vault-native — source of truth is here
- Never add cross-repo wikilinks inside synced repo docs — they collapse the graph
- `← [[repo-name]]` backlinks are injected automatically by the sync script — do not add manually
- No `../` relative links in repo docs — stripped by sync but create transient ghost nodes
- Keep `memory.md` updated at the end of cross-repo sessions

## Active context

- Cluster is production (vollminlab.com) — treat all changes as prod
- K8s cluster uses Flux CD GitOps — all cluster changes go through PRs
- External DNS backed by shared Pi-hole — `upsert-only` policy enforced, never `sync`
- Current focus: observability stack (post-optimization, pre-Cilium migration)
