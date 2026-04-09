# Installing Devkit for Codex

## Installation

1. **Clone the devkit repository:**
   ```bash
   git clone https://github.com/zhpeng24/devkit.git ~/.codex/devkit
   ```

2. **Create the skills symlink:**
   ```bash
   mkdir -p ~/.agents/skills
   ln -s ~/.codex/devkit/skills ~/.agents/skills/devkit
   ```

   **Windows (PowerShell):**
   ```powershell
   New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.agents\skills"
   cmd /c mklink /J "$env:USERPROFILE\.agents\skills\devkit" "$env:USERPROFILE\.codex\devkit\skills"
   ```

3. **Restart Codex** to discover the skills.

## Verify

```bash
ls -la ~/.agents/skills/devkit
```

## Updating

```bash
cd ~/.codex/devkit && git pull
```

## Uninstalling

```bash
rm ~/.agents/skills/devkit
rm -rf ~/.codex/devkit
```
