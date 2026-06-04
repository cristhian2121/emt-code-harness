#!/usr/bin/env sh
# Rebuild REGISTRY.md from runs/*/STATE.yaml
set -eu
. "$(dirname "$0")/pipeline-lib.sh"

root=$(pipeline_root)
registry="$root/REGISTRY.md"
active=""

if [ -f "$registry" ]; then
  active=$(grep '^active:' "$registry" 2>/dev/null | sed 's/^active: *//' | head -1)
fi

{
  echo "# Pipeline Registry"
  echo "active: ${active:-}"
  echo ""
  echo "| name | phase | validation | fix_loop | awaiting_user |"
  echo "| ---- | ----- | ---------- | -------- | ------------- |"

  if [ -d "$root/runs" ]; then
    for sf in "$root"/runs/*/STATE.yaml "$root"/runs/*/STATE.md; do
      [ -f "$sf" ] || continue
      name=$(basename "$(dirname "$sf")")
      phase=$(grep '^phase:' "$sf" | sed 's/^phase: *//' | head -1)
      validation=$(grep '^validation:' "$sf" | sed 's/^validation: *//' | head -1)
      fix_loop=$(grep '^fix_loop:' "$sf" | sed 's/^fix_loop: *//' | head -1)
      awaiting=$(grep '^awaiting_user:' "$sf" | sed 's/^awaiting_user: *//' | head -1)
      phase=${phase:-spec}
      validation=${validation:-pending}
      fix_loop=${fix_loop:-0}
      awaiting=${awaiting:-false}
      echo "| $name | $phase | $validation | $fix_loop | $awaiting |"
    done
  fi
} > "$registry"

echo "ok: rebuilt REGISTRY.md"
