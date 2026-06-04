#!/usr/bin/env sh
# Write validation report. Usage: pipeline-validation.sh <name> -
set -eu
. "$(dirname "$0")/pipeline-lib.sh"

name=${1:?usage: pipeline-validation.sh <name> -}
validate_name "$name"
[ "${2:--}" = "-" ] || { echo "error: use - for stdin" >&2; exit 1; }

mkdir -p "$(run_dir "$name")"
cat > "$(validation_file "$name")"
echo "ok: wrote $(validation_file "$name")"
