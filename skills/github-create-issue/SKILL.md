---
name: github-create-issue
description: Use when a GitHub issue needs to be created for a bug, feature, architecture change, optimization, documentation, security, or tech-debt item.
---

# Create Issue

Structured GitHub issue creation with `gh issue create`. Every issue answers: **为什么要做、造成了什么后果、现在什么样、要改成什么样、影响多大、怎么验收**。

## Quality Gate

Do not create the issue until all checks pass:

- **Single outcome:** one bug, one behavior change, one cleanup theme, or one architectural decision.
- **Bounded scope:** affected modules/files are named or discoverable from the body.
- **Enough context:** the current state includes evidence, examples, paths, screenshots, logs, or reproduction notes when available.
- **Actionable change:** expected changes are specific enough for a developer to start.
- **Verifiable acceptance:** every acceptance criterion is observable by test, command, UI check, or review checklist.
- **Traceability:** related PRs, issues, commits, ADRs, or user reports are linked when known.

If any check fails, ask a clarifying question or split the issue before creation.

## Split Rules

Split instead of creating one broad issue when any condition is true:

- The request contains 2+ independent user scenarios.
- Different parts could ship independently.
- The change spans unrelated modules or labels.
- Acceptance criteria can pass independently.
- The issue mixes discovery/design with implementation.

Use a parent tracking issue only when coordination matters. Child issues must still be implementation-ready and independently verifiable.

## Template

```markdown
## 背景
[为什么这个问题/需求存在？来源是什么？（code review、用户反馈、架构设计…）]

## 已造成问题
[当前状态下产生了什么负面影响？不修复会怎样？]
- 影响 1
- 影响 2

## 当前状态
[相关代码/系统目前是什么样的？贴关键代码片段或文件路径]

## 预期改动
[要改成什么样？分步骤列出]
1. 步骤一
2. 步骤二

## 影响范围
[哪些模块/文件/功能会受影响？]

## 关联
[关联 PR、commit、设计文档、其他 issue]

## 验收标准
[满足什么条件视为完成？尽量可测试]
- [ ] 标准 1
- [ ] 标准 2
```

## 标签体系

创建 issue 前检查标签是否存在，不存在则用 `gh label create` 创建。

| 标签 | 颜色 | 说明 | 适用场景 |
|------|------|------|----------|
| `bug` | `d73a4a` | 已有功能出错 | 测试失败、运行时异常、数据错误 |
| `optimization` | `0e8a16` | 性能/体验/代码质量优化 | 速度慢、冗余代码、UX 改善 |
| `architecture` | `1d76db` | 架构层面变更 | 分层调整、依赖方向、模块拆分 |
| `innovation` | `f9d0c4` | 新能力/创新点 | 新 skill、新 tool、新 pipeline 阶段 |
| `tech-debt` | `d4c5f9` | 技术债务清理 | 遗留代码、TODO 清理、迁移 |
| `documentation` | `0075ca` | 文档补充或修正 | ADR、README、设计文档 |
| `security` | `b60205` | 安全相关 | 权限、输入校验、密钥管理 |

## Title 规范

格式：`[模块] 简述问题或改动`

- `[gateway] FeishuGateway 未使用 IncomingMessage`
- `[pipeline] deep_read 超时未设上限`
- `[agent/tools] follow_author 大小写不去重`

## Section 裁剪规则

不是每种 issue 都需要全部 7 个 section。按类型裁剪：

| 类型 | 可省略 |
|------|--------|
| `bug` | 预期改动（如果 fix 显而易见） |
| `optimization` | 已造成问题（如果是锦上添花） |
| `architecture` | 无，全部必填 |
| `innovation` | 当前状态（如果是全新功能） |
| `tech-debt` | 关联（如果是独立清理） |

## 执行流程

1. Run the Quality Gate and Split Rules.
2. 确认标签存在：`gh label list | grep <label>` → 不存在则 `gh label create <label> --color <color> --description "<desc>"`
3. 填充模板各 section
4. 生成命令：

安全规则：
- Issue 正文必须通过文件传给 `gh`，不要把多行正文放进 `--body "$(cat ...)"`。
- `--title` 只能使用单行标题；如果标题来自用户输入，先去掉换行。
- 需要后续评论或关闭 issue 时，只使用 `gh issue create` 返回的 URL 或 `gh issue view <url> --json number` 得到的数字编号作为目标。

```bash
issue_body_file="$(mktemp)"
trap 'rm -f "$issue_body_file"' EXIT

cat >"$issue_body_file" <<'EOF'
## 背景
...

## 已造成问题
...

## 当前状态
...

## 预期改动
...

## 影响范围
...

## 关联
...

## 验收标准
- [ ] ...
EOF

gh issue create \
  --title "[模块] 简述" \
  --label "label1,label2" \
  --body-file "$issue_body_file"
```

5. 确认 issue 创建成功后返回 URL
