# k8s-vollminlab-cluster

← [[Home]]

GitOps-managed Kubernetes cluster using Flux CD. All workloads are Helm-based under `clusters/vollminlab-cluster/`.

## Docs

- [[repos/k8s-vollminlab-cluster/docs/cluster-reference|Cluster Reference]] — versions, values, resource limits, network policies
- [[cluster-roadmap|Roadmap]] — planned work
- [[repos/k8s-vollminlab-cluster/docs/non-gitops-inventory|Non-GitOps Inventory]] — manually managed resources
- [[repos/k8s-vollminlab-cluster/docs/authentik-design|Authentik SSO Design]] — Authentik deployment design and integration
- [[repos/k8s-vollminlab-cluster/docs/cloudflare-management|Cloudflare Management]] — all Cloudflare resources are Terraform-managed; never edit in the dashboard
- [[repos/k8s-vollminlab-cluster/docs/security-audit|Security & Improvement Audit]] — 2026-05-29 full repo + live cluster audit (closed 2026-06-04)

## Runbooks

- [[repos/k8s-vollminlab-cluster/docs/runbooks/flux-templates|Flux Templates]] — copy-paste HelmRelease, HelmRepository, OCIRepository YAML
- [[repos/k8s-vollminlab-cluster/docs/runbooks/kyverno-recovery|Kyverno Recovery]] — webhook block recovery, stuck HelmRelease recovery
- [[repos/k8s-vollminlab-cluster/docs/runbooks/external-dns|External DNS]] — upsert-only constraint, Pi-hole DNS restore
- [[repos/k8s-vollminlab-cluster/docs/runbooks/homepage|Homepage]] — auto-discovery annotations, widget config
- [[repos/k8s-vollminlab-cluster/docs/runbooks/incidents|Incidents]] — postmortem format, incident index
- [[repos/k8s-vollminlab-cluster/docs/runbooks/longhorn-multipath-blacklist|Longhorn Multipath Blacklist]] — multipath blacklist required on all workers
- [[repos/k8s-vollminlab-cluster/docs/runbooks/longhorn-ext4-corruption|Longhorn ext4 Corruption]] — healthy-but-corrupt volumes, offline e2fsck repair
- [[repos/k8s-vollminlab-cluster/docs/runbooks/expose-dmz-service|Expose DMZ Service]] — steps to expose a new service through the DMZ
- [[repos/k8s-vollminlab-cluster/docs/runbooks/etcd-local-nvme-migration|etcd Local NVMe Migration]] — quorum-safe rolling move of etcd/CP storage to per-host NVMe
- [[repos/k8s-vollminlab-cluster/docs/runbooks/eso-token-rotation|ESO Token Rotation]] — rotate the 1Password Connect access token ESO reads with
- [[repos/k8s-vollminlab-cluster/docs/runbooks/cnpg-password-rotation|CNPG Password Rotation]] — coordinated rotation for create-once (`refreshInterval: "0"`) ExternalSecrets
- [[repos/k8s-vollminlab-cluster/docs/runbooks/harbor-dockerhub-proxy-cache|Harbor Docker Hub Proxy Cache]] — docker.io pull-through cache that dodges the Hub rate limit

## Incidents

- [[repos/k8s-vollminlab-cluster/docs/incidents/2026-04-05-external-dns-kyverno-outage|2026-04-05 External DNS + Kyverno Outage]]
- [[repos/k8s-vollminlab-cluster/docs/incidents/2026-04-20-external-dns-pihole-instability|2026-04-20 External DNS + Pi-hole Instability]]

## Key facts

- All changes via PR — Flux reconciles from `main` within 10 min
- DNS: Pi-hole (pihole-flask-api) — external-dns registers ingress A records (upsert-only)
- Worker nodes provisioned via VMDeployTools
- Branch protection + CI gates managed by github-admin
- See [[Home]] for integration map
