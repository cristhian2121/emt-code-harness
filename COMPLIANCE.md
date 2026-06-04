# Harness compliance checklist

Use this to verify a project installation against requirements.

| Requirement | Status in harness |
| ----------- | ------------------- |
| Hard implementation uses spec → task → implement → validate | Yes — gateway Tier 2/full; router phases 4–7 |
| Validate can send back to implement | Yes — `validation: fail` + `phase: implement` + fix_loop |
| Validate checks **user request vs delivered work** | Yes — validate-agent **Requirement fit** section |
| Validate runs technical checks | Yes — **Technical** section (lint/build/test) |
| Agents ask user instead of assuming | Yes — `awaiting_user` + `question` in STATE; all phase agents |
| Named flow state | Yes — slug `<name>` + `runs/<name>/STATE.yaml` + `REGISTRY.md` |
| Spec file named after task | Yes — `runs/<name>/<name>.md` |
| Tasks file paired to spec name | Yes — `runs/<name>/<name>.tasks.md` (same slug) |
| Scripts update state/tasks (performance) | Yes — `.agents/scripts/pipeline-*.sh` |
| Explicit role per sub-agent | Yes — `**Role:**` + May/Must not in each agent |
| Only implement-agent edits application code | Yes — table in `pipeline-contract.md` |

## File layout per task `oauth-login`

```
.agents/artifacts/runs/oauth-login/
  STATE.yaml
  oauth-login.md
  oauth-login.tasks.md
  oauth-login.validation.md
```

## Scripts

```bash
.agents/scripts/pipeline-init.sh oauth-login mode=full title="OAuth"
.agents/scripts/pipeline-state.sh oauth-login phase=implement
.agents/scripts/pipeline-spec.sh oauth-login - < spec-body.txt
.agents/scripts/pipeline-tasks.sh oauth-login - < tasks-body.txt
.agents/scripts/pipeline-tasks.sh oauth-login check 1
.agents/scripts/pipeline-registry.sh
```
