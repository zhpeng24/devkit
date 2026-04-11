# Launchd Plists (macOS)

Write these files for macOS installations. Uses `~/Library/LaunchAgents/` for user-level agents.

## com.mihomo.proxy.plist

Write to `~/Library/LaunchAgents/com.mihomo.proxy.plist`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>com.mihomo.proxy</string>

  <key>ProgramArguments</key>
  <array>
    <string>{{home}}/.local/bin/mihomo</string>
    <string>-d</string>
    <string>{{home}}/.config/mihomo</string>
    <string>-f</string>
    <string>{{home}}/.config/mihomo/config.yaml</string>
  </array>

  <key>EnvironmentVariables</key>
  <dict>
    <key>SAFE_PATHS</key>
    <string>{{home}}/.local/share/mihomo-ui</string>
  </dict>

  <key>RunAtLoad</key>
  <true/>

  <key>KeepAlive</key>
  <dict>
    <key>SuccessfulExit</key>
    <false/>
  </dict>

  <key>StandardOutPath</key>
  <string>{{home}}/.local/share/mihomo-proxy.stdout.log</string>

  <key>StandardErrorPath</key>
  <string>{{home}}/.local/share/mihomo-proxy.stderr.log</string>
</dict>
</plist>
```

## com.mihomo.update.plist

Write to `~/Library/LaunchAgents/com.mihomo.update.plist`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>com.mihomo.update</string>

  <key>ProgramArguments</key>
  <array>
    <string>{{home}}/.local/bin/update-mihomo-config</string>
  </array>

  <key>StartInterval</key>
  <integer>1800</integer>

  <key>RunAtLoad</key>
  <true/>

  <key>StandardOutPath</key>
  <string>{{home}}/.local/share/mihomo-update.stdout.log</string>

  <key>StandardErrorPath</key>
  <string>{{home}}/.local/share/mihomo-update.stderr.log</string>
</dict>
</plist>
```

- `{{home}}`: absolute path to `$HOME` (e.g., `/Users/username`). Must be expanded at write time — launchd does not expand `~` or `$HOME`.
- `StartInterval: 1800` = every 30 minutes
- `RunAtLoad: true` = run once at load (initial subscription fetch)

## Activation Commands

```bash
launchctl load ~/Library/LaunchAgents/com.mihomo.proxy.plist
launchctl load ~/Library/LaunchAgents/com.mihomo.update.plist
```

## Verification

```bash
launchctl list | grep mihomo    # should show both services
lsof -iTCP:{{mixed_port}} -sTCP:LISTEN   # port should be listening
curl -s http://127.0.0.1:{{controller_port}}   # controller should respond
```

## Unload (for uninstall)

```bash
launchctl unload ~/Library/LaunchAgents/com.mihomo.proxy.plist
launchctl unload ~/Library/LaunchAgents/com.mihomo.update.plist
rm ~/Library/LaunchAgents/com.mihomo.proxy.plist
rm ~/Library/LaunchAgents/com.mihomo.update.plist
```
