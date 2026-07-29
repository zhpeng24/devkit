# Devkit SIES Orchestration

## Stage Routing

| Signal | Current stage | Useful action |
|---|---|---|
| 不知道真正要解决什么 | Goal | `github-product-manager` 补成功信号和非目标 |
| 目标明确但实现方向不清 | Explore | 阅读架构，比较会改变决定的候选 |
| 最大风险来自未知集成或性能 | Prototype | 做最小 spike、benchmark 或探针 |
| 已有原型但不知道是否值得继续 | Evaluate | 按 Evaluation Contract 收集证据 |
| 证据否定当前方案 | Refine | 修改、回到 Explore/Prototype 或停止 |
| 方向已被证据支持 | Engineer | 生产化、选择持久测试、迁移和文档 |
| 完整逻辑增量已完成 | Regress | 目标测试后执行一次交付回归 |
| 出现重复或高影响经验 | Learn | 按 `system-learning.md` 建 Learning Candidate |

## Common Routes

### Deterministic L0

```text
用户目标 → 定位现有路径 → 修改 → diff/静态证据 → 交付
```

所有 SIES 阶段已内联，不创建 Issue、计划或独立评审。

### Local Bug L1

```text
目标与失败模式 → 最小复现 → 修复候选 → 目标评价
→ 工程化整理 → 相关测试 → 交付回归
```

复现测试有长期价值时晋升为 regression；否则可以是一次性探针。

### Feature L2

```text
Goal Contract → 关键未知项 → Prototype → Evaluation → 选择方向
→ Engineering → 目标测试 → 交付回归 → 可选 Learning Candidate
```

GitHub Issue 保存目标和重要阶段证据，不为每个步骤拆 Issue。

### Architecture / High Risk L3

```text
Goal + 风险 → 多方案探索 → 可丢弃原型/基准 → Evaluation
→ Refinement + ADR → Engineering → 风险验证 → 完整回归 → Learning
```

测试可以因安全、迁移、并发或兼容性风险前移，但仍必须映射到目标或风险。

## TDD Compatibility

TDD 与 SIES 的关系是嵌套而非竞争：

```text
SIES lifecycle
└── Engineering
    ├── TDD：稳定契约、可复现 bug、高价值失败模式
    ├── example/contract-first：公共行为和集成边界
    ├── implementation + focused check：确定性机械修改
    └── scenario/visual evaluation：体验和生成式输出
```

如果运行时存在“所有 feature/bug 必须 TDD”的通用 skill，先应用本项目的 SIES Test
Strategy Gate。用户目标和项目研发宪法决定策略；不能仅因修改代码就自动进入逐函数
RED–GREEN–REFACTOR。

## GitHub Routing

| Need | Action |
|---|---|
| 形成产品 Goal Contract | `github-product-manager` |
| 持久化 Goal、Experiment、Engineering 或 Learning work | `github-create-issue` |
| 从现有 Issue 恢复 SIES | `github-issue-workflow` |
| GitHub 不可用 | 保留本地计划、commit 引用和交付证据 |

Issue 和分支不是阶段的必然产物。只有需要协作、恢复、独立交付或风险隔离时才创建。

## Operations and Artifact Routing

| Signal | Route |
|---|---|
| 部署、发布、回滚、健康检查、运行时或生产/测试环境排障 | `deployment-operations` |
| 明确的生产运营/业务统计，只需要只读聚合查询 | `production-statistics` |
| 周报、月报、架构/MVP/项目汇报 `.pptx` | `pptx` 的 repository-report 模式 |
| 项目存在 `.devkit/project.json` | 只读取当前任务相关对象；参数是默认值，不是授权 |

生产统计与部署必须保持边界：统计 skill 不执行 DDL/DML、修复、部署或 Git 版本确认；
部署 skill 不因为能访问数据库就替代专用只读统计流程。

## Planning and Review

- 计划只写到足以避免遗漏和协调接口；不把每次编辑拆成独立任务。
- 只有存在真实设计选择时才启动设计探索。
- 默认执行与风险匹配的本地 diff review。
- 独立 review agent 只用于大范围、高影响、公共接口、安全或用户明确要求的变更。
- 无新代码和新证据时，不用额外 review 或测试制造流程感。

## User Compression

用户要求“直接执行”时：

1. 使用用户原话作为最小 Goal Contract；
2. 自动选择最低成本可信证据；
3. 不重复询问 Issue、worktree、计划或 review；
4. 连续完成完整逻辑批次；
5. 最后报告目标映射、验证结果和未覆盖风险。
