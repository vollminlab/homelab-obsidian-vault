# Vollminlab Homelab

Central index for all homelab documentation. Start here.

## Repos

- [[k8s-vollminlab-cluster]] — GitOps K8s cluster (Flux CD)
- [[homelab-infrastructure]] — Terraform, VMs, network infra
- [[VMDeployTools]] — PowerShell VM provisioning module
- [[pihole-flask-api]] — Pi-hole DNS management REST API
- [[github-admin]] — GitHub org configuration (Terraform)
- [[groupme_exporter]] — GroupMe chat export tool
- [[masters-league]] — Masters Tournament fantasy golf league viewer
- [[shlink-ingress-controller]] — Kubernetes ingress controller for Shlink short links
- [[homelab-obsidian-vault]] — this vault (git repo, vault structure, sync setup)

## Cross-repo

- [[architecture/homelab-overview|Homelab Overview]] — full topology, node map, network layout
- [[architecture/obsidian-setup|Obsidian Setup]] — how the vault works, adding new repos
- [[roadmap/roadmap|Roadmap]] — what's planned
- [[runbooks/disaster-recovery|Disaster Recovery]] — boot order, Flux bootstrap, DNS restore, Longhorn

## Key systems

| System | Repo | URL |
| --- | --- | --- |
| Kubernetes cluster | [[k8s-vollminlab-cluster]] | — |
| Harbor registry | [[k8s-vollminlab-cluster]] | harbor.vollminlab.com |
| Shlink short links | [[k8s-vollminlab-cluster]] | go.vollminlab.com |
| Pi-hole DNS | [[pihole-flask-api]] | 192.168.100.1 (VIP) |
| VM provisioning | [[VMDeployTools]] | vSphere |
| Obsidian vault sync | [[homelab-infrastructure]] | devsbx01 ↔ vollminxps |
