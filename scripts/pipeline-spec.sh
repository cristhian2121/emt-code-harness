#!/usr/bin/env sh
# Write spec file. Usage: pipeline-spec.sh <name> -   (body from stdin)
set -eu
. "$(dirname "$0")/pipeline-lib.sh"

name=${1:?usage: pipeline-spec.sh <name> -}
body_src=${2:--}
validate_name "$name"

dir=$(run_dir "$name")
mkdir -p "$dir"
out=$(spec_file "$name")

if [ "$body_src" != "-" ]; then
  echo "error: second arg must be - (stdin)" >&2
  exit 1
fi

cat > "$out"

echo "ok: wrote $(spec_file "$name")"
