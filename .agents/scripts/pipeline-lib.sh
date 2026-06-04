#!/usr/bin/env sh
# Shared helpers. Run from project root (where AGENTS.md lives).
set -eu

EMT_SPECS_DIR=emt-specs
EMT_TASKS_DIR=emt-tasks
EMT_STATE_DIR=emt-state
EMT_VALIDATION_DIR=emt-validation
META_BASENAME=_meta

ensure_emt_dirs() {
  mkdir -p "$EMT_SPECS_DIR" "$EMT_TASKS_DIR" "$EMT_STATE_DIR" "$EMT_VALIDATION_DIR"
}

validate_name() {
  name=$1
  case "$name" in
    ''|*/*|*' '*|$META_BASENAME|_example)
      echo "error: invalid task name: $name" >&2
      exit 1
      ;;
  esac
  case "$name" in
    *[!a-z0-9-]*)
      echo "error: task name must be kebab-case (a-z, 0-9, -): $name" >&2
      exit 1
      ;;
  esac
}

meta_file() { printf '%s/%s.yaml\n' "$EMT_STATE_DIR" "$META_BASENAME"; }
spec_file() { printf '%s/%s.md\n' "$EMT_SPECS_DIR" "$1"; }
tasks_file() { printf '%s/%s.md\n' "$EMT_TASKS_DIR" "$1"; }
state_file() { printf '%s/%s.yaml\n' "$EMT_STATE_DIR" "$1"; }
validation_file() { printf '%s/%s.md\n' "$EMT_VALIDATION_DIR" "$1"; }

get_active() {
  mf=$(meta_file)
  if [ -f "$mf" ]; then
    grep '^active:' "$mf" 2>/dev/null | sed 's/^active: *//' | head -1
    return
  fi
  if [ -f "$EMT_STATE_DIR/REGISTRY.md" ]; then
    grep '^active:' "$EMT_STATE_DIR/REGISTRY.md" 2>/dev/null | sed 's/^active: *//' | head -1
    return
  fi
  printf ''
}

set_active() {
  name=$1
  validate_name "$name"
  ensure_emt_dirs
  cat > "$(meta_file)" <<EOF
# Active task slug (single source for default routing)
active: $name
EOF
}

# Print one task name per line (sorted)
list_task_names() {
  ensure_emt_dirs
  for sf in "$EMT_STATE_DIR"/*.yaml; do
    [ -f "$sf" ] || continue
    name=$(basename "$sf" .yaml)
    case "$name" in $META_BASENAME|_example) continue ;; esac
    echo "$name"
  done | sort
}

count_tasks() {
  list_task_names | wc -l | tr -d ' '
}

# Legacy (.agents/artifacts layout) — read only
legacy_spec() {
  n=$1
  if [ -f ".agents/artifacts/runs/$n/$n.md" ]; then
    printf '.agents/artifacts/runs/%s/%s.md\n' "$n" "$n"
  else
    printf '.agents/artifacts/runs/%s/SPEC.md\n' "$n"
  fi
}
legacy_tasks() {
  n=$1
  if [ -f ".agents/artifacts/runs/$n/$n.tasks.md" ]; then
    printf '.agents/artifacts/runs/%s/%s.tasks.md\n' "$n" "$n"
  elif [ -f ".agents/artifacts/runs/$n/$n.md" ]; then
    printf '.agents/artifacts/runs/%s/%s.md\n' "$n" "$n"
  else
    printf '.agents/artifacts/runs/%s/TASKS.md\n' "$n"
  fi
}
legacy_state() {
  n=$1
  if [ -f ".agents/artifacts/runs/$n/STATE.yaml" ]; then
    printf '.agents/artifacts/runs/%s/STATE.yaml\n' "$n"
  else
    printf '.agents/artifacts/runs/%s/STATE.md\n' "$n"
  fi
}

resolve_spec_file() {
  n=$1
  sf=$(spec_file "$n")
  if [ -f "$sf" ]; then printf '%s\n' "$sf"; return; fi
  if [ -f "$(legacy_spec "$n")" ]; then legacy_spec "$n"; return; fi
  printf '%s\n' "$sf"
}

resolve_tasks_file() {
  n=$1
  tf=$(tasks_file "$n")
  if [ -f "$tf" ]; then printf '%s\n' "$tf"; return; fi
  if [ -f "$(legacy_tasks "$n")" ]; then legacy_tasks "$n"; return; fi
  printf '%s\n' "$tf"
}

resolve_state_file() {
  n=$1
  sf=$(state_file "$n")
  if [ -f "$sf" ]; then printf '%s\n' "$sf"; return; fi
  if [ -f "$(legacy_state "$n")" ]; then legacy_state "$n"; return; fi
  printf '%s\n' "$sf"
}
