# emt-code-harness

Plantilla de workflow SDLC con agentes para **Cursor**. Cada repositorio decide si la instala o no; no es global ni obligatoria.

## Instalación por proyecto (opt-in)

Desde este repositorio, apunta al proyecto destino:

```bash
# macOS / Linux
./install.sh /ruta/al/proyecto

# O desde la raíz del proyecto destino
/path/to/emt-code-harness/install.sh .

# Windows: Git Bash o WSL
bash install.sh C:/dev/mi-app
```

El script:

- Crea `.agents/agents/` y `.agents/artifacts/` si no existen.
- Copia los **5 agentes** a `.agents/agents/` (reemplaza solo archivos con el mismo nombre).
- Copia `AGENTS.md` a la raíz del proyecto (salvo con `--agents-only`).

```bash
./install.sh --agents-only /ruta/al/proyecto   # solo los 5 .md, sin AGENTS.md
./install.sh --help
```

Luego en Cursor, confirma que el workspace carga `AGENTS.md` como regla del proyecto.

Trabaja siempre en una rama de feature (`feature/<id>-<slug>`), nunca en `main`/`master` con el pipeline activo.

**Repos sin harness:** no ejecutes el instalador. El agente de Cursor se comporta como siempre.

**Actualizar el harness:** vuelve a ejecutar `install.sh` en el proyecto; los archivos del harness se sobrescriben, el resto en `.agents/` se conserva.

## Verificación rápida

1. Tras `install.sh .`, existen `.agents/agents/` (5 archivos) y `.agents/artifacts/`.
2. Un segundo `install.sh` actualiza los `.md` del harness sin borrar otros archivos en esas carpetas.
3. `AGENTS.md` en la raíz referencia `./.agents/agents/team-router.md`.

## Velocidad: diseño para no alargar sesiones

El pipeline completo (4 fases) es para **features medianas/grandes**. Para el día a día:

| Modo                  | Cuándo                                           | Qué pasa                                                                      |
| --------------------- | ------------------------------------------------ | ----------------------------------------------------------------------------- |
| **Tier 1**            | Preguntas, typos, cambios de 1 línea             | El gateway responde o edita **sin** subagentes ni artefactos.                 |
| **Fast path**         | Bugfix acotado, ≤3 archivos, sin deps ni schema  | SPEC + TASKS mínimos; validación solo en archivos tocados; máx. 2 bucles fix. |
| **Pipeline completo** | Feature nueva, refactor amplio, contratos/API/DB | Las 4 fases con artefactos completos.                                         |

Reglas de equipo para ir rápido:

- Pide explícitamente _"rápido"_ o _"solo X archivo"_ cuando aplique.
- No uses Tier 2 para tareas que caben en una respuesta directa (Tier 1).
- Commitea `SPEC.md` / `TASKS.md` en el PR solo si aportan revisión; en fast path pueden ser muy cortos.

## Flujo (pipeline completo)

| Fase | Agente            | Artefacto                    |
| ---- | ----------------- | ---------------------------- |
| 1    | `spec-agent`      | `.agents/artifacts/SPEC.md`  |
| 2    | `task-agent`      | `.agents/artifacts/TASKS.md` |
| 3    | `implement-agent` | código + `[x]` en TASKS      |
| 4    | `validate-agent`  | reporte breve                |

El `team-router` elige la fase según qué archivos ya existen en `.agents/artifacts/`.

## Cuándo usar qué (gateway)

- **Explicaciones, documentación, dudas** → Tier 1.
- **Cambio pequeño acotado** → Fast path (router + artefactos mínimos).
- **Feature / refactor grande** → Pipeline completo vía `team-router`.

## Artefactos y Git

- Ruta: `.agents/artifacts/SPEC.md`, `TASKS.md`.
- Recomendado: incluirlos en el PR del feature para trazabilidad.
- **Nuevo feature en la misma rama:** borra o archiva los artefactos anteriores y vuelve a pedir el trabajo.

## Estructura

**Repo plantilla (emt-code-harness):**

```
install.sh             # Instalador
AGENTS.md              # Gateway (se copia al destino)
subagents/             # Fuente de los 5 agentes para install.sh
```

**Proyecto destino (tras install):**

```
AGENTS.md
.agents/
  agents/              # team-router, spec, task, implement, validate
  artifacts/           # SPEC.md, TASKS.md en runtime
```

## Limitaciones

- Requiere Cursor con reglas de workspace que lean `AGENTS.md`.
- En Windows nativo (CMD/PowerShell) usa Git Bash o WSL para `install.sh`.
- La fase de validación ejecuta comandos del proyecto (`lint`, `test`, etc.); no sustituye CI.
- La velocidad depende del tamaño del pedido: acota el scope en el prompt.
