# Project Types

Identify the project type before judging layout, public API, tests, or tooling. Good Python looks different across project shapes, but all production code still needs named data, clear boundaries, and verification.

| Type | Optimize for | Structure defaults | Watch for |
|---|---|---|---|
| Application/service | operational clarity, config, observability, boundaries | `config`, `domain`, `adapters`, `api` only when they map to real concepts | framework-shaped folders with no ownership, raw request dicts in core logic |
| CLI | obvious entry point, parse/execute split, useful errors | `cli.py` parses args, core module does work, tests cover core behavior | business logic inside argparse callbacks |
| Library/SDK | stable public API, compatibility, typed exports | intentional `__init__.py` re-exports, `__all__`, `py.typed`, public API tests | applying application "no re-export" rules blindly |
| Script collection | safe evolution from scripts to modules | keep scripts thin, move reusable logic into named modules | copy-pasted functions and global state |
| Data/notebook support | reproducibility, explicit schemas, thin notebooks | notebooks call modules; data shapes named in code | analysis logic trapped inside notebooks |
| Plugin/integration | boundary isolation, explicit contracts | adapter modules per integration, Protocols for local contracts | third-party response dicts leaking everywhere |

## Decision Rules

- If external users import it, treat it as library surface.
- If humans run it from a terminal, keep CLI parsing separate from work.
- If it talks to HTTP, files, databases, environment, subprocesses, or SDKs, isolate that boundary.
- If the same raw shape appears twice, name it.
- If a directory name does not explain ownership, rename or remove it.

## Public Surface

Application code should usually import from the module that owns the concept.

Library code may intentionally expose a shorter public API:

```python
from .client import Client
from .errors import ClientError

__all__ = ["Client", "ClientError"]
```

The deciding question is: "Will downstream users reasonably import this?"
