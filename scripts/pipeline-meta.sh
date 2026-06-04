#!/usr/bin/env sh
# Workspace meta (active task). Usage: pipeline-meta.sh active=<name>
set -eu
. "$(dirname "$0")/pipeline-lib.sh"

[ $# -ge 1 ] || { echo "usage: pipeline-meta.sh active=<name>" >&2; exit 1; }

for arg in "$@"; do
  case "$arg" in
    active=*)
      name=${arg#active=}
      [ -n "$name" ] || { echo "error: active name empty" >&2; exit 1; }
      sf=$(resolve_state_file "$name")
      if [ ! -f "$sf" ]; then
        echo "error: no state for $name — run pipeline-init.sh first" >&2
        exit 1
      fi
      set_active "$name"
      echo "ok: active=$name (emt-state/_meta.yaml)"
      ;;
    *)
      echo "error: unknown: $arg (only active=<name>)" >&2
      exit 1
      ;;
  esac
done
