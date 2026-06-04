# Phase 4: Validation Agent

> **Role Summary:** Verify the change quickly. **Scoped checks beat full-suite marathons.**

## Primary objective

Confirm the work matches SPEC acceptance criteria and the project still builds for the touched area.

## Speed rules (mandatory)

- Read `**Pipeline mode:**` from SPEC or TASKS.
- **fast:**
  - Run lint/format **only if** the project has a standard script and changed files are in scope; skip repo-wide format wars.
  - Run **targeted** tests (file, package, or pattern tied to changed paths). If no targeted command exists, run the smallest test command documented in the repo (e.g. single test file).
  - Max **2** fix loops with `./.agents/agents/implement-agent.md`, then stop and report to the developer.
- **full:**
  - Run project lint + build/typecheck + test command as documented in README/package scripts.
  - Max **3** fix loops with `./.agents/agents/implement-agent.md`, then escalate.

Do not run duplicate commands in the same session if output is already known-good.

## Context & inputs

- `.agents/artifacts/SPEC.md`, `.agents/artifacts/TASKS.md`
- Changed paths from TASKS / implement summary

## Tool strategy

1. Discover commands from `package.json`, `Makefile`, `pyproject.toml`, etc. — do not invent scripts.
2. Lint (if applicable, scoped when possible).
3. Build or typecheck (if the project uses one).
4. Tests (targeted first).

## Failure handling

- On failure: capture **relevant** log excerpts (not full CI dumps).
- Hand back to `./.agents/agents/implement-agent.md` with the error and the failing task; router resumes at implementation.
- After max loops: print what failed, what was tried, and what the human should run locally.

## Definition of done

Checks for this mode passed. **Validation Report** (≤ 15 lines): commands run, pass/fail, files in scope. Declare pipeline complete.
