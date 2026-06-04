# emt-code-harness

Plantilla SDLC con agentes para asistentes de código (Cursor, Claude Code, Codex, etc.). Instalación opt-in por proyecto.

## Instalación

```bash
./install.sh /ruta/al/proyecto
./install.sh --help
```

Instala: `AGENTS.md`, 6 agentes, **8 scripts**, carpetas `emt-specs/`, `emt-tasks/`, `emt-state/`, `emt-validation/`, y `emt-state/_meta.yaml`.

## Estado: solo YAML (sin REGISTRY.md)

Cada tarea = un archivo. La **lista de procesos** es el directorio:

```
emt-state/
  _meta.yaml          # active: oauth-login  (tarea por defecto)
  oauth-login.yaml    # phase, validation, fix_loop, awaiting_user, …
  fix-footer.yaml
```

| Archivo | Rol |
|---------|-----|
| `emt-specs/<name>.md` | Spec |
| `emt-tasks/<name>.md` | Tasks (mismo `<name>.md`) |
| `emt-state/<name>.yaml` | **Fuente de verdad** del flujo |
| `emt-state/_meta.yaml` | Solo `active:` |
| `emt-validation/<name>.md` | Reporte validate |

Vista humana opcional (no commitear como fuente de verdad):

```bash
.agents/scripts/pipeline-list.sh
.agents/scripts/pipeline-list.sh --markdown
```

## Scripts clave

```bash
.agents/scripts/pipeline-init.sh oauth-login mode=full title="OAuth"
.agents/scripts/pipeline-meta.sh active=oauth-login
.agents/scripts/pipeline-spec.sh oauth-login - < spec.txt
.agents/scripts/pipeline-tasks.sh oauth-login - < tasks.txt
.agents/scripts/pipeline-state.sh oauth-login phase=implement
.agents/scripts/pipeline-list.sh
```

Ver [COMPLIANCE.md](COMPLIANCE.md).

## Flujo

spec → task → implement → validate (validate puede volver a implement). Solo **implement-agent** edita código fuente.

## Triage (gateway)

| Intent | Acción |
| ------ | ------ |
| Q&A, typo, fix mínimo | Tier 1 |
| Cambio pequeño | Fast + `task: <slug>` |
| Implementación difícil | Full pipeline obligatorio |

Solo `AGENTS.md` always-on; agentes bajo demanda.

## Repo plantilla

```
install.sh
AGENTS.md
subagents/
scripts/
emt-state/_meta.yaml
COMPLIANCE.md
```
