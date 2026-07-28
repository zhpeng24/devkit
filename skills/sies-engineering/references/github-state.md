# GitHub as SIES State

## Role

GitHub stores recoverable goals, decisions, evidence, and delivery links. It is
not a linear workflow engine. A label or checked box helps navigation but does
not prove a phase is complete.

## Capability Modes

| Mode | Storage |
|---|---|
| GitHub repository + authenticated `gh` | Issue body, comments, linked branches, PR, ADR |
| GitHub repository without usable `gh` | Local branch/commit plus prepared Issue or PR text |
| No GitHub remote | Local plan, ADR, commit, and delivery summary |

Tool availability changes persistence, not the SIES reasoning contract.

## Goal Contract

Use the smallest version that preserves decisions:

```markdown
## SIES Goal Contract
- Outcome:
- Success signals:
- Non-goals:
- Constraints:
- Key uncertainties:

## Evaluation Contract
- Decision to make:
- Evidence:
- Pass / fail / stop conditions:
```

Add user scenarios, impact, scope, links, or rollout details only when they
change the decision or make future recovery materially safer.

## Phase Records

Preserve material transitions as comments or linked documents:

```markdown
## SIES: <Explore | Prototype | Evaluate | Refine | Engineer | Regress | Learn>
- Question or decision:
- Evidence:
- Result:
- Next state:
```

Do not post a comment merely to announce that a step happened. Record evidence,
a changed decision, a remaining risk, or a handoff another person needs.

## Resume Algorithm

1. Read the Issue body and recent material comments.
2. Inspect linked PRs, branches, ADRs, prototypes, and test evidence.
3. Compare existing evidence with the Goal and Evaluation Contracts.
4. Find the first decision that remains unsupported.
5. Resume there; do not repeat earlier questions, experiments, or unchanged
   tests.

If the Goal Contract changed, explicitly mark superseded evidence instead of
silently treating it as current.

## Issue and Branch Boundaries

- One tracking Issue may span the SIES loop when one outcome owns the work.
- Create child Issues only for independently decidable, shippable, or parallel
  work.
- An exploration Issue may finish with a rejected option or stop decision.
- Create a branch only when a prototype or Engineering step changes files.
- A disposable prototype does not require a production PR.
- A production PR starts after Refinement selects an Engineering direction.

Use `sies` and one current-phase label when the repository benefits from
queries. Labels are optional and must not cause phase-churn work without value.

## PR Evidence

A production PR should make these relationships recoverable:

- Goal signal → implemented behavior;
- selected option → Evaluation evidence;
- risk or contract → persistent test or other verification;
- coherent increment → target tests and delivery regression;
- unresolved limitation → follow-up or explicit acceptance.

Do not copy the entire Issue into the PR. Link it and summarize the decisions
that a reviewer needs.

## Learning Candidate

Create one only for a repeated failure, high-impact systemic gap, substantially
better method, or explicit request. Record:

- observation and evidence;
- affected class of work;
- proposed change to a skill, instruction, automation, or template;
- expected benefit and possible downside.

Do not mutate shared process rules automatically. Open the candidate for review
unless the user already authorized that system change.
