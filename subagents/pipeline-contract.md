# Pipeline contract (all agents)

Run from **project root** (same directory as `AGENTS.md`). Scripts: `.agents/scripts/`.

## Layout (project root)

| Path | Content |
| ---- | ------- |
| `emt-specs/<name>.md` | Specification |
| `emt-tasks/<name>.md` | Tasks (**same filename** as spec) |
| `emt-state/<name>.yaml` | **Source of truth** per task (phase, validation, fix_loop, …) |
| `emt-state/_meta.yaml` | **active:** `<name>` — default task slug only |
| `emt-validation/<name>.md` | Validation report |
| `.agents/agents/`, `.agents/scripts/` | Harness (installed) |

**Task list** = files `emt-state/*.yaml` except `_meta.yaml`. No `REGISTRY.md` required. Optional: `pipeline-list.sh` for humans.

## Who may edit what

| Agent | May create/edit | Must not |
| ----- | ----------------- | -------- |
| team-router | `_meta.yaml` via `pipeline-meta.sh`; `pipeline-init` | App source; spec/task/validation bodies |
| spec-agent | `emt-specs/<name>.md`, state (scripts) | App source; `emt-tasks/` |
| task-agent | `emt-tasks/<name>.md`, state (scripts) | App source; `emt-specs/` |
| **implement-agent** | **App source** + task checkboxes via `pipeline-tasks.sh check` | Change spec scope |
| validate-agent | `emt-validation/<name>.md`, state | App source (read-only) |

## Scripts

| Script | Usage |
| ------ | ----- |
| `pipeline-init.sh` | `<name> mode=fast\|full title="..."` — creates state + sets **active** |
| `pipeline-meta.sh` | `active=<name>` — switch default task |
| `pipeline-state.sh` | `<name> phase=... validation=... awaiting_user=... question="..." fix_loop=N` |
| `pipeline-spec.sh` | `<name> -` ← stdin |
| `pipeline-tasks.sh` | `<name> -` ← stdin; `<name> check <n>` |
| `pipeline-validation.sh` | `<name> -` ← stdin |
| `pipeline-list.sh` | optional `--markdown` (stdout only; not committed) |

## STATE (`emt-state/<name>.yaml`)

`task`, `phase` (spec|task|implement|validate), `validation` (pending|done|fail), `fix_loop`, `awaiting_user`, `question`, `mode`, `title`.

Read state via `resolve_state_file` concept: prefer `emt-state/<name>.yaml`.

## Ask — do not assume

→ `pipeline-state.sh` `awaiting_user=true` `question="..."` → return `task: <name> awaiting_user`.

## Handoff

`task: <name> done` | `blocked: …` | `awaiting_user`

## Routing priority (router)

1. `task:` in handoff  
2. `active:` in `emt-state/_meta.yaml`  
3. If exactly one `emt-state/<name>.yaml` → that name  
4. Else `pipeline-list.sh` + ask user  

## Validation report

Requirement fit + Technical. Pass only if both OK. max fix loops: 2 (fast) / 3 (full).

## Legacy

`.agents/artifacts/runs/` and old `REGISTRY.md` — read-only fallback; new writes only under `emt-*`.
