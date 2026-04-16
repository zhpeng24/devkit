---
name: github-create-issue
description: Use when creating GitHub issues for bugs, features, architecture changes, or optimizations. Ensures structured sections (background, impact, current state, expected changes, scope, acceptance criteria) and consistent labeling via gh CLI.
---

# Create Issue

Structured GitHub issue creation with `gh issue create`. Every issue answers: **为什么要做、造成了什么后果、现在什么样、要改成什么样、影响多大、怎么验收**。

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

1. 确认标签存在：`gh label list | grep <label>` → 不存在则 `gh label create <label> --color <color> --description "<desc>"`
2. 填充模板各 section
3. 生成命令：

```bash
gh issue create \
  --title "[模块] 简述" \
  --label "label1,label2" \
  --body "$(cat <<'EOF'
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
)"
```

4. 确认 issue 创建成功后返回 URL
