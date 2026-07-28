---
name: using-devkit
description: Use when starting any conversation or when the user asks to write, change, fix, refactor, debug, optimize, implement, or build code in a repository.
---

# Using Devkit

Devkit 的唯一入口：负责技能发现；遇到研发任务时，默认进入
`sies-engineering`。

**Goal → Explore → Prototype → Evaluate → Refine → Engineer → Regress → Learn**

L0–L3 只控制阶段深度、证据和持久化程度，不再维护另一套开发入口或固定工具流水线。

## Development Start

1. 读取用户原话、相关代码、仓库说明和已有 Issue/PR/ADR。
2. 检测语言、项目原生工具、Git/GitHub 能力和工作区状态。
3. 按 `references/level-decision.md` 判断 L0–L3。
4. **REQUIRED SUB-SKILL:** 使用 `sies-engineering` 建立或恢复研发状态。

用户已说“直接开始”“不用讨论”或给出等价授权时，告知判断后直接推进。不要重复询问
Issue、worktree、计划或评审方式；根据风险自动选择，并在交付时说明。

## SIES Depth

| Level | Default depth | Persistence |
|---|---|---|
| **L0** | 阶段内联；定位、修改、最小评价 | 无 Issue |
| **L1** | 简短目标与证据契约；通常一个候选方案 | Issue 可选 |
| **L2** | 显式目标、不确定性、评价和决定 | 默认 GitHub Issue |
| **L3** | 完整探索、原型证据、风险策略与架构决定 | Issue + 重要决策 ADR |

模糊不等于复杂。范围、未知项、影响面和可逆性共同决定深度。

## Adaptive Routing

| Current need | Skill or action |
|---|---|
| 产品目标或成功信号仍不清楚 | `github-product-manager` |
| 持久化 Goal、Experiment、Engineering 或 Learning | `github-create-issue` |
| 从已有 Issue 恢复和推进 | `github-issue-workflow` |
| 原因未知的 bug | 原因优先调试和最小复现实验 |
| Python 或其他语言实现 | 对应 `friendly-*`；不可用时用仓库原生工具 |
| 选择测试策略 | `sies-engineering` 的 Evidence Strategy |
| 产生可复用经验 | `references/system-learning.md` |

完整路由和传统 TDD 兼容规则见 `references/orchestration-cheatsheet.md`。

## Evidence and Delivery

- GitHub 保存目标、证据和决定，不是必须按顺序打卡的流水线。
- Goal 或架构未稳定时先 Prototype/Evaluation，不把临时假设固化为回归测试。
- TDD 只有通过 SIES Test Strategy Gate 后才使用。
- 完整逻辑增量后运行目标测试；交付前统一执行一次风险匹配的回归。
- 测试通过但成功信号未满足，任务仍未完成。
- 本地 diff review 是默认；独立评审只用于高影响任务或用户明确要求。
- 只有重复、高影响或明确可复用的经验才建立 Learning Candidate。

## Available Skills

| Skill | Use |
|---|---|
| **sies-engineering** | 默认目标优先、证据驱动研发序列 |
| **friendly-python** | Python 类型、格式、诊断和项目规范 |
| **humanizing-writing** | 中英文日常写作、技术文档和 PR 去 AI 味 |
| **taste-skill** | 上下文感知的网页设计与重设计 |
| **image-to-code-skill** | 从截图、Figma 或批准参考实现网页 |
| **imagegen-frontend-web** | 生成纯图片网站概念与分区参考 |
| **imagegen-frontend-mobile** | 生成移动端屏幕和流程概念图 |
| **pptx** | 创建、读取、编辑和验证 PowerPoint |
| **mihomo-proxy-setup** | 安装和维护 Mihomo 开发代理 |
| **github-create-issue** | 创建自适应 SIES Issue Profile |
| **github-issue-workflow** | 从现有 GitHub 目标和证据恢复状态 |
| **github-product-manager** | 形成可评价的产品 Goal Contract |

Skills 在相关任务中自动触发。显式调用方式：

- Claude Code：`devkit:<skill-name>`
- Codex：`devkit/<skill-name>`
- Copilot CLI：`<skill-name>`
- Cursor：自然语言触发
- Gemini CLI：`activate_skill`
- OpenCode：`devkit/<skill-name>`

## Red Flags

- 再创建一个与 `using-devkit` 平行的开发总入口；
- 用等级选择固定工具链，而不是缩放 SIES；
- 用户已授权直接执行后仍反复请求流程确认；
- 把测试全绿当成目标达成；
- 每改一个文件就回归或启动评审；
- 为模板完整创建无决策价值的 Issue、ADR 或复盘。

## References

- `references/level-decision.md` — L0–L3 深度判定
- `references/language-stack.md` — 语言检测和原生工具回退
- `references/orchestration-cheatsheet.md` — 场景、阶段和 skill 速查
- `references/system-learning.md` — Learning Candidate 筛选与晋升
