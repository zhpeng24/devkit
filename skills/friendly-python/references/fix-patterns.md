# Fix Patterns Reference

Before/after examples for each diagnostic category. Organized by priority.

---

## P1: Unused Imports

### Simple removal
```python
# Before
from typing import Optional
import numpy as np  # not used anywhere

# After
# (lines removed entirely)
```

### Partial import cleanup
```python
# Before
from typing import Any, Optional, List, Dict

# After (only Any still used)
from typing import Any
```

### Trap: import used only in annotations with __future__
```python
from __future__ import annotations
import numpy as np  # ← Pylint says unused, but...

def process(data: np.ndarray) -> np.ndarray:  # used in annotation
    return data * 2
```
With `from __future__ import annotations`, annotations are strings at runtime.
`np` is still needed IF:
- Used in runtime code (function bodies)
- Used with `get_type_hints()` or Pydantic models

NOT needed IF:
- Used ONLY in annotations AND you never call `get_type_hints()`

**Safe approach:** Keep the import; suppress with `# pylint: disable=W0611`.

---

## P2: Deprecated Typing (Python ≥ 3.10)

### Full migration
```python
# Before
from typing import Optional, Union, List, Dict, Tuple, Set, FrozenSet, Type

def fetch(url: str, timeout: Optional[int] = None) -> Union[str, bytes]:
    results: List[Dict[str, Any]] = []
    coords: Tuple[int, int] = (0, 0)
    seen: Set[str] = set()
    frozen: FrozenSet[int] = frozenset()
    cls: Type[Exception] = ValueError

# After
from typing import Any

def fetch(url: str, timeout: int | None = None) -> str | bytes:
    results: list[dict[str, Any]] = []
    coords: tuple[int, int] = (0, 0)
    seen: set[str] = set()
    frozen: frozenset[int] = frozenset()
    cls: type[Exception] = ValueError
```

### Nested generics
```python
# Before
from typing import Dict, List, Optional, Tuple

cache: Dict[str, List[Tuple[int, Optional[str]]]] = {}

# After
cache: dict[str, list[tuple[int, str | None]]] = {}
```

### Type alias migration (Python ≥ 3.12)
```python
# Before (any version)
from typing import TypeAlias
StateType: TypeAlias = tuple[int, int]

# After (Python ≥ 3.12)
type StateType = tuple[int, int]
```

---

## P3: Missing Type Parameters

### Config dictionaries
```python
# Before
def __init__(self, config: dict):
    self.params: dict = config.get("params", {})

# After
def __init__(self, config: dict[str, Any]) -> None:
    self.params: dict[str, Any] = config.get("params", {})
```

### Tuple from list conversion (common pitfall)
```python
# Before — Pylance flags: tuple[int | str, ...] not assignable to tuple[int, int]
start: tuple[int, int] = tuple(config["start"])

# Fix option 1: explicit construction
start: tuple[int, int] = (int(config["start"][0]), int(config["start"][1]))

# Fix option 2: cast (when safe)
from typing import cast
start = cast(tuple[int, int], tuple(config["start"]))

# Fix option 3: suppress with explanation
start: tuple[int, int] = tuple(config["start"])  # type: ignore[assignment]  # 2-element list
```

### Set comprehension with nested tuples
```python
# Before
obstacles = set(tuple(o) for o in config["obstacles"])

# After
obstacles: set[tuple[int, int]] = {
    (int(o[0]), int(o[1])) for o in config["obstacles"]
}
```

### Return type inference
```python
# Before
def get_neighbors(self, pos) -> list:
    return [(pos[0]+dx, pos[1]+dy) for dx, dy in DIRS]

# After
def get_neighbors(self, pos: tuple[int, int]) -> list[tuple[int, int]]:
    return [(pos[0]+dx, pos[1]+dy) for dx, dy in DIRS]
```

---

## P4: Missing Return Types

### Dunder methods
```python
# Before
class Agent:
    def __init__(self, lr: float):
        self.lr = lr
    def __repr__(self):
        return f"Agent(lr={self.lr})"
    def __len__(self):
        return len(self.data)
    def __eq__(self, other):
        return self.lr == other.lr

# After
class Agent:
    def __init__(self, lr: float) -> None:
        self.lr = lr
    def __repr__(self) -> str:
        return f"Agent(lr={self.lr})"
    def __len__(self) -> int:
        return len(self.data)
    def __eq__(self, other: object) -> bool:
        return isinstance(other, Agent) and self.lr == other.lr
```

### Instance attribute annotations
```python
# Before — Pylance may flag as reportUnknownMemberType
class Trainer:
    def __init__(self):
        self.history = []
        self.best_reward = -999
        self.cache = {}

# After
class Trainer:
    def __init__(self) -> None:
        self.history: list[float] = []
        self.best_reward: float = -999.0
        self.cache: dict[str, Any] = {}
```

### Property return types
```python
# Before
@property
def is_done(self):
    return self.steps >= self.max_steps

# After
@property
def is_done(self) -> bool:
    return self.steps >= self.max_steps
```

---

## P5: Logging Lazy Formatting

### Simple conversion
```python
# Before
logger.info(f"Loaded {count} items from {path}")
logger.debug(f"Q[{state}][{action}] = {value:.4f}")
logger.warning(f"Retry {i}/{max_retries}")

# After
logger.info("Loaded %d items from %s", count, path)
logger.debug("Q[%s][%s] = %.4f", state, action, value)
logger.warning("Retry %d/%d", i, max_retries)
```

### Multi-line f-string logging
```python
# Before
logger.info(
    f"Batch {batch_id}: processed={count}, "
    f"duration={duration:.2f}s, errors={errors}"
)

# After
logger.info(
    "Batch %d: processed=%d, duration=%.2fs, errors=%d",
    batch_id, count, duration, errors,
)
```

### Expression in f-string
```python
# Before
logger.debug(f"Shape: {arr.shape}, dtype: {arr.dtype}")

# After
logger.debug("Shape: %s, dtype: %s", arr.shape, arr.dtype)
```

### Conditional / complex expressions
```python
# Before
logger.info(f"Status: {'done' if finished else 'running'}")

# After — extract to variable first
status = "done" if finished else "running"
logger.info("Status: %s", status)
```

---

## P6: Style / Convention (Pylint C-codes)

### Missing module docstring (C0114)
```python
# Before
import os

# After
"""Module for file processing utilities."""
import os
```

### Missing class/function docstring (C0115/C0116)
```python
# Before
class DataLoader:
    def reset(self):
        self.state = self.initial

# After
class DataLoader:
    """Loads and preprocesses data from source files."""

    def reset(self) -> None:
        """Reset loader to initial state."""
        self.state = self.initial
```

---

## Unused Arguments (W0613)

### Reserved interface parameter — prefix with `_`
```python
# Before — Pylint W0613: Unused argument 'epoch'
def on_epoch_end(self, strategy: str = "exponential",
                 epoch: int = 0, total_epochs: int = 100) -> None:
    if strategy == "exponential":
        self.lr = max(self.lr_min, self.lr * self.lr_decay)

# After
def on_epoch_end(self, strategy: str = "exponential",
                 _epoch: int = 0, total_epochs: int = 100) -> None:
    if strategy == "exponential":
        self.lr = max(self.lr_min, self.lr * self.lr_decay)
```

### Dead parameter — remove from full call chain
```python
# Before — output_dir passed everywhere but never used (hardcoded Path("./output") instead)
def generate_report(self, data: dict[str, list[float]],
                    output_dir: Path) -> None:
    target = Path("./output")  # output_dir ignored!
    ...

# app.py
report.generate_report(metrics, output_dir)

# After — remove from signature AND all callers
def generate_report(self, data: dict[str, list[float]]) -> None:
    target = Path("./output")
    ...

# app.py
report.generate_report(metrics)
```

---

## Broad Exception (W0718)

### Narrow to specific exceptions
```python
# Before — W0718: Catching too general exception Exception
try:
    plt.rcParams["font.sans-serif"] = ["Arial Unicode MS", "SimHei"]
    plt.rcParams["axes.unicode_minus"] = False
except Exception:
    pass

# After — specific to what matplotlib font config can raise
try:
    plt.rcParams["font.sans-serif"] = ["Arial Unicode MS", "SimHei"]
    plt.rcParams["axes.unicode_minus"] = False
except (ValueError, OSError, RuntimeError):
    pass
```

---

## Wrong Import Position (C0413) — matplotlib pattern

### `matplotlib.use()` must precede pyplot import
```python
# Before — Pylint C0413 on every import after matplotlib.use()
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt        # C0413
import matplotlib.patches as mpatches  # C0413
import numpy as np                     # C0413

# After — suppress with inline comment (intentional ordering)
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt  # pylint: disable=C0413
import matplotlib.patches as mpatches  # pylint: disable=C0413
import numpy as np  # pylint: disable=C0413
```

This is a well-known pattern. The `matplotlib.use()` call MUST happen before `import matplotlib.pyplot`. The C0413 suppression is correct and expected.

---

## Modern API Preferences

### matplotlib colormaps
```python
# Before — plt.cm.X not in type stubs, triggers reportAttributeAccessIssue
cmap = plt.cm.viridis.copy()

# After — modern API, properly typed
cmap = matplotlib.colormaps["viridis"].copy()
```

