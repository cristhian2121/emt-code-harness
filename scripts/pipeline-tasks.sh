#!/usr/bin/env sh
# Write or update tasks file (same stem as spec: <name>.tasks.md).
# Usage:
#   pipeline-tasks.sh <name> -              # body from stdin
#   pipeline-tasks.sh <name> check <n>      # mark nth checkbox [ ] -> [x] (1-based)
set -eu
. "$(dirname "$0")/pipeline-lib.sh"

name=${1:?usage: pipeline-tasks.sh <name> - | check <n>}
cmd=$2
validate_name "$name"

dir=$(run_dir "$name")
mkdir -p "$dir"
out=$(tasks_file "$name")

case "$cmd" in
  -)
    cat > "$out"
    echo "ok: wrote $out"
    ;;
  check)
    n=${3:?usage: pipeline-tasks.sh <name> check <n>}
    if [ ! -f "$out" ]; then
      if [ -f "$(legacy_tasks "$name")" ]; then
        out=$(legacy_tasks "$name")
      else
        echo "error: tasks file missing" >&2
        exit 1
      fi
    fi
    awk -v target="$n" '
      BEGIN { c = 0 }
      /^\- \[ \]/ {
        c++
        if (c == target) { sub(/\[ \]/, "[x]"); }
      }
      { print }
    ' "$out" > "${out}.tmp" && mv "${out}.tmp" "$out"
    echo "ok: checked item $n in $out"
    ;;
  *)
    echo "error: unknown command: $cmd" >&2
    exit 1
    ;;
esac
