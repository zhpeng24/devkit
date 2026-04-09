# Tool Diagnostic Codes Reference

Comprehensive mapping of diagnostic codes across Python static analysis tools, with suppression syntax and configuration guidance.

---

## Pylance / Pyright Diagnostic Codes

Pylance is VS Code's Python language server built on Pyright.

### Strictness levels (pyright)
```
off → basic → standard → strict → all
```
Configure in `pyrightconfig.json` or `pyproject.toml`:
```toml
[tool.pyright]
typeCheckingMode = "standard"  # or "strict"
pythonVersion = "3.12"
```

### Common diagnostic rules

| Code | Severity | Description | Fix |
|---|---|---|---|
| `reportUnusedImport` | warn | Import not used | Remove import |
| `reportDeprecated` | warn | Deprecated typing construct | Modernize to built-in generics |
| `reportMissingTypeArgument` | warn | Generic without type params | Add `[X]` to `dict`, `list`, etc. |
| `reportUnknownParameterType` | warn | Function param has no type | Add annotation |
| `reportUnknownVariableType` | warn | Variable type not inferred | Add explicit annotation |
| `reportUnknownMemberType` | warn | Attribute type not inferred | Annotate in `__init__` |
| `reportUnknownArgumentType` | warn | Argument type unknown | Add annotation to source |
| `reportMissingParameterType` | warn | Missing param annotation | Add type hint |
| `reportGeneralClassIssues` | error | Class definition problems | Fix class structure |
| `reportIndexIssue` | error | Invalid index operation | Fix indexing logic |
| `reportReturnType` | error | Return type mismatch | Fix return annotation or logic |
| `reportAssignmentType` | error | Incompatible assignment | Fix types or cast |
| `reportAttributeAccessIssue` | error | Invalid attribute access | Fix attribute or type |
| `reportCallIssue` | error | Invalid function call | Fix arguments |
| `reportPossiblyUnbound` | warn | Variable may be unbound | Initialize before use |
| `reportUnnecessaryIsInstance` | info | Redundant isinstance check | Remove check |

### Suppression
```python
x = value  # type: ignore[reportAssignmentType]
# or (Pyright generic form):
x = value  # type: ignore[assignment]
```

### Per-line rule disable
```python
x = value  # pyright: ignore[reportUnknownMemberType]
```

---

## Pylint Diagnostic Codes

### Code format: `XNNNN` where X = category letter

| Prefix | Category | Examples |
|---|---|---|
| `C` | Convention | `C0114` missing docstring, `C0301` line too long, `C0103` bad name |
| `R` | Refactor | `R0903` too few public methods, `R0913` too many arguments |
| `W` | Warning | `W0611` unused import, `W1203` logging f-string, `W0612` unused variable |
| `E` | Error | `E1101` no member, `E0401` import error, `E1120` missing argument |
| `F` | Fatal | `F0001` parse error |

### Most common warnings

| Code | Name | Description | Fix |
|---|---|---|---|
| `W0611` | `unused-import` | Import not used | Remove import |
| `W0612` | `unused-variable` | Variable assigned but not used | Remove or prefix with `_` |
| `W0613` | `unused-argument` | Argument not used | Prefix with `_` or remove |
| `W1203` | `logging-fstring-interpolation` | f-string in logging | Use `%s`/`%d` lazy formatting |
| `W0621` | `redefined-outer-name` | Variable shadows outer scope | Rename |
| `W0622` | `redefined-builtin` | Variable shadows builtin | Rename |
| `W0107` | `unnecessary-pass` | `pass` in non-empty body | Remove `pass` |
| `W0613` | `unused-argument` | Argument not used | Prefix with `_` or remove |
| `W0718` | `broad-exception-caught` | `except Exception` too broad | Narrow to specific types |
| `C0114` | `missing-module-docstring` | No module docstring | Add module docstring |
| `C0115` | `missing-class-docstring` | No class docstring | Add class docstring |
| `C0116` | `missing-function-docstring` | No function docstring | Add function docstring |
| `C0301` | `line-too-long` | Line exceeds max length | Reformat or configure max |
| `C0103` | `invalid-name` | Name doesn't match convention | Rename or disable |
| `C0413` | `wrong-import-position` | Import after non-import code | Reorder or `# pylint: disable=C0413` (e.g., matplotlib.use) |
| `R0903` | `too-few-public-methods` | Class with < 2 public methods | Disable for dataclass-like |
| `R0913` | `too-many-arguments` | Function has > 5 args | Refactor or disable |
| `E1101` | `no-member` | Object has no such member | Fix attribute name or add stub |

### Suppression
```python
x = value  # pylint: disable=W0611
x = value  # pylint: disable=unused-import  # name form also works

# Block disable
# pylint: disable=C0114,C0115
class MyClass:
    ...
# pylint: enable=C0114,C0115
```

### Configuration (`pyproject.toml`)
```toml
[tool.pylint.messages_control]
disable = [
    "C0114",  # missing-module-docstring
    "C0115",  # missing-class-docstring
    "R0903",  # too-few-public-methods
]

[tool.pylint.format]
max-line-length = 120
```

---

## mypy Diagnostic Codes

### Common error codes

| Code | Description | Fix |
|---|---|---|
| `[import]` | Cannot find module | Install type stubs or add `# type: ignore[import]` |
| `[assignment]` | Incompatible types in assignment | Fix types or cast |
| `[arg-type]` | Incompatible argument type | Fix argument type |
| `[return-value]` | Incompatible return value | Fix return type |
| `[name-defined]` | Name not defined | Import or define |
| `[attr-defined]` | Has no attribute | Fix attribute access |
| `[type-arg]` | Missing type argument for generic | Add type parameter |
| `[override]` | Incompatible method override | Fix override signature |
| `[no-untyped-def]` | Function without type annotations | Add annotations (strict mode) |
| `[no-any-return]` | Returning Any from typed function | Add annotation or cast |
| `[union-attr]` | Optional access without None check | Add `if x is not None` guard |
| `[index]` | Invalid index type | Fix index expression |
| `[misc]` | Miscellaneous error | Read message carefully |

### Suppression
```python
x = value  # type: ignore[assignment]
x = value  # type: ignore[assignment, arg-type]  # multiple codes
```

### Configuration (`pyproject.toml`)
```toml
[tool.mypy]
python_version = "3.12"
strict = true
warn_return_any = true
warn_unused_ignores = true
disallow_untyped_defs = true

[[tool.mypy.overrides]]
module = "matplotlib.*"
ignore_missing_imports = true
```

---

## ruff Diagnostic Codes

ruff replaces flake8 + isort + many plugins. Uses letter-number codes:

### Common code prefixes

| Prefix | Source | Examples |
|---|---|---|
| `E` | pycodestyle errors | `E501` line too long, `E711` comparison to None |
| `W` | pycodestyle warnings | `W291` trailing whitespace |
| `F` | Pyflakes | `F401` unused import, `F841` unused variable |
| `I` | isort | `I001` unsorted imports |
| `UP` | pyupgrade | `UP006` deprecated typing, `UP007` use `X \| Y` |
| `B` | flake8-bugbear | `B006` mutable default, `B905` zip without strict |
| `SIM` | flake8-simplify | `SIM102` collapsible if, `SIM108` ternary |
| `TCH` | flake8-type-checking | `TCH001` move to TYPE_CHECKING block |
| `ANN` | flake8-annotations | `ANN001` missing function arg, `ANN201` missing return |
| `RUF` | ruff-specific | `RUF100` unused noqa |

### Suppression
```python
x = value  # noqa: F401
x = value  # noqa: F401, E501  # multiple codes
```

### Configuration (`pyproject.toml`)
```toml
[tool.ruff]
target-version = "py312"
line-length = 120

[tool.ruff.lint]
select = ["E", "F", "W", "I", "UP", "B", "SIM"]
ignore = ["E501"]  # line length handled by formatter

[tool.ruff.lint.per-file-ignores]
"__init__.py" = ["F401"]  # allow unused imports in __init__
"tests/**" = ["ANN"]       # don't require annotations in tests
```

### Auto-fix
```bash
ruff check . --fix          # fix auto-fixable issues
ruff check . --fix --unsafe-fixes  # include unsafe fixes
ruff format .               # format code (replaces black)
```

---

## Third-Party Type Stubs

When mypy/Pylance reports `[import]` or "Cannot find type stubs", install the appropriate stub package:

| Library | Stub package |
|---|---|
| requests | `types-requests` |
| PyYAML | `types-PyYAML` |
| beautifulsoup4 | `types-beautifulsoup4` |
| redis | `types-redis` |
| Pillow | `types-Pillow` |
| six | `types-six` |
| protobuf | `types-protobuf` |
| Markdown | `types-Markdown` |
| Flask | ships with types |
| Django | `django-stubs` |
| SQLAlchemy | ships with types (≥ 2.0) |
| numpy | ships with types (≥ 1.20) |
| pandas | `pandas-stubs` |

Search for stubs: `pip install types-<package>` or check [typeshed](https://github.com/python/typeshed).

For libraries without stubs, suppress per-module:
```toml
# mypy
[[tool.mypy.overrides]]
module = "some_untyped_lib.*"
ignore_missing_imports = true
```
```toml
# pyright
[tool.pyright]
reportMissingTypeStubs = false
```

---

## Cross-Tool Suppression Cheat Sheet

| Scenario | Pylance/Pyright | mypy | Pylint | ruff/flake8 |
|---|---|---|---|---|
| Unused import | `# type: ignore` | `# type: ignore[import]` | `# pylint: disable=W0611` | `# noqa: F401` |
| Type mismatch | `# type: ignore[reportAssignmentType]` | `# type: ignore[assignment]` | — | — |
| Missing member | `# type: ignore[reportAttributeAccessIssue]` | `# type: ignore[attr-defined]` | `# pylint: disable=E1101` | — |
| Line too long | — | — | `# pylint: disable=C0301` | `# noqa: E501` |
| Multiple tools | `# type: ignore[assignment]  # pylint: disable=E1101  # noqa: E501` ||||

**Golden rule:** Always include the specific error code. Bare `# type: ignore` or `# noqa` suppresses ALL diagnostics on that line — it hides future real bugs.
