---
name: using-dev
description: "Developer entry-point. Auto-trigger when the user asks to write, change, fix, refactor, debug, optimize, or implement code. Common phrases: 写需求、改 bug、修复、新功能、加个功能、重构、优化、debug、实现、开发、做个功能、write feature、fix bug、refactor、implement、build feature. Explicit commands: 开干、走完整开发流程、/dev. Detects task level (L0-L3) and orchestrates friendly-python, github-create-issue, github-issue-workflow, brainstorming, writing-plans, executing-plans, architecture-designer, self-improving. Do NOT trigger for read-only questions like 解释这段代码 / 看 X 是什么 / 这个函数干嘛的."
---

# Using Dev

开发总入口——根据任务复杂度（L0-L3）编排 `friendly-*`、`github-*`、superpowers 系列子 skill。覆盖从"改 typo"到"架构级新功能"的全光谱开发场景。

> 这是一个**编排者**，不直接编码、不直接发 issue。它的工作是：识别任务、判定等级、按剧本调用合适的子 skill。

## 触发与开场

### 三类触发路径

| 类型 | 触发 | 示例 |
|------|------|------|
| 关键词自动触发 | description 中的任意开发动词 | "帮我修个 bug"、"加个功能 X"、"重构这个模块" |
| 显式口令 | "开干"、"走完整开发流程"、"/dev" | "开干，做用户登录" |
| ❌ 不触发 | 纯只读 / 解释 / 询问 | "解释这段代码"、"X 是什么意思"、"这个函数干嘛的" |

### 开场固定 5 步

被唤醒后**永远先走完这 5 步**，再动手：

1. **检测语言**：扫描 `pyproject.toml` / `package.json` / `go.mod` / `Cargo.toml` / 源码后缀，决定挂哪个 `friendly-*`（详见 `references/language-stack.md`）
2. **检测 Repo**：
   ```bash
   git rev-parse --git-dir 2>/dev/null      # 在 git 仓库内？
   git remote -v | grep -E "github\.com"    # GitHub remote？
   gh auth status 2>&1                       # gh 登录可用？
   ```
3. **判定等级 L0-L3**：依据用户原话 + `git status` + 改动信号（详见 `references/level-decision.md`）
4. **一句话向用户确认**，模板：
   > 识别到 [bug 修复 / 新功能 / 重构 / ...]，建议按 **L[N]** 流程推进（[Python] 项目，[已检测到 / 未检测到] GitHub remote）。可以吗？想升到 L[N+1] / 降到 L[N-1] / 跳过 issue 直接改？
5. **用户确认 / 调整后才动手**。永远不在跳过这一步的情况下直接编辑代码。

## 等级判定与编排链路

| 等级 | 触发条件 | 编排链路 | 是否建 issue |
|------|----------|----------|--------------|
| **L0** | 单行 / typo / 格式 / 日志 / 注释 | `friendly-*` 规范自检 → commit | ❌ 不问 |
| **L1** | 单文件 / 单 bug / 一个明确小功能 | `friendly-*` → 询问 issue → `github-issue-workflow`（单 issue 路径） | ✅ 询问，默认推荐建 |
| **L2** | 多文件 / 跨模块 / 新功能 | `brainstorming`（如需求模糊）→ `writing-plans` → `github-create-issue` → `github-issue-workflow` → `friendly-*`（贯穿）| ✅ 必建 |
| **L3** | 架构变更 / 公共接口 / 数据模型 / 安全相关 | `architecture-designer` → ADR → `brainstorming` → `writing-plans` → `github-create-issue`（带 `architecture` 标签）→ `github-issue-workflow` → `friendly-*` | ✅ 必建 + ADR |

### 判定原则

1. **模糊时取较低档** + 在开场确认里告诉用户："判定为 L1，要升到 L2 吗？"
2. **永远允许用户主动降级**——用户说"别建 issue 直接改" → 退回 L0/L1（看改动范围）
3. **L2/L3 用户拒绝建 issue** → 提示风险（"无 issue → PR 不会自动 close、追溯断链、复盘困难"）但**不强行拦截**
4. **PM 类需求**（来自 `github-product-manager`）默认 L2 起步，必读 issue body 中的 `MVP 定义` 字段做切片

判定细则与边界 case 见 `references/level-decision.md`。

## 语言适配

| 检测到 | 编码规范 skill | 未实现时回退 |
|--------|----------------|--------------|
| Python | `friendly-python`（已有） | — |
| TypeScript / JavaScript | `friendly-typescript`（TODO） | ESLint / Prettier 默认 |
| Go | `friendly-go`（TODO） | `gofmt` + `golangci-lint` |
| Rust | `friendly-rust`（TODO） | `rustfmt` + `clippy` |
| Shell / 其他 | 无 | shellcheck / agent 通用规范 |

未实现的 `friendly-*` 在开场确认时一句话告知，不阻塞。完整适配规则与多语言项目处理见 `references/language-stack.md`。

## Repo 适配（降级策略）

```
1. 在 git 仓库内？      → 否 → 询问"要不要 git init？"
2. 有 GitHub remote？   → 否 → 降级模式
3. gh auth 可用？       → 否 → 提示登录，拒绝则降级
```

**降级模式行为：** 跳过所有 `gh` 调用与 issue/PR 流程，正常走 `brainstorming` / `writing-plans` + 编码 + 本地 commit 规范。不为 GitLab/Gitee 写专门适配——开发流程本质相通，issue/MR 由用户在对应平台手动操作即可。

## Commit Message 规范

沿用 `github-issue-workflow` 现有约定：

```
<type>: <description>

Closes #N    # 完整模式有；降级模式省略
```

`<type>` 取自现有标签：`fix` / `feat` / `refactor` / `docs` / `chore` / `perf`。

## 收尾流程

| 等级 | 收尾动作 |
|------|----------|
| L0 | 改完 → `friendly-*` 自检 → `git commit`，结束 |
| L1 | 跑测试 → `code-reviewer` subagent → commit + push → `gh pr create`（或 close issue） |
| L2 | 同 L1 + **询问轻量复盘**："做个 5 分钟复盘吗？/ skip" |
| L3 | 同 L1 + **默认触发 `self-improving` 复盘** + 询问是否写 ADR（`docs/adr/YYYYMMDD-<topic>.md`） |

复盘模板与沉淀位置见 `references/postmortem.md`。

## 红线（Red Flags）

遇到下列情况立即停止 / 回到正轨：

- ❌ 跳过开场 5 步直接动手
- ❌ 用户拒绝建 issue 后**没**告知"无 issue → 追溯断链"的风险
- ❌ L3 改动不写 ADR
- ❌ 在没检测语言/Repo 的情况下假设是 GitHub Python 项目
- ❌ 用户说"修个 typo" 也走完整 L2 流程（过度仪式化）
- ❌ L2/L3 改动不询问 / 不触发复盘
- ❌ 把 PM 类需求按 L1 处理、忽略 issue body 里的 MVP 定义

## 关联 Skills

本 skill 会在合适时机调用以下子 skill。"什么场景调什么"速查见 `references/orchestration-cheatsheet.md`。

| Skill | 用途 |
|-------|------|
| `friendly-python` | Python 编码规范，所有等级贯穿 |
| `github-create-issue` | 按模板建 GitHub issue（L1 询问 / L2/L3 必用） |
| `github-issue-workflow` | 端到端 issue 推进（L1+） |
| `brainstorming` | 需求/设计澄清（L2/L3） |
| `writing-plans` | 实施计划（L2/L3） |
| `executing-plans` | 按 plan 执行 + 检查点（任意等级，有 plan 就用） |
| `architecture-designer` | 架构决策（L3 必用） |
| `self-improving` | 复盘（L2 询问 / L3 默认） |
| `debug-pro` | 系统性调试（任意等级，bug 不明时按需调用） |

## References

- `references/level-decision.md` — L0-L3 判定细则、边界 case、关键词映射
- `references/language-stack.md` — 语言检测、适配表、未实现回退、多语言项目处理
- `references/postmortem.md` — L2/L3 复盘模板、ADR 路径、沉淀机制
- `references/orchestration-cheatsheet.md` — 场景 → skill 速查、典型剧本、跳过策略
