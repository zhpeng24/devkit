---
name: using-devkit
description: Use when starting any conversation — establishes how to find and use devkit skills
---

# Using Devkit

Devkit is a developer toolkit that provides coding skills for your AI agent. Skills load automatically when relevant to your task.

## Available Skills

> **开发场景首选：** 直接喊"开干"或描述开发任务（写需求 / 改 bug / 重构 等），`using-dev` 会按等级自动编排所有需要的子 skill。

| Skill | Description |
|-------|------------|
| **using-dev** | 开发总入口：根据任务复杂度（L0-L3）自动编排 `friendly-*`、`github-*`、superpowers 系列 skills，覆盖从"改 typo"到"架构级新功能"的全光谱开发场景 |
| **friendly-python** | Python code cleanup: Pyright strict mode, modern typing, automated formatting, Pylint fixes |
| **github-create-issue** | Structured GitHub issue creation with `gh` CLI — enforces template sections and consistent labeling |
| **github-issue-workflow** | End-to-end issue development workflow — triage, develop, code review, ship |
| **github-product-manager** | Product manager-style requirement analysis — refines ideas through Q&A and produces structured product requirement GitHub issues |

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
