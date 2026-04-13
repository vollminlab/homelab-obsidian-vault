#!/usr/bin/env bash
# Enforce Obsidian graph color groups — runs via cron to survive Obsidian overwrites
# Add new repos by extending the GROUPS array below
# Colors use matplotlib tab10 palette for maximum visual distinction

set -euo pipefail

GRAPH_JSON="$HOME/obsidian/homelab/.obsidian/graph.json"

GROUPS='[
  {"query":"path:repos/k8s-vollminlab-cluster/","color":{"a":1,"rgb":2062260}},
  {"query":"path:repos/homelab-infrastructure/","color":{"a":1,"rgb":2924588}},
  {"query":"path:repos/VMDeployTools/","color":{"a":1,"rgb":16744206}},
  {"query":"path:repos/pihole-flask-api/","color":{"a":1,"rgb":9725885}},
  {"query":"path:repos/github-admin/","color":{"a":1,"rgb":14034728}},
  {"query":"path:repos/groupme_exporter/","color":{"a":1,"rgb":1556175}},
  {"query":"path:repos/masters-league/","color":{"a":1,"rgb":12369186}},
  {"query":"path:repos/shlink-ingress-controller/","color":{"a":1,"rgb":14907330}},
  {"query":"path:repos/homelab-obsidian-vault/","color":{"a":1,"rgb":9197131}},
  {"query":"path:architecture/ OR path:roadmap/ OR path:runbooks/","color":{"a":1,"rgb":8355711}},
  {"query":"file:Home OR file:CLAUDE OR file:memory","color":{"a":1,"rgb":16766720}}
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
