# VMDeployTools

← [[Home]]

PowerShell module for automated VMware vSphere VM provisioning. Single command provisions a full VM: SSH key → DNS → VM clone → cloud-init → password storage.

## Docs

- [[repos/VMDeployTools/docs/vmdeploytools-architecture|Architecture]] — full 8-step deployment workflow, cloud-init config, network/datastore selection
- [[repos/VMDeployTools/docs/vmdeploytools-configuration|Configuration]] — 1Password bootstrap, config keys, auth flow
- [[repos/VMDeployTools/docs/vmdeploytools-operations|Operations]] — deploy/remove commands, credential retrieval, troubleshooting

## Quick reference

```powershell
Invoke-VMDeployment -VMName "myserver01" -TemplateName "Ubuntu-24.04-Template" `
    -IPAddress "192.168.152.100" -VMFolder "Linux VMs" `
    -CPU 2 -MemoryGB 4 -DiskGB 40 -PowerOn -ClearOpAuthToken

Remove-VMDeployment -VMName "myserver01" -ClearOpAuthToken
```

## Networks

| Subnet | Port group |
|--------|-----------|
| 192.168.152.x | 152-DPG-GuestNet |
| 192.168.160.x | 160-DPG-DMZ |

## Key facts

- On deploy: registers A record via pihole-flask-api, commits SSH config to homelab-infrastructure
- Pester unit tests required to merge (enforced by github-admin)
- See [[architecture/homelab-overview|Homelab Overview]] for integration map
