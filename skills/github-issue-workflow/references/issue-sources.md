# Issue 来源与模板差异

仓库内的 issue 主要来自两个上游 skill，body 模板与标签体系不同。开发前必须先识别来源，再按对应模板字段读取实现依据。

## 对照表

| 来源 skill | 典型类型标签 | 优先级标签 | Body 关键 section | 适用场景 |
|------------|------------|-----------|-------------------|---------|
| `github-create-issue` | `bug` / `architecture` / `tech-debt` / `optimization` / `innovation` / `documentation` / `security` | 无（用类型隐含优先级） | 背景 / 已造成问题 / 当前状态 / 预期改动 / 影响范围 / 关联 / 验收标准 | 工程类问题与改造 |
| `github-product-manager` | `feature` / `enhancement` / `ux` / `needs-design` | `P0-critical` / `P1-important` / `P2-normal` / `P3-nice-to-have` | 用户故事 / 背景与动机 / 用户场景 / 当前状态 / 预期行为 / 边界与约束 / 竞品参考 / 影响范围 / MVP 定义 / 验收标准 / 优先级建议 | 产品需求 |

## 判定方法

1. **看类型标签**：含 `feature` / `enhancement` / `ux` / `needs-design` → PM 来源；含 `bug` / `architecture` / `tech-debt` 等 → 工程来源。
2. **看 body 关键字**：含 `用户故事` / `用户场景` / `MVP 定义` → PM 来源；含 `预期改动` / `已造成问题` → 工程来源。
3. **两者都没有**：按工程模板处理，并提示该 issue 缺少结构化字段，建议补全。

## 实现依据字段

开发时必读字段（缺失则 STOP，回到 issue 作者补充）：

- **工程类**：`预期改动`（做什么）+ `影响范围`（改哪里）+ `验收标准`（做完的标志）
- **PM 类**：`用户场景`（为谁解决什么）+ `预期行为`（期望表现）+ `MVP 定义`（本期范围）+ `验收标准`（做完的标志）

## Code Review 上下文

传给 `code-reviewer` 的 issue 内容必带：

- 两类都必带：完整 issue body + `验收标准`
- PM 类额外带：`用户故事` + `MVP 定义`，用于校验"是否走偏 / 是否超出 MVP"
