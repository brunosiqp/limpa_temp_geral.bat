@echo off
title LIMPEZA ULTIMATE WINDOWS
color 0A

:: Verificar se esta como Administrador
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo ==========================================
    echo EXECUTE ESTE SCRIPT COMO ADMINISTRADOR
    echo ==========================================
    pause
    exit
)

cls
echo ==================================================
echo          LIMPEZA ULTIMATE DO WINDOWS
echo ==================================================
echo.

echo [1/19] Parando servicos...
net stop wuauserv >nul 2>&1
net stop bits >nul 2>&1

echo [2/19] Limpando TEMP do usuario...
del /s /f /q "%temp%\*.*" >nul 2>&1
for /d %%x in ("%temp%\*") do rd /s /q "%%x" >nul 2>&1

echo [3/19] Limpando AppData Temp...
del /s /f /q "%localappdata%\Temp\*.*" >nul 2>&1
for /d %%x in ("%localappdata%\Temp\*") do rd /s /q "%%x" >nul 2>&1

echo [4/19] Limpando TEMP de todos os usuarios...
for /d %%u in (C:\Users\*) do (
    del /s /f /q "%%u\AppData\Local\Temp\*.*" >nul 2>&1
    for /d %%x in ("%%u\AppData\Local\Temp\*") do rd /s /q "%%x" >nul 2>&1
)

echo [5/19] Limpando Windows Temp...
del /s /f /q "%windir%\Temp\*.*" >nul 2>&1
for /d %%x in ("%windir%\Temp\*") do rd /s /q "%%x" >nul 2>&1

echo [6/19] Limpando Prefetch...
del /s /f /q "C:\Windows\Prefetch\*.*" >nul 2>&1

echo [7/19] Limpando cache do Windows Update...
del /s /f /q "C:\Windows\SoftwareDistribution\Download\*.*" >nul 2>&1

echo [8/19] Limpando Delivery Optimization...
del /s /f /q "C:\Windows\SoftwareDistribution\DeliveryOptimization\*.*" >nul 2>&1

echo [9/19] Limpando logs do Windows...
del /s /f /q "C:\Windows\Logs\*.*" >nul 2>&1

echo [10/19] Limpando dumps de memoria...
del /s /f /q "C:\Windows\Minidump\*.*" >nul 2>&1
del /f /q "C:\Windows\MEMORY.DMP" >nul 2>&1

echo [11/19] Limpando cache DNS...
ipconfig /flushdns >nul

echo [12/19] Esvaziando Lixeira...
PowerShell.exe -NoProfile -Command "Clear-RecycleBin -Force" >nul 2>&1

echo [13/19] Limpando cache de miniaturas...
taskkill /f /im explorer.exe >nul 2>&1
del /f /q "%LocalAppData%\Microsoft\Windows\Explorer\thumbcache_*.db" >nul 2>&1
start explorer.exe

echo [14/19] Limpando DirectX Shader Cache...
del /s /f /q "%localappdata%\D3DSCache\*.*" >nul 2>&1

echo [15/19] Limpando Crash Dumps...
del /s /f /q "%localappdata%\CrashDumps\*.*" >nul 2>&1

echo [16/19] Limpando cache do Edge...
del /s /f /q "%localappdata%\Microsoft\Edge\User Data\Default\Cache\*.*" >nul 2>&1

echo [17/19] Limpando cache do Chrome...
del /s /f /q "%localappdata%\Google\Chrome\User Data\Default\Cache\*.*" >nul 2>&1

echo [18/19] Limpando historico do Windows Defender...
del /s /f /q "C:\ProgramData\Microsoft\Windows Defender\Scans\History\*.*" >nul 2>&1

echo [19/19] Reiniciando servicos...
net start bits >nul 2>&1
net start wuauserv >nul 2>&1

echo.
echo ==================================================
echo            LIMPEZA CONCLUIDA
echo ==================================================
echo.

for /f "tokens=3" %%A in ('dir c:\ ^| find "bytes free"') do set LIVRE=%%A
echo Espaco livre atual: %LIVRE% bytes
echo.

start ms-settings:storagesense

echo Windows limpo com sucesso.
pause