# Examples

Use these as shape examples. They are not templates to copy blindly.

## Anonymous Data Shape

Bad:

```python
def schedule_job(job: dict, options: dict) -> None:
    if options.get("retry"):
        retry_count = int(options.get("retry_count", 3))
    queue.push(job["name"], job["payload"], retry_count)
```

Good:

```python
from dataclasses import dataclass


@dataclass(frozen=True)
class JobRequest:
    name: str
    payload: bytes


@dataclass(frozen=True)
class RetryPolicy:
    enabled: bool
    max_attempts: int = 3


def schedule_job(job: JobRequest, retry_policy: RetryPolicy) -> None:
    max_attempts = retry_policy.max_attempts if retry_policy.enabled else 1
    queue.push(job.name, job.payload, max_attempts)
```

Why: the caller can see the contract without reading the function body.

## Boundary Parsing

Bad:

```python
def create_user(payload: dict[str, object]) -> User:
    email = str(payload["email"]).lower()
    if "@" not in email:
        raise ValueError("bad email")
    return User(email=email, name=str(payload.get("name", "")))
```

Good:

```python
from typing import TypedDict


class CreateUserPayload(TypedDict):
    email: str
    name: str


def parse_create_user_payload(payload: dict[str, object]) -> CreateUserPayload:
    email = payload.get("email")
    name = payload.get("name", "")
    if not isinstance(email, str) or "@" not in email:
        raise ValueError("email must be a valid email address")
    if not isinstance(name, str):
        raise ValueError("name must be a string")
    return {"email": email.lower(), "name": name}


def create_user(payload: CreateUserPayload) -> User:
    return User(email=payload["email"], name=payload["name"])
```

Why: raw input is handled once at the boundary; core logic receives a named shape.

## Utility Dump

Bad:

```text
utils.py
  parse_date()
  calculate_invoice_total()
  retry_request()
  normalize_email()
```

Good:

```text
billing/invoice.py       # calculate_invoice_total
identity/email.py        # normalize_email
http/retry.py            # retry_request
time/parse.py            # parse_date
```

Why: module names tell the maintainer where concepts live.

## Comments Explaining What

Bad:

```python
# Check if the user is active and has enough credits.
if user.is_active and user.credits >= required_credits:
    process_order(order)
```

Good:

```python
if can_process_order(user, required_credits):
    process_order(order)


def can_process_order(user: User, required_credits: int) -> bool:
    return user.is_active and user.credits >= required_credits
```

Why: the condition has a name, so future changes have an obvious home.

## Test Setup Noise

Bad:

```python
def test_applies_discount() -> None:
    user = User(id="u1", email="a@example.com", is_active=True)
    product = Product(id="p1", price_cents=1000, currency="USD")
    cart = Cart(user=user, products=[product], coupon_code="SAVE10")

    total = calculate_total(cart)

    assert total.due_cents == 900
```

Good:

```python
def test_applies_discount() -> None:
    cart = cart_with_product(price_cents=1000, coupon_code="SAVE10")

    total = calculate_total(cart)

    assert total.due_cents == 900
```

Why: irrelevant construction details do not hide the behavior under test.

## Premature Framework

Bad:

```python
class HandlerRegistry:
    def __init__(self) -> None:
        self._handlers: dict[str, Handler] = {}

    def register(self, name: str, handler: Handler) -> None:
        self._handlers[name] = handler

    def dispatch(self, name: str, request: Request) -> Response:
        return self._handlers[name].handle(request)
```

Good, when there are only two explicit paths:

```python
def handle_request(request: Request) -> Response:
    if request.kind == "create":
        return create_item(request)
    if request.kind == "delete":
        return delete_item(request)
    raise ValueError(f"unsupported request kind: {request.kind}")
```

Why: abstractions should follow real pressure, not anticipate it.

## Mini Case: CLI Config Parsing

Bad:

```python
def main() -> None:
    args = parser.parse_args()
    timeout = int(args.timeout or os.environ.get("TIMEOUT", "30"))
    if timeout < 1:
        raise SystemExit("bad timeout")
    run({"path": args.path, "timeout": timeout, "dry": args.dry_run})
```

Good:

```python
from dataclasses import dataclass


@dataclass(frozen=True)
class RunConfig:
    path: str
    timeout_seconds: int
    dry_run: bool


def parse_run_config(args: argparse.Namespace, environ: Mapping[str, str]) -> RunConfig:
    timeout_seconds = int(args.timeout or environ.get("TIMEOUT", "30"))
    if timeout_seconds < 1:
        raise ValueError("timeout_seconds must be at least 1")
    return RunConfig(
        path=args.path,
        timeout_seconds=timeout_seconds,
        dry_run=args.dry_run,
    )


def main() -> None:
    args = parser.parse_args()
    config = parse_run_config(args, os.environ)
    run(config)
```

Why: CLI parsing stays at the boundary; core work receives a typed config.

## Mini Case: Service Boundary

Bad:

```python
def handle_webhook(request_json: dict[str, object]) -> Response:
    if request_json.get("event") == "invoice.paid":
        mark_invoice_paid(str(request_json["invoice_id"]))
    return Response(status=204)
```

Good:

```python
from dataclasses import dataclass
from typing import Literal


@dataclass(frozen=True)
class InvoicePaidEvent:
    event: Literal["invoice.paid"]
    invoice_id: str


def parse_invoice_paid_event(payload: dict[str, object]) -> InvoicePaidEvent:
    if payload.get("event") != "invoice.paid":
        raise ValueError("event must be invoice.paid")
    invoice_id = payload.get("invoice_id")
    if not isinstance(invoice_id, str) or not invoice_id:
        raise ValueError("invoice_id must be a non-empty string")
    return InvoicePaidEvent(event="invoice.paid", invoice_id=invoice_id)


def handle_webhook(request_json: dict[str, object]) -> Response:
    event = parse_invoice_paid_event(request_json)
    mark_invoice_paid(event.invoice_id)
    return Response(status=204)
```

Why: validation, error messages, and domain action are separate.

## Mini Case: Library Public API

Bad:

```python
# mylib/__init__.py
from .client import *
from .internal.cache import *
```

Good:

```python
# mylib/__init__.py
from .client import Client
from .errors import ClientError

__all__ = ["Client", "ClientError"]
```

Why: downstream users get a stable, intentional import surface; internals stay internal.
