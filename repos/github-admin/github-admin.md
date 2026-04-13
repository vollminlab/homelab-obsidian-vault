# github-admin

← [[Home]]

Terraform-managed GitHub organization configuration for `vollminlab`. Branch protection, required status checks, and repo settings — all IaC, never the GitHub UI.

## Docs

- [[repos/github-admin/docs/github-admin-overview|Overview]] — what's managed, CI workflow, secrets
- [[repos/github-admin/docs/github-admin-adding-repos|Adding Repos]] — Terraform resource creation, importing existing repos

## Repos managed

| Repo | Required checks |
| --- | --- |
| k8s-vollminlab-cluster | Security Scan, Validate K8s Manifests, Kyverno Validation, Integration Test |
| VMDeployTools | Pester Unit Tests |
| github-admin | Terraform Plan |
| homelab-infrastructure | *(none)* |
| pihole-flask-api | test (3.11), test (3.12) |

## Key facts

- Self-hosted ARC runner in k8s-vollminlab-cluster (`actions-runner-system` namespace)
- Terraform state: HCP Terraform Cloud
- See [[Home]] for integration map
