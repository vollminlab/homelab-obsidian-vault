#!/usr/bin/env bash
# Sync repo docs/ folders into the Obsidian vault mirror
# Source of truth: ~/repos/vollminlab/<repo>/docs/
# Destination:     ~/obsidian/homelab/repos/<repo>/docs/
#
# Vault-native files (<repo>.md) are never touched by this script.
# Each synced .md file gets a ← [[repo]] backlink prepended for Obsidian graph.
# Any doc not listed in the repo index file is appended automatically.

set -euo pipefail

REPOS_DIR="$HOME/repos/vollminlab"
VAULT_DIR="$HOME/obsidian/homelab/repos"

repos=(
  k8s-vollminlab-cluster
  homelab-infrastructure
  groupme_exporter
  pihole-flask-api
  github-admin
  VMDeployTools
  masters-league
  shlink-ingress-controller
  homelab-obsidian-vault
)

# Globally unique rename map: "repo/docs/original.md" -> "new-name.md"
# These prevent Obsidian graph collisions when multiple repos have same filename
declare -A renames=(
  ["pihole-flask-api/docs/architecture.md"]="pihole-architecture.md"
  ["pihole-flask-api/docs/operations.md"]="pihole-operations.md"
  ["VMDeployTools/docs/architecture.md"]="vmdeploytools-architecture.md"
  ["VMDeployTools/docs/configuration.md"]="vmdeploytools-configuration.md"
  ["VMDeployTools/docs/operations.md"]="vmdeploytools-operations.md"
  ["github-admin/docs/overview.md"]="github-admin-overview.md"
  ["github-admin/docs/adding-repos.md"]="github-admin-adding-repos.md"
  ["groupme_exporter/docs/architecture.md"]="groupme-architecture.md"
  ["k8s-vollminlab-cluster/docs/roadmap.md"]="cluster-roadmap.md"
)

inject_backlink() {
  local file="$1"
  local repo="$2"
  local marker="← \[\[$repo\]\]"

  grep -q "$marker" "$file" 2>/dev/null && return 0

  local tmp
  tmp=$(mktemp)
  local heading_line
  heading_line=$(grep -n "^#" "$file" | head -1 | cut -d: -f1 || echo "0")

  if [ "$heading_line" -gt 0 ]; then
    awk -v line="$heading_line" -v link="← [[$repo]]" \
      'NR==line{print; print ""; print link; next}1' "$file" > "$tmp"
  else
    { echo "← [[$repo]]"; echo ""; cat "$file"; } > "$tmp"
  fi
  mv "$tmp" "$file"
}

# Extract the first heading from a markdown file as the doc title
get_title() {
  local file="$1"
  grep -m1 "^#" "$file" | sed 's/^#\+[[:space:]]*//' || basename "$file" .md
}

# Rebuild the "## Unlisted Docs" section in the repo index file.
# Strips the previous section, then re-adds any docs not listed in the main content.
update_index() {
  local repo="$1"
  local dst="$2"
  local index="$VAULT_DIR/$repo/$repo.md"

  [ -f "$index" ] || return 0

  # Strip previous Unlisted Docs section (everything from the header to EOF)
  local tmp
  tmp=$(mktemp)
  sed '/^## Unlisted Docs/,$d' "$index" > "$tmp"
  mv "$tmp" "$index"

  # Collect any docs not referenced in the (now clean) index
  local unlisted=()
  while IFS= read -r -d '' doc_file; do
    local short_name
    short_name=$(basename "$doc_file" .md)
    grep -q "$short_name" "$index" 2>/dev/null && continue
    unlisted+=("$doc_file")
  done < <(find "$dst" -name "*.md" -print0)

  [ ${#unlisted[@]} -eq 0 ] && return 0

  # Append the rebuilt section
  printf '\n## Unlisted Docs\n\n' >> "$index"
  for doc_file in "${unlisted[@]}"; do
    local short_name title rel_path
    short_name=$(basename "$doc_file" .md)
    title=$(get_title "$doc_file")
    rel_path=$(realpath --relative-to="$HOME/obsidian/homelab" "$doc_file" | sed 's/\.md$//')
    echo "Adding unlisted doc to index: $short_name → $repo"
    echo "- [[$rel_path|$title]]" >> "$index"
  done
}

for repo in "${repos[@]}"; do
  src="$REPOS_DIR/$repo/docs"
  dst="$VAULT_DIR/$repo/docs"

  if [ -d "$src" ]; then
    mkdir -p "$dst"
    rsync -a --delete "$src/" "$dst/" 2>/dev/null || true

    # Apply globally unique renames to avoid Obsidian graph filename collisions
    for src_rel in "${!renames[@]}"; do
      if [[ "$src_rel" == "$repo/docs/"* ]]; then
        orig="$VAULT_DIR/$src_rel"
        new_name="${renames[$src_rel]}"
        new_path="$(dirname "$orig")/$new_name"
        [ -f "$orig" ] && mv "$orig" "$new_path"
      fi
    done

    # Clean relative ../path links that create ghost nodes in Obsidian
    while IFS= read -r -d '' f; do
      python3 - "$f" <<'PYEOF' 2>/dev/null || true
import re, sys
path = sys.argv[1]
content = open(path).read()
content = re.sub(r'\[([^\]]+)\]\(\.\.[^)]*\)', r'\1', content)
content = re.sub(r'\.\./\S+', '', content)
open(path, 'w').write(content)
PYEOF
    done < <(find "$dst" -name "*.md" -print0)

    # Inject backlinks into all synced .md files
    while IFS= read -r -d '' f; do
      inject_backlink "$f" "$repo"
    done < <(find "$dst" -name "*.md" -print0)

    # Add any docs not yet listed in the repo index
    update_index "$repo" "$dst"

    echo "✓ $repo"
  else
    echo "- $repo (no docs/ folder, skipping)"
  fi
done

echo ""
echo "Vault sync complete. Syncthing will propagate to Windows."
