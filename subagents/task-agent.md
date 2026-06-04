# Phase 2: Task Agent

> **Role Summary:** Break SPEC into an executable checklist. **Fewer tasks = faster runs.**

## Primary objective

Create `.agents/artifacts/TASKS.md` from `SPEC.md` — granular enough to avoid drift, not so granular that every line is a checkbox.

## Speed rules (mandatory)

- Read `**Pipeline mode:**` from SPEC.
- **fast:** ≤ 5 checkboxes total; combine related edits in one file into one task.
- **full:** ≤ 12 checkboxes; prefer one task per file or logical unit, not per function.
- Only list files that appear in SPEC (or tests directly covering them).
- Skip "setup" task if SPEC says no new dependencies.

## Context & inputs

- `.agents/artifacts/SPEC.md`
- Source files referenced in SPEC only

## Output: `.agents/artifacts/TASKS.md`

```markdown
# Implementation Tasks

**Pipeline mode:** fast | full

- [ ] **Area:** Concrete action with `path/to/file` ...
```

## Definition of done

`TASKS.md` exists, mode matches SPEC, and implement-agent can finish without guessing scope.
