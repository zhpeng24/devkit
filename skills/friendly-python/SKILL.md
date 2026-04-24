---
name: friendly-python
description: "Use when writing, editing, reviewing, or fixing diagnostics in Python codebases."
---

# Python Code Standards

This skill is intentionally opinionated. It is optimized for **production application code** and **AI-assisted code generation**, where consistency, static analysis quality, and refactor safety matter more than local convenience.

## Scope

This skill is designed for **application and service codebases**. For public libraries and SDKs, some decisions differ — especially around package exports, import surfaces, and `__init__.py` conventions. Where library-specific advice diverges, the relevant rule calls it out explicitly.

This skill operates in two modes. Detect which applies and follow accordingly:

| Mode | When | What to do |
|---|---|---|
| **Writing** | Creating new code or modifying existing code | Apply all standards inline as you write (see Coding Checklist below) |
| **Cleanup** | User shares diagnostics or asks to fix warnings | Follow Phase 0–6 diagnostic workflow below |

**Writing mode is the default.** Every `.py` file you create or edit must conform to these standards.

## Fast Path

1. Detect project tooling before choosing commands: `uv.lock`, `poetry.lock`, `pdm.lock`, `Pipfile`, `tox.ini`, `noxfile.py`, `pyproject.toml`, `requirements*.txt`.
2. Read local tool config: `pyproject.toml`, `pyrightconfig.json`, `mypy.ini`, `ruff.toml`, `pytest.ini`.
3. Apply the coding checklist while editing.
4. Verify with the project's native runner. Use `references/project-workflow.md` for command selection.
5. If no configured tool exists, use the smallest truthful fallback: `python -m pytest`, `python -m compileall <package>`, or direct entry-point execution.

Do not introduce a new Python manager, formatter, or package layout unless the task is explicitly about project setup.

---

## Code Style Philosophy

These opinionated preferences guide every coding decision. They optimize for **strong typing, IDE discoverability, and explicit code paths**.

Each rule carries a severity label:
- **Required** — must follow; deviation is a defect
- **Default** — follow by default; justified exceptions allowed
- **Avoid** — generally discouraged, but not an error in the right context

### 1. Avoid `TYPE_CHECKING` by default — prefer architectural fixes first
**Status: Default**

Prefer direct imports and architectural fixes over `if TYPE_CHECKING:`.

`TYPE_CHECKING` should not be used to hide avoidable dependency problems. First try:
- Extracting shared types into a `types.py` or `_types.py` module
- Restructuring modules to break the cycle
- Using a `Protocol` in the depended-upon module (depend on behavior, not concrete implementations)

```python
# ❌ AVOID — two code paths, hides dependency issues
from typing import TYPE_CHECKING
if TYPE_CHECKING:
    from .engine import Engine

# ✅ PREFER — import directly
from .engine import Engine

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

**Allow `TYPE_CHECKING` only when one of these applies:**
- The import is **truly typing-only** (never used at runtime)
- The imported module is **heavy or optional** at runtime (pandas, torch, tensorflow)
- A localized cycle **remains after reasonable refactoring** (e.g., third-party code you don't control)

When used, keep it minimal and local. Do not use it as a default pattern.

```python
# ⚠️ Acceptable — heavy optional dependency, typing-only
from __future__ import annotations
from typing import TYPE_CHECKING

if TYPE_CHECKING:
    import pandas as pd

def summarize(df: pd.DataFrame) -> dict[str, float]: ...
```

### 2. Avoid re-export in application code — allow in library public API
**Status: Default**

Re-exporting symbols in `__init__.py` creates two valid import paths for the same symbol. In **application code**, this confuses IDE "go to definition", breaks refactoring tools, and makes dependency graphs opaque.

```python
# ❌ AVOID in application code — myapp/__init__.py
from .database import Database
from .auth import AuthService
# allows: from myapp import Database (which file? unclear)

# ✅ PREFER — import from the actual module
from myapp.database import Database
from myapp.auth import AuthService
```

**⚠️ Acceptable in library / public API packages:**

When a package intentionally defines a public import surface (SDK, framework, shared library), re-export via `__init__.py` is the standard Python convention. Use `__all__` to make the surface explicit:

```python
# ✅ Library public API — mylib/__init__.py
from .client import Client
from .exceptions import MyLibError
from .config import Config

__all__ = ["Client", "MyLibError", "Config"]
```

**Decision:** If the package is consumed by external users as a library, re-export is expected. If it's internal application code, import from the actual module.

### 3. Prefer no empty `__init__.py` when tooling and packaging allow it
**Status: Default**

Python 3.3+ supports namespace packages (PEP 420), so empty `__init__.py` files are often unnecessary. Prefer omitting them when the project layout and tooling intentionally support that model.

Choose a deliberate package strategy and apply it consistently across the project.

**✅ Regular packages (with `__init__.py`):**

The standard choice. Required by setuptools `find_packages()`, expected by most tools, and unambiguous. An `__init__.py` that exists to mark a directory as a package is legitimate — it is not "empty boilerplate."

```
# ✅ Regular package — deliberate choice
myapp/
├── __init__.py     ← marks as regular package (may be empty — that's fine)
├── database.py
└── auth.py
```

**✅ Implicit namespace packages (PEP 420, no `__init__.py`):**

Appropriate when the project intentionally adopts namespace package semantics (e.g., plugin systems, multi-repo packages that share a top-level namespace).

```
# ✅ Namespace package — deliberate choice
myapp/
├── database.py
└── auth.py
```

**Note:** Requires `find_namespace_packages()` in setuptools and `namespace_packages = true` in mypy configuration.

**❌ AVOID: Accidental empty files** — `__init__.py` committed with no deliberate choice. If it exists, it should be there for a reason (even if that reason is "our project uses regular packages"). If removal breaks imports, packaging, or tests, keep the file. If it exists only for tooling/package discovery, keep it empty.

### 4. Maximum type strictness — IDE-first
**Status: Required**

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

For **CLI Pyright**, configure the project environment explicitly when needed:
```toml
[tool.pyright]
typeCheckingMode = "strict"
pythonVersion = "3.12"
venvPath = "."
venv = ".venv"
reportUnnecessaryTypeIgnoreComment = true
```

For **Pylance** (VS Code):
`venvPath` and `venv` are ignored by Pylance. Instead, configure the interpreter:
- `Cmd+Shift+P` → "Python: Select Interpreter" → choose your `.venv`
- Or set `python.defaultInterpreterPath` in workspace settings

**Either way**, ensure the virtual environment is discoverable. Without it, every third-party import (`numpy`, `matplotlib`, etc.) becomes `reportUnknownMemberType` noise.

### 5. Code formatting — automate, don't debate
**Status: Required**

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
**Status: Required**

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
**Status: Required**

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
**Status: Required**

Types annotate *what*, docstrings explain *why* and *how*. Don't repeat type information in docstrings — let type annotations self-document signatures.

**Language: English by default — always.**

All comments and docstrings **MUST** be written in English, regardless of the operating system locale, the user's chat language, or the surrounding natural-language context. Do **not** mirror the user's chat language into code comments.

The only exception: the user **explicitly** asks for another language (e.g., "用中文写注释", "comments in Chinese"). In that case, follow the request for that session.

Rationale: English keeps the codebase accessible to international contributors, static-analysis tools, doc generators, and LLMs; mixed-language comments fragment the codebase over time.

**Style: concise and signal-dense.**

Every comment must earn its line. Strip filler, state the constraint or intent, and stop.

- Prefer **one short sentence** or a fragment over a paragraph.
- Lead with the **key requirement / constraint / "why"** — not background narration.
- Drop articles ("the", "a") and pleasantries when they don't change meaning.
- Avoid hedging ("maybe", "I think", "we could") — comments are assertions.
- No decorative wording, no emoji, no restating the obvious.

```python
# ❌ Verbose, narrates what the code does
# Here we are going to loop over the list of users that we fetched
# from the database in the previous step, and for each one we will
# check whether they are active or not.
for user in users:
    if user.active: ...

# ✅ Concise — only the non-obvious constraint
# Skip soft-deleted users; `active` flag is set lazily by the nightly job.
for user in users:
    if user.active: ...
```

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
**Status: Default**

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

### 10. Boundary layer exceptions — wider types at the edges
**Status: Default**

Core domain code follows maximum type strictness (§4). But code at system boundaries often handles inherently dynamic data. These **boundary layers** may use wider types (`dict[str, Any]`, `Any`, `cast()`) **provided they narrow types before passing data into core logic.**

**Recognized boundary layers:**

| Layer | Example | Acceptable wider type |
|---|---|---|
| API ingress/egress | FastAPI/Flask request/response handlers | `dict[str, Any]`, Pydantic models with `Any` fields |
| ORM / framework hooks | Django signals, SQLAlchemy event listeners | Callback signatures dictated by framework |
| Third-party dynamic payloads | Webhook bodies, external SDK responses | `dict[str, Any]` → validate → TypedDict/dataclass |
| Plugin registries | Dynamic loading via `importlib` | `Any` for loaded objects → Protocol/ABC on use |
| Prototype / spike code | Exploratory scripts, notebooks | Relaxed types OK — add `# TODO: narrow types` |

```python
# ✅ Boundary layer with narrowing — FastAPI endpoint
from typing import Any
from pydantic import BaseModel

class CreateUserRequest(BaseModel):
    name: str
    email: str

@app.post("/users")
async def create_user(payload: dict[str, Any]) -> dict[str, str]:
    # Narrow at the boundary — validate into typed model
    user = CreateUserRequest(**payload)
    return _create_user_internal(user)  # core logic receives typed data

# ✅ Plugin registry — Any at load, Protocol on use
from typing import Any, Protocol

class PluginInterface(Protocol):
    def execute(self, data: bytes) -> str: ...

def load_plugin(name: str) -> Any:  # dynamic loading — Any is honest
    module = importlib.import_module(f"plugins.{name}")
    return module.Plugin()

def run_plugin(plugin: PluginInterface, data: bytes) -> str:  # narrowed
    return plugin.execute(data)
```

**Rules:**
1. Wider types **MUST NOT** leak past the boundary — narrow at the earliest point (validation, parsing, factory function)
2. Add a comment or docstring explaining why wider types are needed at this boundary
3. Prototype code must include `# TODO: narrow types` markers
4. Framework-dictated signatures are acceptable as-is — don't fight the framework's own type stubs

---

## Writing Mode: Coding Checklist

Apply every item below when writing or modifying any `.py` file. This is not aspirational — it is mandatory.

### Imports
- [ ] No `from typing import Optional, Union, List, Dict, Tuple, Set` — use built-in generics + `|`
- [ ] Prefer direct imports; use `TYPE_CHECKING` only for typing-only imports, expensive imports, or third-party cycles (see §1)
- [ ] No re-export in application code; library public API packages may re-export with `__all__` (see §2)
- [ ] Package strategy is deliberate: regular packages (with `__init__.py`) or namespace packages (without) — no accidental empty files (see §3)
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
- [ ] Boundary layers (API, ORM, plugins) may use wider types — narrow before entering core domain (see §10)

### Logging
- [ ] Use lazy `%s`/`%d` formatting in all `logger.*()` calls, never f-strings

### Formatting & Style
- [ ] 4 spaces indentation (never tabs)
- [ ] Automated formatter configured and run (`ruff format .` or `black .`)
- [ ] Import order enforced by tool (`ruff check --select I` or `isort`)
- [ ] No broad `except Exception` — narrow to specific types or justify with `# pylint: disable=W0718`
- [ ] Unused arguments prefixed with `_` (reserved) or removed from full call chain (dead)
- [ ] Pyright env configured: `venvPath`+`venv` for CLI Pyright; interpreter selection for Pylance (see §4)

### Comments & Docstrings
- [ ] **All comments and docstrings written in English** — never mirror chat/system language; only switch when user explicitly requests another language (see §8)
- [ ] **Concise and signal-dense** — one short sentence or fragment; lead with the constraint/intent, no narration, no filler (see §8)
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
Check pyproject.toml   → [project] requires-python
      setup.cfg        → [options] python_requires
      .python-version
      runtime          → python3 --version
```

Also detect the project runner and toolchain before verification. See `references/project-workflow.md` for `uv`, Poetry, PDM, Pipenv, tox, nox, and plain venv command selection.

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

Process in priority order. Batch all edits per file per response. See `references/fix-patterns.md` for detailed before/after examples of each category.

**P0: Real bugs** — understand semantics before fixing (index errors, type incompatibility, unreachable code).

**P1: Unused imports** — remove entirely; verify not used via grep first. Trap: `import X` may be needed at runtime even if only used in annotations with `__future__`.

**P2: Deprecated typing** — modernize based on Python version: `List[X]` → `list[X]`, `Optional[X]` → `X | None`. See `references/fix-patterns.md` for full migration table.

**P3: Missing type parameters** — infer from usage context: `dict` → `dict[str, Any]`, `tuple` → `tuple[int, int]`, etc.

**P4: Missing return types** — `__init__` → `-> None`, `__repr__` → `-> str`, `__len__` → `-> int`, etc. Annotate instance attributes in `__init__` when type is non-obvious.

**P5: Logging f-string → lazy formatting** — `logger.info(f"x={x}")` → `logger.info("x=%s", x)`.

**P6: Style / convention** — only fix if user explicitly asks. Docstrings, line length, naming.

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
2. Re-run formatter/linter/type checker using the project's native runner
3. If regressions found, fix and re-verify

```bash
# Examples; choose using references/project-workflow.md
uv run pytest              # uv project
poetry run pytest          # Poetry project
python -m pytest           # plain venv / fallback
python -m compileall src   # syntax fallback when tests do not exist
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

- `references/fix-patterns.md` — Before/after examples for each fix category (P0–P6 detail)
- `references/project-workflow.md` — Python project detection, command selection, verification ladder
- `references/advanced-patterns.md` — TypeVar, Protocol, TypedDict, overload, Callable, numpy/matplotlib, TYPE_CHECKING patterns
- `references/tool-codes.md` — Comprehensive diagnostic code mapping and tool configuration
- `references/boundary-layer-exceptions.md` — Before/after examples for API, ORM, plugin, prototype boundary patterns
- `references/package-layout-patterns.md` — Regular vs namespace packages, re-export patterns, app vs library layout
