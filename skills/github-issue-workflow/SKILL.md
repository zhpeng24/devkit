---
name: github-issue-workflow
description: Use when pulling GitHub issues and developing them end-to-end — triage, develop, review, ship. Triggers on "处理 issue", "拉取 issue", "develop issues", "work on issues", "close issues".
---

# GitHub Issue Workflow

Pull → Triage → Develop → Review → Ship. Every issue goes through the full cycle. **No shortcut from "tests pass" to "commit".**

## Workflow

### 1. Triage

```bash
gh issue list --state open --json number,title,labels,body
```

For each issue, identify affected files/modules. Classify overlap:

| Overlap | Strategy |
|---------|----------|
| No shared files | Parallel subagents |
| Shared files | Sequential, dependency-first |
| Unsure | Read both issues' code scope, then decide |

Priority order: `bug` > `architecture` > `tech-debt` > `optimization` > `innovation`.

### 2. Plan

| Issue count | Branch strategy |
|-------------|----------------|
| 1 issue | `fix/issue-N` or `feat/issue-N` |
| 2-5 related issues | One branch `fix/issues-N-M` or topical name |
| Unrelated issues | Separate branches per issue (enables independent PRs) |

- Create TodoWrite with one item per issue

### 3. Develop

Each implementation MUST:

1. Read affected code before editing
2. Make changes
3. Run relevant tests (`pytest tests/ -v --tb=short`) — document any exclusions with reason in commit body
4. Verify architecture guard tests pass (`pytest tests/test_architecture.py`)

**Parallel** (independent issues): dispatch subagent per issue — recommended for 2+ issues with no shared files.
**Sequential** (dependent issues): implement in priority order in main workspace. Never parallelize shared-file issues.

### 4. Review

**MANDATORY — do NOT skip even if all tests pass.**

Dispatch `code-reviewer` subagent with:
- Git diff of all changes (`git diff HEAD~1` or `git diff main...HEAD`)
- Original issue requirements (paste issue body)
- Architecture invariants

Fix critical/important findings. Re-run tests after fixes.

### 5. Ship

```bash
# One commit per logical group — reference specific issues
git commit -m "fix: description

Closes #N, closes #M"

# Push + PR (preferred) or push + close
git push -u origin HEAD
gh pr create --title "..." --body "..."
# OR for direct-push workflows:
gh issue close N --comment "Fixed in <sha>: <summary>"
```

## Commit Discipline

| Rule | Why |
|------|-----|
| One commit per logical group | Enables per-issue revert |
| Message references issue numbers | Traceability |
| Document excluded tests in commit body | Future debugging |
| Never mix unrelated issues in one commit | Clean history |

## Red Flags — STOP

- About to commit without code review → dispatch `code-reviewer` first
- About to parallelize issues that share files → switch to sequential
- About to skip tests "because only docs changed" → run them anyway
- Rationalizing "review is overkill for small changes" → it's not

## Common Rationalizations

| Excuse | Reality |
|--------|---------|
| "Tests pass, no need for review" | Tests verify behavior; review catches design issues, path errors, missing edge cases |
| "These issues are small, one commit is fine" | Small issues become unrevertable when bundled |
| "I'll review after pushing" | Post-push review creates pressure to not fix findings |
| "Parallel is always faster" | Parallel on shared files = merge conflicts = slower |
