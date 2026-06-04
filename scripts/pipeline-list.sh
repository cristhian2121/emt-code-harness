#!/usr/bin/env sh
# List all pipeline tasks from emt-state/*.yaml (optional human view).
# Usage: pipeline-list.sh [--markdown]
set -eu
. "$(dirname "$0")/pipeline-lib.sh"

format=plain
[ "${1:-}" = "--markdown" ] && format=markdown

ensure_emt_dirs
active=$(get_active)

if [ "$format" = markdown ]; then
  echo "# Pipeline tasks (generated — not source of truth)"
  echo ""
  echo "active: ${active:-}"
  echo ""
  echo "| name | phase | validation | fix_loop | awaiting |"
  echo "| ---- | ----- | ---------- | -------- | -------- |"
fi

found=0
for name in $(list_task_names); do
  sf=$(resolve_state_file "$name")
  [ -f "$sf" ] || continue
  found=1
  phase=$(grep '^phase:' "$sf" | sed 's/^phase: *//' | head -1)
  validation=$(grep '^validation:' "$sf" | sed 's/^validation: *//' | head -1)
  fix_loop=$(grep '^fix_loop:' "$sf" | sed 's/^fix_loop: *//' | head -1)
  awaiting=$(grep '^awaiting_user:' "$sf" | sed 's/^awaiting_user: *//' | head -1)
  phase=${phase:-spec}
  validation=${validation:-pending}
  fix_loop=${fix_loop:-0}
  awaiting=${awaiting:-false}
  if [ "$format" = markdown ]; then
    echo "| $name | $phase | $validation | $fix_loop | $awaiting |"
  else
    echo "$name  phase=$phase  validation=$validation  fix_loop=$fix_loop  awaiting=$awaiting"
  fi
done

if [ "$found" -eq 0 ]; then
  echo "(no tasks — run pipeline-init.sh <name>)" >&2
  exit 0
fi

echo "ok: listed $found task(s)" >&2
