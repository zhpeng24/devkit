# Postmortem — L2/L3 复盘模板与沉淀机制

主 SKILL.md 的「收尾流程」指出 L2 询问复盘、L3 默认复盘。本文件提供：触发规则细则、轻量与完整复盘模板、ADR 模板、沉淀位置、以及把复盘转化为 skill 改进的链路。

## 触发规则

| 等级 | 复盘触发 |
|------|----------|
| L0 | ❌ 不触发 |
| L1 | ❌ 不触发（除非用户主动要求） |
| L2 | ⚠️ **询问**："刚走完一个 L2 流程，做个 5 分钟轻量复盘吗？/ skip" |
| L3 | ✅ **默认调用 `self-improving` skill** + 询问是否写 ADR |

**重要：** L2 询问要给"skip"明确选项，不强制；L3 默认走，但用户可以拒绝。

## 轻量复盘模板（L2）

文件路径：`docs/learnings/YYYY-MM-DD-<topic>.md`

```markdown
# 复盘 - <issue 标题> (#N)

**日期：** YYYY-MM-DD
**等级：** L2
**关联：** issue #N、PR #M、commit <sha>

## 偏离与原因

- 实现是否偏离了原始 issue / plan？哪里偏？为什么？
- 偏离是否合理？合理 → 记录新认知；不合理 → 下次怎么避免？

## 规范遵守

- 哪些 friendly-* 规则被破坏？
- 是规则不合理（→ 反馈到对应 skill 的 issue），还是落地有问题（→ 下次注意）？

## 流程动作

- 哪些子 skill 被跳过了？
- 跳过的对错？正确跳过 → 记录适用条件；错误跳过 → 下次别再跳。

## 改进建议

- 下次类似场景，using-dev 的判定 / 编排应该怎么调整？
- 是否需要更新 references/level-decision.md 或 orchestration-cheatsheet.md？
```

## 完整复盘流程（L3）

L3 改动牵动更大，复盘更深入。流程：

1. **调用 `self-improving` skill** 引导深度反思
2. **以上述轻量模板为基础**，额外补充：
   - **架构决策回顾**：实际架构与 ADR 是否一致？偏差原因？
   - **对未来变更的影响评估**：本次改动对系统的可维护性、可扩展性影响如何？
   - **依赖与契约变化**：是否引入新依赖？公共契约是否变化？兼容性影响？
3. **必写 ADR**：见下面「ADR 模板」

## ADR 模板（L3 必写）

文件路径：`docs/adr/YYYYMMDD-<topic>.md`

```markdown
# ADR <序号>: <标题>

**日期：** YYYY-MM-DD
**状态：** Accepted | Superseded by ADR-XXX | Deprecated
**关联：** issue #N、PR #M

## 背景

<为什么要做这个决策？当前系统的什么状态促成了这次改动？>

## 决策

<我们决定做什么？1-3 句话讲清楚最终选择。>

## 备选方案

<考虑过哪些其他方案？为什么没选？至少列 1 个被否的备选。>

## 后果

### 积极
- ...

### 消极 / 代价
- ...

### 中性
- ...

## 实施

- 关键 commit：<sha>
- 影响模块：<列表>
- 数据迁移 / 兼容措施：<如有>
```

## 沉淀位置

| 产物 | 路径 |
|------|------|
| L2 复盘 | `docs/learnings/YYYY-MM-DD-<topic>.md` |
| L3 复盘 | `docs/learnings/YYYY-MM-DD-<topic>.md`（与 L2 同位置）|
| ADR | `docs/adr/YYYYMMDD-<topic>.md` |

两个目录如不存在，**首次复盘时自动创建**：

```bash
mkdir -p docs/learnings docs/adr
```

## 复盘转化为 skill 改进的链路

复盘不是终点，而是 skill 自身迭代的输入。建议节奏：

1. **每月扫一遍 `docs/learnings/`**——找出高频问题
2. **把高频问题转成 issue**——用 `github-create-issue` 建对应的 `tech-debt` 或 `optimization` issue
3. **反过来更新 `using-dev`**：
   - 判定问题 → 改 `references/level-decision.md`
   - 编排问题 → 改 `references/orchestration-cheatsheet.md`
   - 触发问题 → 改主 SKILL.md 的 description 关键词或开场流程
4. **更新通过自身的 `using-dev` 流程做**——形成自举闭环

## 反模式（避免）

- ❌ L3 改动跳过 ADR——架构决策没有书面记录，半年后没人记得为什么这么做
- ❌ 复盘走过场（复制模板填几个字）——不如不写
- ❌ 复盘后不沉淀到 `docs/learnings/`——只在对话里说一下，下次没人看得到
- ❌ 用户拒绝 L3 复盘后不再追问——下次同类型 L3 又跳过，永远没复盘
- ❌ 把 L0/L1 也复盘——增加摩擦，复盘价值低
