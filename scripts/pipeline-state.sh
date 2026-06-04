#!/usr/bin/env sh
# Update STATE.yaml. Usage: pipeline-state.sh <name> key=value [key=value ...]
set -eu
. "$(dirname "$0")/pipeline-lib.sh"

name=${1:?usage: pipeline-state.sh <name> phase=... validation=...}
shift
validate_name "$name"

dir=$(run_dir "$name")
mkdir -p "$dir"
sf=$(state_file "$name")

if [ ! -f "$sf" ]; then
  echo "error: missing STATE — run pipeline-init.sh $name first" >&2
  exit 1
fi

# Read current values (simple grep; YAML is flat key: value)
get_val() {
  grep "^$1:" "$sf" 2>/dev/null | sed "s/^$1: *//" | head -1
}

task=$(get_val task); task=${task:-$name}
phase=$(get_val phase); phase=${phase:-spec}
validation=$(get_val validation); validation=${validation:-pending}
fix_loop=$(get_val fix_loop); fix_loop=${fix_loop:-0}
awaiting=$(get_val awaiting_user); awaiting=${awaiting:-false}
question=$(get_val question); question=${question:-}
mode=$(get_val mode); mode=${mode:-fast}
title=$(get_val title); title=${title:-$name}

for arg in "$@"; do
  case "$arg" in
    phase=*) phase=${arg#phase=} ;;
    validation=*) validation=${arg#validation=} ;;
    fix_loop=*) fix_loop=${arg#fix_loop=} ;;
    awaiting_user=*) awaiting=${arg#awaiting_user=} ;;
    question=*) question=${arg#question=} ;;
    mode=*) mode=${arg#mode=} ;;
    title=*) title=${arg#title=} ;;
    task=*) task=${arg#task=} ;;
    *)
      echo "error: unknown field: $arg" >&2
      exit 1
      ;;
  esac
done

cat > "$sf" <<EOF
task: $task
phase: $phase
validation: $validation
fix_loop: $fix_loop
awaiting_user: $awaiting
question: "$question"
mode: $mode
title: $title
EOF

echo "ok: $name phase=$phase validation=$validation awaiting_user=$awaiting"
