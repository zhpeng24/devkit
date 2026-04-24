# Anti-Patterns

These are not style preferences. Seeing one means stop and improve the shape before continuing, unless the current task is explicitly a temporary spike.

## Raw Shape Pipeline

Bad signal:

- Core functions pass `dict[str, object]`, JSON blobs, database rows, or SDK responses through multiple layers.
- Callers need to know hidden keys or value types.
- The same shape is checked in several places.

Stop and:

- Parse at the boundary.
- Name the shape with dataclass, TypedDict, enum/Literal, or value object.
- Pass the named shape through core logic.

## Utility Dump

Bad signal:

- `utils.py`, `helpers.py`, `common.py`, or `misc.py` grows unrelated functions.
- A helper has no obvious owning module.
- Developers must search globally to find where a concept lives.

Stop and:

- Move the helper next to the domain that owns it.
- Rename the module around the concept.
- Keep generic helpers private and tiny when unavoidable.

## Comment-Driven Code

Bad signal:

- Comments explain normal control flow.
- Every branch needs a note to be understood.
- Comments and code can drift apart.

Stop and:

- Rename variables and functions.
- Extract named predicates or steps.
- Keep comments only for constraints, tradeoffs, external quirks, or non-obvious reasons.

## Test Wall

Bad signal:

- Test setup is larger than the behavior signal.
- Tests copy the same construction details repeatedly.
- Tests assert private helper calls or internal order instead of outcomes.
- Adding a small feature requires editing many brittle tests.

Stop and:

- Add fixtures, builders, or scenario helpers.
- Test public behavior and boundary effects.
- Keep one test focused on one behavior.

## Premature Framework

Bad signal:

- A registry, base class hierarchy, plugin layer, manager, or service abstraction has one real caller.
- Names are generic before the domain needs them.
- The abstraction hides a simple if/else or direct function call.

Stop and:

- Inline simple behavior or use a local helper.
- Wait for real repetition or boundary pressure.
- Prefer concrete names over generic framework names.

## Boolean Flag Tangle

Bad signal:

- One function accepts several flags that steer different workflows.
- Callers pass combinations whose meaning is unclear.
- Tests multiply around flag combinations.

Stop and:

- Split workflows into named functions.
- Use a dataclass or Literal mode for one coherent variation.
- Make invalid combinations impossible.

## Hidden Global State

Bad signal:

- Importing a module registers handlers, mutates global config, starts work, or changes process state.
- Tests depend on execution order.
- Behavior changes based on previous calls.

Stop and:

- Use explicit construction or registration.
- Pass dependencies as parameters or objects.
- Reset state at boundaries when global state is unavoidable.

## Type Theater

Bad signal:

- Annotations are present but mostly `Any`, bare containers, or aliases for vague data.
- `cast()` and suppressions hide uncertainty.
- Runtime shape and type annotations disagree.

Stop and:

- Name real data shapes.
- Narrow at the source.
- Remove broad suppressions.
- Make annotations describe design, not silence tools.

## Architecture By Directory

Bad signal:

- Folders named `services`, `managers`, `core`, or `common` contain unrelated concepts.
- Layer names exist but dependency direction is unclear.
- Moving code into folders made navigation harder.

Stop and:

- Organize around concepts and boundaries.
- Keep layer names only when they describe real ownership.
- Prefer fewer modules with clear names over many ceremonial folders.
