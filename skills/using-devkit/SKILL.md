---
name: using-devkit
description: Use when starting any conversation — establishes how to find and use devkit skills
---

# Using Devkit

Devkit is a developer toolkit that provides coding skills for your AI agent. Skills load automatically when relevant to your task.

## Available Skills

> **开发场景首选：** 直接喊“开干”或描述开发任务。`using-dev` 默认进入
> SIES，L0–L3 只调节探索、证据、GitHub 产物和回归深度。

| Skill | Description |
|-------|------------|
| **using-dev** | 开发总入口：默认把代码任务路由到 SIES，并按 L0–L3 缩放阶段深度 |
| **sies-engineering** | 目标优先、证据驱动的默认研发序列；测试验证目标一致性，TDD 按场景选择 |
| **friendly-python** | Python code cleanup: Pyright strict mode, modern typing, automated formatting, Pylint fixes |
| **humanizing-writing** | 中英文去 AI 味：按日常写作、技术文档和 PR 描述调整表达，同时保留事实与作者语气 |
| **taste-skill** | 网页设计与重设计：先读产品、受众、品牌和现有技术栈，再建立适合当前项目的视觉系统 |
| **image-to-code-skill** | 从截图、Figma 或批准的视觉参考实现网页，并按源视口和响应式视口校验还原度 |
| **imagegen-frontend-web** | 只生成网站概念图和分区参考图，不输出代码 |
| **imagegen-frontend-mobile** | 只生成 iOS、Android 或跨平台移动端屏幕与流程图，不输出代码 |
| **pptx** | 创建、读取、编辑和验证 PowerPoint `.pptx`/`.potx` 文件，保护原文件并区分结构检查与视觉检查 |
| **mihomo-proxy-setup** | 在 Linux/macOS 用户空间安装和维护 Mihomo 代理、订阅、Web UI 与开发工具代理包装器 |
| **github-create-issue** | 按 Goal、Exploration、Prototype、Engineering、Learning 选择自适应 Issue Profile |
| **github-issue-workflow** | 从已有目标和证据恢复状态，在第一个未解决的 SIES 决策继续 |
| **github-product-manager** | 只追问会改变结果的未知项，形成可评价的产品 Goal Contract |

## How Skills Work

1. Agent receives your request
2. Checks if any devkit skill applies
3. Loads and follows the relevant skill

## Invoking Skills

- **Claude Code:** `Skill` tool → `devkit:<skill-name>`
- **Copilot CLI:** `skill` tool → `<skill-name>`
- **Cursor:** use natural language; skills auto-trigger when relevant and may not appear as slash commands
- **Codex:** `skill` tool → `devkit/<skill-name>`
- **Gemini CLI:** `activate_skill` tool
- **OpenCode:** `skill` tool → `devkit/<skill-name>`
