# Installing Devkit for OpenCode

## Installation

Add devkit to the `plugin` array in your `opencode.json` (global or project-level):

```json
{
  "plugin": ["devkit@git+https://github.com/zhpeng24/devkit.git"]
}
```

Restart OpenCode. The plugin auto-installs and registers all skills.

Verify by asking: "Tell me about your devkit skills"

## Usage

Use OpenCode's native `skill` tool:

```
use skill tool to list skills
use skill tool to load devkit/friendly-python
```

## Updating

Devkit updates automatically when you restart OpenCode.

To pin a specific version:

```json
{
  "plugin": ["devkit@git+https://github.com/zhpeng24/devkit.git#v1.0.0"]
}
```

## Uninstalling

Remove the `devkit` entry from the `plugin` array in `opencode.json`.
