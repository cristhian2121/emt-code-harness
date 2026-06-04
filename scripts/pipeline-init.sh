#!/usr/bin/env sh
# Create a named pipeline run at project root.
# Usage: pipeline-init.sh <name> [mode=fast|full] [title="..."]
set -eu
. "$(dirname "$0")/pipeline-lib.sh"

name=${1:?usage: pipeline-init.sh <name> [mode=fast|full] [title=...]}
shift
validate_name "$name"
ensure_emt_dirs

mode=fast
title=$name
for arg in "$@"; do
  case "$arg" in
    mode=*) mode=${arg#mode=} ;;
    title=*) title=${arg#title=} ;;
    *) echo "error: unknown arg: $arg" >&2; exit 1 ;;
  esac
done

sf=$(spec_file "$name")
[ -f "$sf" ] || : > "$sf"

cat > "$(state_file "$name")" <<EOF
task: $name
phase: spec
validation: pending
fix_loop: 0
awaiting_user: false
question: ""
mode: $mode
title: $title
EOF

set_active "$name"

echo "ok: $name → emt-specs/$name.md, emt-state/$name.yaml, active set in _meta.yaml"
