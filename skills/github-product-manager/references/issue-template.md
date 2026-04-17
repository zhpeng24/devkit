# Product Requirement Issue Template

## Template Structure

```markdown
## 用户故事
作为 [角色]，我希望 [做什么]，以便 [获得什么价值]。

## 背景与动机
[这个需求从哪来？解决什么问题？不做会怎样？]

## 用户场景
[具体的使用场景描述，1-3 个典型场景]
1. 场景一：...
2. 场景二：...

## 当前状态
[项目中现有的相关功能/代码是什么样的？有什么差距？]

## 预期行为
[详细描述期望的功能表现]
1. ...
2. ...

## 边界与约束
[边界情况、技术约束、兼容性要求、性能要求等]

## 竞品/参考
[有没有参考的实现？竞品是怎么做的？]

## 影响范围
[哪些模块/功能会受影响？]

## MVP 定义
[最小可行版本包含什么？什么可以后续迭代？]

## 验收标准
- [ ] 标准 1
- [ ] 标准 2

## 优先级建议
[P0-P3 + 理由]
```

## Trimming Rules

Not every issue needs all sections. Trim based on requirement type:

| Requirement Type | Can Omit |
|-----------------|----------|
| Simple feature | 竞品/参考, 边界与约束 |
| Improvement / Optimization | 用户故事 (if internal improvement) |
| Large feature | None, all required |
| UX improvement | MVP 定义 (if no phasing needed) |

## Label System

Before submission, check if labels exist: `gh label list | grep <label>`. Create if missing: `gh label create <label> --color <color> --description "<desc>"`

### Type Labels

| Label | Color | Description |
|-------|-------|-------------|
| `feature` | `1d76db` | New feature request |
| `enhancement` | `0e8a16` | Improvement to existing feature |
| `ux` | `f9d0c4` | User experience improvement |
| `needs-design` | `d4c5f9` | Requires further design |

### Priority Labels

| Label | Color | Description |
|-------|-------|-------------|
| `P0-critical` | `b60205` | Highest priority |
| `P1-important` | `d93f0b` | High priority |
| `P2-normal` | `fbca04` | Normal priority |
| `P3-nice-to-have` | `c5def5` | Low priority |

## Title Convention

Format: `[模块] 简述需求`

Examples:
- `[auth] 支持第三方 OAuth 登录`
- `[editor] 添加 Markdown 实时预览`
- `[skills] 产品经理式需求分析流程`

## Submission Command

```bash
gh issue create \
  --title "[模块] 简述需求" \
  --label "label1,label2" \
  --body "$(cat <<'EOF'
## 用户故事
...

## 背景与动机
...

## 用户场景
...

## 当前状态
...

## 预期行为
...

## 边界与约束
...

## 竞品/参考
...

## 影响范围
...

## MVP 定义
...

## 验收标准
- [ ] ...

## 优先级建议
...
EOF
)"
```

## Multi-Issue Splitting

When a requirement is split into multiple issues:

1. List all sub-requirement titles and summaries for user confirmation
2. Create them one by one, adding a "关联" section at the end of each issue body to cross-reference issue numbers
3. After all are created, return a summary with all URLs
