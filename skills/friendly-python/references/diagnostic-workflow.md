# Diagnostic Workflow

Use when the user shares Pyright, Pylance, mypy, Ruff, Pylint, pytest, or editor diagnostics.

## Phase 0: Project Context

Determine:

- Python version: `pyproject.toml`, `setup.cfg`, `.python-version`, runtime
- runner: uv, Poetry, PDM, Pipenv, tox, nox, plain venv
- tool config: `pyrightconfig.json`, `mypy.ini`, `ruff.toml`, `pytest.ini`, `pyproject.toml`

See `project-workflow.md` for command selection.

## Phase 1: Triage

Group diagnostics:

| Priority | Category | Examples |
|---|---|---|
| P0 | Real bugs | invalid access, wrong return type, unbound variable, failing test |
| P1 | Import/runtime risks | unresolved import, circular import, missing dependency |
| P2 | Type source problems | unknown parameter/member/variable, missing generic |
| P3 | Deprecated/modernization | `Optional`, old generics, outdated syntax |
| P4 | Logging/exceptions | logging f-string, broad exception |
| P5 | Style only | docstring, line length, naming |

Fix P0/P1 before style. Style-only cleanup should stay scoped.

## Phase 2: Read Before Editing

Read affected files and surrounding code. Diagnostics can be stale or symptoms of an upstream type problem.

Also inspect tests or call sites before changing signatures.

## Phase 3: Fix Root Causes

Prefer:

- annotate the source of unknown values
- introduce TypedDict/dataclass for structured data
- narrow optional values with explicit guards
- model repeated data shapes once instead of repeating `dict[str, object]`
- split mixed responsibilities that confuse inference
- remove dead code/imports only after checking runtime usage

Avoid:

- `cast()` as the first move
- `Any` to silence propagation
- broad ignores
- changing tests to match broken behavior

## Phase 4: Suppression

Use suppression only when the code is correct and the tool cannot know it.

Rules:

- Include a specific code: `# type: ignore[assignment]`, `# noqa: F401`.
- Explain non-obvious suppressions.
- Keep suppression local to the line or smallest block.
- Never use bare `# type: ignore` or bare `# noqa`.

## Phase 5: Verify

Run the same tool that reported the diagnostic, through the native runner:

```bash
uv run pyright
poetry run mypy
python -m ruff check .
python -m pytest path/to/test.py
```

If the exact tool cannot run, state why and run the closest honest fallback.
