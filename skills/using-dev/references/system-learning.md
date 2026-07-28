# SIES System Learning

## Principle

复盘不是每个任务必须填写的模板。只有证据表明某项经验能改善未来一类工作时，才建立
Learning Candidate。

## Promotion Signals

满足任一条件才记录：

- 同一错误、摩擦或误判重复出现；
- 一次高影响事件暴露系统性缺口；
- 新方法显著降低了时间、Token、运行成本或风险；
- 已有规则导致目标偏离或无效流程；
- 用户明确要求把经验写进系统。

“刚完成一个 L2/L3 任务”本身不是复盘理由。

## Candidate Record

```markdown
# Learning Candidate: <observable pattern>

- Evidence:
- Affected class of work:
- Current system behavior:
- Proposed change:
- Expected benefit:
- Cost or downside:
- Promotion decision: candidate | adopted | rejected
```

记录事实和证据，不写泛泛感想。

## Destination

| Finding | Destination |
|---|---|
| 单项目架构决定 | `docs/adr/` |
| 可复用研发判断 | 对应 skill 或 reference |
| 可机械检查的约束 | validator、lint 或 CI |
| 尚需更多证据 | GitHub Learning Issue |
| 一次性上下文 | Issue/PR comment，不晋升 |

## Promotion

1. 检查是否已经有相同规则或检查。
2. 判断是通用规律还是项目局部事实。
3. 选择最小、最接近使用位置的修改。
4. 说明新规则会替代什么旧行为。
5. 获得相应授权后再修改共享 skill、CI 或项目宪法。
6. 下一次相关任务观察结果；证据不支持时撤回或修正规则。

不要自动把每次经验追加到入口 skill。频繁加载的 skill 应保持短小，详细知识进入按需
reference 或自动检查。

## Anti-Patterns

- 每个任务都生成复盘文档；
- 只有观点，没有失败记录、数据或可观察行为；
- 用一次低影响偏好创建全局硬规则；
- 同一个要求同时写进多个 skills；
- 可以自动检查的机械约束只写成文字；
- 未经授权自动改变团队共享研发流程。
