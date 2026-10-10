# slate-builder

← [[Home]]

Internal analytics app: a Python API and React SPA over Postgres, deployed to the k8s cluster.

## Docs

- [[repos/slate-builder/docs/slate-builder-architecture|Architecture]] — components, data flow, deployment
- [[repos/slate-builder/docs/superpowers/specs/slate-builder-spec-1-design|Spec 1 Design]] — first sub-project design
- [[repos/slate-builder/docs/superpowers/plans/slate-builder-spec-1|Spec 1 Implementation Plan]] — task-by-task build plan

## Key facts

- Private repo. GitHub Free gives private repos no branch protection, so a pre-push hook refuses pushes to `main` and all changes go through PRs
- Python 3.12 / FastAPI / SQLAlchemy + Alembic backend, React 19 / Vite / Tailwind SPA, shipped as a single image
- Postgres via CNPG (`slate-builder-db`), backed up to MinIO
- Auth is the Authentik forward-auth headers, with user and admin groups. ingress-nginx is the only network path to the pod, so the NetworkPolicies are part of the auth boundary
- Consumes a metered third-party API: every paid call is budgeted up front and recorded in a usage ledger
- Image and Helm chart published to Harbor (OCI) on a `vX.Y.Z` tag. LAN-only, never exposed through Cloudflare
- See [[Home]] for integration map
