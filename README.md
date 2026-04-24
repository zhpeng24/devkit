# Devkit

Developer toolkit — a collection of coding skills for AI agents, usable across all major platforms.

## Skills

| Skill | Description |
|-------|-------------|
| **using-devkit** | Devkit entry-point: helps agents discover and invoke the available devkit skills |
| **using-dev** | Developer entry-point: detects task level (L0-L3) and orchestrates `friendly-*`, `github-*`, and superpowers skills end-to-end |
| **friendly-python** | Python code cleanup: Pyright strict mode, modern typing, automated formatting (`ruff`), Pylint fix patterns |
| **mihomo-proxy-setup** | User-space Mihomo proxy installer: Clash subscription, Web UI, dev tool wrappers (Cursor/Copilot/Claude), Linux + macOS |
| **github-create-issue** | Structured GitHub issue creation with `gh` CLI — enforces background, impact, acceptance criteria sections and consistent labeling |
| **github-issue-workflow** | End-to-end GitHub issue development workflow — triage, develop, code review, ship |
| **github-product-manager** | Product requirement analysis: clarifies feature ideas and turns scoped requirements into GitHub issues |

## Installation

One-liner install — pick your platform:

**macOS / Linux:**

```bash
# curl cannot show the interactive menu; specify a platform directly
curl -fsSL https://raw.githubusercontent.com/zhpeng24/devkit/main/scripts/install.sh | bash -s -- claude

# Local clone interactive menu
bash scripts/install.sh
```

**Windows (PowerShell):**

```powershell
# Interactive menu
& ([scriptblock]::Create((irm https://raw.githubusercontent.com/zhpeng24/devkit/main/scripts/install.ps1)))

# Or specify a platform directly
& ([scriptblock]::Create((irm https://raw.githubusercontent.com/zhpeng24/devkit/main/scripts/install.ps1))) -Platform claude
```

Supported platforms: `claude` · `cursor` · `copilot` · `codex` · `opencode` · `gemini`

<details>
<summary>Manual installation</summary>

### Claude Code

```bash
claude plugins marketplace add https://github.com/zhpeng24/devkit.git
claude plugins install devkit
```

### Cursor

```bash
git clone https://github.com/zhpeng24/devkit.git ~/.cursor/plugins/local/devkit
# Restart Cursor to detect the plugin
```

Cursor loads the plugin for agent use. In Cursor 4.17, plugin skills may auto-trigger from natural language instead of appearing as slash commands.

### GitHub Copilot CLI

```bash
git clone https://github.com/zhpeng24/devkit.git ~/.copilot/plugins/devkit
copilot plugin install ~/.copilot/plugins/devkit
```

### Codex

```bash
git clone https://github.com/zhpeng24/devkit.git ~/.codex/devkit
mkdir -p ~/.agents/skills
ln -s ~/.codex/devkit/skills ~/.agents/skills/devkit
```

### OpenCode

Add to `opencode.json`:

```json
{
  "plugin": ["devkit@git+https://github.com/zhpeng24/devkit.git"]
}
```

### Gemini CLI

```bash
gemini extensions install https://github.com/zhpeng24/devkit.git
```

</details>

## What's Inside

### friendly-python

A comprehensive Python code cleanup skill that enforces:

- **Pyright strict mode** with proper venv configuration
- **Modern Python 3.12+** — `type` statements, built-in generics, `X | None`
- **Automated formatting** — `ruff format`, `ruff check --select I`
- **Full type annotations** — parameters, returns, instance attributes
- **Clean imports** — no empty `__init__.py`, no `TYPE_CHECKING`, no re-exports
- **Pylint fix patterns** — unused arguments, broad exceptions, import ordering
- **TypedDict / Protocol / Literal** over loose `dict` / `Any`

### mihomo-proxy-setup

A complete user-space proxy installer and manager:

- **Mihomo (Clash.Meta)** binary — auto-detects OS and architecture
- **Clash subscription** integration with auto-update (every 30 min)
- **MetaCubeXD Web UI** panel for managing proxy rules
- **Proxy wrappers** — `with-proxy`, `proxy-agent`, `proxy-copilot`, `proxy-claude`
- **Service management** — systemd (Linux) / launchd (macOS) user services
- **Uninstall** — full cleanup of all files, services, and configuration
- **No root required** — everything runs in user space

### github-create-issue

A structured GitHub issue template skill that enforces:

- **7-section template** — 背景, 已造成问题, 当前状态, 预期改动, 影响范围, 关联, 验收标准
- **Standardized labels** — `bug`, `optimization`, `architecture`, `innovation`, `tech-debt`, `documentation`, `security`
- **Title convention** — `[模块] 简述问题或改动`
- **Section trimming** — auto-adapt required sections by issue type
- **`gh` CLI execution** — creates labels if missing, generates full `gh issue create` command

### github-issue-workflow

An end-to-end development workflow skill that enforces:

- **5-step cycle** — Triage → Plan → Develop → Review → Ship
- **Overlap detection** — shared-file issues go sequential, independent issues go parallel
- **Mandatory code review** — never skip even if "tests pass" or "changes are small"
- **Commit discipline** — one commit per logical group, issue references, excluded tests documented
- **Rationalization defense** — explicit counters for common shortcuts

### Skill Structure

```
skills/
  friendly-python/
    SKILL.md                    # Main skill document
    references/
      fix-patterns.md           # Before/after fix examples
      tool-codes.md             # Pyright/Pylint code reference
      advanced-patterns.md      # Complex type patterns
  mihomo-proxy-setup/
    SKILL.md                    # Installation/uninstall flow
    references/
      config-templates.md       # Config files and script templates
      systemd-units.md          # Linux systemd service units
      launchd-plist.md          # macOS launchd plist files
      troubleshooting.md        # Common issues and fixes
  github-create-issue/
    SKILL.md                    # Issue creation template & workflow
  github-issue-workflow/
    SKILL.md                    # Issue development lifecycle
```

## Updating

Re-run the install script — it auto-detects existing installations and updates via `git pull`:

```bash
# macOS / Linux
curl -fsSL https://raw.githubusercontent.com/zhpeng24/devkit/main/scripts/install.sh | bash -s -- claude
```

```powershell
# Windows
& ([scriptblock]::Create((irm https://raw.githubusercontent.com/zhpeng24/devkit/main/scripts/install.ps1))) -Platform claude
```

<details>
<summary>Manual update</summary>

```bash
# Claude Code
claude plugins update devkit

# Cursor
cd ~/.cursor/plugins/local/devkit && git pull

# Copilot CLI
cd ~/.copilot/plugins/devkit && git pull

# Codex
cd ~/.codex/devkit && git pull

# OpenCode — restart OpenCode (auto-updates from git)

# Gemini CLI
gemini extensions update devkit
```

</details>

## Contributing

1. Fork the repository
2. Create your skill in `skills/<skill-name>/SKILL.md`
3. Submit a PR

## License

MIT License — see [LICENSE](LICENSE) file.
