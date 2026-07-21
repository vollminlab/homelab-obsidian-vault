# longhorn-rebalancing-controller

← [[Home]]

Custom Go controller that evicts Longhorn replicas to rebalance storage **bytes** across worker nodes. Longhorn's built-in `replica-auto-balance` counts replicas, not bytes, so nodes holding a few large volumes end up far more loaded than nodes holding many small ones.

## Docs

- [[repos/longhorn-rebalancing-controller/docs/longhorn-rebalancing-controller-overview|Overview]] — how it works, two modes, safety gates

## Key facts

- Deployed in `longhorn-system` via Flux HelmRelease; chart and image at harbor.vollminlab.com/vollminlab/
- **Live and enforcing** — `dryRun: false`. It really does evict replicas.
- Two modes: `rebalance` (absolute 75% node threshold, maintenance-window-gated) graduates to `steady-state` (1.5× imbalance ratio, no window) after 3 clean cycles
- Maintenance window is **13:00–19:00 UTC** — deliberately outside the nightly backup window, which it used to overlap
- Eviction caps: 4/day in `rebalance` (30 min cooldown), 5/day in `steady-state` (10 min cooldown)
- Evicts **largest replicas first** (`smallestFirst: false`) — fewer, larger moves rather than many small ones
- Six safety gates must all hold before any eviction: every volume cluster-wide `healthy`, nothing rebuilding, cooldown elapsed, daily cap not hit, inside the window, and `dryRun: false`
- Live config lives in the `longhorn-rebalancing-controller` ConfigMap in `longhorn-system`, not in this repo's docs

## Open observation (2026-07-21)

Rebalancing appears to **relocate** the hot node rather than flatten it — the hot spot moved w04 → w03 while w01 sat flat. Working theory is that large anchored volumes (MinIO, VictoriaMetrics long-term) chase whichever node is currently emptiest, so evicting from the hot node just recreates the imbalance elsewhere. Currently hands-off and under observation; not yet confirmed.

See [[Home]] for integration map.
