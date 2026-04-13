# homelab-obsidian-vault

Living documentation layer for the vollminlab homelab. Synthesises docs from all active repos into a single Obsidian vault, synced between a Linux dev VM and a Windows PC via Syncthing.

## How it works

Two cron jobs run every 5 minutes on `devsbx01`:

| Script | Purpose |
|--------|---------|
| `scripts/sync-docs-to-vault.sh` | Rsyncs each repo's `docs/` into the vault, injects `← [[repo]]` backlinks, handles filename collision renames, appends unlisted docs to repo index files |
| `scripts/enforce-graph-colors.sh` | Ensures Obsidian graph color groups are set correctly (Obsidian resets them on every interaction) |

Syncthing propagates vault changes from `devsbx01` (`~/obsidian/homelab/`) to Windows (`C:\Users\Scott\Documents\Obsidian Vault\homelab`) automatically.

## Vault structure

```
architecture/          — cross-repo architecture and integration docs (source of truth: this repo)
roadmap/               — planned work across the homelab (source of truth: this repo)
runbooks/              — cross-repo operational procedures (source of truth: this repo)
repos/<repo>/          — vault index file + mirrored docs/ from each repo
scripts/               — cron scripts that drive vault sync and graph enforcement
Home.md                — central hub
CLAUDE.md              — Claude Code context for vault sessions
memory.md              — cross-session continuity log
```

## Repos tracked

| Repo | Purpose |
|------|---------|
| `k8s-vollminlab-cluster` | GitOps-managed K8s cluster (Flux CD) |
| `homelab-infrastructure` | Terraform, VM provisioning, network infra |
| `pihole-flask-api` | Pi-hole DNS management REST API |
| `github-admin` | GitHub org config, repos, teams |
| `VMDeployTools` | VM deployment automation |
| `shlink-ingress-controller` | Kubernetes ingress controller for Shlink |
| `groupme_exporter` | GroupMe chat export tool |
| `masters-league` | Fantasy sports league tools |

## Adding a new repo

See `architecture/obsidian-setup.md` in the vault for the full checklist. Summary:

1. Add the repo name to `repos=()` in `scripts/sync-docs-to-vault.sh`
2. Add any filename collision renames to the `renames` array in that script
3. Create `repos/<repo>/<repo>.md` (vault index file)
4. Add `[[new-repo]]` to `Home.md`
5. Add a graph color entry to `scripts/enforce-graph-colors.sh` and bump the threshold
6. Add runtime integrations to `architecture/homelab-overview.md` if applicable
7. Commit, PR, merge — next cron run picks it up automatically
