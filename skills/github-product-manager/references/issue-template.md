# Product Goal Contract Profile

Use the sections that carry decision value. Omit optional sections instead of
filling them with generic prose.

```markdown
## SIES Goal Contract

### Outcome
[用户或系统将获得的可观察结果]

### Users and scenarios
[一到三个能体现价值的场景；纯内部工作可省略]

### Success signals
- [可观察信号；可以是行为、指标、场景、视觉结果、契约或测试]

### Non-goals / MVP
- Included:
- Excluded:

### Constraints and impact
[兼容性、性能、政策、时间、影响模块；没有重要约束可省略]

### Key uncertainties
- [会改变方向或范围的未知项；确定性任务可写 none]

## Evaluation Contract
- Decision to make:
- Evidence:
- Pass condition:
- Fail / stop condition:

## Relationships
[相关 Issue、PR、ADR、用户反馈或参考；未知可省略]
```

## Trimming

| Work | Keep |
|---|---|
| Small product enhancement | Outcome, Success signals, MVP, Evaluation |
| Large product feature | All relevant sections |
| Internal improvement | Outcome, Success signals, Constraints, Evaluation |
| Exploration | Outcome, Key uncertainties, Evaluation; implementation scope remains open |
| UX/visual change | Users/scenarios, Success signals, visual/scenario evidence, non-goals |

## Labels

Type labels remain compatible with existing repositories:

| Label | Meaning |
|---|---|
| `feature` | New user-facing capability |
| `enhancement` | Improvement to an existing capability |
| `ux` | User-experience outcome |
| `needs-design` | A material decision is still unsupported |
| `innovation` | Experimental or novel capability |

Priority labels: `P0-critical`, `P1-important`, `P2-normal`,
`P3-nice-to-have`.

Add `sies` when the repository uses SIES labels. A current-phase label is
optional; it never substitutes for evidence.

## Title

Use `[module] observable outcome`, for example:

- `[auth] 支持第三方 OAuth 登录`
- `[editor] 降低长文预览延迟`
- `[skills] 以 SIES 作为默认研发序列`
