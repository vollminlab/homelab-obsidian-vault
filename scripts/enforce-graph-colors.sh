#!/usr/bin/env bash
# Enforce Obsidian graph color groups — runs via cron to survive Obsidian overwrites
# Add new repos by extending the GROUPS array below
#
# Color hierarchy:
#   Gold  (#FFD700) — Home, CLAUDE, memory (vault root)
#   Red   (#FF0000) — repo index files (parent level) — LAST group, always wins
#   Repo colors     — docs and diagrams within each repo
#
# Repo colors (matplotlib tab10 base, adjusted):
#   k8s-vollminlab-cluster      #1F77B4  steel blue
#   homelab-infrastructure      #2CA02C  green
#   VMDeployTools               #FF7F0E  orange
#   pihole-flask-api            #795548  brown
#   github-admin                #00897B  teal
#   groupme_exporter            #17BECF  cyan
#   masters-league              #F9A825  amber
#   shlink-ingress-controller   #EC407A  pink
#   homelab-obsidian-vault      #9C27B0  deep purple (Obsidian brand)

set -euo pipefail

GRAPH_JSON="$HOME/obsidian/homelab/.obsidian/graph.json"

GROUPS='[
  {"query":"path:repos/k8s-vollminlab-cluster/","color":{"a":1,"rgb":2062260}},
  {"query":"path:repos/homelab-infrastructure/","color":{"a":1,"rgb":2924588}},
  {"query":"path:repos/VMDeployTools/","color":{"a":1,"rgb":16744206}},
  {"query":"path:repos/pihole-flask-api/","color":{"a":1,"rgb":7951688}},
  {"query":"path:repos/github-admin/","color":{"a":1,"rgb":35195}},
  {"query":"path:repos/groupme_exporter/","color":{"a":1,"rgb":1556175}},
  {"query":"path:repos/masters-league/","color":{"a":1,"rgb":16361509}},
  {"query":"path:repos/shlink-ingress-controller/","color":{"a":1,"rgb":15483002}},
  {"query":"path:repos/homelab-obsidian-vault/ OR path:architecture/ OR path:roadmap/ OR path:runbooks/ OR path:diagrams/","color":{"a":1,"rgb":10233776}},
  {"query":"file:Home OR file:CLAUDE OR file:memory","color":{"a":1,"rgb":16766720}},
  {"query":"file:k8s-vollminlab-cluster OR file:homelab-infrastructure OR file:VMDeployTools OR file:pihole-flask-api OR file:github-admin OR file:groupme_exporter OR file:masters-league OR file:shlink-ingress-controller OR file:homelab-obsidian-vault","color":{"a":1,"rgb":16711680}}
]'

# Check if colorGroups is actually an array with the right number of entries
# (Obsidian resets it to the integer 1000 when it overwrites the file)
current_count=$(jq 'if (.colorGroups | type) == "array" then (.colorGroups | length) else 0 end' "$GRAPH_JSON" 2>/dev/null || echo 0)

if [ "$current_count" -lt 11 ]; then
  tmp=$(mktemp)
  jq --argjson groups "$GROUPS" '.colorGroups = $groups' "$GRAPH_JSON" > "$tmp"
  mv "$tmp" "$GRAPH_JSON"
  echo "$(date): graph colors enforced (was $current_count groups)"
fi
