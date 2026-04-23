# `using-dev` Skill 设计

## 背景

devkit 现有 `friendly-python`（编码规范）、`github-create-issue`（issue 模板）、`github-issue-workflow`（端到端开发流程）三个开发相关 skill，使用时需要用户分别记忆和触发。本设计提出一个总入口 skill `using-dev`，作为**编排者**统一串联现有开发 skill 与 superpowers 系列（`brainstorming` / `writing-plans` / `executing-plans` / `architecture-designer` / `self-improving` 等），实现"一键唤醒并完成完整开发流程"。

## 目标

- 一个入口覆盖从"看代码 / 改 typo"到"架构级新功能"的全光谱开发场景
- 主动跟随 `friendly-python` 编码规范，无需用户提醒
- 主动询问是否创建 GitHub issue，并能驱动完整 issue workflow
- 同时把 superpowers 系列（设计、计划、复盘）按场景自动挂载
- 未来可平滑扩展到其他语言（`friendly-typescript` / `friendly-go` 等）

## 整体设计

### 1. 触发机制（混合模式）

| 路径 | 描述 |
|------|------|
| 关键词自动触发 | description 铺设：写需求 / 改 bug / 修复 / 新功能 / 重构 / 优化 / debug / 实现 / 开发 / 加个功能 / write feature / fix bug / refactor / implement |
| 显式口令 | "开干" / "走完整开发流程" / "/dev" |
| 明确不触发 | "解释这段代码" / "看 X 是什么" / "这个函数干嘛的"等纯只读场景 |

### 2. 开场固定 5 步

1. 检测项目语言（`pyproject.toml`/`*.py` → Python，`package.json` → TS/JS，`go.mod` → Go ...）
2. 检测 git remote 与 GitHub 可用性（`git remote -v` + `gh auth status`）
3. 判定任务等级 L0-L3
4. 一句话向用户确认："识别到 [bug 修复 / 新功能 / 重构 / ...]，建议按 L[N] 流程推进（[Python] 项目，[已检测到 / 未检测到] GitHub remote）。可以吗？/ 想降级到 L[N-1]？"
5. 用户确认 / 调整后才动手

### 3. 等级判定与编排链路

| 等级 | 触发条件 | 编排链路 | 是否建 issue |
|------|----------|----------|--------------|
| **L0** | 单行 / typo / 格式 / 日志 / 注释 | `friendly-python`（仅规范） | ❌ 不问 |
| **L1** | 单文件 / 单 bug / 一个明确小功能 | `friendly-python` → 询问 issue → `github-issue-workflow`（单 issue 路径） | ✅ 询问，默认推荐建 |
| **L2** | 多文件 / 跨模块 / 新功能 | `brainstorming`（如需求模糊）→ `writing-plans` → `github-create-issue` → `github-issue-workflow` → `friendly-python`（贯穿） | ✅ 必建 |
| **L3** | 架构变更 / 公共接口 / 数据模型 / 安全相关 | `architecture-designer` → ADR 文档 → `brainstorming` → `writing-plans` → `github-create-issue`（带 `architecture` 标签）→ `github-issue-workflow` → `friendly-python` | ✅ 必建 + ADR |

**判定原则：**
- 模糊时取较低档 + 在开场确认里告诉用户："判定为 L1，要升到 L2 吗？"
- 永远允许用户主动降级："别建 issue 直接改" → 退回 L0
- L2/L3 用户拒绝建 issue → 提示风险但不强行拦截
- PM 类需求（来自 `github-product-manager`）默认 L2 起步，按 issue body 中 `MVP 定义` 切片

### 4. 语言适配（未来可扩展）

| 检测到 | 编码规范 skill | 检测信号 |
|--------|----------------|----------|
| Python | `friendly-python`（已有） | `pyproject.toml` / `setup.py` / `*.py` |
| TypeScript / JavaScript | `friendly-typescript`（TODO，未实现时回退 agent 通用） | `package.json` / `tsconfig.json` |
| Go | `friendly-go`（TODO） | `go.mod` |
| Rust | `friendly-rust`（TODO） | `Cargo.toml` |
| Shell / 其他 | 无专属 skill，回退 agent 通用规范 | — |

未实现时开场提示一句即可，不阻塞。

### 5. Repo 适配（降级策略）

```
1. 在 git 仓库内？      → 否 → 询问"要不要 git init？"
2. 有 GitHub remote？   → 否 → 降级模式（跳过所有 issue/PR 流程）
3. gh auth 通过？       → 否 → 提示登录，拒绝则降级
```

**降级模式行为：** 跳过所有 `gh` 调用，正常走 `brainstorming` / `writing-plans` + 编码 + 本地 commit。不为 GitLab/Gitee 写专门适配。

### 6. Commit Message 规范（所有模式通用）

沿用 `github-issue-workflow` 现有约定：

```
<type>: <description>

Closes #N   # 完整模式有
```

type：`fix` / `feat` / `refactor` / `docs` / `chore` / `perf`

### 7. 收尾流程

| 等级 | 收尾动作 |
|------|----------|
| L0 | 改完 → 自检 → `git commit`，结束 |
| L1 | 跑测试 → `code-reviewer` subagent → commit + push → `gh pr create` 或 close issue |
| L2 | 同 L1 + **询问是否轻量复盘**（"做个 5 分钟复盘吗？/ skip"） |
| L3 | 同 L1 + **默认触发 `self-improving` 复盘** + 询问是否写 ADR（`docs/adr/YYYYMMDD-<topic>.md`） |

### 8. 复盘内容要点

L2/L3 复盘模板：

- 这次实现是否偏离了原始 issue / plan？为什么？
- 哪些 `friendly-python` 规则被破坏了？是规则有问题还是落地有问题？
- 哪些子 skill 被跳过了？跳过对错？
- 下次类似场景，`using-dev` 应该怎么调整判定逻辑？

复盘结论沉淀到 `docs/learnings/YYYY-MM-DD-<topic>.md`，作为 skill 自身迭代输入。

## 文件结构

```
skills/using-dev/
├── SKILL.md                          # 主文件：触发、L0-L3 判定表、编排链路、降级
└── references/
    ├── level-decision.md             # L0-L3 判定细则（信号、边界 case）
    ├── language-stack.md             # 语言适配表 + 通用规范回退
    ├── postmortem.md                 # L2/L3 复盘模板
    └── orchestration-cheatsheet.md   # "什么场景调什么 skill" 速查表
```

## 同步更新（一并改的文件）

- `README.md` → 表格新增 `using-dev` 行
- `skills/using-devkit/SKILL.md` → 表格新增 `using-dev` 行，且标注为开发场景首选入口

## 验收标准

- [ ] 输入"帮我修个 typo" → 走 L0，不问 issue
- [ ] 输入"加个新功能 X" → 走 L2，先 brainstorming → 询问建 issue
- [ ] 输入"重构核心模块" → 走 L3，先 architecture-designer
- [ ] 在无 GitHub remote 的目录触发 → 自动降级，不调 `gh`
- [ ] 在 Python 项目里全程贯穿 `friendly-python`
- [ ] L2/L3 流程结束后会询问 / 触发复盘
- [ ] `README.md` 与 `using-devkit/SKILL.md` 表格同步更新

## 关键决策记录

| 决策点 | 选择 | 理由 |
|--------|------|------|
| issue 创建策略 | 智能判断（按 L 等级） | 兼顾流程严谨与体感 |
| 子 skill 编排深度 | 分层触发（L0-L3） | 复杂度匹配工作量，覆盖全光谱 |
| 语言范围 | 通用 + 语言适配表 | 当前 Python 全覆盖，未来可平滑扩展 |
| 触发机制 | 混合（关键词 + 口令 + 开场确认） | 解决误触发与"得记口令"两个痛点 |
| 无 GitHub remote | 降级运行，跳过 issue 流程 | 不限定仓库类型，覆盖内网项目 |
| 复盘触发 | 按等级（L2 询问 / L3 默认） | 与分层一致，避免复盘疲劳 |
| skill 命名 | `using-dev` | 与 `using-devkit` 形成族系 |
