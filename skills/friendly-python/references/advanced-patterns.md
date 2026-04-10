# Advanced Typing Patterns

Patterns for complex type annotation scenarios. Read when encountering advanced diagnostics or when basic fix-patterns.md doesn't cover the case.

---

## Resolving Circular Imports

Prefer architectural solutions over `if TYPE_CHECKING`. It creates two code paths and can hide dependency issues. Use these alternatives first:

### Option 1: Shared types module (preferred)
Extract types both modules depend on into a dedicated `types.py` or `_types.py`:

```python
# src/types.py — shared type definitions
from dataclasses import dataclass

@dataclass
class State:
    x: int
    y: int

type RewardMap = dict[tuple[int, int], float]
type ActionSpace = list[int]

# myapp/types.py
from .types import State, RewardMap   # no cycle

# myapp/agent.py
from .types import State, ActionSpace  # no cycle
```

### Option 2: Protocol in the depended-upon module
If module A imports B and B needs to reference A's type, define a Protocol in B:

```python
# myapp/environment.py — does NOT import agent
from typing import Protocol

class AgentLike(Protocol):
    """Structural type — any class with these methods satisfies it."""
    def choose_action(self, state: tuple[int, int]) -> int: ...
    def update(self, state: tuple[int, int], action: int, reward: float) -> None: ...

class Environment:
    def run_episode(self, agent: AgentLike) -> float:  # no import needed
        ...

# myapp/agent.py
from .environment import Environment  # one-way import, no cycle

class Agent:  # satisfies AgentLike without inheriting
    def choose_action(self, state: tuple[int, int]) -> int: ...
    def update(self, state: tuple[int, int], action: int, reward: float) -> None: ...
```

### Option 3: Restructure modules
If A↔B cycle exists, the modules are too coupled. Merge them or extract shared logic into C.

### Option 4: `TYPE_CHECKING` (last resort)
When architectural fixes are impractical — the cycle involves third-party code you don't control, or the import is only needed for annotations and is expensive at runtime — `TYPE_CHECKING` is acceptable:

```python
from __future__ import annotations
from typing import TYPE_CHECKING

if TYPE_CHECKING:
    import pandas as pd  # heavy import, only needed for annotations

def summarize(df: pd.DataFrame) -> dict[str, float]:
    return {"mean": float(df.mean()), "std": float(df.std())}
```

**Conditions for using `TYPE_CHECKING`:**
- The import is **typing-only** (never used at runtime in function bodies)
- The imported module is **heavy or optional** (pandas, torch, tensorflow)
- You've already considered Options 1–3 and they don't fit
- Always combine with `from __future__ import annotations` or quoted forward references

---

## Forward References (Without __future__)

When a class references itself, quote the annotation:

```python
class Node:
    def __init__(self) -> None:
        self.children: list["Node"] = []

    def add_child(self, child: "Node") -> None:
        self.children.append(child)
```

On Python ≥ 3.12, `from __future__ import annotations` is acceptable as it's heading toward default behavior. But prefer quoted strings for isolated self-references.

---

## TypeVar and Generic

### Basic TypeVar
```python
from typing import TypeVar

T = TypeVar("T")

def first(items: list[T]) -> T:
    return items[0]
```

### Bounded TypeVar
```python
from typing import TypeVar
import numpy as np

ArrayLike = TypeVar("ArrayLike", bound=np.ndarray)

def normalize(data: ArrayLike) -> ArrayLike:
    return data / data.max()
```

### Generic class
```python
from typing import Generic, TypeVar

T = TypeVar("T")

class Stack(Generic[T]):
    def __init__(self) -> None:
        self._items: list[T] = []

    def push(self, item: T) -> None:
        self._items.append(item)

    def pop(self) -> T:
        return self._items.pop()
```

### Python 3.12 syntax (PEP 695) — preferred when available
```python
# Before (any version)
T = TypeVar("T")
def first(items: list[T]) -> T: ...

# After (Python ≥ 3.12)
def first[T](items: list[T]) -> T: ...

# Generic class
class Stack[T]:
    def push(self, item: T) -> None: ...
```

---

## Protocol (Structural Subtyping)

Preferred over ABC when you want structural ("duck") typing with full IDE support:

```python
from typing import Protocol

class Renderable(Protocol):
    def render(self) -> str: ...

class Widget:
    def render(self) -> str:
        return "<widget/>"

def display(obj: Renderable) -> None:  # Widget satisfies this without inheritance
    print(obj.render())
```

### Runtime checkable protocol
```python
from typing import Protocol, runtime_checkable

@runtime_checkable
class Sized(Protocol):
    def __len__(self) -> int: ...

assert isinstance([1, 2, 3], Sized)  # True at runtime
```

### Protocol vs ABC decision

| Use Protocol when | Use ABC when |
|---|---|
| No shared implementation | Shared default methods needed |
| Third-party classes must satisfy it | You control all subclasses |
| Structural ("looks like a duck") | Nominal ("is registered as a duck") |
| Avoiding import dependencies | Inheritance tree is intentional |

---

## TypedDict — Structured Dicts with IDE Support

Prefer TypedDict over `dict[str, Any]` when the dict has a known schema. This gives IDE autocomplete on keys and type-checks values:

```python
from typing import TypedDict

class EnvConfig(TypedDict):
    rows: int
    cols: int
    start: tuple[int, int]
    obstacles: list[tuple[int, int]]

class ModelConfig(TypedDict, total=False):  # all keys optional
    learning_rate: float
    batch_size: int
    epochs: int

def load_env(config: EnvConfig) -> None:
    rows = config["rows"]      # IDE knows this is int
    start = config["start"]    # IDE knows this is tuple[int, int]
```

**When to use what:**

| Type | When |
|---|---|
| `TypedDict` | Known fixed keys, JSON/YAML with stable schema |
| `dataclass` | When you also want methods, defaults, `__init__` |
| `dict[str, X]` | Dynamic/unknown keys, homogeneous values |
| `dict[str, Any]` | Last resort — add `# TODO: define TypedDict` |

---

## Literal

For constrained string/int values — gives IDE autocomplete on valid options:

```python
from typing import Literal

def set_mode(mode: Literal["train", "eval", "test"]) -> None: ...

def set_verbosity(level: Literal[0, 1, 2]) -> None: ...

# Combine with type alias for reuse
type EpsilonStrategy = Literal["linear", "exponential", "step"]
```

---

## Callable

```python
from collections.abc import Callable

# Function: (int, str) → bool
handler: Callable[[int, str], bool]

# No args → None
callback: Callable[[], None]

# Avoid Callable[..., Any] — define a Protocol instead
```

### Complex signatures → Protocol (preferred for IDE support)
```python
from typing import Protocol
import numpy as np

class LossFunction(Protocol):
    def __call__(
        self,
        pred: np.ndarray,
        target: np.ndarray,
        *,
        reduction: str = "mean",
    ) -> float: ...

def train(loss_fn: LossFunction) -> None: ...
```

---

## @overload

For functions with different return types based on input:

```python
from typing import overload

@overload
def parse(data: str) -> dict[str, int]: ...
@overload
def parse(data: bytes) -> list[int]: ...

def parse(data: str | bytes) -> dict[str, int] | list[int]:
    if isinstance(data, str):
        return json.loads(data)
    return list(data)
```

**Rules:**
- `@overload` bodies are just `...` (no implementation)
- Final implementation has no `@overload` decorator
- Implementation signature must be compatible with all overloads

---

## *args and **kwargs Typing

```python
# Each positional arg is a float
def mean(*args: float) -> float:
    return sum(args) / len(args)

# Each keyword arg is a str
def tag(**kwargs: str) -> dict[str, str]:
    return kwargs

# ParamSpec for decorators (preserves caller signature in IDE)
from typing import ParamSpec, TypeVar
from collections.abc import Callable

P = ParamSpec("P")
R = TypeVar("R")

def retry(fn: Callable[P, R], *args: P.args, **kwargs: P.kwargs) -> R:
    return fn(*args, **kwargs)
```

---

## numpy / matplotlib Specifics

### numpy type annotations
```python
import numpy as np
from numpy.typing import NDArray

# Preferred (numpy ≥ 1.20)
def process(data: NDArray[np.float64]) -> NDArray[np.float64]: ...

# Also valid but less precise
def legacy(data: np.ndarray) -> np.ndarray: ...
```

### matplotlib return types
```python
import matplotlib.pyplot as plt
from matplotlib.figure import Figure
from matplotlib.axes import Axes

def create_plot(data: list[float]) -> tuple[Figure, Axes]:
    fig, ax = plt.subplots()
    ax.plot(data)
    return fig, ax
```

### matplotlib.use() placement
```python
import matplotlib
matplotlib.use("Agg")  # MUST be before importing pyplot
import matplotlib.pyplot as plt  # noqa: E402
```

---

## cast() — Explicit Type Narrowing

Use sparingly. Prefer `isinstance()` checks which narrow types AND validate:

```python
from typing import cast

# Acceptable: you've validated but checker can't see it
data = json.loads(response.text)
assert isinstance(data, dict)
result = cast(dict[str, list[int]], data)

# Better: isinstance narrows without cast
if isinstance(data, dict):
    process(data)  # type checker knows it's dict now
```

**Rules:**
- `cast()` is zero-cost at runtime
- Never use to silence real type errors
- Always add a comment explaining WHY the cast is safe
- Prefer `isinstance()` → `assert isinstance()` → `cast()` → `# type: ignore`

---

## Self Type (Python ≥ 3.11)

```python
from typing import Self

class Builder:
    def set_name(self, name: str) -> Self:
        self.name = name
        return self

    @classmethod
    def create(cls) -> Self:
        return cls()
```

For Python < 3.11, use quoted class name:
```python
class Builder:
    def set_name(self, name: str) -> "Builder":
        self.name = name
        return self
```
