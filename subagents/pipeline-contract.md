# Pipeline contract (all agents)

## Who may edit what

| Agent | May create/edit | Must not |
| ----- | ----------------- | -------- |
| team-router | `REGISTRY.md` (via script), delegate | Application source code; `runs/<name>/*` content files |
| spec-agent | `runs/<name>/<name>.md`, STATE (script) | Application source code; `<name>.tasks.md` |
| task-agent | `runs/<name>/<name>.tasks.md`, STATE (script) | Application source code; `<name>.md` |
| **implement-agent** | **Application source code** + pipeline tasks/STATE (scripts) | Change spec or rewrite tasks scope |
| validate-agent | `runs/<name>/<name>.validation.md`, STATE (script) | Application source code (read-only for audit) |

**Only implement-agent** modifies project source (src, tests, config, etc.). Others: pipeline artifacts and scripts only.

## Scripts (prefer over hand-editing YAML/lists)

Run from **project root**. Scripts live in `.agents/scripts/`.

| Script | Usage |
| ------ | ----- |
| `pipeline-init.sh` | `<name> mode=fast\|full title="..."` — new run |
| `pipeline-state.sh` | `<name> phase=... validation=... fix_loop=... awaiting_user=... question="..."` |
| `pipeline-spec.sh` | `<name> -` — write spec body via stdin |
| `pipeline-tasks.sh` | `<name> -` — write tasks via stdin; `<name> check <n>` — mark checkbox n |
| `pipeline-validation.sh` | `<name> -` — write validation report via stdin |
| `pipeline-registry.sh` | rebuild `REGISTRY.md` from all runs |

**Do not** rewrite `STATE.yaml` or checkbox lines manually unless a script is unavailable.

## Named files (per run `<name>`)

| File | Role |
| ---- | ---- |
| `runs/<name>/STATE.yaml` | Machine state |
| `runs/<name>/<name>.md` | **Spec** (same basename as task slug) |
| `runs/<name>/<name>.tasks.md` | **Tasks** (same slug + `.tasks.md`) |
| `runs/<name>/<name>.validation.md` | Validation report |

Legacy `SPEC.md` / `TASKS.md` / `VALIDATION.md` — read if present; migrate to named files on write.

## STATE.yaml fields

```yaml
task: <name>
phase: spec | task | implement | validate
validation: pending | done | fail
fix_loop: 0
awaiting_user: false
question: ""
mode: fast | full
title: human-readable title
```

Router runs `pipeline-registry.sh` each turn.

## Ask — do not assume

If requirements, scope, or acceptance criteria are **unclear**:

1. Run `pipeline-state.sh <name> awaiting_user=true question="…"` with **one** concrete question.
2. Return `task: <name> awaiting_user` — stop; do not write spec/tasks/code.
3. After the user answers, set `awaiting_user=false` and continue.

Never guess APIs, paths, business rules, or UX.

## Handoff to router

- `task: <name> done`
- `task: <name> blocked: <reason>`
- `task: <name> awaiting_user` (question in STATE)

## Read order

| phase | Read |
| ----- | ---- |
| spec | STATE, `<name>.md` draft, targeted sources |
| task | STATE, `<name>.md` |
| implement | STATE, `<name>.tasks.md`, `<name>.validation.md` if fail |
| validate | STATE, `<name>.md`, `<name>.tasks.md`, changed code paths |

## Spec content (`<name>.md`)

`mode`, **user request summary**, acceptance criteria (testable), paths, deps, out-of-scope. Limits: fast ≤35 lines; full ≤80 lines.

## Tasks (`<name>.tasks.md`)

Checkboxes only. fast ≤5; full ≤12.

## Validation (`<name>.validation.md`)

Two sections required:

1. **Requirement fit** — map each acceptance criterion from `<name>.md` to evidence (file:line or behavior); mark met / not met.
2. **Technical** — lint/build/test commands + result (≤8 lines on pass; ~20 log lines on fail).

Pass only if **both** requirement fit and technical checks succeed.

## Fix loops

max = 2 (fast) or 3 (full). On technical or requirement fail: `validation=fail`, `phase=implement`, increment `fix_loop` via `pipeline-state.sh`.

## Parallel runs

One `<name>` per invocation. Distinct slugs per parallel feature.
