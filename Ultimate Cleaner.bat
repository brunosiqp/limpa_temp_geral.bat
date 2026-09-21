@echo off
setlocal EnableExtensions EnableDelayedExpansion
title LIMPEZA ULTIMATE DO WINDOWS
color 0A
mode con cols=92 lines=35

:: ============================================================
:: CONFIGURACOES
:: ============================================================

set "SCRIPT_VERSION=3.0"
set "SYSTEM_DRIVE=%SystemDrive%"
set "LOG_DIR=%~dp0Logs_Limpeza"
set "RELATORIO_DIR=%~dp0Relatorios_Limpeza"

:: ============================================================
:: VALIDAR ADMINISTRADOR
:: ============================================================

fltmc >nul 2>&1
if errorlevel 1 (
    cls
    color 0C
    echo ============================================================
    echo          ESTE SCRIPT PRECISA DE ADMINISTRADOR
    echo ============================================================
    echo.
    echo Tentando executar novamente como Administrador...
    echo.

    powershell.exe -NoProfile -ExecutionPolicy Bypass -Command ^
    "Start-Process -FilePath '%~f0' -Verb RunAs"

    exit /b
)

:: ============================================================
:: PREPARAR PASTAS E DATA
:: ============================================================

if not exist "%LOG_DIR%" mkdir "%LOG_DIR%" >nul 2>&1
if not exist "%RELATORIO_DIR%" mkdir "%RELATORIO_DIR%" >nul 2>&1

for /f %%D in ('powershell.exe -NoProfile -Command "Get-Date -Format yyyy-MM-dd_HH-mm-ss"') do (
    set "DATA_EXECUCAO=%%D"
)

set "LOG_FILE=%LOG_DIR%\Limpeza_%DATA_EXECUCAO%.log"
set "REPORT_FILE=%RELATORIO_DIR%\Relatorio_%DATA_EXECUCAO%.txt"

:: ============================================================
:: ESPACO INICIAL
:: ============================================================

for /f %%A in ('powershell.exe -NoProfile -Command ^
    "[math]::Round((Get-PSDrive -Name $env:SystemDrive.Substring 2)"') do (
    set "ESPACO_INICIAL_GB=%%A"
)

for /f %%A in ('powershell.exe -NoProfile -Command ^
    "(Get-PSDrive -Name $env:SystemDrive.Substring(0,1)).Free"') do (
    set "ESPACO_INICIAL_BYTES=%%A"
)

:: ============================================================
:: MENU
:: ============================================================

:MENU
cls
color 0A

echo ============================================================================================
echo                         LIMPEZA ULTIMATE DO WINDOWS
echo                                  Versao %SCRIPT_VERSION%
echo ============================================================================================
echo.
echo Unidade do sistema: %SYSTEM_DRIVE%
echo Espaco livre atual: %ESPACO_INICIAL_GB% GB
echo.
echo [1] LIMPEZA SEGURA
echo     Temporarios, caches, miniaturas, DNS, lixeira e navegadores.
echo.
echo [2] LIMPEZA PROFUNDA
echo     Inclui Windows Update, Delivery Optimization, componentes antigos e relatorio DISM.
echo.
echo [3] SOMENTE ANALISAR
echo     Nao apaga arquivos. Exibe armazenamento e abre as configuracoes do Windows.
echo.
echo [4] SAIR
echo.
echo ============================================================================================

choice /c 1234 /n /m "Escolha uma opcao: "

if errorlevel 4 exit /b
if errorlevel 3 goto ANALISAR
if errorlevel 2 (
    set "MODO=PROFUNDA"
    goto CONFIRMAR
)
if errorlevel 1 (
    set "MODO=SEGURA"
    goto CONFIRMAR
)

:: ============================================================
:: CONFIRMACAO
:: ============================================================

:CONFIRMAR
cls
color 0E

echo ============================================================================================
echo                              CONFIRMACAO
echo ============================================================================================
echo.
echo Modo selecionado: %MODO%
echo.
echo Arquivos bloqueados ou em uso serao ignorados.
echo Documentos, Downloads, Area de Trabalho e arquivos pessoais nao serao excluidos.
echo Navegadores nao serao fechados automaticamente.
echo.
echo Recomendacoes:
echo.
echo  - Salve seus trabalhos antes de continuar.
echo  - Feche Chrome, Edge e outros programas para limpar mais arquivos.
echo  - Nao desligue o computador durante a limpeza profunda.
echo.

choice /c SN /n /m "Deseja iniciar a limpeza? [S/N]: "

if errorlevel 2 goto MENU
if errorlevel 1 goto INICIAR

:: ============================================================
:: INICIO
:: ============================================================

:INICIAR
cls
color 0A

call :LOG "============================================================"
call :LOG "INICIO DA LIMPEZA"
call :LOG "Modo: %MODO%"
call :LOG "Computador: %COMPUTERNAME%"
call :LOG "Usuario: %USERNAME%"
call :LOG "Espaco inicial: %ESPACO_INICIAL_GB% GB"
call :LOG "============================================================"

echo ============================================================================================
echo                           LIMPEZA EM ANDAMENTO
echo ============================================================================================
echo.
echo Modo selecionado: %MODO%
echo Log: %LOG_FILE%
echo.

:: ============================================================
:: LIMPEZA SEGURA
:: ============================================================

call :ETAPA "Temporarios do usuario atual"
call :LIMPAR_PASTA "%TEMP%"
call :LIMPAR_PASTA "%LOCALAPPDATA%\Temp"

call :ETAPA "Temporarios do Windows"
call :LIMPAR_PASTA "%WINDIR%\Temp"

call :ETAPA "Temporarios dos perfis de usuarios"
for /d %%U in ("%SYSTEMDRIVE%\Users\*") do (
    if exist "%%~fU\AppData\Local\Temp" (
        call :LIMPAR_PASTA "%%~fU\AppData\Local\Temp"
    )
)

call :ETAPA "Cache de miniaturas"
call :LIMPAR_ARQUIVOS "%LOCALAPPDATA%\Microsoft\Windows\Explorer" "thumbcache_*.db"

call :ETAPA "Cache de icones"
call :LIMPAR_ARQUIVOS "%LOCALAPPDATA%\Microsoft\Windows\Explorer" "iconcache_*.db"

call :ETAPA "Cache DirectX Shader"
call :LIMPAR_PASTA "%LOCALAPPDATA%\D3DSCache"

call :ETAPA "Relatorios de falhas de aplicativos"
call :LIMPAR_PASTA "%LOCALAPPDATA%\CrashDumps"
call :LIMPAR_PASTA "%LOCALAPPDATA%\Microsoft\Windows\WER\ReportArchive"
call :LIMPAR_PASTA "%LOCALAPPDATA%\Microsoft\Windows\WER\ReportQueue"

call :ETAPA "Cache de aplicativos INetCache"
call :LIMPAR_PASTA "%LOCALAPPDATA%\Microsoft\Windows\INetCache"

call :ETAPA "Cache do Chrome"
call :LIMPAR_PASTA "%LOCALAPPDATA%\Google\Chrome\User Data\Default\Cache"
call :LIMPAR_PASTA "%LOCALAPPDATA%\Google\Chrome\User Data\Default\Code Cache"
call :LIMPAR_PASTA "%LOCALAPPDATA%\Google\Chrome\User Data\Default\GPUCache"

call :ETAPA "Cache do Microsoft Edge"
call :LIMPAR_PASTA "%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Cache"
call :LIMPAR_PASTA "%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Code Cache"
call :LIMPAR_PASTA "%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\GPUCache"

call :ETAPA "Cache do Microsoft Store"
wsreset.exe -i >nul 2>&1
call :LOG "Comando de limpeza do Microsoft Store executado."

call :ETAPA "Cache DNS"
ipconfig /flushdns >>"%LOG_FILE%" 2>&1

call :ETAPA "Lixeira"
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command ^
"try { Clear-RecycleBin -Force -ErrorAction Stop } catch { exit 0 }" >>"%LOG_FILE%" 2>&1

if /I "%MODO%"=="SEGURA" goto FINALIZAR

:: ============================================================
:: LIMPEZA PROFUNDA
:: ============================================================

call :ETAPA "Criando ponto de verificacao no log"
call :LOG "Inicio das operacoes profundas."

call :ETAPA "Parando servicos do Windows Update"

set "WUAUSERV_PARADO=0"
set "BITS_PARADO=0"
set "DOSVC_PARADO=0"

sc query wuauserv | find /i "RUNNING" >nul 2>&1
if not errorlevel 1 (
    net stop wuauserv >>"%LOG_FILE%" 2>&1
    set "WUAUSERV_PARADO=1"
)

sc query bits | find /i "RUNNING" >nul 2>&1
if not errorlevel 1 (
    net stop bits >>"%LOG_FILE%" 2>&1
    set "BITS_PARADO=1"
)

sc query dosvc | find /i "RUNNING" >nul 2>&1
if not errorlevel 1 (
    net stop dosvc >>"%LOG_FILE%" 2>&1
    set "DOSVC_PARADO=1"
)

call :ETAPA "Cache baixado do Windows Update"
call :LIMPAR_PASTA "%WINDIR%\SoftwareDistribution\Download"

call :ETAPA "Cache do Delivery Optimization"
call :LIMPAR_PASTA "%WINDIR%\SoftwareDistribution\DeliveryOptimization"
call :LIMPAR_PASTA "%SYSTEMDRIVE%\ProgramData\Microsoft\Windows\DeliveryOptimization\Cache"

call :ETAPA "Arquivos temporarios do sistema"
if exist "%WINDIR%\Downloaded Program Files" (
    call :LIMPAR_PASTA "%WINDIR%\Downloaded Program Files"
)

call :ETAPA "Limpeza de componentes antigos do Windows"
DISM.exe /Online /Cleanup-Image /StartComponentCleanup >>"%LOG_FILE%" 2>&1
set "DISM_RESULT=%errorlevel%"

if "%DISM_RESULT%"=="0" (
    call :LOG "DISM StartComponentCleanup concluido com sucesso."
) else (
    call :LOG "DISM retornou o codigo %DISM_RESULT%."
)

call :ETAPA "Analise do armazenamento de componentes"
DISM.exe /Online /Cleanup-Image /AnalyzeComponentStore >>"%LOG_FILE%" 2>&1

call :ETAPA "Reiniciando servicos"

if "!DOSVC_PARADO!"=="1" (
    net start dosvc >>"%LOG_FILE%" 2>&1
)

if "!BITS_PARADO!"=="1" (
    net start bits >>"%LOG_FILE%" 2>&1
)

if "!WUAUSERV_PARADO!"=="1" (
    net start wuauserv >>"%LOG_FILE%" 2>&1
)

:: Garantir que os servicos importantes nao ficaram parados
sc query wuauserv | find /i "RUNNING" >nul 2>&1
if errorlevel 1 net start wuauserv >>"%LOG_FILE%" 2>&1

sc query bits | find /i "RUNNING" >nul 2>&1
if errorlevel 1 net start bits >>"%LOG_FILE%" 2>&1

:: ============================================================
:: FINALIZAR
:: ============================================================

:FINALIZAR

call :ETAPA "Calculando espaco liberado"

for /f %%A in ('powershell.exe -NoProfile -Command ^
    "(Get-PSDrive -Name $env:SystemDrive.Substring(0,1)).Free"') do (
    set "ESPACO_FINAL_BYTES=%%A"
)

for /f %%A in ('powershell.exe -NoProfile -Command ^
    "[math]::Round((Get-PSDrive -Name $env:SystemDrive.Substring(0)"') do (
    set "ESPACO_FINAL_GB=%%A"
)

for /f %%A in ('powershell.exe -NoProfile -Command ^
    "$d=[decimal]'%ESPACO_FINAL_BYTES%'-[decimal]'%ESPACO_INICIAL_BYTES%'; [math]:: do (
    set "ESPACO_LIBERADO_GB=%%A"
)

for /f %%A in ('powershell.exe -NoProfile -Command ^
    "$d=[decimal]'%ESPACO_FINAL_BYTES%'-[decimal]'%ESPACO_INICIAL_BYTES%'; [math]::Round
    set "ESPACO_LIBERADO_MB=%%A"
)

call :LOG "============================================================"
call :LOG "LIMPEZA FINALIZADA"
call :LOG "Espaco inicial: %ESPACO_INICIAL_GB% GB"
call :LOG "Espaco final: %ESPACO_FINAL_GB% GB"
call :LOG "Espaco liberado: %ESPACO_LIBERADO_GB% GB"
call :LOG "============================================================"

:: ============================================================
:: RELATORIO
:: ============================================================

(
    echo ============================================================
    echo          RELATORIO DE LIMPEZA DO WINDOWS
    echo ============================================================
    echo.
    echo Data: %DATE% %TIME%
    echo Computador: %COMPUTERNAME%
    echo Usuario: %USERNAME%
    echo Modo executado: %MODO%
    echo.
    echo Espaco livre antes: %ESPACO_INICIAL_GB% GB
    echo Espaco livre depois: %ESPACO_FINAL_GB% GB
    echo Espaco liberado: %ESPACO_LIBERADO_GB% GB
    echo Espaco liberado em MB: %ESPACO_LIBERADO_MB% MB
    echo.
    echo Arquivos bloqueados ou em uso foram ignorados.
    echo Documentos e arquivos pessoais nao foram removidos.
    echo.
    echo Log detalhado:
    echo %LOG_FILE%
    echo.
    echo ============================================================
) >"%REPORT_FILE%"

cls
color 0A

echo ============================================================================================
echo                              LIMPEZA CONCLUIDA
echo ============================================================================================
echo.
echo Modo executado:        %MODO%
echo Espaco livre antes:   %ESPACO_INICIAL_GB% GB
echo Espaco livre depois:  %ESPACO_FINAL_GB% GB
echo Espaco liberado:      %ESPACO_LIBERADO_GB% GB
echo.
echo Log detalhado:
echo %LOG_FILE%
echo.
echo Relatorio:
echo %REPORT_FILE%
echo.
echo ============================================================================================
echo [1] Abrir relatorio
echo [2] Abrir configuracoes de armazenamento
echo [3] Encerrar
echo.

choice /c 123 /n /m "Escolha uma opcao: "

if errorlevel 3 exit /b
if errorlevel 2 (
    start "" ms-settings:storage
    exit /b
)
if errorlevel 1 (
    start "" notepad.exe "%REPORT_FILE%"
    exit /b
)

exit /b

:: ============================================================
:: SOMENTE ANALISAR
:: ============================================================

:ANALISAR
cls
color 0B

echo ============================================================================================
echo                         ANALISE DE ARMAZENAMENTO
echo ============================================================================================
echo.
echo Espaco livre atual: %ESPACO_INICIAL_GB% GB
echo.
echo Abrindo as configuracoes de armazenamento...
echo Nenhum arquivo sera apagado.
echo.

start "" ms-settings:storage

timeout /t 3 /nobreak >nul
exit /b

:: ============================================================
:: FUNCOES
:: ============================================================

:ETAPA
echo [OK] %~1...
call :LOG "%~1"
exit /b

:LOG
echo [%DATE% %TIME%] %~1>>"%LOG_FILE%"
exit /b

:LIMPAR_PASTA
set "PASTA_ALVO=%~1"

if "%PASTA_ALVO%"=="" exit /b

if not exist "%PASTA_ALVO%" (
    call :LOG "Pasta nao encontrada: %PASTA_ALVO%"
    exit /b
)

powershell.exe -NoProfile -ExecutionPolicy Bypass -Command ^
"$p=$env:PASTA_LIMPEZA; if(Test-Path -LiteralPath $p){Get-ChildItem -LiteralPath $p -Force -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue}" ^
>>"%LOG_FILE%" 2>&1

:: Fallback nativo do CMD
del /f /s /q "%PASTA_ALVO%\*" >>"%LOG_FILE%" 2>&1

for /d %%G in ("%PASTA_ALVO%\*") do (
    rd /s /q "%%~fG" >>"%LOG_FILE%" 2>&1
)

call :LOG "Limpeza processada: %PASTA_ALVO%"
exit /b

:LIMPAR_ARQUIVOS
set "PASTA_ARQUIVOS=%~1"
set "FILTRO_ARQUIVOS=%~2"

if not exist "%PASTA_ARQUIVOS%" (
    call :LOG "Pasta nao encontrada: %PASTA_ARQUIVOS%"
    exit /b
)

del /f /q "%PASTA_ARQUIVOS%\%FILTRO_ARQUIVOS%" >>"%LOG_FILE%" 2>&1
call :LOG "Filtro processado: %PASTA_ARQUIVOS%\%FILTRO_ARQUIVOS%"
exit /b
