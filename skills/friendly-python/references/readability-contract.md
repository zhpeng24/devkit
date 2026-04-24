# Readability Contract

Readable Python is a correctness property. A change that works but leaves the code harder to understand is not finished.

## Engineering Python

Python can be written casually, but this skill targets production code. Prefer explicit structure over demo-style convenience:

- Named domain models over anonymous containers.
- Explicit function signatures over inference-by-reading.
- Narrow interfaces over "pass the whole dict around".
- Boundary parsing over defensive checks scattered everywhere.
- Clear module ownership over script-like function piles.

If the data shape is implicit, every caller has to rediscover it. That is not acceptable for production code.

## Good Code Shape

Good Python code should feel direct and intentional:

- Public APIs are discoverable and intentionally shaped.
- Modules have clear ownership and names that match the concept they implement.
- Code is direct and readable before it is abstract.
- Error messages are specific and useful to the caller.
- Extension points are explicit; magic registration and hidden side effects are rare.
- Tests exercise behavior and compatibility, not private choreography.
- Internal helpers exist, but they stay close to the module that owns them.
- Abstractions appear after real repetition or real boundary pressure, not before.

Avoid deep class hierarchies, generic service layers, and pattern-heavy architecture unless the project already uses them and the complexity is justified.

## Complexity Budget

Every file, function, abstraction, test, and comment spends complexity budget. Spend it only when it buys clarity, isolation, or safer change.

| Smell | Preferred response |
|---|---|
| Long function with mixed responsibilities | Split into named domain steps |
| `utils.py` full of unrelated helpers | Move helpers next to the owning domain |
| Comment explains what code does | Rename, extract, or simplify until the code says it |
| Many boolean flags | Replace with separate functions, value object, or `Literal` mode |
| Raw nested `dict` in core logic | Parse at boundary into dataclass, TypedDict, or domain object |
| Test repeats setup in every case | Extract fixture, builder, or scenario helper |
| Test asserts private call details | Assert observable behavior or boundary effects |
| One-line clever expression | Prefer boring multi-line code with obvious names |
| Framework-style abstraction for one caller | Inline or use a local helper until a second real use exists |
| Hidden global registration | Prefer explicit construction or a named registration point |

## Naming Standard

Names should carry intent:

- Use domain nouns for data: `Invoice`, `RetryPolicy`, `UserProfile`.
- Use verbs for actions: `parse_config`, `send_receipt`, `resolve_workspace`.
- Avoid vague names: `data`, `info`, `obj`, `manager`, `helper`, `process`.
- Avoid names that describe type only: `dict_data`, `list_items`.

Good names reduce comments. If a comment says "calculate active users", the function should probably be named `calculate_active_users`.

## Function Shape

A clean function usually has:

- one responsibility
- a visible happy path
- explicit boundary errors
- no surprising mutation
- parameters that make invalid calls difficult

Red flags:

- requires scrolling
- deeply nested `if`/`for`/`try`
- mutates inputs while also returning a value
- mixes IO, parsing, business rules, and formatting
- has flags like `dry_run`, `validate_only`, `skip_cache`, `force` all steering unrelated branches

## Module Shape

A module should answer: "What concept owns this code?"

Prefer:

```text
billing/
  invoice.py
  pricing.py
  tax.py
```

Avoid:

```text
utils.py
helpers.py
common.py
misc.py
```

Generic names are acceptable only for tiny local modules with a narrow owner, such as `billing/_utils.py`.

## Comments

Comments should explain why, constraints, or non-obvious tradeoffs.

Good:

```python
# GitHub returns draft PRs in this endpoint; filter locally to keep old CLI compatibility.
```

Bad:

```python
# Loop through users and append active users to the list.
```

If a comment narrates ordinary code, improve the code.

## Tests

Tests should make behavior obvious:

- Names describe behavior, not implementation.
- Setup is smaller than the assertion story.
- Fixtures/builders hide irrelevant construction detail.
- Mock only hard boundaries: network, time, process, filesystem, third-party APIs.
- Prefer testing public behavior over private helper choreography.

Many tests can still be bad if they copy setup, assert internals, or make refactoring painful.

## Boundary Rule

Messy data belongs at boundaries. Core logic should receive structured, validated concepts.

Allowed at boundaries:

- `dict[str, object]` from JSON
- optional third-party SDK response fields
- database row mappings
- CLI/env string inputs

Before core logic:

- validate required fields
- convert to dataclass, TypedDict, enum/Literal, or domain object
- normalize names and types
- isolate optional/missing behavior

## Type Shape

Use Python typing to communicate design, not just satisfy a checker.

Prefer:

```python
@dataclass(frozen=True)
class RetryPolicy:
    max_attempts: int
    backoff_seconds: float


def fetch_invoice(invoice_id: str, retry_policy: RetryPolicy) -> Invoice:
    ...
```

Avoid:

```python
def fetch_invoice(invoice_id, options):
    ...
```

The second form forces every caller and maintainer to rediscover the contract.
