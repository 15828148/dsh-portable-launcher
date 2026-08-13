@echo off
setlocal
title DSH Web UI - Setup

rem Creates a desktop shortcut with the DeepSeek icon, pointing to dsh-web.bat.
rem Run this once after copying the folder anywhere on your PC.

cd /d "%~dp0"

powershell -NoProfile -Command "$w=New-Object -ComObject WScript.Shell;$s=$w.CreateShortcut([Environment]::GetFolderPath('Desktop')+'\DSH Web UI.lnk');$s.TargetPath=(Join-Path (Get-Location) 'dsh-web.bat');$s.WorkingDirectory=(Get-Location).Path;$s.IconLocation=(Join-Path (Get-Location) 'deepseek.ico')+',0';$s.Description='DeepSeek Harness Web UI (http://127.0.0.1:3080)';$s.Save();Write-Host ('Shortcut: ' + [Environment]::GetFolderPath('Desktop') + '\DSH Web UI.lnk')"

if errorlevel 1 (
    echo [ERROR] Failed to create the shortcut.
    pause
    exit /b 1
)

echo.
echo Done! Double-click "DSH Web UI" on your desktop to start.
pause
