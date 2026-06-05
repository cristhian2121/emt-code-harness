#!/usr/bin/env sh
# Install emt-code-harness into a target project (macOS, Linux, Bash / WSL on Windows).
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname "$0")" && pwd)
SOURCE_AGENTS="${SCRIPT_DIR}/subagents"
SOURCE_SCRIPTS="${SCRIPT_DIR}/scripts"

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
      echo "  TARGET_DIR      Project root (default: .) — same folder as AGENTS.md"
      echo "  --agents-only   Skip copying AGENTS.md"
      echo ""
      echo "Installs:"
      echo "  AGENTS.md"
      echo "  .agents/agents/       (pipeline-contract + 5 phase agents)"
      echo "  .agents/scripts/      (pipeline-*.sh)"
      echo "  emt-specs/            (<name>.md)"
      echo "  emt-tasks/            (<name>.md — same name as spec)"
      echo "  emt-state/            (<name>.yaml + _meta.yaml for active task)"
      echo "  emt-validation/       (<name>.md)"
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

REQUIRED_SCRIPTS="
pipeline-lib.sh
pipeline-init.sh
pipeline-meta.sh
pipeline-state.sh
pipeline-spec.sh
pipeline-tasks.sh
pipeline-validation.sh
pipeline-list.sh
"

mkdir -p \
  "${TARGET_DIR}/.agents/agents" \
  "${TARGET_DIR}/.agents/scripts" \
  "${TARGET_DIR}/emt-specs" \
  "${TARGET_DIR}/emt-tasks" \
  "${TARGET_DIR}/emt-state" \
  "${TARGET_DIR}/emt-validation"

echo "Installing harness into: ${TARGET_DIR}"

if [ ! -d "$SOURCE_SCRIPTS" ]; then
  echo "error: scripts not found: $SOURCE_SCRIPTS" >&2
  exit 1
fi

for s in $REQUIRED_SCRIPTS; do
  src="${SOURCE_SCRIPTS}/${s}"
  if [ ! -f "$src" ]; then
    echo "error: missing script: $src" >&2
    exit 1
  fi
  cp -f "$src" "${TARGET_DIR}/.agents/scripts/${s}"
  chmod +x "${TARGET_DIR}/.agents/scripts/${s}"
  echo "  updated .agents/scripts/${s}"
done

for f in $AGENT_FILES; do
  src="${SOURCE_AGENTS}/${f}"
  if [ ! -f "$src" ]; then
    echo "error: missing agent: $src" >&2
    exit 1
  fi
  cp -f "$src" "${TARGET_DIR}/.agents/agents/${f}"
  echo "  updated .agents/agents/${f}"
done

if [ -f "${SCRIPT_DIR}/emt-state/_meta.yaml" ] && [ ! -f "${TARGET_DIR}/emt-state/_meta.yaml" ]; then
  cp -f "${SCRIPT_DIR}/emt-state/_meta.yaml" "${TARGET_DIR}/emt-state/_meta.yaml"
  echo "  created emt-state/_meta.yaml"
fi

for d in emt-specs emt-tasks emt-state emt-validation; do
  touch "${TARGET_DIR}/${d}/.gitkeep"
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

echo ""
echo "Done."
echo "  Gateway:    ${TARGET_DIR}/AGENTS.md"
echo "  Agents:     ${TARGET_DIR}/.agents/agents/ (6)"
echo "  Scripts:    ${TARGET_DIR}/.agents/scripts/ (8)"
echo "  State:      ${TARGET_DIR}/emt-state/<name>.yaml + _meta.yaml"
echo "  List tasks: ${TARGET_DIR}/.agents/scripts/pipeline-list.sh"
