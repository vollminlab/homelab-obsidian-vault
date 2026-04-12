# Homelab Memory

← [[Home]]

Cross-session continuity log. Update at end of org-level vault sessions.

## Last updated

2026-04-11

## Infrastructure state

- K8s cluster: healthy, all workloads running
- Harbor: deployed 2026-04, 25Gi registry PVC
- Longhorn: recovered from iSCSI/multipath issues on all workers (2026-04-08/09)
- External DNS: upsert-only (sync policy wiped Pi-hole DNS 2026-04-05, restored manually)

## Active initiatives

- Token efficiency optimization: complete (rules restructured, runbooks split out, plugins installed)
- Observability stack: next major milestone (pre-Cilium migration)
- Cilium migration: planned but not started

## Key decisions

- Sealed Secrets sealing key: backed up in 1Password as "Sealed Secrets Sealing Key" (Homelab vault)
- GitHub PAT: 1Password item "Github-Org-PAT" — used for gh CLI, GitHub MCP
- Syncthing: Linux VM (devsbx01) ↔ Windows PC vault sync
- DMZ nodes: k8sworker05 + k8sworker06 (taint: dmz=true:NoSchedule)
