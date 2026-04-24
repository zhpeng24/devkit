# Python Project Workflow

Use this reference when deciding how to run, verify, or bootstrap a Python project. Prefer the project's existing tooling. Do not introduce a new manager or formatter unless the user asked for setup work.

## Project Signals

| Signal | Meaning |
|---|---|
| `uv.lock` or `[tool.uv]` | Use `uv` commands |
| `poetry.lock` or `[tool.poetry]` | Use Poetry commands |
| `pdm.lock` or `[tool.pdm]` | Use PDM commands |
| `Pipfile` or `Pipfile.lock` | Use Pipenv commands |
| `tox.ini` or `[tool.tox]` | Project has tox environments |
| `noxfile.py` | Project has nox sessions |
| `pyproject.toml` | PEP 517/518 project metadata and tool config |
| `requirements*.txt` | pip/venv dependency flow |
| `pyrightconfig.json`, `mypy.ini`, `.mypy.ini` | Type checker configuration |
| `ruff.toml`, `.ruff.toml`, `[tool.ruff]` | Ruff configuration |
| `pytest.ini`, `[tool.pytest.ini_options]` | pytest configuration |

## Command Selection

Pick the first matching row.

| Project type | Install/sync | Run tests | Lint/format | Type check |
|---|---|---|---|---|
| uv | `uv sync` | `uv run pytest` | `uv run ruff check .` / `uv run ruff format .` | `uv run pyright` or `uv run mypy` |
| Poetry | `poetry install` | `poetry run pytest` | `poetry run ruff check .` / `poetry run ruff format .` | `poetry run pyright` or `poetry run mypy` |
| PDM | `pdm install` | `pdm run pytest` | `pdm run ruff check .` / `pdm run ruff format .` | `pdm run pyright` or `pdm run mypy` |
| Pipenv | `pipenv install --dev` | `pipenv run pytest` | `pipenv run ruff check .` / `pipenv run ruff format .` | `pipenv run pyright` or `pipenv run mypy` |
| tox | existing env | `tox` or `tox -e py` | tox env if configured | tox env if configured |
| nox | existing env | `nox` or relevant session | nox session if configured | nox session if configured |
| plain venv | `python -m pip install -r requirements.txt` | `python -m pytest` | `python -m ruff check .` / `python -m ruff format .` | `python -m pyright` or `python -m mypy` |

If a tool is not installed or dependencies are missing, report the missing tool and use the smallest available verification (`python -m compileall <package>` for syntax, targeted tests when available). Do not silently skip verification.

## Verification Ladder

Use the narrowest check that proves the change, then broaden before delivery:

1. Targeted test for the changed behavior.
2. Formatter/linter for touched Python files.
3. Type checker for touched package or project.
4. Full test suite if the change touches shared code, public APIs, packaging, or behavior used across modules.

## Bootstrap Guidance

For a new Python project, prefer:

```toml
[project]
requires-python = ">=3.12"

[tool.ruff]
target-version = "py312"
line-length = 88

[tool.ruff.lint]
select = ["E", "F", "W", "I", "UP", "B", "SIM"]

[tool.pyright]
typeCheckingMode = "strict"
pythonVersion = "3.12"
reportUnnecessaryTypeIgnoreComment = true
```

Add pytest, Ruff, and Pyright only when the project needs a new toolchain or has no existing standard. For existing projects, follow local conventions first.
