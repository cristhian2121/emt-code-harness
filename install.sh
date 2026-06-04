#!/usr/bin/env sh
# Install emt-code-harness into a target project (macOS, Linux, Git Bash / WSL on Windows).
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname "$0")" && pwd)
SOURCE_AGENTS="${SCRIPT_DIR}/subagents"

AGENTS_ONLY=0
TARGET_DIR=""

for arg in "$@"; do
  case "$arg" in
    --agents-only)
      AGENTS_ONLY=1
      ;;
    -h|--help)
      echo "Usage: $0 [--agents-only] [TARGET_DIR]"
      echo ""
      echo "  TARGET_DIR   Project root (default: current directory)"
      echo "  --agents-only   Copy only agents under .agents/agents/ (skip AGENTS.md)"
      echo ""
      echo "Creates .agents/agents/, .agents/scripts/, .agents/artifacts/runs/ if missing."
      echo "Replaces harness files with the same name; does not delete other files."
      exit 0
      ;;
    -*)
      echo "error: unknown option: $arg" >&2
      exit 1
      ;;
    *)
      if [ -n "$TARGET_DIR" ]; then
        echo "error: unexpected argument: $arg" >&2
        exit 1
      fi
      TARGET_DIR=$arg
      ;;
  esac
done

TARGET_DIR=${TARGET_DIR:-.}

if [ ! -d "$TARGET_DIR" ]; then
  echo "error: target directory does not exist: $TARGET_DIR" >&2
  exit 1
fi

TARGET_DIR=$(CDPATH= cd -- "$TARGET_DIR" && pwd)

if [ ! -d "$SOURCE_AGENTS" ]; then
  echo "error: agent source not found: $SOURCE_AGENTS" >&2
  echo "Run this script from the emt-code-harness repository." >&2
  exit 1
fi

AGENT_FILES="
pipeline-contract.md
team-router.md
spec-agent.md
task-agent.md
implement-agent.md
validate-agent.md
"

mkdir -p "${TARGET_DIR}/.agents/agents" "${TARGET_DIR}/.agents/scripts" "${TARGET_DIR}/.agents/artifacts/runs"

echo "Installing harness into: ${TARGET_DIR}"

if [ -d "${SCRIPT_DIR}/scripts" ]; then
  for s in "${SCRIPT_DIR}"/scripts/pipeline-*.sh; do
    [ -f "$s" ] || continue
    base=$(basename "$s")
    cp -f "$s" "${TARGET_DIR}/.agents/scripts/${base}"
    chmod +x "${TARGET_DIR}/.agents/scripts/${base}"
    echo "  updated .agents/scripts/${base}"
  done
fi

for f in $AGENT_FILES; do
  src="${SOURCE_AGENTS}/${f}"
  if [ ! -f "$src" ]; then
    echo "error: missing source file: $src" >&2
    exit 1
  fi
  cp -f "$src" "${TARGET_DIR}/.agents/agents/${f}"
  echo "  updated .agents/agents/${f}"
done

if [ "$AGENTS_ONLY" -eq 0 ]; then
  if [ ! -f "${SCRIPT_DIR}/AGENTS.md" ]; then
    echo "error: missing ${SCRIPT_DIR}/AGENTS.md" >&2
    exit 1
  fi
  cp -f "${SCRIPT_DIR}/AGENTS.md" "${TARGET_DIR}/AGENTS.md"
  echo "  updated AGENTS.md"
else
  echo "  skipped AGENTS.md (--agents-only)"
fi

echo "Done. Agents: ${TARGET_DIR}/.agents/agents/"
echo "       Registry:  ${TARGET_DIR}/.agents/artifacts/REGISTRY.md (created by pipeline)"
echo "       Scripts:   ${TARGET_DIR}/.agents/scripts/pipeline-*.sh"
echo "       Runs:      ${TARGET_DIR}/.agents/artifacts/runs/<name>/<name>.md"
