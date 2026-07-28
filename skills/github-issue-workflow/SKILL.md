---
name: github-issue-workflow
description: Use when working on one or more existing GitHub issues in a repository and the agent must recover goals, evidence, decisions, implementation state, or delivery work.
---

# Phase-Aware GitHub Issue Workflow

Treat an Issue as recoverable SIES state, not a ticket that must replay a fixed
Pull → Triage → Develop → Review → Ship ritual.

Read `references/issue-sources.md` before deciding where to resume.

## Capability and Target Safety

Check repository, remote, authentication, current branch, and workspace:

```bash
git rev-parse --git-dir 2>/dev/null
git remote -v
gh auth status 2>&1
git branch --show-current
git status --short
```

For comments, labels, links, or close operations:

- obtain the number from user-provided digits or structured `gh` JSON;
- validate `[[ "$issue_number" =~ ^[0-9]+$ ]]`;
- never parse a target from title, body, branch text, or generated Markdown;
- pass multi-line content through `--body-file`;
- comment first, then close by validated number.

GitHub unavailability changes persistence, not the Goal/Evidence contract.

## Recover SIES State

Use structured data and read only material history:

```bash
gh issue view <N> \
  --json number,title,body,labels,state,comments,assignees,projectItems
```

Then:

1. Extract or derive the Goal Contract.
2. Find the current Evaluation Contract and linked evidence.
3. Inspect relevant linked PRs, branches, ADRs, incidents, and prototypes.
4. Mark evidence superseded by later Goal changes.
5. Resume at the first decision that lacks sufficient evidence.

Do not restart clarification, rerun unchanged tests, or recreate an artifact
whose decision is already supported.

## State Controller

| Unsupported decision | Resume at | Useful output |
|---|---|---|
| Outcome or success signal | Goal | Updated contract or one blocking question |
| Technical/product direction | Explore | Candidate comparison and evidence plan |
| Feasibility/integration/performance | Prototype | Minimal artifact and observations |
| Whether evidence supports continuation | Evaluate | Pass, fail, inconclusive, or stop |
| Which direction to adopt | Refine | Decision, remaining risks, ADR when important |
| How to produce and ship selected behavior | Engineer | Production changes and verification map |
| Whether confirmed behavior remains intact | Regress | Target and delivery regression evidence |
| Whether experience should change the system | Learn | Learning Candidate or no action |

Evaluation may return to Explore or Prototype. A valid stop or rejected option
can complete an Issue without code.

## Multiple Issues

Prioritize by user impact/priority, dependency, risk, and evidence readiness.
Parallelize only independently decidable work with no shared state. Shared
files, contracts, migrations, or unresolved parent decisions stay sequential.

Do not split one Outcome merely because it has several SIES phases.

## Workspace and Branch

Create a branch only when files will change.

| Condition | Default |
|---|---|
| User explicitly chose current/main branch | Respect it |
| Clean workspace, one reversible task | Current workspace |
| Unrelated user changes, high-risk experiment, or parallel work | Isolated worktree |
| Exploration without file changes | No branch |
| Disposable code prototype | Temporary or clearly marked branch; no production PR required |

When Full GitHub mode benefits from Development linking, use
`gh issue develop <N> --base <default> --name <branch> --checkout`. In degraded
mode use the same naming/traceability locally.

Do not ask a worktree question when the user already authorized direct
execution and the choice can be made safely from these signals.

## Execute the Current Decision

### Explore / Prototype / Evaluate

- Define the question before producing an artifact.
- Use the cheapest credible evidence.
- Keep disposable work visibly separate from production obligations.
- Record a material transition only when it changes the decision, remaining
  risk, or handoff.

### Engineer

- Read the selected direction, scope, contracts, and Evaluation evidence.
- Implement one coherent logical increment.
- Use repository-native language and formatting rules.
- Choose tests through the SIES Test Strategy Gate.
- Promote only stable, non-duplicative tests to the regression suite.
- Keep unrelated refactors and speculative features out.

### Review

Always inspect the complete diff against the Goal Contract and selected
direction. Use local review by default. Add an independent reviewer only for
large/high-impact changes, security, migration, public contracts, cross-service
work, or explicit user request.

Tests passing cannot replace goal/scope review.

### Regress

- Run focused checks during work only when they answer a live question.
- Run target tests after the coherent increment.
- Run one risk-matched delivery regression.
- If a related fix changes evidence inputs, rerun affected checks and delivery
  regression; never repeat an unchanged suite for ceremony.

## Ship or Stop

A production PR should link:

- Goal signal → implemented behavior;
- selected option → Evaluation evidence;
- risk/contract → test or other verification;
- coherent increment → regression result;
- unresolved limitation → accepted risk or follow-up.

Use `Closes #N` only when the Outcome is actually complete. Use `Refs #N` for
prototypes, partial Engineering, or evidence that should not close the Issue.

For direct close:

```bash
issue_number="${ISSUE_NUMBER:?set from trusted structured data}"
[[ "$issue_number" =~ ^[0-9]+$ ]] || exit 1

comment_file="$(mktemp)"
trap 'rm -f "$comment_file"' EXIT

cat >"$comment_file" <<'EOF'
## SIES: Regress
- Goal evidence:
- Regression:
- Remaining risk:
EOF

gh issue comment "$issue_number" --body-file "$comment_file"
gh issue close "$issue_number" --reason completed
```

A stop/reject outcome should record evidence and close with the repository's
appropriate reason; do not claim implementation success.

## Red Flags

- Restarting a fixed workflow without reading existing evidence;
- creating a branch before any file-changing decision;
- treating labels or checked boxes as proof;
- forcing an Exploration Issue to contain production-ready implementation;
- assuming a passing suite proves the Outcome;
- fixing an invalidated solution instead of returning to Explore/Prototype;
- mandatory review-agent or worktree questions without a risk signal;
- posting phase comments that contain no decision, evidence, or handoff;
- closing a tracking Issue when only a prototype or partial increment exists.
