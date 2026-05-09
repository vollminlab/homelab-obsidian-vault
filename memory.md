# Homelab Memory

← [[Home]]

Cross-session continuity log. Update at end of org-level vault sessions.

## Last updated

2026-05-09

## Infrastructure state

- K8s cluster: healthy, all workloads running
- Harbor: deployed 2026-04, 25Gi registry PVC
- Longhorn: recovered from iSCSI/multipath issues on all workers (2026-04-08/09)
- External DNS: upsert-only (sync policy wiped Pi-hole DNS 2026-04-05, restored manually)
- Authentik: SSO deployment in progress (design doc committed)
- Observability stack: design complete, implementation plan exists — next major milestone pre-Cilium migration
- Cilium migration: planned but not started

## Active initiatives

- Observability stack: implementation plan in docs/superpowers/plans/observability-stack.md (k8s repo)
- Jellyfin: design doc exists (docs/superpowers/specs/jellyfin-design.md in k8s repo), not started
- Audiobookshelf: plan exists, not started

## Key decisions

- Sealed Secrets sealing key: backed up in 1Password as "Sealed Secrets Sealing Key" (Homelab vault)
- GitHub PAT: 1Password item "Github-Org-PAT" — used for gh CLI, GitHub MCP
- Syncthing: devsbx01 syncs vault at ~/repos/vollminlab/homelab-obsidian-vault to devices
  - vollminxps (laptop): currently active Syncthing peer — REMOVE once GLaDOS is set up
  - GLaDOS (Windows PC, always on): NOT YET CONFIGURED — needs SyncTrayzor + device pairing
  - devsbx01 device ID: LCMBZJE-WWJQ3MM-P7M37A2-QGOW777-NE67R72-BLXFRB7-O4IURUL-FR7ZJQO
  - Intended flow: devsbx01 → Syncthing → GLaDOS → Obsidian Sync → vollminxps + mobile
- DMZ nodes: k8sworker05 + k8sworker06 (taint: dmz=true:NoSchedule)

## Vault sync pipeline

- Cron every 5 min: sync-docs-to-vault.sh + enforce-graph-colors.sh
- Vault root: ~/repos/vollminlab/homelab-obsidian-vault (IS the git repo, NOT ~/obsidian/homelab which is stale)
- Syncthing folder ID: homelab-vault, path: ~/repos/vollminlab/homelab-obsidian-vault
- Syncthing UI: http://127.0.0.1:8384
- All docs/ in all repos flow to Obsidian via cron rsync regardless of gitignore status
- docs/superpowers/ in k8s repo is gitignored but still reaches Obsidian (rsync is filesystem-based)
