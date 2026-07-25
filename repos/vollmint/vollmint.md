# vollmint

← [[Home]]

Household budget tracker — Go API + React SPA ingesting SimpleFIN bank data and Venmo CSV exports into Postgres.

## Docs

- [[repos/vollmint/docs/development|Development]] — local dev setup, tests, production build

## Key facts

- Go 1.26 backend + React 18/TypeScript SPA, shipped as a single binary with the frontend embedded
- Data sources: SimpleFIN Bridge (twice-daily sync) + Venmo CSV upload
- Money is decimal strings end-to-end (Postgres numeric → Go string → JSON → TS) — never floats
- Four household views (Scott/Nikki/Joint/Household) are filters over one dataset, single Authentik login
- Deployment target: the k8s cluster via its own Helm chart (Harbor OCI), LAN/Tailscale only — never exposed through Cloudflare
- See [[Home]] for integration map
