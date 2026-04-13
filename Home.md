# Vollminlab Homelab

Central index and infrastructure reference for the vollminlab homelab.

## Repos

### Infrastructure

- [[k8s-vollminlab-cluster]] — GitOps K8s cluster (Flux CD)
- [[homelab-infrastructure]] — Terraform, VMs, network infra
- [[VMDeployTools]] — PowerShell VM provisioning module
- [[pihole-flask-api]] — Pi-hole DNS management REST API
- [[github-admin]] — GitHub org configuration
- [[shlink-ingress-controller]] — Kubernetes ingress controller for Shlink
- [[homelab-obsidian-vault]] — this vault

### Side projects

- [[groupme_exporter]] — GroupMe chat export tool
- [[masters-league]] — Masters Tournament fantasy golf league viewer

## Vault

- [[architecture/obsidian-setup|Obsidian Setup]] — how the vault works, adding new repos
- [[roadmap/roadmap|Roadmap]] — what's planned
- [[runbooks/disaster-recovery|Disaster Recovery]] — boot order, Flux bootstrap, DNS restore, Longhorn

## Network topology

```
Internet
    │
    └──► Router (192.168.1.1)
              │
              ├──► Main LAN (192.168.100.x) — infrastructure
              │       ├── pihole1 (192.168.100.2) — [[pihole-flask-api]]
              │       ├── pihole2 (192.168.100.3) — [[pihole-flask-api]]
              │       └── VRRP VIP (192.168.100.1) — DNS clients point here
              │
              └──► GuestNet (192.168.152.x) — VMs and K8s nodes
                      ├── k8scp01 (192.168.152.8)
                      ├── k8scp02 (192.168.152.9)
                      ├── k8scp03 (192.168.152.10)
                      ├── k8sworker01–04 (192.168.152.11–14)
                      ├── k8sworker05–06 (192.168.152.15–16) — DMZ workers
                      └── devsbx01 — Claude Code dev VM
```

## K8s cluster nodes

| Node | Role | IP |
| --- | --- | --- |
| k8scp01 | Control plane | 192.168.152.8 |
| k8scp02 | Control plane | 192.168.152.9 |
| k8scp03 | Control plane | 192.168.152.10 |
| k8sworker01 | Worker | 192.168.152.11 |
| k8sworker02 | Worker | 192.168.152.12 |
| k8sworker03 | Worker | 192.168.152.13 |
| k8sworker04 | Worker | 192.168.152.14 |
| k8sworker05 | DMZ worker | 192.168.152.15 |
| k8sworker06 | DMZ worker | 192.168.152.16 |

## Repo integration map

| Trigger | Caller | Called | What happens |
| --- | --- | --- | --- |
| New VM deployed | [[VMDeployTools]] | [[pihole-flask-api]] | A record registered for VM hostname |
| New VM deployed | [[VMDeployTools]] | [[homelab-infrastructure]] | SSH config block committed to repo |
| Ingress created in K8s | [[k8s-vollminlab-cluster]] | [[pihole-flask-api]] | external-dns registers A record (upsert-only) |
| PR opened on any repo | [[github-admin]] | [[k8s-vollminlab-cluster]] | ARC runner executes required CI checks |

## Key services

### Cluster management

| Service | URL | Namespace |
| --- | --- | --- |
| Capacitor (Flux UI) | capacitor.vollminlab.com | flux-system |
| Longhorn (storage) | longhorn.vollminlab.com | longhorn-system |
| Portainer | portainer.vollminlab.com | portainer |
| Kyverno policy reporter | policyreporter.vollminlab.com | kyverno |
| Harbor registry | harbor.vollminlab.com | harbor |

### Applications

| Service | URL | Namespace |
| --- | --- | --- |
| Homepage dashboard | homepage.vollminlab.com | homepage |
| Bookstack (wiki) | bookstack.vollminlab.com | bookstack |
| Shlink (URL shortener) | go.vollminlab.com | shlink |
| Shlink web UI | shlink.vollminlab.com | shlink |
| MinIO console | minio.vollminlab.com | minio |
| MinIO S3 endpoint | s3.vollminlab.com | minio |

### Mediastack

| Service | URL | Namespace |
| --- | --- | --- |
| Sonarr | sonarr.vollminlab.com | mediastack |
| Radarr | radarr.vollminlab.com | mediastack |
| Bazarr | bazarr.vollminlab.com | mediastack |
| Prowlarr | prowlarr.vollminlab.com | mediastack |
| SABnzbd | sabnzbd.vollminlab.com | mediastack |
| Overseerr | overseerr.vollminlab.com | mediastack |
| Tautulli | tautulli.vollminlab.com | mediastack |

### Internal only

| Service | Namespace | Notes |
| --- | --- | --- |
| Velero | velero | Backup/restore |
| ECK operator | elastic-system | Elastic Cloud on K8s |
| CNPG operator | cnpg-system | CloudNativePG |

## Storage

Longhorn — replica count 3. Every PVC requires 3× its size in free Longhorn space across 3 nodes. See [[k8s-vollminlab-cluster]] for sizing guidelines.

## Secrets management

All secrets in 1Password (Homelab vault). Kubernetes secrets via SealedSecrets (bitnami). Sealing key backed up in 1Password as "Sealed Secrets Sealing Key".
