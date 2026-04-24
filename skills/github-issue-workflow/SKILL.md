---
name: github-issue-workflow
description: Use when working on one or more existing GitHub issues in a repository.
---

# GitHub Issue Workflow

Pull → Triage → Develop → Review → Ship. Every issue goes through the full cycle. **No shortcut from "tests pass" to "commit".**

仓库内 issue 可能来自 `github-create-issue`（工程类）或 `github-product-manager`（PM 类），两套模板与标签不同。**Triage 前先读 `references/issue-sources.md` 识别来源**，按对应模板字段提取实现依据。

## Capability Modes

Check capabilities before planning:

```bash
git rev-parse --git-dir 2>/dev/null
git remote -v | grep -E "github\.com"
gh auth status 2>&1
```

| Mode | Conditions | Behavior |
|---|---|---|
| Full GitHub | git repo + GitHub remote + `gh` auth | Use `gh issue develop`, push branch, open PR |
| GitHub degraded | GitHub remote but `gh` unavailable/unauthenticated | Use local branch, reference issue in commits/PR body, tell user which `gh` action was skipped |
| Local fallback | No GitHub remote | Use local branch/commit discipline; keep issue references in text only |

If a review agent or subagent is unavailable, use the local review checklist in the Review phase. Tool unavailability changes the route, not the quality bar.

## Workflow

### 1. Triage

```bash
gh issue list --state open --json number,title,labels,body
```

For each issue：
- 按 `references/issue-sources.md` 判定来源（PM vs 工程）
- 找出受影响的文件/模块
- 评估与其他 issue 的文件重叠

**Overlap 判定：**

| Overlap | Strategy |
|---------|----------|
| No shared files | Parallel work if the platform/user allows it; otherwise sequential |
| Shared files | Sequential, dependency-first |
| Unsure | Read both issues' code scope, then decide |

**优先级排序（先 P 标签，后类型）：**

1. 优先使用 P0-P3 标签：`P0-critical` > `P1-important` > `P2-normal` > `P3-nice-to-have`
2. 无 P 标签时回退到类型优先级：`bug` > `architecture` > `security` > `tech-debt` > `feature` > `enhancement` > `optimization` > `ux` > `innovation` > `documentation`
3. 同优先级下，标 `needs-design` 的 PM issue 应延后（缺少设计无法直接实现）

### 2. Plan

| 场景 | Branch 策略 |
|------|------------|
| 1 issue | 工程类 `fix/issue-N`；PM 类 `feat/issue-N` |
| 2-5 related issues | 单 branch，topical 命名 |
| Unrelated issues | 每 issue 一个 branch（独立 PR） |

- Create TodoWrite，**一个 issue 一项**
- **PM issue 拆分**：feature 类范围较大，先按 body 中的 `MVP 定义` 切成最小切片，每片在 TodoWrite 中作为子项；后续迭代部分作为 follow-up issue 记录而不是塞进当前 PR

#### 2.1 创建分支并关联 issue（Full GitHub mode）

**用 `gh issue develop` 而不是 `git checkout -b`** —— 它会同时建分支、推到 remote、并把分支挂到 issue 的 Development 面板，PR 合入时 GitHub 会自动关闭 issue。

```bash
# 单 issue：建分支并 checkout，自动关联到 issue #N 的 Development
gh issue develop <N> --base main --name fix/issue-<N> --checkout
# PM 类把前缀改成 feat/issue-<N>

# 多 issue 共用一个 topical 分支：先用主 issue 建分支，其余 issue 复用同一分支名追加关联
gh issue develop <N1> --base main --name <topical-branch> --checkout
gh issue develop <N2> --name <topical-branch>   # 不带 --checkout，仅追加关联
gh issue develop <N3> --name <topical-branch>

# 校验关联是否生效
gh issue develop <N> --list
```

注意：
- `--name` 必须传，否则 GitHub 会按 issue title 生成默认名，不符合命名规范
- `--base main` 显式指定基线，避免从当前分支拉错
- 分支已存在时再次执行 `gh issue develop <N> --name <existing>` 只追加关联，不会重建分支
- 如果忘了用 `gh issue develop`，已经用 `git checkout -b` 建好的分支可补关联：`gh issue develop <N> --name <existing-branch>`

**Degraded/local fallback:** create a branch with the same naming convention (`fix/issue-N`, `feat/issue-N`, or topical name), then keep `Closes #N` / `Refs #N` in commit and PR text. Document that GitHub Development linking was unavailable.

### 3. Develop

每个 implementation MUST：

1. **读 issue body**，按来源提取实现依据（字段对照见 `references/issue-sources.md`）
2. Read affected code before editing
3. Make changes（PM 类严格只实现 MVP 范围内的能力；超出部分留 follow-up）
4. Run relevant tests using the project's native runner — document any exclusions with reason in commit body
5. Verify architecture guard tests pass if they exist
6. 逐条对照 `验收标准` checklist 自检

Python projects: use `friendly-python/references/project-workflow.md` to choose `uv run pytest`, `poetry run pytest`, `python -m pytest`, tox, nox, or fallback syntax checks.

**Parallel** (independent issues): dispatch separate workers only when the platform and user allow it; otherwise keep sequential.
**Sequential** (dependent issues): implement in priority order in main workspace. Never parallelize shared-file issues.

### 4. Review

**MANDATORY — do NOT skip even if all tests pass.**

Preferred: dispatch a review agent with：
- Git diff (`git diff HEAD~1` or `git diff main...HEAD`)
- Original issue body（完整粘贴）+ 来源对应的关键字段（见 `references/issue-sources.md` 的 "Code Review 上下文"）
- Architecture invariants

If no review agent is available, perform local review:

- Diff matches the issue scope and MVP only
- Acceptance criteria are all checked
- Tests or documented verification cover the changed behavior
- No unrelated refactors, formatting churn, secrets, debug logs, or broad suppressions
- Public API, migration, and packaging changes are documented

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

Degraded/local fallback: if push or `gh pr create` is unavailable, leave the branch ready locally and report the exact command the user should run.

PM 类 issue 关闭时，若仅完成 MVP，需在 close comment 中列出延后到 follow-up issue 的项目并附 issue 号。

## Commit Discipline

| Rule | Why |
|------|-----|
| One commit per logical group | Enables per-issue revert |
| Message references issue numbers | Traceability |
| Document excluded tests in commit body | Future debugging |
| Never mix unrelated issues in one commit | Clean history |
| PM issue 仅实现 MVP，超出部分另开 issue | 防止 PR 无限膨胀 |

## Red Flags — STOP

- About to commit without review → run review agent or local review checklist first
- About to parallelize issues that share files → switch to sequential
- About to skip tests "because only docs changed" → run them anyway
- 用 `git checkout -b` 直接建分支，没走 `gh issue develop` → 分支不会出现在 issue Development 面板，补一次 `gh issue develop <N> --name <branch>` 关联
- Rationalizing "review is overkill for small changes" → it's not
- 用类型直觉处理 PM issue（忽略 P0-P3 标签）→ 回到 Triage 重新排序
- PM issue 实现超出 `MVP 定义` 范围 → 砍掉超出部分，开 follow-up issue
- 开发前没读 `用户场景` / `预期行为` 直接写代码 → 大概率走偏，停下来先读 issue body

## Common Rationalizations

| Excuse | Reality |
|--------|---------|
| "Tests pass, no need for review" | Tests verify behavior; review catches design issues, path errors, missing edge cases |
| "These issues are small, one commit is fine" | Small issues become unrevertable when bundled |
| "I'll review after pushing" | Post-push review creates pressure to not fix findings |
| "Parallel is always faster" | Parallel on shared files = merge conflicts = slower |
| "PM issue 写得很清楚，不用再读 body" | 模板字段（用户场景/MVP）就是实现的边界，跳过 = 范围失控 |
| "P3 也很简单，先做完算了" | 低优先级先做会挤占 P0/P1 时间窗口，按标签排 |
| "PM 模板字段太多，挑重要的看就行" | `验收标准` 必读，`用户场景` / `MVP 定义` 是判定"做对没/做多了没"的唯一依据 |
| "`git checkout -b` 也能建分支，何必用 `gh issue develop`" | 前者不写入 issue Development 面板，issue 与分支失去自动追溯；PR 合入时也不会自动 close issue |
| "`gh` 不可用，所以 issue 流程做不了" | 降级到本地分支与 commit traceability；质量门禁仍保留 |
