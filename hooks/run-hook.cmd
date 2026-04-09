@echo off
setlocal
:: run-hook.cmd — cross-platform hook runner (Windows + WSL/Git Bash)
:: Usage: run-hook.cmd <hook-name>

set "HOOK=%~1"
if "%HOOK%"=="" (
    echo Usage: run-hook.cmd ^<hook-name^>
    exit /b 1
)

set "SCRIPT_DIR=%~dp0"
set "HOOK_SCRIPT=%SCRIPT_DIR%%HOOK%"

:: Try bash first (Git Bash / WSL)
where bash >nul 2>nul
if %ERRORLEVEL%==0 (
    bash "%HOOK_SCRIPT%"
    exit /b %ERRORLEVEL%
)

:: Fallback: sh
where sh >nul 2>nul
if %ERRORLEVEL%==0 (
    sh "%HOOK_SCRIPT%"
    exit /b %ERRORLEVEL%
)

echo ERROR: No bash or sh found. Cannot run hook: %HOOK%
exit /b 1
