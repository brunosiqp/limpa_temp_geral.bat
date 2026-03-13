@echo off
title LIMPEZA PESADA WINDOWS
color 0A

echo ===============================
echo LIMPEZA PESADA DO WINDOWS
echo ===============================
echo.

echo Parando servicos...
net stop wuauserv >nul 2>&1
net stop bits >nul 2>&1

echo Limpando TEMP do usuario...
del /s /f /q "%temp%\*.*" >nul 2>&1
rd /s /q "%temp%" >nul 2>&1
mkdir "%temp%"

echo Limpando AppData Local Temp...
del /s /f /q "%localappdata%\Temp\*.*" >nul 2>&1
rd /s /q "%localappdata%\Temp" >nul 2>&1
mkdir "%localappdata%\Temp"

echo Limpando Windows Temp...
del /s /f /q C:\Windows\Temp\*.* >nul 2>&1

echo Limpando Prefetch...
del /s /f /q C:\Windows\Prefetch\*.* >nul 2>&1

echo Limpando cache do Windows Update...
del /s /f /q C:\Windows\SoftwareDistribution\Download\*.* >nul 2>&1

echo Limpando logs do sistema...
del /s /f /q C:\Windows\Logs\*.* >nul 2>&1

echo Limpando dumps de erro...
del /s /f /q C:\Windows\Minidump\*.* >nul 2>&1
del /s /f /q C:\Windows\MEMORY.DMP >nul 2>&1

echo Limpando cache de thumbnails...
del /s /f /q "%localappdata%\Microsoft\Windows\Explorer\thumbcache_*" >nul 2>&1

echo Limpando DirectX Shader Cache...
del /s /f /q "%localappdata%\D3DSCache\*.*" >nul 2>&1

echo Limpando Delivery Optimization...
del /s /f /q "C:\Windows\SoftwareDistribution\DeliveryOptimization\*.*" >nul 2>&1

echo Limpando cache de rede...
ipconfig /flushdns >nul

echo Limpando cache do Edge...
del /s /f /q "%localappdata%\Microsoft\Edge\User Data\Default\Cache\*.*" >nul 2>&1

echo Limpando cache do Chrome...
del /s /f /q "%localappdata%\Google\Chrome\User Data\Default\Cache\*.*" >nul 2>&1

echo Limpando crash reports...
del /s /f /q "%localappdata%\CrashDumps\*.*" >nul 2>&1

echo Limpando cache do Windows Defender...
del /s /f /q "C:\ProgramData\Microsoft\Windows Defender\Scans\History\*.*" >nul 2>&1

echo Reiniciando servicos...
net start wuauserv >nul 2>&1
net start bits >nul 2>&1

echo.
echo ===============================
echo LIMPEZA FINALIZADA
echo ===============================
pause