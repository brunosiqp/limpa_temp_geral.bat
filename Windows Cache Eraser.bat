@echo off
title Windows Cache Eraser
color 0A

echo ========================================
echo   LIMPEZA SEGURA DE CACHE DO WINDOWS
echo ========================================
echo.

echo Limpando TEMP do Usuario...
del /f /s /q "%temp%\*" >nul 2>&1
for /d %%x in ("%temp%\*") do rd /s /q "%%x" >nul 2>&1

echo Limpando TEMP do Windows...
del /f /s /q C:\Windows\Temp\* >nul 2>&1
for /d %%x in (C:\Windows\Temp\*) do rd /s /q "%%x" >nul 2>&1

echo Limpando cache de DNS...
ipconfig /flushdns >nul

echo Limpando cache de Thumbnails...
taskkill /f /im explorer.exe >nul 2>&1
del /f /q "%LocalAppData%\Microsoft\Windows\Explorer\thumbcache_*.db" >nul 2>&1
start explorer.exe

echo Limpando Prefetch (leve)...
del /f /q C:\Windows\Prefetch\* >nul 2>&1

echo.
echo ========================================
echo        LIMPEZA CONCLUIDA
echo ========================================

pause
