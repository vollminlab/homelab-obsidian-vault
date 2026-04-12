# Homelab Overview

← [[Home]]

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
              ├──► GuestNet (192.168.152.x) — VMs and K8s workers
              │       ├── k8smaster01 (192.168.152.10)
              │       ├── k8sworker01–04 (192.168.152.11–14)
              │       ├── devsbx01 (192.168.152.x) — Claude Code dev VM
              │       └── GLaDOS (admin workstation)
              │
              └──► DMZ (192.168.160.x) — externally-accessible services
                      ├── k8sworker05 (192.168.160.x) — DMZ K8s worker
                      └── k8sworker06 (192.168.160.x) — DMZ K8s worker
```

## K8s cluster nodes

| Node | Role | IP | Notes |
| --- | --- | --- | --- |
| k8smaster01 | Control plane | 192.168.152.10 | |
| k8sworker01 | Worker | 192.168.152.11 | |
| k8sworker02 | Worker | 192.168.152.12 | |
| k8sworker03 | Worker | 192.168.152.13 | |
| k8sworker04 | Worker | 192.168.152.14 | |
| k8sworker05 | DMZ worker | 192.168.160.x | Taint: dmz=true:NoSchedule |
| k8sworker06 | DMZ worker | 192.168.160.x | Taint: dmz=true:NoSchedule |

## Repo responsibilities

| What | Repo |
| --- | --- |
| K8s workloads (GitOps) | [[k8s-vollminlab-cluster]] |
| VM provisioning | [[VMDeployTools]] |
| DNS management | [[pihole-flask-api]] |
| Infra config (Terraform, SSH) | [[homelab-infrastructure]] |
| GitHub org config | [[github-admin]] |
| GroupMe chat export | [[groupme_exporter]] |

## Repo integration map

How repos call each other at runtime:

| Trigger | Caller | Called | What happens |
| --- | --- | --- | --- |
| New VM deployed | [[VMDeployTools]] | [[pihole-flask-api]] | A record registered for VM hostname |
| New VM deployed | [[VMDeployTools]] | [[homelab-infrastructure]] | SSH config block committed to repo |
| Ingress created in K8s | [[k8s-vollminlab-cluster]] | [[pihole-flask-api]] | external-dns registers A record (upsert-only) |
| PR opened on any repo | [[github-admin]] | [[k8s-vollminlab-cluster]] | ARC runner executes required CI checks |

## Key services

| Service | URL | Namespace |
| --- | --- | --- |
| Harbor registry | harbor.vollminlab.com | harbor |
| Shlink URL shortener | go.vollminlab.com | shlink |
| Homepage dashboard | homepage.vollminlab.com | homepage |
| Longhorn storage | (internal) | longhorn-system |
| Kyverno policies | (internal) | kyverno |

## Storage

Longhorn — replica count 3. Every PVC requires 3× its size in free Longhorn space across 3 nodes. See [[k8s-vollminlab-cluster]] for sizing guidelines.

## Secrets management

All secrets in 1Password (Homelab vault). Kubernetes secrets via SealedSecrets (bitnami). Sealing key backed up in 1Password as "Sealed Secrets Sealing Key".
