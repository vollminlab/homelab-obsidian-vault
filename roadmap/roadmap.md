# Roadmap

← [[Home]]

## Active / next up

### Observability stack
Planned as the next major milestone before Cilium migration.
- Target: metrics, logs, and traces across all cluster workloads
- ECK (Elasticsearch + Kibana) already deployed in `observability` namespace
- Grafana/Prometheus TBD
- Affects: [[k8s-vollminlab-cluster]]

### Shlink ingress controller (deferred)
Custom Go controller watching Ingress objects with annotation `shlink.vollminlab.com/slug: <value>` — automatically creates Shlink short links for new services.
- Harbor was deployed without a short link (gap this would close)
- Framework: controller-runtime
- Affects: [[k8s-vollminlab-cluster]]

## Planned

### Cilium migration
Replace Calico CNI with Cilium. Manual operation — CNI changes cannot go through Flux.
- Prerequisite: observability stack (need visibility during migration)
- High risk — requires cluster downtime planning

### Obsidian documentation build-out
- ✅ Vault structure and Syncthing sync
- ✅ Docs for pihole-flask-api, github-admin, VMDeployTools
- ✅ Cross-repo wikilinks and graph view
- [ ] Architecture diagrams (Excalidraw in Obsidian)
- [ ] homelab-infrastructure detailed docs

## Completed

- Token efficiency optimization (2026-04) — rules restructured, runbooks split, plugins installed
- Harbor deployment (2026-04) — container registry at harbor.vollminlab.com
- Longhorn iSCSI/multipath recovery (2026-04-08/09)
- External DNS + Kyverno outage recovery (2026-04-05)
