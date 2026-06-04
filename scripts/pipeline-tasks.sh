#!/usr/bin/env sh
# Write emt-tasks/<name>.md or mark checkbox n
set -eu
. "$(dirname "$0")/pipeline-lib.sh"

name=${1:?usage: pipeline-tasks.sh <name> - | check <n>}
cmd=$2
validate_name "$name"
ensure_emt_dirs
out=$(tasks_file "$name")

case "$cmd" in
  -)
    cat > "$out"
    echo "ok: wrote emt-tasks/$name.md"
    ;;
  check)
    n=${3:?usage: pipeline-tasks.sh <name> check <n>}
    tf=$(resolve_tasks_file "$name")
    awk -v target="$n" '
      BEGIN { c = 0 }
      /^\- \[ \]/ { c++; if (c == target) sub(/\[ \]/, "[x]"); }
      { print }
    ' "$tf" > "${tf}.tmp" && mv "${tf}.tmp" "$tf"
    echo "ok: checked item $n in $tf"
    ;;
  *)
    echo "error: unknown command: $cmd" >&2
    exit 1
    ;;
esac
