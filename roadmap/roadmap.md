# Roadmap

← [[homelab-obsidian-vault]]

← [[Home]]

Cross-repo roadmap for the homelab. Status last verified against the live cluster **2026-07-22**.

## Active / next up

### Cilium migration
Replace Calico CNI with Cilium. Manual operation — CNI changes cannot go through Flux.
- Calico is still live (`calico-node`, 9 nodes) — this has not started
- Prerequisite **met**: the observability stack it was waiting on is deployed
- Still gated on a validated Velero test restore before any CNI work begins
- High risk — requires cluster downtime planning
- Affects: [[k8s-vollminlab-cluster]]

### Obsidian sync architecture (self-hosted LiveSync)

**Goal:** eliminate the Obsidian Sync subscription and the Windows PC as sync bridge. Make the vault accessible from any device without depending on a user machine being on.

**Target architecture:**
```
devsbx01 cron (git fetch + ff-only each repo, then rsync docs)
    ↓ Syncthing
obsidian-sync VM (lightweight Linux, Obsidian + Xvfb + LiveSync plugin)
    ↓ LiveSync
CouchDB (K8s cluster)
    ↑↓ LiveSync plugin
All clients (Windows, Mac, iPhone, iPad)
```

**To flesh out:**
- [ ] CouchDB deployment in K8s (LiveSync has a setup guide)
- [ ] obsidian-sync VM spec — how lightweight can it go, resource allocation
- [ ] LiveSync external access strategy (ingress + auth, or VPN-only for mobile)
- [ ] Migration plan off Obsidian Sync

## Planned

### Obsidian documentation build-out
- ✅ Vault structure and Syncthing sync
- ✅ Docs for pihole-flask-api, github-admin, VMDeployTools
- ✅ Cross-repo wikilinks and graph view
- [ ] Architecture diagrams (Excalidraw in Obsidian) — `diagrams/` is still empty
- [ ] homelab-infrastructure detailed docs — 8 docs now exist; may be closeable

## Completed

- **Vault sync fetches latest commits** (2026-07) — `sync-docs-to-vault.sh` does `git fetch` + `merge --ff-only` per repo before mirroring, so the vault reflects pushed commits rather than whatever sat on devsbx01's disk. This was the near-term prerequisite for LiveSync.
- **Vault secret scanning** (2026-07) — gitleaks runs on every push and PR to the vault repo
- **Longhorn rebalancing controller** (2026-07) — byte-aware replica rebalancer; Longhorn's built-in `replica-auto-balance` counts replicas rather than bytes. Live and enforcing. Affects: [[longhorn-rebalancing-controller]], [[k8s-vollminlab-cluster]]
- **Observability stack** (2026-06/07) — Prometheus, Grafana, Alertmanager, and Loki live in the `monitoring` namespace, with VictoriaMetrics as the long-term tier. ECK was not the path taken; the `observability` namespace no longer exists. Affects: [[k8s-vollminlab-cluster]]
- **Shlink ingress controller** (2026-06) — Go controller watching Ingress objects for `shlink.vollminlab.com/slug`, auto-creating short links. Live; the annotation is now mandatory on every new Ingress. Affects: [[shlink-ingress-controller]], [[k8s-vollminlab-cluster]]
- Token efficiency optimization (2026-04) — rules restructured, runbooks split, plugins installed
- Harbor deployment (2026-04) — container registry at harbor.vollminlab.com
- Longhorn iSCSI/multipath recovery (2026-04-08/09)
- External DNS + Kyverno outage recovery (2026-04-05)
