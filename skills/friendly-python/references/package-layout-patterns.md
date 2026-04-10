# Package Layout Patterns

Guidance for Python package structure decisions: regular packages vs namespace packages, `__init__.py` conventions, and re-export patterns. Read when setting up a new project or reviewing package layout.

---

## Regular Packages vs Namespace Packages

Python supports two package models. Choose one deliberately and apply it consistently.

### Regular Packages (with `__init__.py`)

The traditional and most widely supported model. Every directory that should be importable contains an `__init__.py` file.

```
myapp/
├── __init__.py          ← marks as importable package
├── core/
│   ├── __init__.py
│   ├── models.py
│   └── services.py
├── api/
│   ├── __init__.py
│   └── routes.py
└── utils.py
```

**When to use:**
- Most application and service codebases (this is the default choice)
- Any project using `setuptools.find_packages()` (requires `__init__.py`)
- Projects using mypy with `namespace_packages = false` (the default)
- When team members have mixed experience levels (regular packages are unambiguous)

**The `__init__.py` may be empty.** An empty file that exists to mark a directory as a package is intentional, not boilerplate. Don't delete it just because it's empty — delete it only if the project has deliberately adopted namespace packages.

### Namespace Packages (PEP 420, no `__init__.py`)

Directories without `__init__.py` are treated as namespace packages. Multiple directories across different locations on `sys.path` can contribute to the same package namespace.

```
# Two separate repos/installations contribute to the same namespace:
vendor_a/myframework/auth/login.py
vendor_b/myframework/billing/invoice.py

# Both importable as:
from myframework.auth.login import ...
from myframework.billing.invoice import ...
```

**When to use:**
- Plugin systems where multiple packages share a top-level namespace
- Multi-repo projects that intentionally split a namespace across repos
- Projects that explicitly configure `find_namespace_packages()` in setuptools

**Required tooling configuration:**
```toml
# pyproject.toml — setuptools
[tool.setuptools.packages.find]
namespaces = true

# mypy.ini or pyproject.toml
[tool.mypy]
namespace_packages = true
```

**Warning:** Accidentally omitting `__init__.py` in a regular-package project can cause hard-to-debug import failures — Python may silently treat the directory as a namespace package, leading to `ModuleNotFoundError` when the module is found via a different `sys.path` entry.

---

## When to Keep Empty `__init__.py`

| Situation | Keep it? | Reason |
|---|---|---|
| Project uses `find_packages()` | **Yes** | Required for discovery |
| mypy with default config | **Yes** | `namespace_packages` defaults to false |
| pytest import modes | **Depends** | `importmode=importlib` works without; `prepend` may need it |
| Distributed package (PyPI) | **Yes** | Unless explicitly using namespace packages |
| Contains real init code | **Yes** | Logging setup, `__version__`, module-level constants |
| Project intentionally uses namespace packages | **No** | Omission is deliberate |
| Directory is not a Python package | **No** | `tests/`, `scripts/`, `docs/` don't need it |

---

## Re-Export Patterns

### Application Code: Avoid Re-Export

In application codebases, re-exporting symbols through `__init__.py` creates dual import paths that confuse tools and developers:

```python
# ❌ myapp/__init__.py — application code
from .database import Database
from .auth import AuthService

# Problem: both paths work, but IDE/refactoring tools get confused:
#   from myapp import Database           ← which file?
#   from myapp.database import Database  ← canonical
```

**Default:** Import from the actual defining module.

```python
# ✅ Direct imports — one canonical path per symbol
from myapp.database import Database
from myapp.auth import AuthService
```

### Library / Public API: Re-Export Is Expected

For packages consumed as libraries or SDKs, `__init__.py` re-export is the standard Python convention for defining the public import surface:

```python
# ✅ mylib/__init__.py — intentional public API
from .client import Client
from .exceptions import MyLibError, AuthError
from .config import Config

__all__ = ["Client", "Config", "MyLibError", "AuthError"]
```

**Rules for library re-export:**
1. Always define `__all__` to make the public surface explicit
2. Re-export only symbols that are part of the intentional public API
3. Internal modules should still use direct imports between each other
4. Document the public API in the package docstring or README

### Decision Table

| Project type | Re-export in `__init__.py`? | `__all__`? |
|---|---|---|
| Web application | **No** | N/A |
| Internal service | **No** | N/A |
| CLI tool | **No** (unless installable) | N/A |
| Published library (PyPI) | **Yes** | **Required** |
| Shared internal SDK | **Yes** | **Required** |
| Framework | **Yes** | **Required** |

---

## Complete Example: Application Layout

```
myapp/
├── __init__.py              ← empty (marks regular package)
├── main.py                  ← entry point
├── config.py                ← AppConfig TypedDict / dataclass
├── core/
│   ├── __init__.py          ← empty
│   ├── models.py            ← domain models
│   └── services.py          ← business logic
├── api/
│   ├── __init__.py          ← empty
│   ├── routes.py            ← FastAPI/Flask routes
│   └── schemas.py           ← Pydantic request/response models
├── db/
│   ├── __init__.py          ← empty
│   ├── repositories.py      ← data access
│   └── migrations/          ← no __init__.py (not a Python package)
└── _types.py                ← shared type definitions (TypedDict, Protocol)
```

**Key decisions:**
- All package directories have `__init__.py` (regular packages — explicit choice)
- No re-exports in any `__init__.py` (application code)
- Shared types in `_types.py` at package root (breaks circular imports)
- `migrations/` has no `__init__.py` (not a Python package — directory of SQL/Alembic files)

## Complete Example: Library Layout

```
mylib/
├── __init__.py              ← re-exports public API + __all__
├── client.py                ← main Client class
├── config.py                ← Config class
├── exceptions.py            ← custom exceptions
├── _internal/
│   ├── __init__.py          ← empty (internal package)
│   ├── transport.py         ← HTTP transport implementation
│   └── serialization.py     ← internal serialization utilities
└── py.typed                 ← PEP 561 marker for type stub support
```

**Key decisions:**
- Top-level `__init__.py` re-exports `Client`, `Config`, `MyLibError` with `__all__`
- `_internal/` is a private package — consumers should not import from it directly
- `py.typed` marker enables downstream type checking
