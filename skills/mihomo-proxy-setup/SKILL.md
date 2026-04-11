---
name: mihomo-proxy-setup
description: Use when the user asks to install a proxy, set up Mihomo, configure Clash subscription proxy, or set up proxy wrappers for dev tools (Cursor, Claude, Copilot). Handles full lifecycle — install, configure, verify, and uninstall — in pure user-space (no root required).
---

# Mihomo Proxy Setup

A skill for installing and managing a **Mihomo-based proxy** in user-space. Supports Linux (systemd user services) and macOS (launchd agents). No root/sudo required.

## When to Use

Trigger when the user asks to:
- Install a proxy / set up Mihomo / configure Clash subscription
- Add proxy wrappers for dev tools (Cursor, Claude, GitHub Copilot)
- Uninstall or clean up an existing Mihomo proxy setup
- Troubleshoot proxy connectivity issues

## Architecture Overview

```
┌─────────────────────────────────────────────────┐
│                  User Space                      │
│                                                  │
│  ┌───────────┐   ┌──────────────────────────┐   │
│  │  Mihomo   │◄──│ Clash Subscription YAML   │   │
│  │ (daemon)  │   │ + Local Overrides         │   │
│  │           │   └──────────────────────────┘   │
│  │ mixed:7890│                                   │
│  │ ctrl:29090│──► MetaCubeXD Web UI              │
│  └───────────┘                                   │
│       ▲                                          │
│       │ HTTP_PROXY / SOCKS5                      │
│  ┌────┴──────────────────────────┐               │
│  │ Proxy Wrappers                │               │
│  │  with-proxy <cmd>             │               │
│  │  proxy-agent   (Cursor)       │               │
│  │  proxy-copilot (GH Copilot)   │               │
│  │  proxy-claude  (Claude CLI)   │               │
│  └───────────────────────────────┘               │
│                                                  │
│  Service Manager:                                │
│    Linux → systemd --user                        │
│    macOS → launchd (~/Library/LaunchAgents)       │
└─────────────────────────────────────────────────┘
```

## Installation Flow

Follow this checklist **in order**. Use `ask_user` for interactive parameter collection.

### Phase 1: Environment Detection

- [ ] Detect OS: `uname -s` → Linux or Darwin
- [ ] Detect architecture: `uname -m` → x86_64/amd64 or aarch64/arm64
- [ ] Check for existing installation: look for `~/.local/bin/mihomo`, `~/.config/mihomo/`
- [ ] If existing installation found, ask user: **upgrade**, **reconfigure**, or **abort**
- [ ] Verify `~/.local/bin` is on PATH; if not, warn user and add to shell profile
- [ ] Verify user systemd is available (Linux: `systemctl --user status` works) or launchd (macOS)

### Phase 2: Collect Parameters (Interactive)

Ask the user **one question at a time** using `ask_user`:

| Parameter | Question | Default | Required |
|-----------|----------|---------|----------|
| `subscription_url` | "请提供你的 Clash/Mihomo 订阅链接" | — | **Yes** |
| `mixed_port` | "代理混合端口 (HTTP+SOCKS5)" | `7890` | No |
| `controller_port` | "Web UI 控制器端口" | `29090` | No |
| `controller_secret` | "Web UI 访问密码" | random 12-char | No |
| `enable_webui` | "是否安装 MetaCubeXD Web 管理面板？" | Yes | No |
| `extra_no_proxy` | "额外的 NO_PROXY 地址（逗号分隔）" | — | No |

> **IMPORTANT:** Never log, echo, or commit the subscription URL. Store it only in `~/.config/mihomo/subscription.url` with mode 600.

### Phase 3: Install Dependencies

- [ ] **Install Mihomo binary**
  - Determine download URL from [MetaCubeX/mihomo releases](https://github.com/MetaCubeX/mihomo/releases/latest)
  - File pattern: `mihomo-{os}-{arch}-latest.gz` where:
    - Linux x86_64 → `mihomo-linux-amd64-compatible-latest.gz`
    - Linux aarch64 → `mihomo-linux-arm64-latest.gz`
    - macOS x86_64 → `mihomo-darwin-amd64-latest.gz`
    - macOS arm64 → `mihomo-darwin-arm64-latest.gz`
  - Download, decompress (`gzip -d`), install to `~/.local/bin/mihomo`, chmod +x
  - Verify: `~/.local/bin/mihomo -v`

- [ ] **Install yq** (YAML merge tool)
  - Download from [mikefarah/yq releases](https://github.com/mikefarah/yq/releases/latest)
  - File pattern: `yq_{os}_{arch}` where:
    - Linux x86_64 → `yq_linux_amd64`
    - Linux aarch64 → `yq_linux_arm64`
    - macOS x86_64 → `yq_darwin_amd64`
    - macOS arm64 → `yq_darwin_arm64`
  - Install to `~/.local/bin/yq`, chmod +x
  - Verify: `~/.local/bin/yq --version`

- [ ] **Install MetaCubeXD Web UI** (if enabled)
  - Download latest release from [MetaCubeX/metacubexd](https://github.com/MetaCubeX/metacubexd/releases/latest)
  - Asset: `compressed-dist.tgz`
  - Extract to `~/.local/share/mihomo-ui/`
  - Verify the directory contains `index.html`

### Phase 4: Generate Configuration

- [ ] Create directory structure:
  ```
  ~/.config/mihomo/           # Main config directory
  ~/.config/proxy/            # Shared proxy env
  ```

- [ ] Write `~/.config/mihomo/subscription.url` (mode 600) with the subscription URL

- [ ] Write `~/.config/mihomo/overrides.yaml` — see [config-templates.md](references/config-templates.md) for template. Key fields:
  ```yaml
  mixed-port: {{mixed_port}}
  allow-lan: false
  external-controller: 127.0.0.1:{{controller_port}}
  log-level: info
  external-ui: ~/.local/share/mihomo-ui    # expand ~ to $HOME
  secret: {{controller_secret}}
  ```

- [ ] Write `~/.config/proxy/env.sh` — see [config-templates.md](references/config-templates.md). Uses `mixed_port` parameter.

- [ ] Write `~/.local/bin/update-mihomo-config` — subscription fetch + merge + validate script. See [config-templates.md](references/config-templates.md) for the full template.

- [ ] Run initial subscription update: `~/.local/bin/update-mihomo-config`
  - This downloads subscription, merges with overrides, validates, and creates `config.yaml`
  - If GeoIP database is missing, the script auto-downloads it
  - **If this fails**, stop and troubleshoot before continuing

### Phase 5: Register Service

**Linux (systemd user):**
- [ ] Write systemd unit files — see [systemd-units.md](references/systemd-units.md)
  - `~/.config/systemd/user/mihomo.service`
  - `~/.config/systemd/user/mihomo-update.service`
  - `~/.config/systemd/user/mihomo-update.timer`
- [ ] `systemctl --user daemon-reload`
- [ ] `systemctl --user enable --now mihomo.service`
- [ ] `systemctl --user enable --now mihomo-update.timer`
- [ ] Enable lingering so services survive logout: `loginctl enable-linger $(whoami)` (may need sudo — skip if unavailable, just warn user)

**macOS (launchd):**
- [ ] Write launchd plist files — see [launchd-plist.md](references/launchd-plist.md)
  - `~/Library/LaunchAgents/com.mihomo.proxy.plist`
  - `~/Library/LaunchAgents/com.mihomo.update.plist`
- [ ] Load services:
  - `launchctl load ~/Library/LaunchAgents/com.mihomo.proxy.plist`
  - `launchctl load ~/Library/LaunchAgents/com.mihomo.update.plist`

### Phase 6: Install Proxy Wrappers

- [ ] Write `~/.local/bin/with-proxy` — see [config-templates.md](references/config-templates.md)
- [ ] Write `~/.local/bin/proxy-agent` — Cursor wrapper with fallback to cursor-agent
- [ ] Write `~/.local/bin/proxy-copilot` — GitHub Copilot CLI wrapper
- [ ] Write `~/.local/bin/proxy-claude` — Claude CLI wrapper
- [ ] `chmod +x` all wrapper scripts
- [ ] Write/update `~/.bash_aliases` with aliases and `proxy-help` function — see [config-templates.md](references/config-templates.md)
- [ ] Ensure `~/.bashrc` sources `~/.bash_aliases` (add `. ~/.bash_aliases` if missing)

### Phase 7: Verification

Run ALL of these checks. Report results to the user.

- [ ] **Service running:** `systemctl --user is-active mihomo` (Linux) or `launchctl list | grep mihomo` (macOS)
- [ ] **Port listening:** `ss -tlnp | grep {{mixed_port}}` (Linux) or `lsof -iTCP:{{mixed_port}}` (macOS)
- [ ] **Controller reachable:** `curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:{{controller_port}}`
- [ ] **Proxy functional:** `curl -x http://127.0.0.1:{{mixed_port}} -s -o /dev/null -w '%{http_code}' https://www.google.com` — expect 200
- [ ] **Wrappers executable:** `with-proxy curl -s https://httpbin.org/ip`
- [ ] **Timer active:** `systemctl --user is-active mihomo-update.timer` (Linux)

### Phase 8: Report to User

After successful installation, print a summary:

```
✅ Mihomo proxy installed successfully!

📋 Configuration:
   Mixed port:     127.0.0.1:{{mixed_port}}
   Controller:     127.0.0.1:{{controller_port}}
   Web UI secret:  {{controller_secret}}
   Config dir:     ~/.config/mihomo/
   
🌐 Web UI Access:
   SSH tunnel: ssh -L {{controller_port}}:127.0.0.1:{{controller_port}} user@server
   Then open: http://127.0.0.1:{{controller_port}}/ui
   
🛠 Commands:
   with-proxy <cmd>  — Run any command through proxy
   proxy-agent       — Launch Cursor with proxy
   proxy-copilot     — Launch GitHub Copilot CLI with proxy
   proxy-claude      — Launch Claude CLI with proxy
   proxy-help        — Show all proxy commands
   
📝 Subscription auto-updates every 30 minutes.
```

---

## Uninstall Flow

When user asks to uninstall/remove the proxy, follow this checklist:

### Uninstall Checklist

- [ ] **Stop services**
  - Linux: `systemctl --user disable --now mihomo.service mihomo-update.timer`
  - macOS: `launchctl unload ~/Library/LaunchAgents/com.mihomo.proxy.plist ~/Library/LaunchAgents/com.mihomo.update.plist`

- [ ] **Remove service files**
  - Linux: `rm ~/.config/systemd/user/mihomo.service ~/.config/systemd/user/mihomo-update.service ~/.config/systemd/user/mihomo-update.timer && systemctl --user daemon-reload`
  - macOS: `rm ~/Library/LaunchAgents/com.mihomo.proxy.plist ~/Library/LaunchAgents/com.mihomo.update.plist`

- [ ] **Remove binaries:** `rm ~/.local/bin/mihomo ~/.local/bin/yq ~/.local/bin/update-mihomo-config`

- [ ] **Remove wrapper scripts:** `rm ~/.local/bin/with-proxy ~/.local/bin/proxy-agent ~/.local/bin/proxy-copilot ~/.local/bin/proxy-claude`

- [ ] **Remove config directories:** `rm -rf ~/.config/mihomo ~/.config/proxy`

- [ ] **Remove Web UI:** `rm -rf ~/.local/share/mihomo-ui`

- [ ] **Clean bash aliases:** Remove proxy-related content from `~/.bash_aliases`

- [ ] **Confirm removal** — verify no mihomo processes running, ports freed

---

## Troubleshooting

When the user reports proxy issues, see [troubleshooting.md](references/troubleshooting.md) for common problems and solutions.

## Key Principles

1. **Pure user-space** — never use sudo. Skip features that need root.
2. **Secret safety** — never echo/log/commit subscription URLs or secrets.
3. **Fail-safe config updates** — always validate before replacing config.yaml. Keep last working config on failure.
4. **Interactive** — collect parameters via `ask_user`, don't assume values.
5. **Idempotent** — re-running installation should detect existing setup and offer upgrade/reconfigure.
6. **Cross-platform** — handle Linux and macOS differences in service management and paths.
