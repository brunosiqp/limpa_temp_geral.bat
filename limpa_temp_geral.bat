@echo off
title FAXINA TOTAL NO WINDOWS
color 0A
echo Iniciando limpeza total do sistema...
echo.

:: Limpar TEMP do Windows
echo [1/7] Limpando C:\Windows\Temp...
del /s /f /q %windir%\Temp\*.*
for /d %%x in (%windir%\Temp\*) do rd /s /q "%%x"

:: Limpar TEMP de todos os usuários
echo [2/7] Limpando TEMP de todos os usuários...
for /d %%u in (C:\Users\*) do (
    del /s /f /q "%%u\AppData\Local\Temp\*.*"
    for /d %%x in ("%%u\AppData\Local\Temp\*") do rd /s /q "%%x"
)

:: Limpar PREFETCH
echo [3/7] Limpando Prefetch...
del /s /f /q C:\Windows\Prefetch\*.*

:: Limpar SoftwareDistribution (atualizações baixadas)
echo [4/7] Limpando updates antigos...
del /s /f /q C:\Windows\SoftwareDistribution\Download\*.*

:: Limpar lixeira
echo [5/7] Esvaziando lixeira...
PowerShell.exe -Command "Clear-RecycleBin -Force"

:: Limpar DNS
echo [6/7] Limpando cache DNS...
ipconfig /flushdns

:: Abrir Storage Sense para limpeza complementar
echo [7/7] Abrindo Storage Sense...
start ms-settings:storagesense

echo.
echo LIMPEZA FINALIZADA. FEI, O WINDOWS TA ZERADO.
pause >nul
