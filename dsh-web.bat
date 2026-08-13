@echo off
setlocal EnableDelayedExpansion
title DeepSeek Harness Web UI

rem ============================================================
rem  DeepSeek Harness Web UI - universal launcher
rem  Major stages: [1/3] Node check, [2/3] dsh package check,
rem  [3/3] launch.  Downloads/installs are minor steps (indented)
rem  and only run when something is missing. When everything is
rem  in place, launch is direct with zero downloads.
rem ============================================================

rem ---- 64-bit Windows required (Node 22+ has no 32-bit builds) ----
if "%PROCESSOR_ARCHITECTURE%"=="x86" if "%PROCESSOR_ARCHITEW6432%"=="" (
    echo.
    echo [ERROR] This PC runs 32-bit Windows.
    echo DeepSeek Harness needs 64-bit Windows.
    echo.
    pause
    exit /b 1
)

rem ---- Resume detection: pick up where a previous run left off ----
if exist "%~dp0node\node.zip" echo [Resume] A Node.js download was found - it will be installed, not re-downloaded.
if exist "%~dp0node\node-dir.txt" echo [Resume] Portable Node.js is already installed on this machine.
if exist "%~dp0dsh-ready.txt" echo [Resume] dsh components are already downloaded.
if exist "%~dp0node\node.zip" if exist "%~dp0node\node-dir.txt" echo [Resume] Node.js install was interrupted - finishing it now.
echo.

rem ============ fast path: dsh already running? ============
netstat -ano | findstr /c:":3080" | findstr /c:"LISTENING" >nul 2>nul
if not errorlevel 1 (
    echo dsh is already running at http://127.0.0.1:3080
    echo Opening browser...
    start "" http://127.0.0.1:3080
    timeout /t 3 >nul
    exit /b 0
)

echo ==================================================
echo   DeepSeek Harness Web UI
echo   URL: http://127.0.0.1:3080
echo   Close this window or press Ctrl+C to stop.
echo   First time? Add your API key in Settings (UI).
echo ==================================================
echo.

rem Background helper: poll until the UI responds, open the browser, mark dsh-ready, log boot time.
set "DSH_LOG=%~dp0dsh-startup.log"
set "DSH_READY=%~dp0dsh-ready.txt"
start "" powershell -WindowStyle Hidden -Command "$d=Get-Date;for($i=0;$i -lt 240;$i++){try{$r=Invoke-WebRequest -Uri 'http://127.0.0.1:3080' -UseBasicParsing -TimeoutSec 2 -ErrorAction Stop;if($r.StatusCode -eq 200){Start-Process 'http://127.0.0.1:3080';Set-Content -Path '%DSH_READY%' -Value 'ok' -Encoding ascii;('{0}  UI ready in {1} s' -f (Get-Date -Format 'HH:mm:ss'),[Math]::Round(((Get-Date)-$d).TotalSeconds,1)) | Out-File -Append -Encoding ascii '%DSH_LOG%';break}}catch{};Start-Sleep -Milliseconds 500}"

rem ================= MAJOR STAGE 1/3: Node.js =================
echo [1/3] Node.js check...
set "NODE_OK="
where node >nul 2>nul
if not errorlevel 1 (
    for /f "tokens=1 delims=." %%v in ('node -v 2^>nul') do set "NMAJOR=%%v"
    set "NMAJOR=!NMAJOR:v=!"
    if defined NMAJOR if !NMAJOR! GEQ 22 set "NODE_OK=1"
)
rem Minor: reuse a portable Node installed by a previous run (PATH persistence may have failed).
if not defined NODE_OK (
    if exist "%~dp0node\node-dir.txt" (
        for /f "usebackq delims=" %%l in ("%~dp0node\node-dir.txt") do set "NODE_DIR=%%l"
        if exist "!NODE_DIR!\node.exe" (
            set "PATH=!NODE_DIR!;%PATH%"
            set "NODE_OK=1"
        )
    )
)
if not defined NODE_OK (
    echo   - Node.js ^(v22+^) not found.
    choice /c YN /n /m "Download portable Node.js automatically [Y] / manual install [N]? "
    if errorlevel 2 goto manualnode
    call :installnode
    if errorlevel 2 exit /b 1
    if errorlevel 1 goto manualnode
)
echo   OK - Node.js ready.
echo.

rem ================= MAJOR STAGE 2/3: dsh package =================
echo [2/3] dsh package check...
set "DSH_OK="
where dsh >nul 2>nul
if not errorlevel 1 set "DSH_OK=1"
if not defined DSH_OK (
    if exist "%~dp0dsh-ready.txt" set "DSH_OK=1"
)
if not defined DSH_OK (
    echo   - dsh not found. First run downloads it ^(a few minutes^).
    call :installdsh
    if errorlevel 2 exit /b 1
    if errorlevel 1 goto dshmanual
)
echo   OK - dsh ready.
echo.

rem ================= MAJOR STAGE 3/3: Launch =================
echo [3/3] Starting dsh... the browser opens automatically.
set "DSH_LAUNCH="
if exist "%APPDATA%\npm\dsh.cmd" set "DSH_LAUNCH=%APPDATA%\npm\dsh.cmd"
if not defined DSH_LAUNCH (
    where dsh >nul 2>nul
    if not errorlevel 1 set "DSH_LAUNCH=dsh"
)
if defined DSH_LAUNCH (
    if exist "%DSH_LAUNCH%" (
        call "%DSH_LAUNCH%" web
    ) else (
        call %DSH_LAUNCH% web
    )
) else (
    echo   - launching via npx ^(components already cached, no download^)...
    call npx --yes @deepseek-ai/dsh@latest web
)
set "code=!errorlevel!"
echo.
echo [3/3] dsh stopped ^(exit code !code!^).
if not "!code!"=="0" echo [TIP] Non-zero exit; common cause: port 3080 already in use.
echo.
pause
exit /b !code!

rem ============================================================
rem  Subroutines
rem ============================================================

:installnode
rem Minor: the download needs a writable folder; report early if this one is protected.
> "%~dp0._wtest" echo ok 2>nul
if not exist "%~dp0._wtest" (
    echo.
    echo [FAILED] This folder is not writable.
    echo --- Manual steps ---
    echo Move the whole folder somewhere normal ^(e.g. D:\ or Desktop^),
    echo then run this file again. Protected folders like Program
    echo Files cannot be used here.
    echo.
    pause
    exit /b 2
)
del "%~dp0._wtest" >nul 2>nul

rem Minor: resume - if a previous run already finished the download, skip it.
if exist "%~dp0node\node.zip" (
    echo   - Node.js download already finished - installing it now.
    goto node_extract
)

set "ATTEMPT=0"
:node_retry
set /a ATTEMPT+=1
echo.
echo   - downloading portable Node.js ^(LTS^) - attempt !ATTEMPT!/4
echo     If it hangs, press Ctrl+C, then run this file again.
mkdir "%~dp0node" >nul 2>nul
powershell -NoProfile -Command "$ProgressPreference='SilentlyContinue';foreach($base in @('https://npmmirror.com/mirrors/node/','https://nodejs.org/dist/')){try{$j=Invoke-RestMethod ($base+'index.json') -TimeoutSec 25;$v=$j|Where-Object{$_.lts -and ($_.files -contains 'win-x64-zip')}|Select-Object -First 1;if($v){$u=$base+$v.version+'/node-'+$v.version+'-win-x64.zip';Write-Host ('Downloading: node-'+$v.version+'-win-x64.zip');Invoke-WebRequest $u -OutFile '%~dp0node\node.zip' -UseBasicParsing -TimeoutSec 300;break}}catch{Write-Host ('mirror failed: '+$base)}}"
if not exist "%~dp0node\node.zip" (
    if !ATTEMPT! GEQ 4 goto node_giveup
    echo.
    echo   - download failed.
    choice /c YN /n /m "Retry [Y] / manual install [N]? "
    if errorlevel 2 exit /b 1
    goto node_retry
)

:node_extract
echo   - installing Node.js...
powershell -NoProfile -Command "$ProgressPreference='SilentlyContinue';Expand-Archive -Path '%~dp0node\node.zip' -DestinationPath '%~dp0node' -Force;Remove-Item '%~dp0node\node.zip' -Force"
for /d %%d in ("%~dp0node\node-v*-win-x64") do set "NODE_DIR=%%d"
if not defined NODE_DIR (
    echo.
    echo   - the previous download was incomplete or corrupt - downloading again.
    del "%~dp0node\node.zip" >nul 2>nul
    if !ATTEMPT! GEQ 4 goto node_giveup
    goto node_retry
)
> "%~dp0node\node-dir.txt" echo !NODE_DIR!
set "PATH=%NODE_DIR%;%PATH%"
echo   - adding Node.js to the user PATH...
powershell -NoProfile -Command "try{$p=[Environment]::GetEnvironmentVariable('Path','User');if($p -notlike '*!NODE_DIR!*'){[Environment]::SetEnvironmentVariable('Path','!NODE_DIR!;'+$p,'User');Write-Host 'Added portable Node to your user PATH.'}else{Write-Host 'Portable Node is already in your user PATH.'}}catch{Write-Host 'Note: could not persist to PATH; local fallback will be used next time.'}"
echo   OK - Node.js ready.
echo.
exit /b 0

:node_giveup
echo.
echo [FAILED] Node.js download failed after 3 retries.
echo --- Manual steps ---
echo 1. Download Node.js LTS from https://nodejs.org
echo 2. Install it ^(run the .msi, click Next through^)
echo 3. Close this window and run this file again.
echo.
pause
exit /b 2

:manualnode
echo.
echo [1/3] Manual install chosen.
echo --- Manual steps ---
echo 1. Download Node.js LTS from https://nodejs.org
echo 2. Install it ^(run the .msi, click Next through^)
echo 3. Close this window and run this file again.
echo.
pause
exit /b 1

:installdsh
set "ATTEMPT=0"
:dsh_retry
set /a ATTEMPT+=1
echo.
echo   - downloading/installing the dsh package - attempt !ATTEMPT!/4
echo     ^(first run only; may take a few minutes^)
if !ATTEMPT! GEQ 2 (
    echo   - also switching npm to the China mirror for this attempt.
    call npm config set registry https://registry.npmmirror.com
)
call npm install -g @deepseek-ai/dsh
if exist "%APPDATA%\npm\dsh.cmd" exit /b 0
where dsh >nul 2>nul
if not errorlevel 1 exit /b 0
if !ATTEMPT! GEQ 4 goto dsh_giveup
echo.
echo   - install failed.
choice /c YN /n /m "Retry [Y] / manual install [N]? "
if errorlevel 2 exit /b 1
goto dsh_retry

:dsh_giveup
echo.
echo [FAILED] dsh package install failed after 3 retries.
echo --- Manual steps ---
echo 1. Check your network connection.
echo 2. Open a terminal and run:
echo      npm config set registry https://registry.npmmirror.com
echo      npm install -g @deepseek-ai/dsh
echo 3. Close this window and run this file again.
echo.
pause
exit /b 2

:dshmanual
echo.
echo [2/3] Manual install chosen.
echo --- Manual steps ---
echo 1. Open a terminal and run:
echo      npm config set registry https://registry.npmmirror.com
echo      npm install -g @deepseek-ai/dsh
echo 2. Close this window and run this file again.
echo.
pause
exit /b 1
