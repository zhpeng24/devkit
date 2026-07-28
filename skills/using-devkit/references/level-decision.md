# SIES Depth Decision

## Purpose

L0–L3 不决定是否采用 SIES，只决定需要显式化多少阶段、证据和持久化产物。

## Four Dimensions

分别观察：

1. **Scope：** 改动文件、模块、服务和调用方数量；
2. **Uncertainty：** 目标、行为、架构或集成方式中有多少未知项；
3. **Blast radius：** 对用户、数据、安全、公共接口和部署的影响；
4. **Reversibility：** 失败后能否低成本撤销。

取四个维度中的最高有效等级。用户可以明确降低流程产物，但不能让被识别的风险从事实
上消失。

## Decision Table

| Level | Observable signals | SIES expression |
|---|---|---|
| **L0** | typo、注释、格式、已知机械变更；无行为风险 | 目标、探索、实现和评价内联完成 |
| **L1** | 局部 bug、单一行为、小范围工具方法；可快速撤销 | 简短 Goal/Evidence Contract，通常验证一个方案 |
| **L2** | 新功能、跨模块、依赖变化、多个未知项 | 持久化 Goal、Evaluation 和选型决定 |
| **L3** | 架构、公共 API、数据模型、安全、迁移、跨服务、高不可逆性 | 完整探索/原型/评价，ADR 和前移风险证据 |

## Boundary Rules

- 一行行为变化至少是 L1；行数不代表风险。
- 多文件机械修改可以是 L1；跨模块语义变化通常是 L2。
- 目标非常清楚的新功能仍可能是 L2，因为影响面较大。
- 小 diff 涉及权限、数据迁移或公共契约时是 L3。
- PM Issue 不自动等于 L2；按实际 MVP、未知项和影响面判断。
- `needs-design` 表示存在未关闭未知项，不自动要求某种固定文档。

## Direct Authorization

用户说“直接改”时：

- 不再询问是否写 Issue、计划、worktree 或是否启动 review agent；
- L0/L1 默认在当前工作区完成；
- L2/L3 根据已有分支政策、工作区污染和风险自动选择隔离方式；
- 压缩 GitHub 和文档产物，但在交付说明中保留目标、关键决定和验证证据；
- 涉及不可逆外部动作时仍遵守对应安全门禁。

## Artifact Scaling

| Artifact | L0 | L1 | L2 | L3 |
|---|---|---|---|---|
| Goal Contract | 对话内隐式 | 对话/简短记录 | Issue 或计划 | Issue，必要时关联 ADR |
| Architecture options | 确认现有路径 | 有未知项才比较 | 比较会改变决定的候选 | 明确代价、可逆性和长期影响 |
| Prototype | 修改本身 | 最小复现/实现 | 明确回答关键未知项 | 可丢弃 spike、benchmark 或集成实验 |
| Evaluation | diff/静态检查 | 目标场景证据 | Evaluation Contract | 多源证据与停止条件 |
| Regression | 最小相关检查 | 目标检查 | 目标测试 + 交付回归 | 风险前移 + 完整交付回归 |
| Learning | 无 | 高影响例外 | 满足晋升条件才记录 | 满足晋升条件才记录 |

## Self-Check

- 等级是否由事实信号决定，而不是任务描述的字数？
- 是否把“不确定性高”与“代码量大”区分开？
- 是否只增加了能改变决策或控制风险的产物？
- 是否保留了用户已经明确给出的目标和授权？
