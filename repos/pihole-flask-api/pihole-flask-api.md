# pihole-flask-api

← [[Home]]

Flask/Gunicorn REST API for programmatic Pi-hole DNS record management. Runs on both pihole1 and pihole2 at port 5001.

## Docs

- [[repos/pihole-flask-api/docs/pihole-architecture|Architecture]] — dual-pihole topology, TOML format, auth, idempotency
- [[repos/pihole-flask-api/docs/pihole-operations|Operations]] — deploy, update, health checks, key rotation, troubleshooting

## Key facts

- API token: `op://Homelab/recordimporter-api-token/password`
- pihole1: `192.168.100.2:5001`
- pihole2: `192.168.100.3:5001`
- VRRP VIP (DNS clients): `192.168.100.1`
- Always write to **both** hosts — no automatic replication
- Callers: VMDeployTools (VM deploy), k8s-vollminlab-cluster external-dns (ingress A records)
- Hardware documented in homelab-infrastructure
- See [[Home]] for integration map
