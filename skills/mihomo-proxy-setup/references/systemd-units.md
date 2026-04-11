# Systemd User Units (Linux)

Write these files for Linux installations. All use `systemctl --user`.

## mihomo.service

Write to `~/.config/systemd/user/mihomo.service`:

```ini
[Unit]
Description=Mihomo proxy service
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
Environment=SAFE_PATHS={{home}}/.local/share/mihomo-ui
ExecStart=%h/.local/bin/mihomo -d %h/.config/mihomo -f %h/.config/mihomo/config.yaml
Restart=on-failure
RestartSec=5

[Install]
WantedBy=default.target
```

- `{{home}}`: absolute path to `$HOME` (e.g., `/home/username`). Used in `SAFE_PATHS` because systemd doesn't expand `%h` in `Environment=`.
- `%h`: systemd specifier for user home directory. Used in `ExecStart` where systemd does expand it.

## mihomo-update.service

Write to `~/.config/systemd/user/mihomo-update.service`:

```ini
[Unit]
Description=Update Mihomo config from subscription
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=%h/.local/bin/update-mihomo-config
```

## mihomo-update.timer

Write to `~/.config/systemd/user/mihomo-update.timer`:

```ini
[Unit]
Description=Refresh Mihomo config every 30 minutes

[Timer]
OnBootSec=2min
OnUnitActiveSec=30min
Persistent=true
Unit=mihomo-update.service

[Install]
WantedBy=timers.target
```

## Activation Commands

After writing the unit files:

```bash
systemctl --user daemon-reload
systemctl --user enable --now mihomo.service
systemctl --user enable --now mihomo-update.timer
```

## Optional: Enable Lingering

So services survive user logout (may need sudo):

```bash
loginctl enable-linger $(whoami)
```

If this fails due to permissions, warn the user:
> "Services will stop when you log out. Ask your admin to run `loginctl enable-linger <username>` for persistent services."

## Verification

```bash
systemctl --user is-active mihomo          # should print "active"
systemctl --user is-active mihomo-update.timer  # should print "active"
systemctl --user status mihomo             # check for errors
journalctl --user -u mihomo --no-pager -n 20   # recent logs
```
