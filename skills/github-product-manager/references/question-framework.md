# Uncertainty-Driven Product Questions

## Decision-Value Rule

Ask a question only when its answer can change at least one of:

- the Outcome or target user;
- the MVP/non-goal boundary;
- the success signal or Evaluation Contract;
- a high-impact constraint or irreversible action;
- whether to explore, prototype, engineer, or stop.

Do not ask merely because a template has an empty optional section.

## Goal Dimensions

| Dimension | Decision it supports | Skip when |
|---|---|---|
| Outcome | What changes for the user or system? | Never, but infer when explicit |
| User/scenario | Who experiences the value and when? | Internal mechanical work |
| Current gap | Why does current behavior miss the goal? | Brand-new capability with clear motivation |
| Success signals | What observable evidence means success? | Never |
| Non-goals/MVP | What must not expand this iteration? | Truly atomic request |
| Constraints | Compatibility, policy, performance, timing | No relevant constraint |
| Key uncertainties | What could reverse the decision? | Deterministic work |
| Evidence | How will the outcome be evaluated? | Never |
| Priority | What trade-off does urgency justify? | User already set it |

## Modes

### Direct and Sufficient

The user supplied an evaluable goal and authorized submission. State any safe
assumptions in the draft and create the Issue without another questionnaire or
preview.

### Material Gap

Ask one question at a time. Prefer options grounded in repository context when
they reduce effort, but do not force multiple choice when the user needs to
describe a novel outcome.

### Exploration

When the answer is unknowable through conversation, stop asking and create an
Exploration or Prototype profile with:

- the unknown;
- competing hypotheses;
- evidence to collect;
- pass/fail/stop conditions;
- budget or boundary.

## Assumptions

Use a safe assumption only when it is reversible and does not change user
impact. State it once. High-impact assumptions become questions or explicit
exploration hypotheses.

## Split Test

Split into child Issues when outcomes can be decided, shipped, or rejected
independently. Do not split one Outcome merely because it passes through
Explore, Prototype, Evaluate, and Engineer.

## Exit Condition

Stop clarification when the Issue can answer:

1. What result are we seeking?
2. What is outside this iteration?
3. What evidence distinguishes success, failure, and stop?
4. What is the next unresolved decision?

Continuing after these are answered is process overhead, not product discovery.
