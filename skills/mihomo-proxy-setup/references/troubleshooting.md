# Troubleshooting Guide

Common problems and solutions for Mihomo proxy setup.

## Port Already in Use

**Symptom:** Mihomo fails to start, logs show `address already in use`

**Diagnosis:**
```bash
# Linux
ss -tlnp | grep '7890\|29090'
# macOS
lsof -iTCP:7890 -sTCP:LISTEN
lsof -iTCP:29090 -sTCP:LISTEN
```

**Solutions:**
1. Kill the conflicting process (old clash, another proxy, etc.)
2. Change `mixed-port` or `external-controller` port in `~/.config/mihomo/overrides.yaml`
3. Re-run `~/.local/bin/update-mihomo-config` to regenerate config
4. Restart service

## Subscription Download Fails

**Symptom:** `update-mihomo-config` fails with curl error

**Diagnosis:**
```bash
# Test direct access to subscription URL (don't echo the URL itself!)
curl -sS -o /dev/null -w '%{http_code}' "$(cat ~/.config/mihomo/subscription.url)"
```

**Solutions:**
1. Check if the subscription URL is still valid (may have expired)
2. If behind a firewall, the subscription server might be blocked — try accessing from a different network
3. Check DNS resolution: `nslookup <subscription-host>`
4. The existing `config.yaml` is preserved on failure — proxy continues working with last good config

## Proxy Not Working (Connection Refused)

**Symptom:** `curl -x http://127.0.0.1:7890 https://google.com` fails with "Connection refused"

**Diagnosis:**
```bash
# Check if service is running
# Linux:
systemctl --user status mihomo
journalctl --user -u mihomo --no-pager -n 30
# macOS:
launchctl list | grep mihomo
cat ~/.local/share/mihomo-proxy.stderr.log
```

**Solutions:**
1. If service not running, start it: `systemctl --user start mihomo` or `launchctl start com.mihomo.proxy`
2. Check Mihomo logs for config errors
3. Validate config: `~/.local/bin/mihomo -t -f ~/.config/mihomo/config.yaml`
4. Re-run subscription update: `~/.local/bin/update-mihomo-config`

## Proxy Runs But Cannot Reach External Sites

**Symptom:** Proxy accepts connections but external requests timeout or fail

**Diagnosis:**
```bash
# Check what proxy nodes are available via controller API
curl -s -H "Authorization: Bearer $(cat ~/.config/mihomo/overrides.yaml | grep secret | awk '{print $2}')" \
  http://127.0.0.1:29090/proxies | head -c 500
```

**Solutions:**
1. Open Web UI and check if proxy nodes are alive — switch to a different node
2. Subscription nodes may be expired — update subscription: `~/.local/bin/update-mihomo-config`
3. DNS issues inside proxy — check if `dns` section in config.yaml is valid

## Web UI Not Loading

**Symptom:** `http://127.0.0.1:29090/ui` returns 404 or blank page

**Diagnosis:**
```bash
# Check if UI files exist
ls ~/.local/share/mihomo-ui/index.html
# Check external-ui path in config
grep external-ui ~/.config/mihomo/config.yaml
# Check controller is accessible
curl -s http://127.0.0.1:29090
```

**Solutions:**
1. Verify `external-ui` path in overrides.yaml points to the correct absolute path
2. Re-download MetaCubeXD if files are missing
3. Ensure you're accessing via SSH tunnel if on a remote server:
   ```bash
   ssh -L 29090:127.0.0.1:29090 user@server
   ```

## GeoIP Database Errors

**Symptom:** Config validation fails with GeoIP/MMDB errors

**Diagnosis:**
```bash
ls -la ~/.config/mihomo/geoip.metadb
```

**Solutions:**
1. Delete and re-download:
   ```bash
   rm ~/.config/mihomo/geoip.metadb
   ~/.local/bin/update-mihomo-config
   ```
2. The update script auto-downloads MMDB on validation failure, so this usually self-heals

## Wrapper Script Issues

**Symptom:** `proxy-agent`, `proxy-copilot`, or `proxy-claude` fails

**Diagnosis:**
```bash
# Check if the target tool exists
which cursor cursor-agent copilot claude gh 2>/dev/null
# Check if with-proxy works
with-proxy echo "proxy env loaded"
# Check env.sh
cat ~/.config/proxy/env.sh
```

**Solutions:**
1. If the target tool is not installed, install it first
2. If `with-proxy` fails, check that `~/.config/proxy/env.sh` exists and is readable
3. For `proxy-agent`: cursor may need a 2s timeout probe — if the shim is broken, it falls back to `cursor-agent`
4. Ensure `~/.local/bin` is on your PATH

## Service Not Surviving Logout (Linux)

**Symptom:** Mihomo stops when SSH session ends

**Solution:**
```bash
loginctl enable-linger $(whoami)
```
This requires admin privileges. If unavailable, use `tmux` or `screen` to keep the session alive, or ask your admin to enable lingering for your user.

## Full Reset

If everything is broken, do a clean reinstall:

1. Ask the agent to uninstall: "请帮我卸载 Mihomo 代理"
2. Then reinstall: "请帮我重新安装 Mihomo 代理"

The uninstall flow removes all files, services, and configuration. A fresh install starts from scratch.
