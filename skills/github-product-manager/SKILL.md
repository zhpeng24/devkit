---
name: github-product-manager
description: Use when a user describes a product requirement, feature idea, user need, or ambiguous outcome that should be clarified, evaluated, or persisted in GitHub.
---

# Product Goal Discovery

Turn product intent into a SIES Goal Contract and, when authorized, a GitHub
Issue. The purpose is to close decisions that matter, not to complete a fixed
questionnaire.

This skill does not design architecture or implement code.

## Start With Existing Evidence

Read only the context needed to understand the request:

- user-provided goals and examples;
- relevant README, product docs, code paths, issues, and recent decisions;
- existing Goal Contract, if one already exists.

Do not scan the whole repository, list every PR, or ask the user to reconfirm
facts that are already reliable. Summarize assumptions only when a wrong
assumption would change scope or success.

## Build the Decision Map

Read `references/question-framework.md`. Classify each Goal Contract field as:

- **known** — supported by the request or repository evidence;
- **safe assumption** — low-impact and reversible; state it briefly;
- **blocking unknown** — the answer changes outcome, scope, evaluation, or an
  irreversible action.

Ask one concise question only for a blocking unknown. If the contract is already
evaluable, draft it immediately.

## Goal Contract

Read `references/issue-template.md` and capture:

- Outcome and affected users or systems;
- success signals;
- non-goals and MVP boundary;
- constraints and impact;
- key uncertainties;
- Evaluation Contract: decision, evidence, and pass/fail/stop conditions.

Success signals must be observable but do not all need to be automated tests.
Use user scenarios, runtime behavior, metrics, visual evidence, contracts, or
tests according to the goal.

## Choose the Next Artifact

| Current state | Next artifact |
|---|---|
| Goal is clear and Engineering can start | Product Goal / Engineering Issue |
| A product or technical assumption still dominates risk | Exploration or Prototype Issue |
| Evidence is already sufficient | Decision record or implementation handoff |
| Outcome is not worth pursuing | Stop decision; do not manufacture an Issue |

Use `github-create-issue` for profile selection and safe submission.

## Authorization and Preview

- If the user explicitly asks to create/submit the Issue or says to proceed
  directly, that is submission authorization. Do not add a duplicate preview
  gate.
- If the user asks only to analyze, draft, or discuss, return a draft without
  changing GitHub.
- If a blocking unknown remains, ask before submission even when creation was
  requested; do not invent a high-impact product decision.
- When showing a preview would expose a material assumption, preview that
  assumption and the affected section rather than replaying the entire process.

## Submission

Before submission:

1. Check for a substantially overlapping open Issue.
2. Confirm the Issue has one primary Outcome; use a tracking Issue when one
   Outcome legitimately spans exploration and Engineering.
3. Select type/priority labels and a SIES profile.
4. Pass the body through a temporary file to `gh issue create --body-file`.
5. Return the created URL and state which decision or phase comes next.

## Stop Signals

- Success cannot be observed even with a proxy signal;
- different user outcomes have been bundled into one deliverable;
- a risky assumption is being presented as a known fact;
- acceptance is defined only as “tests pass” without a user or system outcome;
- clarification is continuing even though no unanswered question can change the
  Issue.
