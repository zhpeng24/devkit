# Design: friendly-python — Pragmatic Rule Exceptions

**Date:** 2026-04-10
**Status:** Validated via brainstorming session

## Problem

The `friendly-python` skill uses absolute prohibitions for 5 rules that are not universally correct. This leads to dogmatic application in cases where the "prohibited" pattern is actually the right choice (e.g., `TYPE_CHECKING` for typing-only imports, `__init__.py` re-exports in library public APIs).

## Approach

Keep the **strict default tone** (execution-oriented, "follow by default") but convert 5 absolute bans into **"default preference + explicit exception conditions."** Add a new boundary layer exceptions section.

## Changes

### Files affected

1. `skills/friendly-python/SKILL.md` — §1, §2, §3, §4 config block, new §10, Coding Checklist
2. `skills/friendly-python/references/advanced-patterns.md` — Circular Imports section

---

### Proposal 1: TYPE_CHECKING → "Prefer direct imports — avoid TYPE_CHECKING unless justified"

**§1 heading:** "NO `TYPE_CHECKING` — direct imports only" → "Prefer direct imports — avoid `TYPE_CHECKING` unless justified"

**Body:** Keep ❌ AVOID / ✅ PREFER examples and all three architectural alternatives (shared types module, Protocol, restructure). Add after them:

```
⚠️ Acceptable uses of TYPE_CHECKING:
- Typing-only imports that would otherwise create a runtime dependency
  on a heavy or optional package (e.g., importing pandas just for annotations)
- Localized cycle avoidance when the cycle is in third-party code you don't control
- Expensive imports used only in annotations (large ML frameworks at import time)

When using TYPE_CHECKING, always combine with quoted forward references
or `from __future__ import annotations` so runtime import never fires.
```

**advanced-patterns.md:** In "Resolving Circular Imports (WITHOUT TYPE_CHECKING)":
- Soften opening line: "Prefer architectural solutions over `if TYPE_CHECKING`. It creates two code paths and can hide dependency issues. Use these alternatives first:"
- Add "Option 4: TYPE_CHECKING (last resort)" with the same acceptable-use conditions and a code example.

**Checklist update:** "No `from typing import TYPE_CHECKING` — resolve cycles via shared types module or Protocol" → "Prefer direct imports; use `TYPE_CHECKING` only for typing-only imports, expensive imports, or third-party cycles (see §1)"

---

### Proposal 2: Empty `__init__.py` → "Package strategy must be explicit"

**§3 heading:** "NO empty `__init__.py` (Python ≥ 3.3)" → "Package strategy must be explicit — no accidental empty `__init__.py`"

**Body restructured:**

- ✅ Regular packages (with `__init__.py`): Standard choice, required by `find_packages()`, unambiguous. An `__init__.py` that marks a directory as a package is legitimate.
- ✅ Implicit namespace packages (PEP 420): Appropriate when intentionally adopted. Requires `find_namespace_packages()` and `namespace_packages = true` in mypy.
- ❌ AVOID: Accidental empty files with no deliberate choice.

**Checklist update:** "No empty `__init__.py` — delete unless it contains real code or tools require it" → "Package strategy is deliberate: regular packages (with `__init__.py`) or namespace packages (without) — no accidental empty files"

---

### Proposal 3: Re-export → "Avoid in application code; allow in library public API"

**§2 heading:** "NO re-export via `__init__.py`" → "Avoid re-export in application code — allow in library public API"

**Body restructured:**

- ❌ AVOID in application code (existing rationale: two import paths, confusing IDE, opaque deps)
- ⚠️ Acceptable in library/public API packages: re-export is the standard Python convention for defining a public import surface. Use `__all__` to make the surface explicit.

**Checklist update:** "No re-export in `__init__.py` — import from actual module path" → "No re-export in application code; library public API packages may re-export with `__all__` (see §2)"

---

### Proposal 4: Pyright venvPath/venv → Environment-aware guidance

**§4 config block:** Replace single `pyproject.toml` example + "Critical: always set venvPath + venv" with environment-aware guidance:

- **CLI Pyright:** `venvPath` + `venv` in `pyproject.toml` (existing example)
- **Pylance (VS Code):** `venvPath`/`venv` are ignored. Use "Python: Select Interpreter" or `python.defaultInterpreterPath` workspace setting.
- Either way, ensure env is discoverable to avoid `reportUnknownMemberType` noise.

**Checklist update:** "Pyright `venvPath` + `venv` set in `pyproject.toml`" → "Pyright env configured: `venvPath`+`venv` for CLI Pyright; interpreter selection for Pylance"

---

### Proposal 5: New §10 — Boundary Layer Exceptions

**New standalone section** after §9 (Third-party library typing), before the Coding Checklist.

**Recognized boundary layers** (table):
| Layer | Example | Acceptable wider type |
|---|---|---|
| API ingress/egress | FastAPI/Flask handlers | `dict[str, Any]`, Pydantic models |
| ORM / framework hooks | Django signals, SQLAlchemy events | Framework-dictated signatures |
| Third-party dynamic payloads | Webhooks, external SDK responses | `dict[str, Any]` → validate → TypedDict |
| Plugin registries | Dynamic loading via importlib | `Any` → Protocol/ABC on use |
| Prototype / spike code | Exploratory scripts, notebooks | Relaxed types + `# TODO: narrow` |

**Rules:**
1. Wider types MUST NOT leak past the boundary — narrow at earliest point
2. Comment/docstring explaining why wider types are needed
3. Prototype code must include `# TODO: narrow types` markers
4. Framework-dictated signatures are acceptable as-is

**Checklist addition:** New item in Type Annotations section: "Boundary layers (API, ORM, plugins) may use wider types — narrow before entering core domain (see §10)"

---

## Non-goals

- No changes to §4 (maximum type strictness) for core domain code
- No changes to §5-§9 (formatting, unused args, exceptions, docstrings, third-party typing)
- No changes to Cleanup Mode (Phases 0-6)
- No changes to `references/tool-codes.md`
- No changes to `references/fix-patterns.md`

## Implementation notes

- All changes are text edits to two markdown files
- Section numbering shifts: current §3 → still §3, new §10 inserted
- The Coding Checklist is updated inline for each affected item
