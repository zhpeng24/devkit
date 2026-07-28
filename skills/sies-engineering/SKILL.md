---
name: sies-engineering
description: Use when an engineering task involves writing, changing, fixing, refactoring, debugging, optimizing, or shipping code and the work must stay aligned with user goals while choosing evidence proportionate to uncertainty and risk.
---

# SIES Engineering

## Overview

SIES（Self-Improving Engineering System）是 Devkit 的默认研发序列。
它用“目标是否被证据支持、关键不确定性是否被关闭”衡量进展，而不是用测试数量或流程动作衡量进展。

测试不会被取消。测试是验证目标一致性、稳定契约和真实风险的重要证据，但 TDD 只是
Engineering 阶段内按需选择的策略。

## Start From State

1. 读取用户目标、仓库状态、现有 Issue/PR/ADR 和相关实现。
2. 恢复已有 Goal Contract 与证据；不要重新执行已经关闭的阶段。
3. 判断复杂度、风险和不确定性，决定每个阶段需要多深。
4. 用户说“直接改”时压缩产物和沟通，不反复确认；仍保留最小目标、风险判断和交付验证。

GitHub 参与任务时，读取 `references/github-state.md`。选择 Evaluation、测试和回归策略时，
读取 `references/evidence-strategy.md`。

## Default Sequence

| Phase | Required outcome |
|---|---|
| **Goal** | 明确结果、成功信号、非目标、约束和关键未知项 |
| **Explore** | 找到值得验证的路径；确定性工作可确认现有路径 |
| **Prototype** | 用最小实现或实验回答关键问题 |
| **Evaluate** | 用预先声明的证据判断目标一致性 |
| **Refine** | 采用、修改、回退或停止，并记录理由 |
| **Engineer** | 把选定方向转成生产质量实现 |
| **Regress** | 完整增量后运行目标测试；交付前统一回归 |
| **Learn** | 只沉淀重复、高影响或明确可复用的经验 |

Evaluation 可以返回 Explore 或 Prototype。证据不支持目标时，不得仅靠增加测试把实现
推进到 Engineering。

## Scale, Do Not Replace

| Level | Depth |
|---|---|
| **L0** | 阶段内联完成；通常以用户原话、代码定位、diff 或静态检查为证据 |
| **L1** | 简短 Goal Contract；通常验证一个候选方案；Issue 可选 |
| **L2** | 持久化目标、关键未知项、评价契约和决定；必要时比较方案 |
| **L3** | 完整探索与原型证据；重要架构决定写 ADR；高风险验证前移 |

阶段可以合并。只有不存在会改变决定的未知项时才可以快速通过，不能为了制造流程感创建
无价值文档、Issue、测试或评审。

## Testing Contract

- 每个持久测试必须追溯到成功信号、稳定契约或真实失败模式。
- 可复现 bug、公共契约、安全、迁移、并发和兼容性风险适合前移针对性测试。
- 架构、产品方向或体验仍不确定时，先用 Prototype 和 Evaluation；不要让测试过早固化假设。
- Prototype 的探针和断言默认是临时证据，只有值得长期保护的行为才晋升为回归测试。
- 完成一个完整逻辑批次后运行目标测试；交付前运行一次与风险匹配的回归。
- 相关输入和实现未变化时，不重复运行同一套验证。
- 测试通过但目标证据失败，Evaluation 仍然失败。

## Orchestration

- 产品目标仍模糊时使用 `github-product-manager` 建立 Goal Contract。
- 需要 GitHub 状态时使用 `github-create-issue` 或 `github-issue-workflow`，由当前阶段决定。
- 使用适合项目语言的 `friendly-*` 或仓库原生规范。
- 只有复杂度和未知项确实需要时才调用设计、计划、调试或独立评审 skill。
- 不自动调用 blanket TDD 流程；先通过 Test Strategy Gate 决定是否采用 TDD。

## Completion Contract

交付前确认：

- 最终结果能映射到 Goal Contract 的成功信号；
- 关键架构决定有证据，而不是只剩未经验证的偏好；
- Engineering 没有混入未评价的原型假设；
- 测试与其他证据覆盖关键目标和风险；
- 回归在完整批次后执行，未验证范围被明确说明；
- 只有满足晋升条件的经验进入 Learning Candidate。

## Red Flags

- 目标尚未明确就开始堆测试；
- 把“测试全绿”等同于“目标达成”；
- 同一智能体从实现细节反推全部测试，没有独立目标来源；
- Prototype 尚未完成 Evaluation 就直接生产化；
- 每改一个文件就运行完整回归或启动独立评审；
- Evaluation 失败后只修测试，不重新判断方案；
- 为了填写模板而创建无决策价值的 GitHub 产物。
