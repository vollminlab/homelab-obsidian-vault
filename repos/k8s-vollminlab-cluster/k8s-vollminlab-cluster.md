# k8s-vollminlab-cluster

← [[Home]]

GitOps-managed Kubernetes cluster using Flux CD. All workloads are Helm-based under `clusters/vollminlab-cluster/`.

## Docs

- [[repos/k8s-vollminlab-cluster/docs/cluster-reference|Cluster Reference]] — versions, values, resource limits, network policies
- [[cluster-roadmap|Roadmap]] — planned work
- [[repos/k8s-vollminlab-cluster/docs/non-gitops-inventory|Non-GitOps Inventory]] — manually managed resources
- [[repos/k8s-vollminlab-cluster/docs/authentik-design|Authentik SSO Design]] — Authentik deployment design and integration

## Runbooks

- [[repos/k8s-vollminlab-cluster/docs/runbooks/flux-templates|Flux Templates]] — copy-paste HelmRelease, HelmRepository, OCIRepository YAML
- [[repos/k8s-vollminlab-cluster/docs/runbooks/kyverno-recovery|Kyverno Recovery]] — webhook block recovery, stuck HelmRelease recovery
- [[repos/k8s-vollminlab-cluster/docs/runbooks/external-dns|External DNS]] — upsert-only constraint, Pi-hole DNS restore
- [[repos/k8s-vollminlab-cluster/docs/runbooks/homepage|Homepage]] — auto-discovery annotations, widget config
- [[repos/k8s-vollminlab-cluster/docs/runbooks/incidents|Incidents]] — postmortem format, incident index
- [[repos/k8s-vollminlab-cluster/docs/runbooks/longhorn-multipath-blacklist|Longhorn Multipath Blacklist]] — multipath blacklist required on all workers
- [[repos/k8s-vollminlab-cluster/docs/runbooks/expose-dmz-service|Expose DMZ Service]] — steps to expose a new service through the DMZ

## Incidents

- [[repos/k8s-vollminlab-cluster/docs/incidents/2026-04-05-external-dns-kyverno-outage|2026-04-05 External DNS + Kyverno Outage]]
- [[repos/k8s-vollminlab-cluster/docs/incidents/2026-04-20-external-dns-pihole-instability|2026-04-20 External DNS + Pi-hole Instability]]

## Key facts

- All changes via PR — Flux reconciles from `main` within 10 min
- DNS: Pi-hole (pihole-flask-api) — external-dns registers ingress A records (upsert-only)
- Worker nodes provisioned via VMDeployTools
- Branch protection + CI gates managed by github-admin
- See [[Home]] for integration map




## Unlisted Docs

- [[repos/k8s-vollminlab-cluster/docs/superpowers/plans/audiobookshelf|Audiobookshelf Implementation Plan]]
- [[repos/k8s-vollminlab-cluster/docs/superpowers/plans/observability-stack|Observability Stack Implementation Plan]]
- [[repos/k8s-vollminlab-cluster/docs/superpowers/plans/observability-enhancement|Observability Enhancement Implementation Plan]]
- [[repos/k8s-vollminlab-cluster/docs/superpowers/specs/observability-stack-design|Observability Stack Design]]
- [[repos/k8s-vollminlab-cluster/docs/superpowers/specs/jellyfin-design|Jellyfin Deployment Design]]
