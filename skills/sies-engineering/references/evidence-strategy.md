# SIES Evidence Strategy

## Purpose

Evaluation asks whether a direction is aligned with the goal. Regression asks
whether confirmed behavior was damaged. A test can support either question,
but the two questions must remain separate.

## Evidence Contract

Before choosing a verification activity, record the minimum useful contract:

```markdown
- Goal signal or risk:
- Decision this evidence informs:
- Cheapest credible evidence:
- Pass, fail, or stop condition:
- Persistence: disposable | regression
```

L0/L1 can hold this reasoning inline. L2/L3 should preserve it in an Issue,
plan, ADR, or PR when it affects later decisions.

## Evidence Ladder

Choose the lowest-cost level that can credibly answer the decision:

1. source/configuration inspection;
2. diff, syntax, type, lint, or static architecture check;
3. minimal runtime experiment or prototype probe;
4. focused unit, example, or contract test;
5. integration, end-to-end, visual, benchmark, or scenario evaluation;
6. repository regression.

Move upward when the cheaper level cannot observe the goal or risk. Do not use
a cheap but irrelevant check merely to report that verification happened.

## Test Strategy Gate

| Observable condition | Strategy |
|---|---|
| Goal or behavior is still disputed | Clarify and prototype before persistent tests |
| Architecture choice is uncertain | Compare spikes, benchmarks, or integration probes |
| A real bug is reproducible | Reproducer-first is usually high value; TDD may be selected |
| Stable rule or public contract is agreed | TDD, example-first, or contract-first may be selected |
| Security, migration, concurrency, or compatibility is at risk | Add early targeted tests and explicit failure cases |
| UI, UX, visual, or generative output is central | Use scenario/rubric/visual evidence; avoid brittle implementation snapshots |
| Change is deterministic and mechanical | Implement, then use the cheapest credible check |
| Coherent increment is complete | Run target tests, then one delivery regression |

TDD is selected only when a stable expected behavior can be expressed before
implementation and watching the test fail provides meaningful evidence. It is
not selected solely because the task contains code.

## Goal-Alignment Review

For every important success signal, identify at least one observable piece of
evidence. Tests written by the same agent as the implementation must anchor to
an independent source:

- user scenario or Goal Contract;
- existing public contract;
- real incident or production evidence;
- external protocol, standard, or compatibility requirement;
- approved Evaluation Contract.

If all evidence was derived from implementation details, the review is
circular even when every test passes.

## Disposable Evidence vs Regression

Prototype probes, benchmark scripts, temporary assertions, screenshots, and
manual observations can be valid disposable evidence. Promote one to the
regression suite only when it:

- protects a stable goal, contract, or real failure mode;
- would fail for the intended defect;
- has a clear and stable assertion;
- adds information not already protected;
- costs less to maintain than the risk it controls.

Remove or archive disposable probes that would otherwise become accidental
production obligations.

## Cadence

- During Explore and Prototype, run only checks that decide the next move.
- During Engineering, run focused checks when they provide new information or
  protect a high-risk boundary.
- After a coherent feature or repair batch, run its target tests.
- Before delivery, run one risk-matched regression.
- After a related fix, rerun affected checks and the delivery regression.
- Do not rerun an unchanged suite when code, configuration, dependencies,
  fixtures, environment, and relevant evidence are unchanged.

## Interpreting Failure

| Failure | Response |
|---|---|
| Prototype cannot produce the promised evidence | Change the experiment, not the pass condition |
| Tests pass but user scenario fails | Evaluation fails; revisit Goal, Explore, or Prototype |
| A test fails for an unrelated implementation detail | Repair or remove the brittle test |
| Regression reveals a real compatibility break | Diagnose, fix, and rerun affected evidence |
| Evidence is inconclusive | Refine the threshold or collect a stronger signal; do not declare success |
