# SIES Engineering Implementation Plan

> **Execution:** Implement inline in the current session. Do not dispatch
> subagents or stop for per-task review. Complete the coherent documentation
> and skill batch before running regression.

**Goal:** Make SIES the default Devkit engineering sequence and convert the
GitHub skills from fixed workflows into adaptive goal-and-evidence tools.

**Architecture:** Add one `sies-engineering` orchestrator with focused
references for evidence strategy and GitHub state. Route `using-dev` through
it, then reshape the three GitHub skills around Goal Contracts, Evaluation
Contracts, resumable phase state, and risk-based verification.

**Tech Stack:** Agent Skills Markdown, GitHub CLI guidance, Bash repository
validation.

**Design:** `docs/superpowers/specs/2026-07-28-sies-engineering-design.md`

## Global Constraints

- SIES is the default sequence for L0–L3; levels change depth, not philosophy.
- Tests verify goal alignment, stable contracts, and real risks.
- TDD is an optional nested Engineering strategy, never the default lifecycle.
- Existing GitHub safety rules for trusted issue numbers and body files remain.
- User authorization may compress ceremony but cannot erase the minimum goal
  and delivery evidence.
- Do not modify third-party cached skills.
- Run one repository regression after the complete implementation batch.

## File Map

| File | Responsibility |
|---|---|
| `skills/sies-engineering/SKILL.md` | Default SIES lifecycle and phase decisions |
| `skills/sies-engineering/references/evidence-strategy.md` | Evaluation, testing, TDD selection, and test promotion |
| `skills/sies-engineering/references/github-state.md` | GitHub Goal Contract, phase records, and recovery |
| `skills/using-dev/SKILL.md` | Repository entry point and SIES routing |
| `skills/using-dev/references/level-decision.md` | L0–L3 depth scaling |
| `skills/using-dev/references/orchestration-cheatsheet.md` | Adaptive scenario routing |
| `skills/using-dev/references/system-learning.md` | Evidence-based learning promotion |
| `skills/github-product-manager/SKILL.md` | Adaptive product Goal Contract discovery |
| `skills/github-product-manager/references/question-framework.md` | Uncertainty-driven questions |
| `skills/github-product-manager/references/issue-template.md` | Product Goal Contract profile |
| `skills/github-create-issue/SKILL.md` | Issue profile selection and safe creation |
| `skills/github-create-issue/references/issue-profiles.md` | Goal, exploration, prototype, engineering, and learning profiles |
| `skills/github-issue-workflow/SKILL.md` | Phase-aware issue controller |
| `skills/github-issue-workflow/references/issue-sources.md` | SIES contract detection and recovery fields |
| `AGENTS.md` | Repository-wide SIES constitution |
| `README.md` | Public discovery and conceptual overview |
| `skills/using-devkit/SKILL.md` | In-agent skill discovery |

`skills/using-dev/references/postmortem.md` is removed after its useful
learning rules are replaced by `system-learning.md`.

## Task 1: Add the SIES Core Skill

**Files:**

- Create `skills/sies-engineering/SKILL.md`
- Create `skills/sies-engineering/references/evidence-strategy.md`
- Create `skills/sies-engineering/references/github-state.md`

**Deliverable:**

- Define Goal → Exploration → Prototype → Evaluation → Refinement →
  Engineering → Regression → Learning.
- Define phase compression for small deterministic work.
- Define decision outcomes: continue, refine, return, or stop.
- Keep detailed test strategy and GitHub formats out of the main skill.

## Task 2: Make SIES the Default Development Entry

**Files:**

- Modify `skills/using-dev/SKILL.md`
- Modify `skills/using-dev/references/level-decision.md`
- Modify `skills/using-dev/references/orchestration-cheatsheet.md`
- Delete `skills/using-dev/references/postmortem.md`
- Create `skills/using-dev/references/system-learning.md`
- Modify `AGENTS.md`

**Deliverable:**

- Route all development requests through `sies-engineering`.
- Use L0–L3 only to scale artifacts, GitHub persistence, risk work, and ADRs.
- Remove fixed superpowers pipelines and mandatory per-change review agents.
- Preserve language-specific coding guidance.
- Establish goal alignment and evidence value as the project constitution.

## Task 3: Rework GitHub Issue Authoring

**Files:**

- Modify `skills/github-product-manager/SKILL.md`
- Modify `skills/github-product-manager/references/question-framework.md`
- Modify `skills/github-product-manager/references/issue-template.md`
- Modify `skills/github-create-issue/SKILL.md`
- Create `skills/github-create-issue/references/issue-profiles.md`

**Deliverable:**

- Replace mandatory questionnaires with questions driven by unresolved
  decisions.
- Replace “everything must be testable” with evaluable success signals and an
  explicit evidence plan.
- Select an Issue Profile from task purpose instead of forcing one template.
- Preserve safe `gh issue create --body-file` execution.
- Allow direct creation without duplicate preview when the user has already
  authorized it.

## Task 4: Rework GitHub Issue Execution

**Files:**

- Modify `skills/github-issue-workflow/SKILL.md`
- Modify `skills/github-issue-workflow/references/issue-sources.md`

**Deliverable:**

- Detect current SIES state from issue body, comments, PRs, and linked work.
- Resume from the first unresolved decision instead of restarting a fixed
  pipeline.
- Allow Evaluation to return to Exploration or Prototype.
- Create branches only when code work begins.
- Choose worktree and review depth from risk and workspace state.
- Preserve trusted issue-number handling, body-file safety, traceability, and
  delivery regression.

## Task 5: Update Discovery and Public Documentation

**Files:**

- Modify `skills/using-devkit/SKILL.md`
- Modify `README.md`

**Deliverable:**

- List `sies-engineering`.
- Describe `using-dev` as the default SIES entry.
- Replace old fixed GitHub workflow descriptions with adaptive behavior.
- Add a concise SIES overview and skill tree entries.

## Task 6: Batch Verification and Delivery

**Checks:**

1. Scan changed skill text for stale fixed-flow rules and contradictory
   blanket TDD requirements.
2. Run official `quick_validate.py` against `sies-engineering`.
3. Run `npm test` once for repository metadata, references, scripts, and
   discovery.
4. Run `git diff --check`.
5. Review the complete diff against the design acceptance criteria.
6. Commit the coherent implementation batch to `main`.

No per-file regression or repeated unchanged suite is part of this plan.
