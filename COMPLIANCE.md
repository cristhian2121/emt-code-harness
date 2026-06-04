# Harness compliance checklist

| Requirement | Status |
| ----------- | ------ |
| Hard jobs: spec → task → implement → validate (loop) | Yes |
| Validate: user request vs delivered + technical | Yes |
| Ask user; do not assume | Yes — `awaiting_user` in `emt-state/<name>.yaml` |
| Named state per task | Yes — `emt-state/<name>.yaml` |
| Task list = directory of yaml files (no REGISTRY source of truth) | Yes |
| Default task | Yes — `emt-state/_meta.yaml` `active:` |
| Spec + tasks same filename, different folders | Yes |
| Artifacts at project root | Yes |
| Scripts for state/spec/tasks | Yes (8 scripts) |
| Only implement-agent edits app source | Yes |

## Layout

```
AGENTS.md
emt-specs/oauth-login.md
emt-tasks/oauth-login.md
emt-state/_meta.yaml
emt-state/oauth-login.yaml
emt-validation/oauth-login.md
```

Legacy `emt-state/REGISTRY.md` — optional read-only fallback for `active:`; do not maintain.
