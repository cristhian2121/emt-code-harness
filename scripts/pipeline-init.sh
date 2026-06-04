#!/usr/bin/env sh
# Create a named pipeline run. Usage: pipeline-init.sh <name> [mode=fast|full] [title="..."]
set -eu
. "$(dirname "$0")/pipeline-lib.sh"

name=${1:?usage: pipeline-init.sh <name> [mode=fast|full] [title=...]}
shift
validate_name "$name"

mode=fast
title=$name
for arg in "$@"; do
  case "$arg" in
    mode=*) mode=${arg#mode=} ;;
    title=*) title=${arg#title=} ;;
    *) echo "error: unknown arg: $arg" >&2; exit 1 ;;
  esac
done

dir=$(run_dir "$name")
mkdir -p "$dir"

sf=$(spec_file "$name")
if [ ! -f "$sf" ] && [ ! -f "$(legacy_spec "$name")" ]; then
  : > "$sf"
fi

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

echo "ok: initialized runs/$name (phase=spec)"
