---
name: using-dev
description: "Use when the user asks to write, change, fix, refactor, debug, optimize, implement, or build code in a repository."
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

### 开场检查

被唤醒后先完成必要的环境判断：

1. **检测语言**：扫描 `pyproject.toml` / `package.json` / `go.mod` / `Cargo.toml` / 源码后缀，决定挂哪个 `friendly-*`（详见 `references/language-stack.md`）
2. **检测 Repo**：
   ```bash
   git rev-parse --git-dir 2>/dev/null      # 在 git 仓库内？
   git remote -v | grep -E "github\.com"    # GitHub remote？
   gh auth status 2>&1                       # gh 登录可用？
   ```
3. **判定等级 L0-L3**：依据用户原话 + `git status` + 改动信号（详见 `references/level-decision.md`）
4. **需要确认时用一句话确认**，模板：
   > 识别到 [bug 修复 / 新功能 / 重构 / ...]，建议按 **L[N]** 流程推进（[Python] 项目，[已检测到 / 未检测到] GitHub remote）。可以吗？想升到 L[N+1] / 降到 L[N-1] / 跳过 issue 直接改？
5. 用户已经明确说“直接开始”“不用讨论”“跳过 issue/plan”或给出等价授权时，不再重复确认；按其授权范围直接执行。

## 等级判定与编排链路

| 等级 | 触发条件 | 编排链路 | 是否建 issue |
|------|----------|----------|--------------|
| **L0** | 单行 / typo / 格式 / 日志 / 注释 | `friendly-*` 规范自检 → commit | ❌ 不问 |
| **L1** | 单文件 / 单 bug / 一个明确小功能 | `friendly-*` → 询问 issue → `github-issue-workflow`（单 issue 路径） | ✅ 询问，默认推荐建 |
| **L2** | 多文件 / 跨模块 / 新功能 | `brainstorming`（如需求模糊）→ `writing-plans` → `github-create-issue` → `github-issue-workflow` → `friendly-*`（贯穿）| ✅ 必建 |
| **L3** | 架构变更 / 公共接口 / 数据模型 / 安全相关 | 架构方案比较（优先 `brainstorming`）→ ADR → `writing-plans` → `github-create-issue`（带 `architecture` 标签）→ `github-issue-workflow` → `friendly-*` | ✅ 必建 + ADR |

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

## 测试节奏（研发原则）

测试按**风险和完整逻辑增量**安排，不按文件数、保存次数或每一次小修改安排。

测试质量优先于数量。测试条数、覆盖率数字和重复执行次数本身都不是目标；优先选择少量但高信息量的测试：

- 对应一个真实失败模式或关键业务风险；
- 有明确、可观察的断言，缺陷出现时确实会失败；
- 覆盖关键边界、错误路径和兼容性约束，而不只重复 happy path；
- 结果稳定、可复现，并能帮助定位问题；
- 与实现细节保持适当距离，避免无意义的脆弱测试。

没有明确风险、没有有效断言，或只是为了增加数量和展示“测过很多次”的测试，不应添加或重复执行。

1. 开发过程中只运行能指导下一步的快速检查，例如复现 bug 的单测、当前模块的类型检查或语法检查。
2. 一个完整功能、修复或逻辑批次完成后，统一运行该范围的目标测试。
3. 整个需求完成、准备交付前，再运行一次项目回归和必要的全量验证。
4. 在代码、配置、依赖、测试夹具和运行环境都没有相关变化时，不重复运行同一套测试来制造流程感。
5. 只有 bug 复现、安全边界、数据迁移、并发、公共接口兼容性、跨平台行为等高风险场景，才把针对性测试前移并提高频率。
6. 文档、skill 和元数据批量修改完后统一跑静态校验；不要求每新增一个文件就启动完整回归或独立评审代理。

每次测试都应回答一个明确问题。若重复测试不会产生新证据，就停止重复，继续完成实现。

## Repo 适配（降级策略）

```
1. 在 git 仓库内？      → 否 → 询问"要不要 git init？"
2. 有 GitHub remote？   → 否 → 降级模式
3. gh auth 可用？       → 否 → 提示登录，拒绝则降级
```

**降级模式行为：** 跳过所有 `gh` 调用，保留 issue 文本追踪、本地分支/commit 规范、review checklist、测试与验收标准。不为 GitLab/Gitee 写专门适配——开发流程本质相通，issue/MR 由用户在对应平台手动操作即可。

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
| L0 | 改完 → 必要的快速自检 → `git commit`，结束 |
| L1 | 完成修复批次 → 目标测试 → review agent 或本地 review checklist → commit + push → `gh pr create`（或降级为本地交付说明） |
| L2 | 同 L1 + **询问轻量复盘**："做个 5 分钟复盘吗？/ skip" |
| L3 | 同 L1 + 按 `references/postmortem.md` 复盘 + 询问是否写 ADR（`docs/adr/YYYYMMDD-<topic>.md`） |

复盘模板与沉淀位置见 `references/postmortem.md`。

交付前优先使用 `verification-before-completion`；若该外部 skill 不可用，直接运行项目自身的目标测试、回归测试和构建/静态检查，不阻塞交付。

## 红线（Red Flags）

遇到下列情况立即停止 / 回到正轨：

- ❌ 在用户已经明确授权直接执行后，仍反复要求流程确认
- ❌ 用户拒绝建 issue 后**没**告知"无 issue → 追溯断链"的风险
- ❌ L3 改动不写 ADR
- ❌ 在没检测语言/Repo 的情况下假设是 GitHub Python 项目
- ❌ 用户说"修个 typo" 也走完整 L2 流程（过度仪式化）
- ❌ L2/L3 改动不询问 / 不触发复盘
- ❌ 把 PM 类需求按 L1 处理、忽略 issue body 里的 MVP 定义
- ❌ 每改一个文件或一小段文本就重复跑全量测试、启动独立评审，且没有新增风险或证据
- ❌ 实现尚未形成完整逻辑增量时，用无休止回归代替继续开发

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
| `systematic-debugging` | 疑难 bug 的原因优先调试；不可用时按复现 → 假设 → 最小实验 → 修复 → 回归的本地流程 |
| `verification-before-completion` | 完整逻辑增量或需求交付前验证；不可用时运行项目自身检查 |
| `references/postmortem.md` | 本地复盘流程，不依赖外部复盘 skill |

## References

- `references/level-decision.md` — L0-L3 判定细则、边界 case、关键词映射
- `references/language-stack.md` — 语言检测、适配表、未实现回退、多语言项目处理
- `references/postmortem.md` — L2/L3 复盘模板、ADR 路径、沉淀机制
- `references/orchestration-cheatsheet.md` — 场景 → skill 速查、典型剧本、跳过策略
