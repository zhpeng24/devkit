---
name: using-dev
description: "Use when the user asks to write, change, fix, refactor, debug, optimize, implement, or build code in a repository."
---

# Using Dev

开发总入口。所有研发任务默认进入 `sies-engineering`：

**Goal → Explore → Prototype → Evaluate → Refine → Engineer → Regress → Learn**

L0–L3 只决定阶段深度、持久化和风险控制，不再选择四套彼此割裂的固定流水线。

## Start

1. 读用户原话、相关代码、仓库说明和已有 Issue/PR/ADR。
2. 检测语言与项目原生工具，规则见 `references/language-stack.md`。
3. 检测 Git/GitHub 能力和工作区状态。
4. 按 `references/level-decision.md` 判断 L0–L3。
5. **REQUIRED SUB-SKILL:** 使用 `sies-engineering` 建立或恢复研发状态。

用户已说“直接开始”“不用讨论”或给出等价授权时，告知判断后直接推进。不要重复询问
Issue、worktree、计划或评审方式；根据风险自动选择，并在交付时说明。

## Depth

| Level | SIES depth | Default persistence |
|---|---|---|
| **L0** | 阶段内联；定位、修改、最小评价 | 无 Issue |
| **L1** | 简短目标与证据契约；通常一个候选方案 | Issue 可选 |
| **L2** | 显式目标、不确定性、评价和决定 | 默认 GitHub Issue |
| **L3** | 完整探索、原型证据、风险策略与架构决定 | Issue + 重要决策 ADR |

模糊不等于复杂。等级由范围、未知项、影响面和可逆性共同决定。完整规则见
`references/level-decision.md`。

## Adaptive Routing

| Current need | Skill or action |
|---|---|
| 产品目标或成功信号仍不清楚 | `github-product-manager` |
| 需要持久化新的 Goal / Experiment / Engineering work | `github-create-issue` |
| 已有 Issue，需要恢复和推进状态 | `github-issue-workflow` |
| 已有明确方案且步骤较多 | 写最小可执行计划；不重复做产品澄清 |
| 原因未知的 bug | 原因优先调试和最小复现实验 |
| Python 或其他语言实现 | 对应 `friendly-*`；不可用时用仓库原生工具 |
| 需要测试策略 | `sies-engineering` 的 Evidence Strategy |
| 产生可复用经验 | `references/system-learning.md` |

使用场景速查和传统 TDD 兼容规则见 `references/orchestration-cheatsheet.md`。

## GitHub Policy

- GitHub 是目标、证据和决定的持久化层，不是必须按顺序打卡的流水线。
- L0 不建 Issue；L1 按追溯价值选择；L2/L3 默认使用，但用户可明确跳过。
- 一个 Outcome 可以由同一 tracking Issue 贯穿；只有独立可决策、可交付或可并行时才拆分。
- 只有开始改文件时才创建分支。worktree 根据工作区污染、并行度和风险自动决定。
- GitHub 不可用时保留本地 Goal Contract、commit traceability 和交付证据，不阻塞。

## Testing Policy

测试用于验证目标一致性、稳定契约和真实风险：

- Goal 或架构尚未稳定时，先 Prototype 与 Evaluation，不把临时假设固化为回归测试。
- 可复现 bug、公共契约、安全、迁移、并发和兼容性可前移针对性测试。
- TDD 只有通过 SIES Test Strategy Gate 后才使用，不因“正在写代码”自动触发。
- 完整逻辑增量完成后运行目标测试；交付前统一运行一次风险匹配的项目回归。
- 相关输入未变化时不重复运行同一验证。
- 测试通过但成功信号未满足，任务仍未完成。

## Delivery

交付前完成：

1. 对照 Goal Contract 逐项说明结果和证据；
2. 确认原型假设经过 Evaluation 后才进入生产实现；
3. 运行目标测试与一次交付回归，说明未验证范围；
4. 做与风险匹配的本地 diff review；只有高影响或用户要求时才启动独立评审；
5. 使用 `<type>: <description>` 提交；有 Issue 时保留引用；
6. 按 `references/system-learning.md` 判断是否存在 Learning Candidate。

## Red Flags

- 用等级选择固定工具链，而不是缩放同一套 SIES；
- 目标不清楚就写计划、测试或生产代码；
- 用户已授权直接执行后仍反复请求流程确认；
- 把测试全绿当成目标达成；
- 每改一个文件就回归或启动评审；
- 无新增证据时重复执行同一测试；
- 为了模板完整而创建无决策价值的 Issue、ADR 或复盘；
- Evaluation 失败后只修实现或测试，不重新判断方案。

## References

- `references/level-decision.md` — L0–L3 深度判定
- `references/language-stack.md` — 语言检测和原生工具回退
- `references/orchestration-cheatsheet.md` — 场景、阶段和 skill 速查
- `references/system-learning.md` — Learning Candidate 筛选与晋升
