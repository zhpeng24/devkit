---
name: friendly-python
description: "Use when writing, editing, reviewing, refactoring, testing, packaging, or fixing diagnostics in Python codebases."
---

# Friendly Python

## Core Promise

Write Python that is easy to read, easy to change, easy to test, and hard to misuse.

This skill optimizes for maintainability before cleverness. Tools, types, tests, and formatting exist to protect readable code. If code is unreadable, everything else is secondary.

Treat Python as engineering code, not a demo language. Dynamic typing is not permission to pass vague shapes around. Production Python should make concepts, boundaries, and failure modes explicit.

Style north star: direct, explicit Python engineering. Prefer clear modules, intentional public surfaces, concrete names, readable imperative flow, precise errors, and minimal magic. Clarity beats ceremony.

## When To Use

Use for any Python work:

- creating or changing `.py` / `.pyi` files
- fixing bugs, type errors, lint errors, or test failures
- adding features, tests, CLI commands, packages, or project config
- reviewing Python diffs for maintainability
- deciding Python project layout, public API, or verification commands

Do not use this to impose a new toolchain on a project unless the task is explicitly project setup or cleanup.

## First 60 Seconds

Before editing, build the minimum useful map:

1. Identify project shape: application, service, CLI, library/SDK, script collection, notebook support, or mixed repo.
2. Identify tooling: `uv.lock`, `poetry.lock`, `pdm.lock`, `Pipfile`, `tox.ini`, `noxfile.py`, `pyproject.toml`, `requirements*.txt`.
3. Read local config: `pyproject.toml`, `pyrightconfig.json`, `mypy.ini`, `ruff.toml`, `pytest.ini`.
4. Find the smallest relevant code path and tests.
5. Choose the project type from `references/project-types.md` and the playbook from `references/task-playbooks.md`.

Follow the project first. Improve quality inside the task boundary.

## Task Router

| Task | Path |
|---|---|
| Bug fix | Reproduce or locate failing behavior, make the smallest readable fix, add or update behavior test, verify regression path |
| Type/lint diagnostics | Classify errors, fix source types before symptoms, avoid `Any`/ignore spread, run native checker |
| Feature | Define observable behavior, add minimal test or acceptance check, implement cleanly, verify public surfaces |
| Refactor/cleanup | Preserve behavior, improve names/boundaries/control flow, keep diff scoped, run existing tests |
| New Python project | Choose the smallest viable toolchain, create clear package/CLI/test structure, add lint/type/test baseline |
| Library/API change | Protect public imports, compatibility, `__all__`, `py.typed`, changelog/docs, downstream ergonomics |
| Tests | Test behavior and boundaries, not private implementation trivia; remove duplicated setup noise |

Detailed paths live in `references/task-playbooks.md`.

## Readability Contract

Code is not done until the next maintainer can scan it safely.

Before delivery, Python code must be:

- **Easy to name:** modules, classes, functions, variables, and tests use domain language.
- **Easy to scan:** control flow is shallow; happy path is visible; exceptional paths are explicit.
- **Easy to test:** side effects sit at boundaries; core logic can be exercised without heavy setup.
- **Easy to change:** responsibilities are separated; unrelated concepts are not bundled together.
- **Hard to misuse:** types and constructors make invalid states difficult to represent.
- **Explicit in shape:** structured data has named types, not anonymous `dict`/`tuple` chains.

Cleanliness rules:

- Every abstraction must earn its place.
- Every helper must have a clear owner; avoid dumping grounds like broad `utils.py`.
- Every comment must justify why naming or structure cannot express the intent.
- Every test must protect behavior, not mirror implementation.
- Every module must have a reason to exist.

See `references/readability-contract.md` for examples and code smells.

## Hard Rules

These are defects unless there is an explicit project constraint:

- Do not make code harder to read to satisfy a tool.
- Do not alter runtime behavior while "only fixing types" or "only formatting".
- Do not introduce a new package manager, formatter, layout, or test framework without need.
- Do not spread raw `Any`, bare `dict`, bare `list`, or unstructured JSON through core logic.
- Do not use Python's flexibility to skip modeling. If data has a schema, name it.
- Do not hide simple behavior behind framework-like abstractions or clever metaprogramming.
- Do not use bare `# type: ignore`, bare `# noqa`, or broad suppressions.
- Do not add comments explaining what unclear code does; rename or restructure first.
- Do not turn tests into implementation mirrors full of mocks and copied setup.
- Do not treat library public API like internal application code.
- Do not skip verification; use the smallest truthful fallback if full verification is unavailable.

## Type And Structure Defaults

Prefer explicit, boring Python:

- Concrete types over loose containers.
- `dataclass`, `TypedDict`, `Protocol`, `Literal`, and small value objects for real concepts.
- Domain types at module boundaries: parse raw input once, then pass named structures.
- Explicit return types for public functions, methods, constructors, and non-trivial private helpers.
- `X | None` over `Optional[X]` when the project supports it.
- Built-in generics: `list[str]`, `dict[str, int]`, `tuple[str, ...]`.
- Direct imports in application code; avoid re-exporting through `__init__.py`.
- Public library packages may re-export intentionally, with `__all__` and docs.
- Keep empty `__init__.py` when the project uses regular packages; remove only when namespace packages are deliberate.
- Lazy logging: `logger.info("Saved %s", path)`, not logging f-strings.
- Specific exceptions and error messages that tell the caller what was invalid and where.

Detailed typing and package guidance:

- `references/package-layout-patterns.md`
- `references/advanced-patterns.md`
- `references/boundary-layer-exceptions.md`

## Verification Contract

Choose commands from the project, not from memory. Use `references/project-workflow.md`.

Verification ladder:

1. Targeted behavior test or reproduction check.
2. Formatter/linter for touched Python files.
3. Type checker for touched package or project.
4. Full test suite when shared behavior, public API, packaging, data model, or cross-module contracts changed.

If dependencies or tools are missing, say what is missing and run the smallest honest check available, such as:

```bash
python -m compileall src
python -m pytest path/to/test.py
uv run pytest
poetry run pytest
```

Do not claim completion without reporting what was verified.

Before final response, run the review checklist in `references/review-checklist.md` mentally or explicitly for non-trivial Python changes.

## Diagnostic Cleanup

When given diagnostics:

1. Detect Python version and project runner.
2. Group diagnostics by category and priority.
3. Read affected files and tool config before editing.
4. Fix root causes before suppressing.
5. Use specific suppressions only when justified.
6. Re-run the same tool or explain why it cannot run.

Use `references/diagnostic-workflow.md` and `references/tool-codes.md`.

## Red Flags

Stop and restructure when you see:

- A function that needs scrolling to understand.
- A module containing unrelated helper piles.
- A test file where setup is larger than the behavior being tested.
- Many comments explaining ordinary control flow.
- Core logic passing around raw API/database/plugin dictionaries.
- Deep nesting, hidden mutation, boolean flag tangles, or stringly typed modes.
- A cleanup diff that changes behavior without a test proving it.
- A type fix that hides uncertainty with `Any` or `ignore`.

Use `references/anti-patterns.md` for unacceptable shapes that require return-to-work.

## Reference Map

| Need | Reference |
|---|---|
| Identify project shape | `references/project-types.md` |
| Choose project commands | `references/project-workflow.md` |
| Pick a task path | `references/task-playbooks.md` |
| Judge readability | `references/readability-contract.md` |
| Stop-worthy anti-patterns | `references/anti-patterns.md` |
| Fix diagnostics | `references/diagnostic-workflow.md`, `references/tool-codes.md` |
| Package/import layout | `references/package-layout-patterns.md` |
| Boundary exceptions | `references/boundary-layer-exceptions.md` |
| Advanced typing | `references/advanced-patterns.md` |
| Fix examples | `references/fix-patterns.md` |
| Good/bad code examples | `references/examples.md` |
| Pre-delivery review | `references/review-checklist.md` |
