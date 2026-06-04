#!/usr/bin/env sh
# Write emt-specs/<name>.md from stdin
set -eu
. "$(dirname "$0")/pipeline-lib.sh"

name=${1:?usage: pipeline-spec.sh <name> -}
[ "${2:--}" = "-" ] || { echo "error: use - for stdin" >&2; exit 1; }
validate_name "$name"
ensure_emt_dirs
cat > "$(spec_file "$name")"
echo "ok: wrote emt-specs/$name.md"
