# Review Checklist

Use before claiming Python work is complete.

## Return-To-Work Gates

If any item is true, keep working before delivery:

- Core logic still receives raw unvalidated `dict` / `object` payloads.
- New behavior is hidden behind an abstraction with only one real caller.
- A public or non-trivial function lacks useful parameter or return types.
- A comment explains ordinary control flow that could be named instead.
- A test has more irrelevant setup than behavior signal.
- A bug fix has no regression check and no explicit reason why not.
- A suppression is broad or lacks a specific code.
- Verification was skipped because the change "looks small".

## Readability

- Can the main behavior be understood without reading unrelated files?
- Do names use domain language instead of vague placeholders?
- Is the happy path visible?
- Are comments explaining constraints or tradeoffs, not narrating ordinary code?
- Did any new abstraction earn its place?

## Structure

- Does each module have a clear owner?
- Are helpers close to the concept that owns them?
- Is raw input parsed at boundaries before entering core logic?
- Are public APIs intentional and documented when needed?
- Is library public surface protected separately from internal imports?

## Types

- Are public and non-trivial functions annotated?
- Do structured values have named shapes: dataclass, TypedDict, Protocol, Literal, enum, or value object?
- Is `Any` avoided unless the value is genuinely unconstrained?
- Are suppressions specific and justified?
- Are optional values narrowed before use?

## Tests

- Do tests protect behavior rather than private implementation?
- Is setup smaller than the assertion story?
- Are mocks limited to hard boundaries?
- Are fixtures/builders hiding only irrelevant construction detail?
- Did bug fixes add or update a regression check when practical?

## Verification

- Did you use the project's native runner?
- Did targeted verification cover the changed behavior?
- Did shared/public behavior get broader tests?
- If a tool could not run, is the reason and fallback explicit?
