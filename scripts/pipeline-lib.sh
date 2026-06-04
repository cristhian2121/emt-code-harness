#!/usr/bin/env sh
# Shared helpers for pipeline scripts. Sourced, not executed directly.
set -eu

pipeline_root() {
  if [ -n "${PIPELINE_ROOT:-}" ]; then
    printf '%s\n' "$PIPELINE_ROOT"
    return
  fi
  if [ -d ".agents/artifacts" ]; then
    printf '%s\n' ".agents/artifacts"
    return
  fi
  echo "error: .agents/artifacts not found (run from project root)" >&2
  exit 1
}

run_dir() {
  name=$1
  root=$(pipeline_root)
  printf '%s/runs/%s\n' "$root" "$name"
}

validate_name() {
  name=$1
  case "$name" in
    ''|*/*|*' '*)
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

spec_file() { printf '%s/%s.md\n' "$(run_dir "$1")" "$1"; }
tasks_file() { printf '%s/%s.tasks.md\n' "$(run_dir "$1")" "$1"; }
validation_file() { printf '%s/%s.validation.md\n' "$(run_dir "$1")" "$1"; }
state_file() { printf '%s/STATE.yaml\n' "$(run_dir "$1")"; }

# Legacy filenames
legacy_spec() { printf '%s/SPEC.md\n' "$(run_dir "$1")"; }
legacy_tasks() { printf '%s/TASKS.md\n' "$(run_dir "$1")"; }
