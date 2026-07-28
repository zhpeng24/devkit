# Orchestration Cheatsheet — 场景 → Skill 速查

主 SKILL.md 的「关联 Skills」给了概览。本文件是开发过程中的速查表：什么场景该调什么、典型剧本怎么走、用户 opt-out 时怎么裁剪。

## 场景 → Skill 速查

| 场景 | 推荐 skill | 触发时机 |
|------|-----------|---------|
| 需求模糊、不知道做啥 | `brainstorming` | L2/L3 进入开发前 |
| 任务清楚但步骤多 | `writing-plans` | L2/L3 在 brainstorming 之后、动手之前 |
| 已有 plan 要按部就班执行 | `executing-plans` | 任意等级，有 plan 就用 |
| 架构级决策 | `brainstorming` + 本地 ADR 流程 | L3；外部 skill 不可用时也能执行 |
| 改 Python 代码 | `friendly-python` | 任意等级，遇到 `.py` 就贯穿 |
| 改 TypeScript / Go / Rust | `friendly-<lang>`（未实现回退默认工具） | 任意等级 |
| 要建 issue | `github-create-issue` | L1 询问后 / L2/L3 必用 |
| 端到端推进 issue | `github-issue-workflow` | L1+ 用，等级越高越严格 |
| 完成后复盘 | `references/postmortem.md` | L2 询问 / L3 默认 |
| 调试疑难问题 | `systematic-debugging`（不可用时走本地原因优先流程） | 任意等级，bug 不明时按需调用 |
| 交付验证 | `verification-before-completion`（不可用时跑项目检查） | 完整逻辑增量或需求完成后 |
| git 工作树管理 / 多分支并行 | `git-essentials` / 工作树相关 | L2/L3 多任务并行时 |
| 代码评审 | review agent 或本地 checklist | 完整功能/修复批次结束后；L0 可跳过 |

## 测试原则速查

- 先识别关键风险和失败模式，再决定测什么；不以测试数量、覆盖率数字或重复次数代替判断。
- 开发中只跑能指导下一步的快速检查；完整功能或逻辑批次结束后跑目标测试，需求交付前统一跑回归。
- 优先保留断言明确、缺陷出现时真的会失败、能覆盖边界/错误路径且结果稳定的高信息量测试。
- 代码、配置、依赖和环境没有相关变化时，不重复跑同一套测试。
- 文档、skill、元数据等同类改动批量完成后统一校验，不为每个文件单独启动全量回归和评审。
- 安全、迁移、并发、公共接口兼容性和 bug 复现可提前做针对性测试，但仍以风险为依据。

## 典型剧本

### L0 剧本：改个 typo / 调日志

```
1. 检测语言 + Repo（开场必做）
2. 一句话告诉用户："识别为 L0，直接改，跳过 issue"
3. 编辑文件
4. friendly-* 自检（仅本文件）
5. git commit
6. 结束
```

### L1 剧本：修单 bug

```
1. 检测语言 + Repo
2. 询问用户："识别为 L1。要建 issue 留追溯吗？(a) 我帮你建 (b) 已有 issue #N (c) 跳过"
3a. 选 a → 调 github-create-issue → 得到 issue #N
3b. 选 b → 直接用现有 #N
3c. 选 c → 告知风险，跳过 issue
4. （3a/3b 走）gh issue develop <N> --base main --name fix/issue-<N> --checkout
5. 读受影响代码
6. 改 → friendly-* 贯穿
7. 完成修复批次后跑目标测试（pytest -v --tb=short 或对应语言的等价命令）
8. 调 code-reviewer subagent
9. commit + push
10. gh pr create（或 gh issue close 走直推流）
11. 结束
```

### L2 剧本：加新功能

```
1. 检测语言 + Repo
2. 一句话告诉用户："识别为 L2，准备走完整流程"
3. （需求模糊时）→ brainstorming 澄清，输出设计文档到 docs/plans/
4. → writing-plans 拆 task，输出 plan 到 docs/plans/
5. → github-create-issue 建 issue（标 feature）
6. gh issue develop <N> --base main --name feat/issue-<N> --checkout
7. → executing-plans 按 plan 推进
8. 编码全程贯穿 friendly-*
9. 完成功能批次后跑目标测试；交付前跑一次回归
10. → code-reviewer subagent
11. commit + push
12. gh pr create
13. 询问用户："做个 5 分钟轻量复盘吗？/ skip"
14. （选复盘）→ 写 docs/learnings/YYYY-MM-DD-<topic>.md
15. 结束
```

### L3 剧本：架构调整 / 改公共 API

```
1. 检测语言 + Repo
2. 一句话告诉用户："识别为 L3，需要架构级决策与 ADR"
3. → brainstorming 比较架构方案（不可用时在本地记录备选与取舍）
4. 写 ADR 到 docs/adr/YYYYMMDD-<topic>.md
5. → brainstorming（如有未澄清点）
6. → writing-plans 拆 task
7. → github-create-issue 建 issue（标 architecture + 关联 ADR）
8. gh issue develop <N> --base main --name feat/issue-<N> --checkout
9. → executing-plans 按 plan 推进
10. 编码全程贯穿 friendly-*
11. 跑测试 + 跑架构守护测试（如有）
12. → code-reviewer subagent
13. commit + push（每个逻辑组一个 commit）
14. gh pr create（在 PR body 引用 ADR）
15. 按 references/postmortem.md 走完整复盘
16. 写 docs/learnings/YYYY-MM-DD-<topic>.md
17. 结束
```

## 跳过策略（用户主动 opt-out）

| 用户说 | 跳过 | 仍保留 |
|--------|------|--------|
| "别建 issue 直接改" | `github-create-issue` / `github-issue-workflow` | `friendly-*` + 本地 commit + 复盘（如适用） |
| "不需要 plan，直接写" | `writing-plans` / `executing-plans` | `friendly-*` + issue 流程（如已建）+ 复盘 |
| "不复盘" | 本地 postmortem | — |
| "直接改" / "快点" | 所有 superpowers + issue 流程 | `friendly-*`（永远保留）|
| "不需要 ADR" (L3) | ADR 写作 | 提示一次"L3 不写 ADR 风险大"后尊重用户 |

**通用规则：**
- `friendly-*` **永远保留**——编码规范是底线，不能跳
- 跳过 issue 流程时，commit message 仍按 `<type>: <description>` 规范写
- 跳过 plan 时，必须告知"复杂任务跳 plan 易遗漏，回头返工成本高"

## 与 superpowers 的边界

`using-dev` 是**编排者**，不重新发明 superpowers 的功能：

| superpowers skill | using-dev 怎么用 |
|------------------|-------------------|
| `brainstorming` | 直接调，让 brainstorming 输出设计文档；using-dev 不替代它做需求澄清 |
| `writing-plans` | 直接调，使用其 plan 模板；using-dev 不重写计划格式 |
| `executing-plans` | 直接调，按其检查点机制推进；using-dev 不替代任务执行 |
| `systematic-debugging` | 疑难 bug 时优先调；不可用则执行本地复现、假设、实验、修复、回归流程 |
| `verification-before-completion` | 在完整增量交付前调；不可用则直接运行项目目标测试与回归 |

如果发现 superpowers 的某个 skill 不够用，**反馈到 superpowers 仓库**，不要在 `using-dev` 里塞副本。

## 反模式（避免）

- ❌ 在 L0 剧本里加上 `code-reviewer` ——typo 不需要 review，徒增摩擦
- ❌ 在 L2/L3 剧本里跳过 `friendly-*` ——编码规范是底线
- ❌ 跳过 `gh issue develop`，用 `git checkout -b` 直接建分支 ——分支不会挂到 issue Development 面板，PR 合入时不会自动 close issue
- ❌ 同一 commit 混入多个 issue 的改动 ——破坏可逆性
- ❌ 不读 issue body 直接动手 ——大概率走偏
- ❌ 用测试数量、覆盖率数字或重复执行次数代替关键风险分析
- ❌ 每改一个文件就跑全量回归或启动独立评审，打断完整功能开发
- ❌ 添加不会在真实缺陷出现时失败、没有有效断言的“展示型测试”
