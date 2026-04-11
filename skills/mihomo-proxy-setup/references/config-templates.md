# Config Templates

Templates for all configuration files and scripts. Replace `{{placeholder}}` values with collected parameters.

## overrides.yaml

```yaml
mixed-port: {{mixed_port}}
allow-lan: false
external-controller: 127.0.0.1:{{controller_port}}
log-level: info
external-ui: {{home}}/.local/share/mihomo-ui
secret: {{controller_secret}}
```

- `{{mixed_port}}`: default `7890`
- `{{controller_port}}`: default `29090`
- `{{controller_secret}}`: user-provided or random 12-char alphanumeric
- `{{home}}`: expand `$HOME` at write time (absolute path, not `~`)

## env.sh

Write to `~/.config/proxy/env.sh` with mode 644:

```bash
export HTTP_PROXY=http://127.0.0.1:{{mixed_port}}
export HTTPS_PROXY=http://127.0.0.1:{{mixed_port}}
export ALL_PROXY=socks5://127.0.0.1:{{mixed_port}}
export NO_PROXY=127.0.0.1,localhost,::1,.local{{extra_no_proxy}}
export http_proxy=http://127.0.0.1:{{mixed_port}}
export https_proxy=http://127.0.0.1:{{mixed_port}}
export all_proxy=socks5://127.0.0.1:{{mixed_port}}
export no_proxy=127.0.0.1,localhost,::1,.local{{extra_no_proxy}}
```

- `{{extra_no_proxy}}`: if user provided extra NO_PROXY entries, prepend with `,` (e.g., `,10.0.0.0/8,.corp.internal`)

## update-mihomo-config

Write to `~/.local/bin/update-mihomo-config` with mode 755:

```bash
#!/usr/bin/env bash
set -euo pipefail

cfg_dir="$HOME/.config/mihomo"
url_file="$cfg_dir/subscription.url"
overrides_file="$cfg_dir/overrides.yaml"
target_file="$cfg_dir/config.yaml"
yq_bin="$HOME/.local/bin/yq"
mihomo_bin="$HOME/.local/bin/mihomo"
mmdb_file="$cfg_dir/geoip.metadb"
mmdb_primary_url="https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@release/country-lite.mmdb"
mmdb_fallback_url="https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/country-lite.mmdb"
safe_paths="$HOME/.local/share/mihomo-ui"
work_dir="$cfg_dir/.update-work.$$"
subscription_file="$work_dir/subscription.yaml"
normalized_subscription_file="$work_dir/subscription.normalized.yaml"
generated_file="$work_dir/config.yaml"
validation_log="$work_dir/validation.log"

cleanup() {
  rm -rf "$work_dir"
}
trap cleanup EXIT

ensure_mmdb() {
  if [ "${1:-}" != "--force" ] && [ -s "$mmdb_file" ]; then
    return
  fi
  curl --fail --silent --show-error --location "$mmdb_primary_url" -o "$mmdb_file" \
    || curl --fail --silent --show-error --location "$mmdb_fallback_url" -o "$mmdb_file"
  chmod 644 "$mmdb_file"
}

validate_config() {
  if SAFE_PATHS="$safe_paths" "$mihomo_bin" -t -f "$generated_file" >"$validation_log" 2>&1; then
    cat "$validation_log"
    return
  fi
  cat "$validation_log" >&2
  if grep -Eq 'GeoIP|MMDB' "$validation_log"; then
    ensure_mmdb --force
    SAFE_PATHS="$safe_paths" "$mihomo_bin" -t -f "$generated_file"
    return
  fi
  return 1
}

url="$(tr -d '\r\n' < "$url_file")"
[[ -n "$url" ]]

mkdir -p "$work_dir"
ensure_mmdb

curl --fail --silent --show-error --location "$url" -o "$subscription_file"
"$yq_bin" eval 'del(.port, .socks-port)' "$subscription_file" > "$normalized_subscription_file"
"$yq_bin" eval-all 'select(fileIndex == 0) * select(fileIndex == 1)' \
  "$normalized_subscription_file" "$overrides_file" > "$generated_file"

validate_config
install -m 600 "$generated_file" "$target_file"

# Restart service (platform-aware)
if command -v systemctl >/dev/null 2>&1 && systemctl --user is-active mihomo >/dev/null 2>&1; then
  systemctl --user restart mihomo
elif command -v launchctl >/dev/null 2>&1; then
  launchctl stop com.mihomo.proxy 2>/dev/null || true
  launchctl start com.mihomo.proxy 2>/dev/null || true
else
  # Manual restart: find and kill existing, then start new
  pkill -u "$(id -u)" -f 'mihomo.*-d.*\.config/mihomo' || true
  sleep 1
  nohup "$mihomo_bin" -d "$cfg_dir" -f "$target_file" >/dev/null 2>&1 &
fi
```

### Key behaviors:
- Downloads subscription to temp dir, never overwrites config.yaml until validated
- Normalizes subscription by removing `port` and `socks-port` (overrides.yaml controls these)
- Merges subscription + overrides using `yq eval-all` (overrides win)
- Auto-downloads GeoIP MMDB if missing or on validation failure
- Restarts service platform-appropriately

## with-proxy

Write to `~/.local/bin/with-proxy` with mode 755:

```bash
#!/usr/bin/env bash
set -euo pipefail
PROXY_ENV_FILE="$HOME/.config/proxy/env.sh"
if [ ! -r "$PROXY_ENV_FILE" ]; then
  printf 'with-proxy: missing proxy env file: %s\n' "$PROXY_ENV_FILE" >&2
  exit 1
fi
# shellcheck disable=SC1090
. "$PROXY_ENV_FILE"
if [ "$#" -eq 0 ]; then
  printf 'with-proxy: expected a command to run\n' >&2
  exit 64
fi
exec "$@"
```

## proxy-agent (Cursor)

Write to `~/.local/bin/proxy-agent` with mode 755:

```bash
#!/usr/bin/env bash
set -euo pipefail

WITH_PROXY="$HOME/.local/bin/with-proxy"
if [ ! -x "$WITH_PROXY" ]; then
  printf 'proxy-agent: missing with-proxy helper: %s\n' "$WITH_PROXY" >&2
  exit 1
fi

cursor_usable() {
  command -v cursor >/dev/null 2>&1 || return 1
  timeout 2s cursor --help >/dev/null 2>&1
}

cursor_agent_usable() {
  command -v cursor-agent >/dev/null 2>&1 || return 1
  timeout 2s cursor-agent --help >/dev/null 2>&1
}

if cursor_usable; then
  exec "$WITH_PROXY" cursor "$@"
fi

if cursor_agent_usable; then
  exec "$WITH_PROXY" cursor-agent "$@"
fi

printf 'proxy-agent: no usable cursor or cursor-agent found\n' >&2
exit 127
```

## proxy-copilot (GitHub Copilot CLI)

Write to `~/.local/bin/proxy-copilot` with mode 755:

```bash
#!/usr/bin/env bash
set -euo pipefail

WITH_PROXY="$HOME/.local/bin/with-proxy"
if [ ! -x "$WITH_PROXY" ]; then
  printf 'proxy-copilot: missing with-proxy helper: %s\n' "$WITH_PROXY" >&2
  exit 1
fi

gh_copilot_usable() {
  command -v gh >/dev/null 2>&1 || return 1
  timeout 10s gh copilot --help >/dev/null 2>&1
}

if command -v copilot >/dev/null 2>&1; then
  exec "$WITH_PROXY" copilot "$@"
fi

if gh_copilot_usable; then
  exec "$WITH_PROXY" gh copilot "$@"
fi

printf 'proxy-copilot: no usable copilot or gh copilot found\n' >&2
exit 127
```

## proxy-claude (Claude CLI)

Write to `~/.local/bin/proxy-claude` with mode 755:

```bash
#!/usr/bin/env bash
set -euo pipefail

WITH_PROXY="$HOME/.local/bin/with-proxy"
if [ ! -x "$WITH_PROXY" ]; then
  printf 'proxy-claude: missing with-proxy helper: %s\n' "$WITH_PROXY" >&2
  exit 1
fi

if ! command -v claude >/dev/null 2>&1; then
  printf 'proxy-claude: claude not found on PATH\n' >&2
  exit 127
fi

exec "$WITH_PROXY" claude "$@"
```

## bash_aliases

Append to (or create) `~/.bash_aliases`:

```bash
# Proxy helper commands for the local Mihomo setup.
#
# with-proxy     Run any command with the local Mihomo proxy injected.
# proxy-agent    Start Cursor (or cursor-agent fallback) with the proxy enabled.
# proxy-copilot  Start GitHub Copilot CLI with the proxy enabled.
# proxy-claude   Start Claude CLI with the proxy enabled.

alias with-proxy='$HOME/.local/bin/with-proxy'
alias proxy-agent='$HOME/.local/bin/proxy-agent'
alias proxy-copilot='$HOME/.local/bin/proxy-copilot'
alias proxy-claude='$HOME/.local/bin/proxy-claude'

proxy-help() {
  cat <<'EOF'
Mihomo Proxy Commands:
  with-proxy <cmd>  Run any command with the local Mihomo proxy injected.
  proxy-agent       Start Cursor (or cursor-agent fallback) with the proxy enabled.
  proxy-copilot     Start GitHub Copilot CLI with the proxy enabled.
  proxy-claude      Start Claude CLI with the proxy enabled.
  proxy-help        Show this help message.
EOF
}
```

> **IMPORTANT:** Before appending, check if proxy aliases already exist in `~/.bash_aliases` to avoid duplicates. If they exist, replace the block; if not, append.

> Also ensure `~/.bashrc` contains `. ~/.bash_aliases` or `source ~/.bash_aliases`. If not, append it.
