@echo off
title FAXINA TOTAL NO WINDOWS
color 0A

echo Parando serviço NFePack_ALB...
net stop NFePack_ALB

echo Limpando logs do NFePack...
SET "folderPath=C:\Inventti\NFePack\ApacheLB\logs"
DEL /Q "%folderPath%\access.log"
DEL /Q "%folderPath%\error.log"

echo Iniciando limpeza total do sistema...
echo.

:: Limpar TEMP do Windows
echo [1/8] Limpando C:\Windows\Temp...
del /s /f /q %windir%\Temp\*.*
for /d %%x in (%windir%\Temp\*) do rd /s /q "%%x"

:: Limpar TEMP de todos os usuários
echo [2/8] Limpando TEMP de todos os usuários...
for /d %%u in (C:\Users\*) do (
    del /s /f /q "%%u\AppData\Local\Temp\*.*"
    for /d %%x in ("%%u\AppData\Local\Temp\*") do rd /s /q "%%x"
)

:: Limpar PREFETCH
echo [3/8] Limpando Prefetch...
del /s /f /q C:\Windows\Prefetch\*.*

:: Limpar SoftwareDistribution (atualizações baixadas)
echo [4/8] Limpando updates antigos...
del /s /f /q C:\Windows\SoftwareDistribution\Download\*.*

:: Limpar lixeira
echo [5/8] Esvaziando lixeira...
PowerShell.exe -NoProfile -Command ^
"$shell = New-Object -ComObject Shell.Application; ^
$recycleBin = $shell.Namespace(10); ^
$items = @(); ^
for ($i = 0; $i -lt $recycleBin.Items().Count; $i++) { $items += $recycleBin.Items().Item($i).Path }; ^
foreach ($item in $items) { Remove-Item -Path $item -Recurse -Force -ErrorAction SilentlyContinue }"

:: Limpar DNS
echo [6/8] Limpando cache DNS...
ipconfig /flushdns

:: Abrir Storage Sense para limpeza complementar
echo [7/8] Abrindo Storage Sense...
start ms-settings:storagesense

echo Iniciando serviço NFePack_ALB novamente...
net start NFePack_ALB

echo.
echo [8/8] LIMPEZA FINALIZADA. FEI, O WINDOWS TA ZERADO.
pause >nul

a
