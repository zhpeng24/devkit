# `using-dev` Skill Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 实现 `skills/using-dev/` 这个开发总入口 skill，能根据任务复杂度（L0-L3）自动编排现有开发 skills 与 superpowers 系列。

**Architecture:** 文档型 skill。SKILL.md 描述触发机制、L0-L3 判定表、编排链路与降级路径；4 个 references 文件分别承载判定细则、语言适配、复盘模板、子 skill 速查。同步更新 README.md 与 using-devkit/SKILL.md 让新 skill 可被发现。

**Tech Stack:** Markdown only。无代码、无依赖。验证手段：人工 review + 对照设计文档验收标准 + skill description 关键词覆盖检查。

**Reference:** 设计文档 `docs/plans/2026-04-23-using-dev-skill-design.md`

---

## Task 0: 创建分支

**Files:** N/A

**Step 1: 创建 feature 分支**

```bash
git checkout -b feat/using-dev-skill
```

Expected: 切到新分支，`git status` 显示 clean。

---

## Task 1: 搭骨架 + 写 SKILL.md 主文件

**Files:**
- Create: `skills/using-dev/SKILL.md`
- Create: `skills/using-dev/references/` (空目录占位)

**Step 1: 建目录**

```bash
mkdir -p skills/using-dev/references
```

**Step 2: 写 SKILL.md**

内容包括以下小节（按顺序）：

1. **YAML frontmatter**
   - `name: using-dev`
   - `description:` 必须包含触发关键词：`写需求 / 改 bug / 修复 / 新功能 / 重构 / 优化 / debug / 实现 / 开发 / 加个功能 / write feature / fix bug / refactor / implement`，以及"开干"、"走完整开发流程"、"/dev"等显式口令；并明确不触发场景

2. **# Using Dev**
   - 一句话定位："开发总入口——根据任务复杂度（L0-L3）编排 friendly-* / github-* / superpowers 等子 skill。"

3. **## 触发与开场**
   - 三类触发路径表（关键词 / 显式口令 / 不触发场景）
   - 开场固定 5 步（语言检测、Repo 检测、等级判定、向用户确认、用户确认后动手）
   - 用户确认话术模板示例

4. **## 等级判定与编排**
   - L0-L3 表（条件、链路、是否建 issue）
   - 判定原则四条（模糊取低档 / 允许降级 / 拒绝建 issue 提示风险但不拦截 / PM 类默认 L2）
   - 引用 `references/level-decision.md` 看细则

5. **## 语言适配**
   - 语言适配表
   - 引用 `references/language-stack.md`

6. **## Repo 适配（降级策略）**
   - 检测顺序流程
   - 降级模式行为：跳过所有 `gh` 调用，正常走 `brainstorming` / `writing-plans` + 编码 + 本地 commit

7. **## Commit Message 规范**
   - 沿用 `github-issue-workflow` 现有约定（`<type>: <description>` + `Closes #N`）

8. **## 收尾流程**
   - 按 L 等级的收尾动作表
   - 复盘触发规则（L2 询问 / L3 默认 + ADR）
   - 引用 `references/postmortem.md`

9. **## 红线（Red Flags）**
   - 列出绝对要避免的反模式：
     - 跳过开场确认直接动手
     - 用户拒绝 issue 后不提示风险
     - L3 改动不写 ADR
     - 在没检测语言/Repo 时假设是 GitHub Python 项目

10. **## 关联 Skills**
    - 列出会编排的所有子 skill：`friendly-python` / `github-create-issue` / `github-issue-workflow` / `brainstorming` / `writing-plans` / `executing-plans` / `architecture-designer` / `self-improving`
    - 引用 `references/orchestration-cheatsheet.md`

**Step 3: Verify**

```bash
# 检查关键词覆盖
grep -E "(改 bug|新功能|重构|debug|/dev|开干)" skills/using-dev/SKILL.md
# 检查 4 个 references 文件都被引用
grep -E "references/(level-decision|language-stack|postmortem|orchestration-cheatsheet)\.md" skills/using-dev/SKILL.md | wc -l
```

Expected:
- 第一条命令有匹配输出
- 第二条命令输出 ≥ 4

**Step 4: Commit**

```bash
git add skills/using-dev/SKILL.md
git commit -m "feat(using-dev): add main SKILL.md with L0-L3 orchestration"
```

---

## Task 2: 写 `references/level-decision.md`

**Files:**
- Create: `skills/using-dev/references/level-decision.md`

**Step 1: 写内容**

包含：

1. **判定流程（伪代码）**
   - 读用户原话 + `git status` 推断改动范围
   - 显式信号优先级表
   - 模糊时取较低档 + 用户可升级
   - 永远允许用户主动降级

2. **L0-L3 信号细则表**

   | 等级 | 触发信号 | 边界 case |
   |------|---------|----------|
   | L0 | 单行改动 / typo / 改注释 / 调日志级别 / 格式化 | 涉及多个文件的批量格式化算 L1 |
   | L1 | 单 bug 修复 / 单功能小调整 / 改一个函数 | 修复牵动多个调用方算 L2 |
   | L2 | 新功能 / 跨模块改动 / 重构非核心模块 / 新增依赖 | 涉及对外接口算 L3 |
   | L3 | 公共 API 变更 / 数据模型变更 / 架构调整 / 安全相关 / 模块拆分 | — |

3. **常见关键词 → 等级映射表**

   | 用户说 | 默认等级 |
   |--------|----------|
   | "改个 typo" / "调日志" | L0 |
   | "修个 bug" | L1（有跨模块迹象升 L2） |
   | "加个功能" / "实现 X" | L2 |
   | "重构 X 模块" | L2（核心模块升 L3） |
   | "调整架构" / "改数据模型" / "拆 X 服务" | L3 |

4. **PM 类需求特殊处理**
   - 默认 L2 起步
   - 必须读 issue body 中 `MVP 定义` 字段
   - 切片实现：MVP 内的算 L2，超出部分开 follow-up issue

5. **降级请求处理**
   - 用户说"别建 issue 直接改" → 降回 L0/L1（看改动范围）
   - 用户说"先不要 plan 了，直接写" → 跳过 `writing-plans` 但仍然走其他步骤

**Step 2: Verify**

```bash
grep -E "^### |^## " skills/using-dev/references/level-decision.md
```

Expected: 输出包含上面 5 个章节标题。

**Step 3: Commit**

```bash
git add skills/using-dev/references/level-decision.md
git commit -m "feat(using-dev): add level-decision reference"
```

---

## Task 3: 写 `references/language-stack.md`

**Files:**
- Create: `skills/using-dev/references/language-stack.md`

**Step 1: 写内容**

包含：

1. **语言检测信号优先级**
   - 1st：`pyproject.toml` / `package.json` / `go.mod` / `Cargo.toml` 等 manifest 文件
   - 2nd：源码文件后缀统计（`*.py` / `*.ts` / `*.go` / `*.rs` 等）
   - 3rd：仓库主语言（`gh repo view --json languages`）

2. **语言适配表**（与 SKILL.md 一致 + 扩展每个语言的"通用规范回退"）

   | 语言 | 编码规范 skill | 未实现时回退到 |
   |------|----------------|----------------|
   | Python | `friendly-python`（已有） | — |
   | TypeScript / JavaScript | `friendly-typescript`（TODO） | ESLint / Prettier 默认 + 项目内 `.eslintrc` |
   | Go | `friendly-go`（TODO） | `gofmt` + `golangci-lint` 默认 + Effective Go |
   | Rust | `friendly-rust`（TODO） | `rustfmt` + `clippy` 默认 |
   | Shell | 无 | shellcheck 默认 + Google Shell Style Guide |
   | 其他 | 无 | agent 通用规范 |

3. **多语言项目处理**
   - 单仓库多语言时，按"本次改动涉及的文件"决定挂载哪个 friendly-*
   - 例：改 `backend/*.py` + `frontend/*.ts` → 同时挂 `friendly-python` 和 ESLint 回退规范

4. **未实现时的开场提示话术**
   ```
   "当前是 Go 项目，暂无 friendly-go skill，编码规范走 gofmt + golangci-lint 默认 + Effective Go。"
   ```

5. **未来新增 friendly-* 的步骤（给后人留路）**
   - Step 1：在 `skills/friendly-<lang>/SKILL.md` 实现
   - Step 2：更新本文件语言适配表
   - Step 3：更新 SKILL.md 的语言适配小节

**Step 2: Verify**

```bash
grep -c "friendly-" skills/using-dev/references/language-stack.md
```

Expected: 至少 5 次匹配（`friendly-python` / `friendly-typescript` / `friendly-go` / `friendly-rust` / `friendly-<lang>`）

**Step 3: Commit**

```bash
git add skills/using-dev/references/language-stack.md
git commit -m "feat(using-dev): add language-stack reference"
```

---

## Task 4: 写 `references/postmortem.md`

**Files:**
- Create: `skills/using-dev/references/postmortem.md`

**Step 1: 写内容**

包含：

1. **触发规则**
   - L0：不触发
   - L1：不触发（除非用户主动要）
   - L2：询问"做个 5 分钟轻量复盘吗？"
   - L3：默认调用 `self-improving` skill 走完整复盘 + 询问是否写 ADR

2. **轻量复盘模板（L2 用）**

   ```markdown
   ## 复盘 - <issue 标题> (#N)
   
   **日期：** YYYY-MM-DD  
   **等级：** L2  
   
   ### 偏离与原因
   - 实现是否偏离了原始 issue / plan？为什么？
   
   ### 规范遵守
   - 哪些 friendly-* 规则被破坏？是规则不合理还是落地有问题？
   
   ### 流程动作
   - 哪些子 skill 被跳过？跳过对错？
   
   ### 改进建议
   - 下次类似场景，using-dev 应该怎么调整判定 / 编排？
   ```

3. **完整复盘流程（L3 用，引用 self-improving）**
   - 调用 `self-improving` skill
   - 把上面的轻量模板作为输入
   - 额外加：架构决策回顾、对未来变更的影响评估

4. **沉淀位置**
   - 复盘结论写到 `docs/learnings/YYYY-MM-DD-<topic>.md`
   - ADR 写到 `docs/adr/YYYYMMDD-<topic>.md`
   - 两个目录如不存在则首次执行时创建

5. **复盘转化为 skill 改进的链路**
   - 每月扫一遍 `docs/learnings/`，把高频问题转成 issue
   - 反过来更新 `using-dev` SKILL.md 或 `level-decision.md`

**Step 2: Verify**

```bash
grep -E "(L0|L1|L2|L3)" skills/using-dev/references/postmortem.md | wc -l
```

Expected: ≥ 4（4 个等级都被提到）

**Step 3: Commit**

```bash
git add skills/using-dev/references/postmortem.md
git commit -m "feat(using-dev): add postmortem reference"
```

---

## Task 5: 写 `references/orchestration-cheatsheet.md`

**Files:**
- Create: `skills/using-dev/references/orchestration-cheatsheet.md`

**Step 1: 写内容**

包含：

1. **场景 → skill 速查表**

   | 场景 | 推荐 skill | 触发时机 |
   |------|-----------|---------|
   | 需求模糊、不知道做啥 | `brainstorming` | L2/L3 进入开发前 |
   | 任务清楚但步骤多 | `writing-plans` | L2/L3 brainstorming 之后、动手之前 |
   | 已有 plan 要按部就班执行 | `executing-plans` | 任何等级，有 plan 就用 |
   | 架构级决策 | `architecture-designer` | L3 必用 |
   | 改 Python 代码 | `friendly-python` | 任何等级，遇到 `.py` 文件就贯穿 |
   | 要建 issue | `github-create-issue` | L1 询问后 / L2/L3 必用 |
   | 端到端推进 issue | `github-issue-workflow` | L1+ 用，等级越高越严格 |
   | 完成后复盘 | `self-improving` | L2 询问 / L3 默认 |
   | 调试疑难问题 | `debug-pro` | 任何等级，bug 不明时用 |
   | git 工作树管理 | `git-essentials` / 工作树 | L2/L3 多分支并行时 |

2. **典型组合（"剧本"）**

   - **L0 剧本：** 直接读文件 → 改 → `friendly-python` 自检 → commit
   - **L1 剧本：** 询问 issue → `github-create-issue`（如选建）→ `gh issue develop` → 改 → `friendly-python` → 测试 → `code-reviewer` → PR
   - **L2 剧本：** `brainstorming`（如需）→ `writing-plans` → `github-create-issue` → `gh issue develop` → 按 plan 执行 → `friendly-python` → 测试 → `code-reviewer` → PR → 询问复盘
   - **L3 剧本：** `architecture-designer` + ADR → `brainstorming` → `writing-plans` → `github-create-issue`（带 `architecture` 标签）→ `gh issue develop` → 按 plan 执行 → `friendly-python` → 测试 → `code-reviewer` → PR → 默认复盘

3. **跳过策略（用户主动 opt-out）**

   | 用户说 | 跳过什么 | 仍保留什么 |
   |--------|----------|-----------|
   | "别建 issue" | `github-create-issue` / `github-issue-workflow` | `friendly-*` + 本地 commit 规范 |
   | "不需要 plan" | `writing-plans` | 其他全部 |
   | "不复盘" | `self-improving` | — |
   | "直接改" | 所有 superpowers + issue 流程 | `friendly-*` 规范 |

**Step 2: Verify**

```bash
# 检查所有应该编排的 skill 都被列到
for s in friendly-python github-create-issue github-issue-workflow brainstorming writing-plans executing-plans architecture-designer self-improving; do
  grep -q "$s" skills/using-dev/references/orchestration-cheatsheet.md || echo "MISSING: $s"
done
```

Expected: 无 `MISSING:` 输出。

**Step 3: Commit**

```bash
git add skills/using-dev/references/orchestration-cheatsheet.md
git commit -m "feat(using-dev): add orchestration cheatsheet"
```

---

## Task 6: 同步更新 README.md

**Files:**
- Modify: `README.md`（Skills 表格）

**Step 1: 读现有表格**

```bash
grep -n "^|" README.md | head -20
```

确认 Skills 表的位置和格式。

**Step 2: 在表中插入新行**

在 `friendly-python` 行之上插入：

```markdown
| **using-dev** | Developer entry-point: detects task level (L0-L3) and orchestrates friendly-*, github-*, and superpowers skills end-to-end |
```

理由：`using-dev` 作为入口应排第一。

**Step 3: Verify**

```bash
grep "using-dev" README.md
```

Expected: 1 行匹配。

**Step 4: Commit**

```bash
git add README.md
git commit -m "docs(readme): list using-dev as the developer entry-point skill"
```

---

## Task 7: 同步更新 using-devkit/SKILL.md

**Files:**
- Modify: `skills/using-devkit/SKILL.md`

**Step 1: 读现有内容**

```bash
cat skills/using-devkit/SKILL.md
```

**Step 2: 在 Available Skills 表中插入新行**

在 `friendly-python` 之上插入：

```markdown
| **using-dev** | 开发总入口：根据任务复杂度（L0-L3）自动编排 friendly-*、github-*、superpowers 系列 skills，覆盖从"改 typo"到"架构级新功能"的全光谱开发场景 |
```

并在表格上方加一句说明：

```markdown
> **开发场景首选：** 直接喊"开干"或描述开发任务（写需求 / 改 bug / 重构 等），`using-dev` 会按等级自动编排所有需要的子 skill。
```

**Step 3: Verify**

```bash
grep "using-dev" skills/using-devkit/SKILL.md
```

Expected: ≥ 2 行匹配（说明 + 表格行）。

**Step 4: Commit**

```bash
git add skills/using-devkit/SKILL.md
git commit -m "docs(using-devkit): list using-dev as developer entry-point"
```

---

## Task 8: 验收 - 对照设计文档跑 6 个验收标准

**Files:** N/A（仅人工/模拟验证）

**Step 1: 检查文件齐备**

```bash
ls -la skills/using-dev/ skills/using-dev/references/
```

Expected:
```
skills/using-dev/SKILL.md
skills/using-dev/references/level-decision.md
skills/using-dev/references/language-stack.md
skills/using-dev/references/postmortem.md
skills/using-dev/references/orchestration-cheatsheet.md
```

**Step 2: 逐条核验设计文档的 7 个验收标准**

读 `docs/plans/2026-04-23-using-dev-skill-design.md` 的「验收标准」小节，对每条用对应内容回答：

- [ ] "帮我修个 typo" → SKILL.md / level-decision.md 是否清晰说明走 L0、不问 issue？
- [ ] "加个新功能 X" → 是否走 L2、先 brainstorming → 询问建 issue？
- [ ] "重构核心模块" → 是否走 L3、先 architecture-designer？
- [ ] 无 GitHub remote → SKILL.md Repo 适配小节是否说明降级行为？
- [ ] Python 项目 → 是否在所有等级都贯穿 friendly-python？
- [ ] L2/L3 流程结束 → 是否有复盘触发说明？
- [ ] README 与 using-devkit 表格 → 是否同步更新？

每条找出对应的文档段落作为证据。

**Step 3: 模拟两个典型对话验证 SKILL.md**

模拟用户说"帮我加个用户登录功能"：
- Skill 应识别为 L2
- 开场确认应包含语言/Repo 检测 + 等级建议
- 应提到 brainstorming → writing-plans → github-create-issue 链路

模拟用户说"改个 print 拼写"：
- Skill 应识别为 L0
- 不问 issue
- 直接走 friendly-python 检查 → commit

**Step 4: 修复发现的问题（如有）**

如果某条验收标准在文档中表述不清，补充说明并 amend 对应 commit。

**Step 5: 最终 commit（仅当 Step 4 有改动）**

```bash
git add -A
git commit -m "docs(using-dev): clarify <specific point> based on acceptance review"
```

---

## Task 9: 准备 PR

**Files:** N/A

**Step 1: 检查 commit 历史干净**

```bash
git log --oneline main..HEAD
```

Expected: 7-9 个 commit，每个对应一个 task，message 清晰。

**Step 2: 推送分支**

```bash
git push -u origin feat/using-dev-skill
```

**Step 3: 创建 PR**

```bash
gh pr create --title "feat: add using-dev skill as developer entry-point" --body "$(cat <<'EOF'
## 背景

devkit 现有 friendly-python / github-create-issue / github-issue-workflow / brainstorming 等开发相关 skill，使用时需用户分别记忆和触发。本 PR 引入 `using-dev` 作为开发总入口，根据任务复杂度（L0-L3）自动编排所有相关 skill。

## 核心改动

- 新增 `skills/using-dev/` 目录，含 SKILL.md + 4 个 references
- 同步更新 `README.md` 与 `skills/using-devkit/SKILL.md`，让新 skill 可被发现
- 设计文档：`docs/plans/2026-04-23-using-dev-skill-design.md`
- 实施计划：`docs/plans/2026-04-23-using-dev-skill-plan.md`

## 关键设计

- **触发：** 关键词 + 显式口令 + 开场确认（混合模式，避免误触发）
- **分层：** L0（typo/log）/ L1（单 bug）/ L2（新功能）/ L3（架构）
- **语言适配：** 通用骨架 + Python 专用规范，未来可扩展 friendly-go / friendly-typescript 等
- **Repo 适配：** 无 GitHub remote 时自动降级，跳过 issue 流程
- **复盘：** L2 询问 / L3 默认触发 self-improving

## 验收

设计文档「验收标准」小节的 7 条全部通过（详见 Task 8 的验证记录）。
EOF
)"
```

Expected: PR 创建成功，URL 输出。

---

## Done Criteria

- [ ] 9 个 task 全部完成且各有独立 commit
- [ ] 7 条验收标准全部找到对应文档段落
- [ ] PR 创建成功
- [ ] 后续可在新会话里直接说"开干"或"加个功能"测试 skill 触发
