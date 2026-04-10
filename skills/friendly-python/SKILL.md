---
name: friendly-python
description: "Python coding standards and type safety enforcement. MUST activate on ANY Python coding task — writing new code, modifying existing code, reviewing code, or fixing diagnostics. Applies strict typing (Pyright strict mode), modern Python 3.10+ idioms, IDE-friendly patterns, and clean import hygiene. Enforces: (1) full type annotations on all functions, parameters, return types, and instance attributes, (2) no TYPE_CHECKING — resolve cycles architecturally, (3) no re-export via __init__.py, (4) no empty __init__.py (namespace packages), (5) built-in generics over typing module, (6) X|None over Optional, (7) TypedDict/Protocol/Literal over loose dict/Any, (8) lazy % logging over f-strings. Triggers on: ANY Python file creation or modification, writing Python code, editing .py files, implementing features in Python, refactoring Python, fixing diagnostics, type annotations, code review."
---

# Python Code Standards

This skill operates in two modes. Detect which applies and follow accordingly:

| Mode | When | What to do |
|---|---|---|
| **Writing** | Creating new code or modifying existing code | Apply all standards inline as you write (see Coding Checklist below) |
| **Cleanup** | User shares diagnostics or asks to fix warnings | Follow Phase 0–6 diagnostic workflow below |

**Writing mode is the default.** Every `.py` file you create or edit must conform to these standards.

---

## Code Style Philosophy

These opinionated preferences guide every coding decision. They optimize for **strong typing, IDE discoverability, and explicit code paths**.

### 1. NO `TYPE_CHECKING` — direct imports only

`if TYPE_CHECKING:` creates two code paths: one for the type checker, one for runtime. This is fragile, confusing to read, and hides real dependency issues.

```python
# ❌ AVOID
from typing import TYPE_CHECKING
if TYPE_CHECKING:
    from .engine import Engine

# ✅ PREFER — import directly
from .engine import Engine
```

**If this causes circular imports**, the architecture is wrong. Fix the dependency cycle by:
- Extracting shared types into a `types.py` or `_types.py` module
- Restructuring modules to break the cycle
- Using a Protocol in the depended-upon module (no import needed)

```python
# ✅ Break cycles with a shared types module
# src/types.py
from dataclasses import dataclass

@dataclass
class State:
    x: int
    y: int

# src/engine.py
from .types import State  # no cycle

# src/agent.py
from .types import State  # no cycle
```

### 2. NO re-export via `__init__.py`

Re-exporting symbols in `__init__.py` creates two valid import paths for the same symbol. This confuses IDE "go to definition", breaks refactoring tools, and makes dependency graphs opaque.

```python
# ❌ AVOID — myapp/__init__.py
from .database import Database
from .auth import AuthService
# allows: from myapp import Database (which file? unclear)

# ✅ PREFER — import from the actual module
from myapp.database import Database
from myapp.auth import AuthService
```

**`__init__.py` should be empty or absent** (see next rule). If it must exist, keep it empty — no imports, no `__all__`.

### 3. NO empty `__init__.py` (Python ≥ 3.3)

Python 3.3+ supports namespace packages (PEP 420). Empty `__init__.py` files are boilerplate noise.

```
# ❌ AVOID
myapp/
├── __init__.py     ← empty, unnecessary
├── database.py
└── auth.py

# ✅ PREFER
myapp/
├── database.py
└── auth.py
```

**Exceptions** (keep `__init__.py` when):
- The tool requires it: some pytest configs, mypy with `namespace_packages = false`
- The package is distributed (setuptools needs it for `find_packages()` unless using `find_namespace_packages()`)
- It contains real initialization code (logging setup, module-level constants)

When cleaning up, check if removing `__init__.py` breaks imports/tests. If yes, keep it but keep it empty.

### 4. Maximum type strictness — IDE-first

Prefer the **most specific type** that is truthful. Avoid `Any` unless the value is genuinely unconstrained.

```python
# ❌ Weak — IDE can't help you
def process(data: dict) -> list: ...
config: dict[str, Any] = load()

# ✅ Strong — IDE autocompletes, catches bugs
def process(data: dict[str, list[float]]) -> list[float]: ...
config: AppConfig = load()  # TypedDict or dataclass
```

**Hierarchy of type precision (prefer top):**
1. Concrete types: `int`, `str`, `MyClass`
2. Parameterized generics: `list[float]`, `dict[str, int]`
3. TypedDict / dataclass for structured dicts
4. Protocol for structural typing contracts
5. `X | None` for nullable
6. `Any` — last resort, always add a `# TODO: narrow type` comment

**Configure Pyright strict mode** in `pyproject.toml`:
```toml
[tool.pyright]
typeCheckingMode = "strict"
pythonVersion = "3.12"
venvPath = "."
venv = ".venv"
reportUnnecessaryTypeIgnoreComment = true
```

**Critical:** always set `venvPath` + `venv` so Pyright resolves third-party imports. Without this, every `numpy`/`matplotlib` call becomes `reportUnknownMemberType` noise.

### 5. Code formatting — automate, don't debate

Use an automated formatter. Never manually adjust whitespace, quotes, or trailing commas.

**Required settings (PEP 8 baseline):**
- 4 spaces per indent level (never tabs)
- Max line length: 88 (black/ruff default) or 120 (project choice — pick one and enforce)
- UTF-8 encoding, LF line endings
- Double quotes for strings (ruff/black default)

**Recommended toolchain (ruff replaces black + isort + flake8):**
```toml
# pyproject.toml
[tool.ruff]
target-version = "py312"
line-length = 88

[tool.ruff.format]
quote-style = "double"

[tool.ruff.lint]
select = ["E", "F", "W", "I", "UP", "B"]

[tool.ruff.lint.isort]
known-first-party = ["myapp"]
```

**Run before commit:**
```bash
ruff format .          # format all files
ruff check . --fix     # auto-fix lint issues
```

If the project already uses `black` or another formatter, follow the existing convention. The point is **automation**, not tool choice.

### 6. Unused arguments — prefix or remove

Unused arguments generate Pylint W0613. Two strategies:

| Situation | Action |
|---|---|
| Interface/reserved parameter (callback, hook, subclass override) | Prefix with `_`: `_epoch`, `_event` |
| Dead parameter (passed but never used anywhere) | Remove from signature AND all call sites |

```python
# ✅ Reserved parameter — prefix with underscore
def on_epoch_end(self, _epoch: int, logs: dict[str, float]) -> None: ...

# ✅ Dead parameter — remove from full call chain
# Before: def generate(self, data, output_dir): ...  # output_dir unused
# After:  def generate(self, data): ...
```

**When removing a dead parameter:** trace ALL callers and update every call site. One missed caller = runtime `TypeError`.

### 7. Exception handling — be specific

Avoid `except Exception` (Pylint W0718). Catch the narrowest exception types that apply:

```python
# ❌ Too broad — hides real bugs
try:
    plt.rcParams["font.sans-serif"] = ["SimHei"]
except Exception:
    pass

# ✅ Specific to what can actually fail
try:
    plt.rcParams["font.sans-serif"] = ["SimHei"]
except (ValueError, OSError, RuntimeError):
    pass
```

**Decision:**
- Know the exact exception? → catch it
- Library docs unclear? → catch the base class of likely errors (`OSError` for I/O, `ValueError` for parsing)
- Genuinely need broad catch (plugin loading, teardown)? → `except Exception` + `# pylint: disable=W0718` with a comment

### 8. Comments & Docstrings — Google style

Types annotate *what*, docstrings explain *why* and *how*. Don't repeat type information in docstrings — let type annotations self-document signatures.

**Language:** Prefer English for all comments and docstrings. English keeps the codebase accessible to international contributors, tools (linters, doc generators), and LLMs. Non-English is acceptable only in domain-specific terms that lose meaning in translation.

#### When to write docstrings

| Target | Rule |
|---|---|
| Public modules (non-`_` prefix) | Docstring **required** |
| Public classes | Docstring **required** |
| Public functions / methods | Docstring **required** |
| `_private` / internal | **Optional** — add only when logic is non-obvious |
| Dunder methods (`__init__`, `__repr__`, etc.) | **Skip** unless behavior is surprising |

#### Module docstring

One-liner at file top, before imports. Multi-line only when needed.

```python
"""Coordinate transforms for grid-based environments."""

import math
```

#### Class docstring

Describe purpose + key behaviors. List public attributes only if non-obvious from type annotations.

```python
class ReplayBuffer:
    """Fixed-size circular buffer for experience replay.

    Attributes:
        capacity: Maximum number of transitions stored.
    """
```

#### Function / method docstring (Google style)

Only document what types don't already express:

```python
def find_path(
    self,
    start: tuple[int, int],
    goal: tuple[int, int],
    *,
    allow_diagonal: bool = False,
) -> list[tuple[int, int]] | None:
    """Find shortest path using A* search.

    Args:
        start: Grid position to start from.
        goal: Target grid position.
        allow_diagonal: If True, allows 8-directional movement.

    Returns:
        Ordered list of positions from start to goal,
        or None if no path exists.

    Raises:
        ValueError: If start or goal is outside grid bounds.
    """
```

**Rules:**
- **No type duplication** — `Args:` describes *meaning*, not types (`start: Grid position` not `start (tuple[int, int]): ...`)
- **`Args:`** — required when ≥ 2 parameters or meaning non-obvious from name + type
- **`Returns:`** — required when return value needs explanation beyond type annotation
- **`Raises:`** — required for explicitly raised exceptions
- **One-liner OK** for simple functions: `"""Return the Manhattan distance between two points."""`
- **Imperative mood** for first line: "Find", "Return", "Calculate" (not "Finds", "Returns")

#### Inline comments (`#`)

Explain *why*, never *what* — code should be self-explanatory for *what*.

```python
# ✅ Explains WHY
offset = 1  # compensate for 0-indexed grid in 1-indexed display

# ❌ Restates WHAT (noise)
offset = 1  # set offset to 1
```

- Place on same line or immediately above the code
- One space after `#`
- Never comment closing brackets / braces

#### TODO / FIXME markers

Standard format with actionable description — no bare `# TODO`:

```python
# TODO: replace dict[str, Any] with TypedDict once API schema stabilizes
config: dict[str, Any] = load_config()

# FIXME: race condition when two workers write to same file
save_results(data)

# Optional: include author / issue reference
# TODO(zhpeng): narrow type after #123 lands
```

- `TODO` = planned improvement, `FIXME` = known bug / defect

#### Anti-patterns (never do)

| Anti-pattern | Fix |
|---|---|
| Commented-out code | Delete it — Git remembers |
| `#---` / `#===` section dividers | Use functions / classes to structure |
| Redundant docstring restating the signature | Skip the docstring or add real context |

```python
# ❌ Redundant — type annotation already documents this
def add(a: int, b: int) -> int:
    """Add a and b and return the result."""
    return a + b

# ✅ Trivial function — skip the docstring entirely
def add(a: int, b: int) -> int:
    return a + b
```

### 9. Third-party library typing — file-level pragmatism

Libraries with incomplete stubs (matplotlib, pandas) produce waves of `reportUnknownMemberType`. Don't fight them per-line.

**Strategy (in order):**
1. Use the modern typed API when available:
   ```python
   # ❌ Untyped in stubs
   cmap = plt.cm.viridis.copy()
   # ✅ Typed via __getitem__
   cmap = matplotlib.colormaps["viridis"].copy()
   ```

2. Add a **file-level** pyright directive when 10+ lines are affected:
   ```python
   # pyright: reportUnknownMemberType=false, reportUnknownVariableType=false
   ```

3. Add per-line suppression only for isolated cases (1–2 lines).

**Never** use bare `# type: ignore` — always include the specific code.

---

## Writing Mode: Coding Checklist

Apply every item below when writing or modifying any `.py` file. This is not aspirational — it is mandatory.

### Imports
- [ ] No `from typing import Optional, Union, List, Dict, Tuple, Set` — use built-in generics + `|`
- [ ] No `from typing import TYPE_CHECKING` — resolve cycles via shared types module or Protocol
- [ ] No re-export in `__init__.py` — import from actual module path
- [ ] No empty `__init__.py` — delete unless it contains real code or tools require it
- [ ] `from typing import Any` only when truly needed; prefer concrete types
- [ ] Group imports: stdlib → third-party → local, separated by blank lines

### Type Annotations
- [ ] All function parameters annotated (no bare `def f(x):`)
- [ ] All return types annotated (including `-> None` for `__init__` and setters)
- [ ] All instance attributes annotated in `__init__` when type is non-obvious (`self.data: list[float] = []`)
- [ ] Generic containers parameterized: `list[X]`, `dict[K, V]`, `tuple[X, Y]`, `set[X]`
- [ ] Use `X | None` not `Optional[X]`
- [ ] Use TypedDict for known-schema dicts (config, API responses)
- [ ] Use Literal for constrained string/int values
- [ ] Use Protocol over ABC when no shared implementation is needed

### Logging
- [ ] Use lazy `%s`/`%d` formatting in all `logger.*()` calls, never f-strings

### Formatting & Style
- [ ] 4 spaces indentation (never tabs)
- [ ] Automated formatter configured and run (`ruff format .` or `black .`)
- [ ] Import order enforced by tool (`ruff check --select I` or `isort`)
- [ ] No broad `except Exception` — narrow to specific types or justify with `# pylint: disable=W0718`
- [ ] Unused arguments prefixed with `_` (reserved) or removed from full call chain (dead)
- [ ] Pyright `venvPath` + `venv` set in `pyproject.toml` to resolve third-party imports

### Comments & Docstrings
- [ ] Public modules have a docstring (one-liner before imports)
- [ ] Public classes have a Google-style docstring (purpose + `Attributes:` if non-obvious)
- [ ] Public functions / methods have a Google-style docstring (`Args:`, `Returns:`, `Raises:` as needed)
- [ ] No type duplication in docstrings — describe meaning, not types
- [ ] Inline comments explain *why*, never *what*
- [ ] No commented-out code — delete it, Git remembers
- [ ] TODO / FIXME markers include actionable description (no bare `# TODO`)

### Precision Hierarchy
When annotating, always pick the most specific truthful type:

```
concrete type  >  parameterized generic  >  TypedDict/dataclass
>  Protocol  >  X | None  >  Any (last resort)
```

### Quick Examples

```python
# ✅ Good — strong, IDE-friendly
def fetch_users(
    self,
    limit: int,
    offset: int = 0,
    active_only: bool = True,
) -> list[dict[str, str]]:
    results: list[dict[str, str]] = []
    ...
    logger.info("Fetched %d users (offset=%d)", len(results), offset)
    return results

# ❌ Bad — weak, IDE-blind
def fetch_users(self, limit, offset=0, active_only=True):
    results = []
    ...
    logger.info(f"Fetched {len(results)} users (offset={offset})")
    return results
```

See `references/advanced-patterns.md` for TypeVar, Generic, Protocol, overload, numpy/matplotlib patterns.

---

## Cleanup Mode: Diagnostic Workflow

Follow Phases 0–6 below when the user shares editor diagnostics or asks to fix warnings.

## Phase 0: Detect project Python version

Before any fix, determine the target Python version — it dictates annotation strategy:

```
Check pyproject.toml → [project] requires-python
      setup.cfg      → [options] python_requires
      .python-version
      runtime (python3 --version)
```

**Decision tree:**

| Python version | Annotation strategy |
|---|---|
| ≥ 3.12 | Built-in generics + `X \| None` + `type` statement for aliases |
| 3.10 – 3.11 | Built-in generics + `X \| None` natively |
| 3.9 | Built-in generics (`list[X]`) OK, but `X \| None` requires `from __future__ import annotations` |
| ≤ 3.8 | Must use `typing.Optional`, `typing.List`, etc. Or add `from __future__ import annotations` |

**Critical:** `from __future__ import annotations` (PEP 563) makes ALL annotations lazy strings, enabling 3.10+ syntax on 3.7+. But it changes runtime behavior — `get_type_hints()` is needed to resolve them, and it breaks libraries that inspect annotations at runtime (e.g., Pydantic v1, dataclasses with `field(default_factory=...)` edge cases). Check before adding.

## Phase 1: Triage diagnostics

Parse the diagnostic payload. Group by category, count, and output a summary table:

| Priority | Category | Pylance codes | Pylint codes | mypy codes |
|---|---|---|---|---|
| P0 | Real bugs / errors | `reportGeneralClassIssues`, `reportIndexIssue` | `E*` (all errors) | `error:` lines |
| P1 | Unused imports | `reportUnusedImport` | `W0611` | `[import]` |
| P2 | Deprecated typing | `reportDeprecated` | — | — |
| P3 | Missing type params | `reportMissingTypeArgument`, `reportUnknownParameterType`, `reportUnknownVariableType` | — | `[type-arg]` |
| P4 | Missing return types | `reportUnknownMemberType`, `reportMissingParameterType` | — | — |
| P5 | Logging format | — | `W1203` | — |
| P6 | Style / convention | — | `C0114`–`C0116` (missing docstrings), `C0301` (line length) | — |

See `references/tool-codes.md` for comprehensive diagnostic code reference and suppression syntax.

## Phase 2: Read all affected files

Read every unique file from diagnostics in **one parallel call**. Never fix from line numbers alone — diagnostics may be stale after prior edits.

Also read: `pyproject.toml` (or `setup.cfg`) for Python version, and any `py.typed` / `mypy.ini` / `pyrightconfig.json` for tool configuration context.

## Phase 3: Apply fixes by category (P0 → P6)

Process in priority order. Batch all edits per file per response.

### P0: Real bugs

Understand semantics before fixing. Common patterns:
- Index out of range, attribute errors → logic fix
- Incompatible types in assignment → check if a `cast()` or redesign is needed
- Unreachable code → dead branch removal

### P1: Unused imports

- Remove the import line entirely
- Verify not used via grep before removing (diagnostics can be stale)
- **Trap:** `import X` used only in type annotations + `from __future__ import annotations` → still needed at runtime if `X` appears in non-annotation code

### P2: Deprecated typing → modern style

Apply based on Python version (Phase 0):

```python
# typing module → built-in (Python ≥ 3.9)
List[X]      →  list[X]
Dict[K, V]   →  dict[K, V]
Tuple[X, Y]  →  tuple[X, Y]
Set[X]       →  set[X]
FrozenSet[X] →  frozenset[X]
Type[X]      →  type[X]

# Union syntax (Python ≥ 3.10 or __future__.annotations)
Optional[X]  →  X | None
Union[X, Y]  →  X | Y
```

**Keep from typing:** `Any`, `TypeVar`, `Generic`, `Protocol`, `TypedDict`, `Literal`, `ClassVar`, `Final`, `Callable`, `Annotated`, `overload`, `TYPE_CHECKING`

After replacing, clean up the `from typing import ...` line — remove symbols no longer needed, delete the line if empty.

### P3: Missing type parameters

Infer from usage context. Common patterns:

| Bare type | Typical parameterization | When |
|---|---|---|
| `dict` | `dict[str, Any]` | YAML/JSON config, `**kwargs` |
| `dict` | `dict[str, str]` | env vars, simple mappings |
| `tuple` | `tuple[int, int]` | coordinates, 2D indices |
| `tuple` | `tuple[Any, ...]` | variable-length homogeneous |
| `list` | `list[float]` | numeric sequences |
| `set` | `set[tuple[int, int]]` | coordinate sets |

**`tuple` conversion pitfall:** `tuple(some_list)` returns `tuple[Any, ...]`, not `tuple[int, int]`. When Pylance flags this, either:
- Use explicit construction: `(some_list[0], some_list[1])`
- Add `# type: ignore[assignment]` with a comment explaining why
- Use `cast(tuple[int, int], tuple(some_list))`

Add `from typing import Any` only when `Any` is actually used in annotations.

### P4: Missing return types

| Pattern | Return type |
|---|---|
| `__init__` | `-> None` |
| Setters / mutating methods | `-> None` |
| `__str__`, `__repr__` | `-> str` |
| `__len__` | `-> int` |
| `__bool__` | `-> bool` |
| `__eq__`, `__lt__`, etc. | `-> bool` |
| `__enter__` | `-> Self` (3.11+) or `-> "ClassName"` |
| `__exit__` | `-> bool \| None` |
| `__iter__` | `-> Iterator[X]` |
| `__next__` | `-> X` |
| Properties | infer from return value |
| Factory / classmethod | `-> "ClassName"` or `-> Self` |

**Instance attributes in `__init__`**: Annotate at assignment when type is non-obvious:
```python
self.history: list[float] = []       # not just `self.history = []`
self.cache: dict[str, Any] = {}      # not just `self.cache = {}`
```

### P5: Logging f-string → lazy formatting

```python
# Before
logger.info(f"Processed {n} items in {elapsed:.1f}s")
# After
logger.info("Processed %d items in %.1fs", n, elapsed)
```

| Specifier | Type | Note |
|---|---|---|
| `%s` | any (via `str()`) | Default choice for non-numeric |
| `%d` | int | Truncates floats |
| `%f` | float | 6 decimal default |
| `%.Nf` | float | N decimal places |
| `%r` | any (via `repr()`) | Useful for debugging |
| `%x` | int → hex | |
| `%%` | literal `%` | Escape |

**Trap:** Multi-line f-string logging — unwrap the f-string first, then convert:
```python
# Before
logger.info(
    f"State={state}, reward={reward:.2f}, "
    f"done={done}"
)
# After
logger.info("State=%s, reward=%.2f, done=%s", state, reward, done)
```

### P6: Style / convention

Only fix if user explicitly asks. Typical Pylint conventions:
- `C0114`–`C0116`: Missing docstrings → add module/class/function docstrings
- `C0301`: Line too long → reformat (prefer `black` or `ruff format`)
- `C0103`: Invalid name → rename or add `# pylint: disable=C0103`

## Phase 4: Handle suppression comments

When a diagnostic cannot be cleanly fixed (false positive, third-party limitation, intentional design), suppress with the correct syntax:

```python
# Pylance / Pyright
x = some_call()  # type: ignore[assignment]

# mypy (same syntax, different codes)
x = some_call()  # type: ignore[assignment]

# Pylint
x = some_call()  # pylint: disable=W0611

# ruff / flake8
x = some_call()  # noqa: F401

# Multiple tools
x = some_call()  # type: ignore[assignment]  # noqa: F401
```

**Rule:** Always include the specific code (`[assignment]`, `W0611`, `F401`), never use bare `# type: ignore` or `# noqa`.

## Phase 5: Verify

1. Run the project's existing entry point or test suite
2. Re-run linter if available (`ruff check .`, `mypy .`, `pylint src/`)
3. If regressions found, fix and re-verify

```bash
# Common runners
python main.py             # or: uv run python main.py
python -m pytest           # test suite
ruff check . --fix         # auto-fixable lint
mypy src/                  # type check
```

## Phase 6: Handle stale diagnostics

If a diagnostic references code already fixed (editor cache), inform the user and suggest:
- Save all files → diagnostics auto-refresh
- `Cmd+Shift+P` → "Developer: Reload Window" (VS Code)
- Restart language server: `Cmd+Shift+P` → "Python: Restart Language Server"

## Key principles

1. **Version-aware** — detect Python version before choosing annotation strategy
2. **Read before fixing** — diagnostics may be stale; verify against actual code
3. **Batch edits per file** — minimize round-trips, reduce merge conflicts
4. **Preserve runtime behavior** — annotation changes must not alter logic
5. **Specific suppression** — never bare `# type: ignore`; always include error code
6. **Verify after fixing** — always run the code to catch regressions

## References

- `references/fix-patterns.md` — Before/after examples for each fix category
- `references/advanced-patterns.md` — TYPE_CHECKING, TypeVar, Protocol, TypedDict, overload, Callable, numpy/matplotlib patterns
- `references/tool-codes.md` — Comprehensive diagnostic code mapping and tool configuration
