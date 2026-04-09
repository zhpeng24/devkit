#Requires -Version 5.1
<#
.SYNOPSIS
    Devkit installer for Windows — supports all major AI coding platforms.
.DESCRIPTION
    Usage: .\install.ps1 [claude|cursor|copilot|codex|opencode|gemini]
           .\install.ps1            (interactive menu)
#>

param(
    [ValidateSet("claude", "cursor", "copilot", "codex", "opencode", "gemini", "")]
    [string]$Platform = ""
)

$ErrorActionPreference = "Stop"
$RepoUrl = "https://github.com/zhpeng24/devkit.git"

# --- Helpers ---
function Write-Info    { param([string]$Msg) Write-Host "▸ $Msg" -ForegroundColor Cyan }
function Write-Success { param([string]$Msg) Write-Host "✔ $Msg" -ForegroundColor Green }
function Write-Warn    { param([string]$Msg) Write-Host "⚠ $Msg" -ForegroundColor Yellow }
function Write-Err     { param([string]$Msg) Write-Host "✖ $Msg" -ForegroundColor Red; exit 1 }

function Invoke-CloneOrUpdate {
    param([string]$Dest)

    if (Test-Path (Join-Path $Dest ".git")) {
        Write-Info "Already installed at $Dest, updating…"
        git -C "$Dest" pull --ff-only --quiet
        if ($LASTEXITCODE -ne 0) { Write-Err "git pull failed" }
        Write-Success "Updated to latest version"
    }
    else {
        Write-Info "Cloning devkit to $Dest…"
        $parent = Split-Path $Dest -Parent
        if (-not (Test-Path $parent)) { New-Item -ItemType Directory -Path $parent -Force | Out-Null }
        git clone --quiet "$RepoUrl" "$Dest"
        if ($LASTEXITCODE -ne 0) { Write-Err "git clone failed" }
        Write-Success "Cloned successfully"
    }
}

# --- Platform installers ---

function Install-Claude {
    Write-Host "`nClaude Code`n" -ForegroundColor White -NoNewline; Write-Host ""

    if (Get-Command claude -ErrorAction SilentlyContinue) {
        Write-Info "Adding devkit marketplace…"
        claude plugins marketplace add $RepoUrl 2>$null
        if ($LASTEXITCODE -eq 0) { Write-Success "Marketplace added" }
        else { Write-Warn "Marketplace may already be configured" }

        Write-Info "Installing devkit plugin…"
        claude plugins install devkit 2>$null
        if ($LASTEXITCODE -eq 0) { Write-Success "Plugin installed" }
        else { Write-Warn "Auto-install failed. Run manually:`n  claude plugins marketplace add $RepoUrl`n  claude plugins install devkit" }
    }
    else {
        Write-Warn "claude CLI not found. After installing Claude Code, run:"
        Write-Host "  claude plugins marketplace add $RepoUrl"
        Write-Host "  claude plugins install devkit"
    }

    Write-Success "Claude Code — done! Restart Claude Code to load the plugin."
}

function Install-Cursor {
    Write-Host "`nCursor`n" -ForegroundColor White -NoNewline; Write-Host ""
    $dest = Join-Path $env:USERPROFILE ".cursor\plugins\local\devkit"
    Invoke-CloneOrUpdate $dest
    Write-Success "Cursor — done! Restart Cursor to detect the plugin."
}

function Install-Copilot {
    Write-Host "`nGitHub Copilot CLI`n" -ForegroundColor White -NoNewline; Write-Host ""
    $dest = Join-Path $env:USERPROFILE ".copilot\plugins\devkit"
    Invoke-CloneOrUpdate $dest

    if (Get-Command copilot -ErrorAction SilentlyContinue) {
        Write-Info "Registering plugin with Copilot CLI…"
        copilot plugin install $dest 2>$null
        if ($LASTEXITCODE -eq 0) { Write-Success "Plugin registered" }
        else { Write-Warn "Auto-registration failed. Run manually:`n  copilot plugin install $dest" }
    }
    else {
        Write-Warn "copilot CLI not found. After installing Copilot CLI, run:"
        Write-Host "  copilot plugin install $dest"
    }

    Write-Success "GitHub Copilot CLI — done!"
}

function Install-Codex {
    Write-Host "`nCodex`n" -ForegroundColor White -NoNewline; Write-Host ""
    $dest = Join-Path $env:USERPROFILE ".codex\devkit"
    $skillsDir = Join-Path $env:USERPROFILE ".agents\skills"
    $link = Join-Path $skillsDir "devkit"

    Invoke-CloneOrUpdate $dest

    if (Test-Path $link) {
        $item = Get-Item $link -Force
        if ($item.LinkType -eq "Junction" -or $item.LinkType -eq "SymbolicLink") {
            Write-Info "Skills junction already exists"
        }
        else {
            Write-Warn "$link already exists but is not a junction — skipping"
        }
    }
    else {
        Write-Info "Creating skills junction…"
        if (-not (Test-Path $skillsDir)) { New-Item -ItemType Directory -Path $skillsDir -Force | Out-Null }
        $target = Join-Path $dest "skills"
        New-Item -ItemType Junction -Path $link -Target $target -Force | Out-Null
        Write-Success "Junction: $link → $target"
    }

    Write-Success "Codex — done! Restart Codex to discover skills."
}

function Install-OpenCode {
    Write-Host "`nOpenCode`n" -ForegroundColor White -NoNewline; Write-Host ""
    Write-Info "OpenCode uses a git URL — no local clone needed."
    Write-Host ""
    Write-Host "  Add to your opencode.json (global or project-level):"
    Write-Host ""
    Write-Host "  {" -ForegroundColor White
    Write-Host "    `"plugin`": [`"devkit@git+$RepoUrl`"]" -ForegroundColor White
    Write-Host "  }" -ForegroundColor White
    Write-Host ""
    Write-Success "After editing, restart OpenCode to auto-install."
}

function Install-Gemini {
    Write-Host "`nGemini CLI`n" -ForegroundColor White -NoNewline; Write-Host ""
    if (Get-Command gemini -ErrorAction SilentlyContinue) {
        Write-Info "Installing Gemini CLI extension…"
        gemini extensions install $RepoUrl
        if ($LASTEXITCODE -eq 0) { Write-Success "Gemini CLI — done!" }
        else { Write-Warn "Installation failed. Run manually:`n  gemini extensions install $RepoUrl" }
    }
    else {
        Write-Warn "gemini CLI not found. After installing Gemini CLI, run:"
        Write-Host "  gemini extensions install $RepoUrl"
    }
}

# --- Interactive menu ---
function Show-Menu {
    Write-Host ""
    Write-Host "  Devkit Installer" -ForegroundColor White
    Write-Host ""
    Write-Host "  1) Claude Code"
    Write-Host "  2) Cursor"
    Write-Host "  3) GitHub Copilot CLI"
    Write-Host "  4) Codex"
    Write-Host "  5) OpenCode"
    Write-Host "  6) Gemini CLI"
    Write-Host ""
    Write-Host "  0) Exit"
    Write-Host ""
    $choice = Read-Host "  Select platform [0-6]"

    switch ($choice) {
        "1" { Install-Claude   }
        "2" { Install-Cursor   }
        "3" { Install-Copilot  }
        "4" { Install-Codex    }
        "5" { Install-OpenCode }
        "6" { Install-Gemini   }
        "0" { Write-Host "Bye!"; exit 0 }
        default { Write-Err "Invalid choice" }
    }
}

# --- Entrypoint ---
switch ($Platform) {
    "claude"   { Install-Claude   }
    "cursor"   { Install-Cursor   }
    "copilot"  { Install-Copilot  }
    "codex"    { Install-Codex    }
    "opencode" { Install-OpenCode }
    "gemini"   { Install-Gemini   }
    ""         { Show-Menu        }
}
