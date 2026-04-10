# Boundary Layer Exceptions

Guidance for handling wider types at system boundaries. Read when working with API endpoints, ORM hooks, third-party payloads, plugin systems, or prototype code.

The core rule: **wider types are acceptable at boundaries, but must be narrowed before entering core domain logic.**

---

## Why Boundaries Are Different

Core domain code benefits from maximum type strictness — it is the code you control, maintain, and refactor most. But at system edges, data is inherently dynamic:

- HTTP request bodies arrive as untyped JSON
- ORM event handlers receive framework-dictated signatures
- Plugin systems load code at runtime
- External SDK responses may lack type stubs

Fighting this with forced narrow types at the boundary itself leads to verbose, fragile code. Instead, **accept the dynamic nature at the edge, then narrow as early as possible.**

---

## Pattern: API Ingress / Egress

### Before — fighting the boundary
```python
# ❌ Overly strict at the edge — fragile and verbose
@app.post("/users")
async def create_user(request: Request) -> JSONResponse:
    body: dict[str, str] = await request.json()  # type: ignore — json() returns Any
    name: str = body["name"]  # KeyError if missing
    email: str = body["email"]
    ...
```

### After — accept and narrow
```python
# ✅ Accept dynamic input, validate into typed model at the boundary
from pydantic import BaseModel

class CreateUserRequest(BaseModel):
    name: str
    email: str

@app.post("/users")
async def create_user(payload: CreateUserRequest) -> CreateUserResponse:
    return _create_user_core(payload)  # core logic receives typed data
```

**Key:** Use Pydantic, `TypedDict`, or manual validation to narrow `Any` / `dict[str, Any]` into concrete types before calling domain functions.

---

## Pattern: ORM / Framework Hooks

### Before — fighting framework signatures
```python
# ❌ Trying to narrow a Django signal receiver
from django.db.models.signals import post_save

def on_user_saved(
    sender: type["User"],
    instance: "User",
    created: bool,
    **kwargs: dict[str, Any],  # wrong — **kwargs is str keys
) -> None:
    ...
```

### After — accept framework's contract
```python
# ✅ Accept the framework's signature, narrow inside the handler
from typing import Any

def on_user_saved(sender: type, instance: Any, created: bool, **kwargs: Any) -> None:
    """Handle post-save signal for User model."""
    if not isinstance(instance, User):
        return
    # Now instance is narrowed to User for the rest of the function
    _process_new_user(instance) if created else _process_updated_user(instance)
```

**Key:** Framework-dictated callback signatures are acceptable as-is. Narrow via `isinstance()` or validation inside the handler body.

---

## Pattern: Third-Party Dynamic Payloads

### Before — pretending the payload is typed
```python
# ❌ Wishful typing — webhook body is unknown at compile time
def handle_webhook(payload: WebhookPayload) -> None:  # WebhookPayload doesn't exist
    ...
```

### After — validate at ingress, typed after
```python
# ✅ Accept Any, validate into TypedDict
from typing import Any, TypedDict

class WebhookEvent(TypedDict):
    event_type: str
    timestamp: str
    data: dict[str, Any]  # nested data may need further validation

def handle_webhook(raw: dict[str, Any]) -> None:
    """Validate and dispatch incoming webhook."""
    event = _validate_webhook(raw)  # returns WebhookEvent or raises
    _dispatch_event(event)  # core logic receives typed data

def _validate_webhook(raw: dict[str, Any]) -> WebhookEvent:
    if "event_type" not in raw or "timestamp" not in raw:
        raise ValueError("Invalid webhook payload")
    return WebhookEvent(
        event_type=str(raw["event_type"]),
        timestamp=str(raw["timestamp"]),
        data=raw.get("data", {}),
    )
```

---

## Pattern: Plugin Registries

### Before — Any everywhere
```python
# ❌ Any leaks through the entire call chain
def load_plugin(name: str) -> Any:
    mod = importlib.import_module(f"plugins.{name}")
    return mod.Plugin()

def run(plugin: Any) -> Any:  # Any in, Any out — no safety
    return plugin.execute()
```

### After — Any at load, Protocol on use
```python
# ✅ Narrow from Any to Protocol at the boundary
from typing import Any, Protocol

class PluginInterface(Protocol):
    def execute(self, data: bytes) -> str: ...

def load_plugin(name: str) -> Any:  # dynamic loading — Any is honest here
    mod = importlib.import_module(f"plugins.{name}")
    return mod.Plugin()

def run_plugin(plugin: PluginInterface, data: bytes) -> str:  # narrowed
    return plugin.execute(data)

# At the call site — narrow immediately after loading
plugin: Any = load_plugin("csv_parser")
assert isinstance(plugin, PluginInterface)  # or use runtime_checkable
result = run_plugin(plugin, raw_data)
```

---

## Pattern: Prototype / Spike Code

Exploratory scripts and notebooks may use relaxed types to support rapid iteration. This is acceptable **with markers**:

```python
# TODO: narrow types — this is prototype code
config: dict[str, Any] = load_yaml("experiment.yaml")
results: list[Any] = []

for trial in config["trials"]:  # type: ignore[index]
    result = run_experiment(trial)  # returns Any for now
    results.append(result)
```

**Rules for prototype code:**
1. Every `Any` or `dict[str, Any]` must have a `# TODO: narrow types` comment
2. Prototype files should be in a clearly marked directory (e.g., `scripts/`, `notebooks/`, `experiments/`)
3. When promoting prototype to production, type narrowing is the first step

---

## Lifetime Rules for Wide Types

| Stage | Allowed types | Example |
|---|---|---|
| **At the boundary** | `Any`, `dict[str, Any]`, framework signatures | Request handler, signal receiver |
| **Validation / parsing** | Narrowing via Pydantic, isinstance, TypedDict | `_validate_webhook()` |
| **After narrowing** | Concrete types only | `User`, `WebhookEvent`, `PluginInterface` |

**The width must decrease monotonically.** Once a value is narrowed into a concrete type, it must never be widened back to `Any` or `dict[str, Any]`.

Wide types that leak past the boundary into domain functions, utility modules, or return types of core APIs are defects — treat them the same as any other type error.
