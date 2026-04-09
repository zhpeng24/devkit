---
name: using-devkit
description: Use when starting any conversation — establishes how to find and use devkit skills
---

# Using Devkit

Devkit is a developer toolkit that provides coding skills for your AI agent. Skills load automatically when relevant to your task.

## Available Skills

| Skill | Description |
|-------|------------|
| **friendly-python** | Python code cleanup: Pyright strict mode, modern typing, automated formatting, Pylint fixes |

## How Skills Work

1. Agent receives your request
2. Checks if any devkit skill applies
3. Loads and follows the relevant skill

## Invoking Skills

- **Claude Code:** `Skill` tool → `devkit:friendly-python`
- **Copilot CLI:** `skill` tool → `friendly-python`
- **Cursor:** `/friendly-python` or skill auto-triggers
- **Codex:** `skill` tool → `devkit/friendly-python`
- **Gemini CLI:** `activate_skill` tool
- **OpenCode:** `skill` tool → `devkit/friendly-python`
