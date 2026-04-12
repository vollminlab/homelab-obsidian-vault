# Disaster Recovery

← [[Home]]

Cross-repo recovery procedures for full or partial homelab failure.

## Boot order after full power loss

Bring systems up in dependency order:

1. **TrueNAS** — NFS/iSCSI backing for ESXi datastores
2. **ESXi hosts** — hypervisors hosting all VMs
3. **pihole1 + pihole2** — DNS must resolve before anything else
4. **k8smaster01** — control plane
5. **k8sworker01–04** — workload nodes
6. **k8sworker05 + k8sworker06** — DMZ nodes
7. Flux reconciles workloads automatically within ~10 min

## Sealed Secrets controller lost

The sealing key is backed up in 1Password as **"Sealed Secrets Sealing Key"** (Homelab vault).

Restore procedure: `bootstrap/sealed-secrets/` in [[k8s-vollminlab-cluster]].

## Flux bootstrap (rebuilt cluster)

```bash
# Apply CNI first — Flux cannot manage Calico
kubectl apply -f bootstrap/calico/

# Restore sealed secrets key before bootstrapping
# (see bootstrap/sealed-secrets/)

# Bootstrap Flux
flux bootstrap github \
  --owner=vollminlab \
  --repository=k8s-vollminlab-cluster \
  --branch=main \
  --path=clusters/vollminlab-cluster
```

See [[k8s-vollminlab-cluster]] for full procedure.

## Pi-hole DNS wiped

DNS records can be wiped if `policy: sync` is ever set in external-dns (happened 2026-04-05). Restore via Pi-hole API:

```bash
API_KEY=$(op read "op://Homelab/recordimporter-api-token/password")
# Re-register each host — see pihole-flask-api docs
```

See [[repos/pihole-flask-api/docs/pihole-operations|pihole-operations]] for the curl commands.  
Full incident: [[repos/k8s-vollminlab-cluster/docs/runbooks/external-dns|external-dns runbook]].

## New VM deployment

See [[VMDeployTools]] — single PowerShell command handles SSH key, DNS, VM clone, cloud-init.

## Longhorn volume stuck / iSCSI errors

Check multipath is blacklisted on all workers first:
```bash
ssh k8sworker01 "cat /etc/multipath.conf | grep -A5 blacklist"
```

See [[repos/k8s-vollminlab-cluster/docs/runbooks/longhorn-multipath-blacklist|longhorn-multipath-blacklist]].
