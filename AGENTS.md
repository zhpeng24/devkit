# Devkit

## Development constitution

- SIES is the default engineering sequence: Goal → Explore → Prototype →
  Evaluate → Refine → Engineer → Regress → Learn.
- Scale or merge SIES phases for small deterministic work; do not replace the
  sequence with a different ceremony for each complexity level.
- Measure progress by goal alignment and closed uncertainty, not by test count,
  coverage theater, review count, or completed workflow steps.
- Testing is evidence for user goals, stable contracts, and real risks. TDD is
  an optional Engineering strategy, not the default lifecycle for every code
  change.
- A passing test suite does not prove success when the Goal Contract or user
  scenario is unmet.
- Every persistent test must protect an observable success signal, stable
  contract, or real failure mode and fail when that behavior breaks.
- During Explore and Prototype, run only checks that answer the current
  decision. Do not prematurely turn disposable probes into regression tests.
- Finish a coherent feature or repair batch before target regression; run the
  broader project regression once before delivery.
- Do not rerun an unchanged suite when relevant code, configuration,
  dependencies, fixtures, environment, and evidence have not changed.
- Move tests earlier for justified risk such as bug reproduction, security,
  migration, concurrency, public API compatibility, or cross-platform behavior.
- GitHub stores goals, evidence, decisions, and delivery links; it is not a
  fixed linear workflow engine.
- Batch documentation, skill, and metadata edits before validation. Do not
  start a full regression or independent review for every edited file.
- Promote a process learning only when repeated evidence, a high-impact event,
  a substantially better method, or explicit user direction justifies it.
