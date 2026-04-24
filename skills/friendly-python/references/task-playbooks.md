# Task Playbooks

Choose the closest path. Keep the path short for small tasks and expand only when risk requires it.

## Bug Fix

1. Reproduce or locate the failing behavior.
2. Read the smallest relevant code path.
3. Identify whether the bug is data shape, boundary parsing, state mutation, control flow, or integration.
4. Add or update a behavior test when practical.
5. Make the smallest readable fix.
6. Verify the regression path.

Do not "clean up around" the bug unless the cleanup is needed to make the fix understandable.

## Type Or Lint Diagnostics

1. Detect Python version and native runner.
2. Group diagnostics by root cause.
3. Fix real bugs first.
4. Narrow types at the source; avoid pushing `Any` downstream.
5. Convert repeated raw shapes into named types.
6. Use specific suppressions only for justified tool or boundary limitations.
7. Re-run the same diagnostic tool.

If a diagnostic points to unclear code, prefer restructuring over adding annotations that preserve confusion.

## Feature

1. State the observable behavior.
2. Identify public API, CLI, config, data model, or UI boundary touched.
3. Define named types for new structured data before passing it through core logic.
4. Choose the most direct API shape; avoid generic framework layers for one feature.
5. Add a focused test or acceptance check.
6. Implement with readable names and structured data.
7. Verify targeted behavior, then broader tests if shared code changed.

Avoid building future options until a test or requirement needs them.

## Refactor Or Cleanup

1. Define the invariant: what behavior must stay identical?
2. Keep the diff scoped to one readability problem.
3. Choose the cleanup target: names, control flow, module ownership, data shape, or test setup.
4. Improve only that target unless the next issue blocks readability.
5. Run existing tests before and after when possible.
6. Do not combine behavior changes with cleanup.

A cleanup that makes future change safer is valuable. A cleanup that just rearranges taste is churn.

## New Python Project

1. Ask or infer project shape: app, CLI, library, service, script.
2. Choose the smallest viable toolchain; prefer existing user preference if present.
3. Create clear package structure and one obvious entry point.
4. Define typed boundaries for config, inputs, outputs, and domain concepts.
5. Add a minimal test showing the main behavior.
6. Add Ruff and type checker baseline only if this is project setup.

Default shape for a small CLI:

```text
src/<package>/
  cli.py
  core.py
tests/
  test_core.py
pyproject.toml
```

## Library Or SDK

1. Identify public import paths and supported Python versions.
2. Preserve backward compatibility unless the task allows breaking changes.
3. Use `__all__` for intentional re-exports.
4. Include `py.typed` when distributing typed code.
5. Test public API, not internals.

Application rules about avoiding re-export do not automatically apply to libraries.

## Tests

1. Name the behavior under test.
2. Keep setup minimal and meaningful.
3. Use builders or fixtures for repeated construction.
4. Mock only hard boundaries.
5. Assert outcomes, state changes, emitted events, files, or return values.
6. Keep one test focused on one behavior; split tests with "and" in the name.

If tests become harder to read than implementation, redesign the test support.
