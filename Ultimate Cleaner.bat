@echo off
setlocal EnableExtensions EnableDelayedExpansion
chcp 65001 >nul 2>&1
title LIMPEZA ULTIMATE DO WINDOWS
color 0A
mode con cols=96 lines=38 >nul 2>&1

rem ============================================================
rem CONFIGURACOES
rem ============================================================
set "VERSAO=4.0"
set "BASE=%~dp0"
set "LOG_DIR=%BASE%Logs_Limpeza"
set "REL_DIR=%BASE%Relatorios_Limpeza"
set "MODO="
set "SERV_WUA=0"
set "SERV_BITS=0"
set "SERV_DOSVC=0"

rem ============================================================
rem ELEVAR PARA ADMINISTRADOR
rem ============================================================
fltmc >nul 2>&1
if errorlevel 1 (
    echo Solicitando permissao de Administrador...
    powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    if errorlevel 1 (
        echo.
        echo Nao foi possivel solicitar permissao de Administrador.
        pause
    )
    exit /b
)

rem ============================================================
rem PREPARAR PASTAS E NOMES
rem ============================================================
if not exist "%LOG_DIR%" md "%LOG_DIR%" >nul 2>&1
if not exist "%REL_DIR%" md "%REL_DIR%" >nul 2>&1

for /f "usebackq delims=" %%A in (`powershell.exe -NoProfile -Command "Get-Date -Format 'yyyy-MM-dd_HH-mm-ss'"`) do set "STAMP=%%A"
if not defined STAMP set "STAMP=%RANDOM%"

set "LOG=%LOG_DIR%\Limpeza_%STAMP%.log"
set "RELATORIO=%REL_DIR%\Relatorio_%STAMP%.txt"

call :OBTER_ESPACO ESPACO_INICIAL_BYTES ESPACO_INICIAL_GB
call :LOG "Inicio do programa. Espaco livre: %ESPACO_INICIAL_GB% GB"

goto MENU

rem ============================================================
rem MENU PRINCIPAL
rem ============================================================
:MENU
cls
color 0A
echo ================================================================================================
echo                           LIMPEZA ULTIMATE DO WINDOWS v%VERSAO%
echo ================================================================================================
echo.
echo Espaco livre atual: %ESPACO_INICIAL_GB% GB
echo.
echo [1] LIMPEZA SEGURA
echo     Temporarios, caches, miniaturas, DNS, lixeira e caches dos navegadores.
echo.
echo [2] LIMPEZA PROFUNDA
echo     Inclui Windows Update, Delivery Optimization e limpeza de componentes com DISM.
echo.
echo [3] SOMENTE ANALISAR
echo     Exibe o espaco atual e abre as configuracoes de armazenamento. Nao exclui nada.
echo.
echo [4] SAIR
echo.
echo ================================================================================================
choice /c 1234 /n /m "Escolha uma opcao [1-4]: "

if errorlevel 4 goto ENCERRAR
if errorlevel 3 goto ANALISAR
if errorlevel 2 (
    set "MODO=PROFUNDA"
    goto CONFIRMAR
)
if errorlevel 1 (
    set "MODO=SEGURA"
    goto CONFIRMAR
)
goto MENU

rem ============================================================
rem CONFIRMACAO
rem ============================================================
:CONFIRMAR
cls
color 0E
echo ================================================================================================
echo                                      CONFIRMACAO
echo ================================================================================================
echo.
echo Modo selecionado: %MODO%
echo.
echo - Documentos, Downloads, Area de Trabalho e arquivos pessoais NAO serao removidos.
echo - Arquivos bloqueados ou em uso serao ignorados.
echo - Feche Chrome e Edge para permitir uma limpeza melhor dos caches.
echo - O modo profundo pode demorar por causa do DISM.
echo.
choice /c SN /n /m "Deseja continuar? [S/N]: "
if errorlevel 2 goto MENU
if errorlevel 1 goto INICIAR
goto MENU

rem ============================================================
rem LIMPEZA SEGURA
rem ============================================================
:INICIAR
cls
color 0A
call :LOG "Inicio da limpeza. Modo: %MODO%"

echo ================================================================================================
echo                              LIMPEZA %MODO% EM ANDAMENTO
echo ================================================================================================
echo.

call :ETAPA "Temporarios do usuario atual"
call :LIMPAR_PASTA "%TEMP%"

if /i not "%TEMP%"=="%LOCALAPPDATA%\Temp" (
    call :LIMPAR_PASTA "%LOCALAPPDATA%\Temp"
)

call :ETAPA "Temporarios do Windows"
call :LIMPAR_PASTA "%WINDIR%\Temp"

call :ETAPA "Temporarios dos perfis locais"
for /d %%U in ("%SystemDrive%\Users\*") do (
    if exist "%%~fU\AppData\Local\Temp" call :LIMPAR_PASTA "%%~fU\AppData\Local\Temp"
)

call :ETAPA "Cache de miniaturas e icones"
call :LIMPAR_ARQUIVOS "%LOCALAPPDATA%\Microsoft\Windows\Explorer" "thumbcache_*.db"
call :LIMPAR_ARQUIVOS "%LOCALAPPDATA%\Microsoft\Windows\Explorer" "iconcache_*.db"

call :ETAPA "Cache DirectX Shader"
call :LIMPAR_PASTA "%LOCALAPPDATA%\D3DSCache"

call :ETAPA "Relatorios de falhas de aplicativos"
call :LIMPAR_PASTA "%LOCALAPPDATA%\CrashDumps"
call :LIMPAR_PASTA "%LOCALAPPDATA%\Microsoft\Windows\WER\ReportArchive"
call :LIMPAR_PASTA "%LOCALAPPDATA%\Microsoft\Windows\WER\ReportQueue"
call :LIMPAR_PASTA "%ProgramData%\Microsoft\Windows\WER\ReportArchive"
call :LIMPAR_PASTA "%ProgramData%\Microsoft\Windows\WER\ReportQueue"

call :ETAPA "Cache de Internet do Windows"
call :LIMPAR_PASTA "%LOCALAPPDATA%\Microsoft\Windows\INetCache"

call :ETAPA "Cache do Google Chrome"
call :LIMPAR_CACHE_CHROMIUM "%LOCALAPPDATA%\Google\Chrome\User Data"

call :ETAPA "Cache do Microsoft Edge"
call :LIMPAR_CACHE_CHROMIUM "%LOCALAPPDATA%\Microsoft\Edge\User Data"

call :ETAPA "Cache DNS"
ipconfig /flushdns >>"%LOG%" 2>&1

call :ETAPA "Lixeira"
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "try { Clear-RecycleBin -Force -ErrorAction Stop } catch { exit 0 }" >>"%LOG%" 2>&1

if /i "%MODO%"=="PROFUNDA" goto PROFUNDA
goto FINALIZAR

rem ============================================================
rem LIMPEZA PROFUNDA
rem ============================================================
:PROFUNDA
call :ETAPA "Verificando e parando servicos de atualizacao"
call :PARAR_SERVICO wuauserv SERV_WUA
call :PARAR_SERVICO bits SERV_BITS
call :PARAR_SERVICO dosvc SERV_DOSVC

call :ETAPA "Cache baixado do Windows Update"
call :LIMPAR_PASTA "%WINDIR%\SoftwareDistribution\Download"

call :ETAPA "Cache do Delivery Optimization"
call :LIMPAR_PASTA "%WINDIR%\SoftwareDistribution\DeliveryOptimization"
call :LIMPAR_PASTA "%ProgramData%\Microsoft\Windows\DeliveryOptimization\Cache"

call :ETAPA "Componentes antigos do Windows com DISM"
DISM.exe /Online /Cleanup-Image /StartComponentCleanup >>"%LOG%" 2>&1
set "DISM_RC=!errorlevel!"
call :LOG "DISM finalizado com codigo !DISM_RC!."

call :ETAPA "Reiniciando servicos anteriormente ativos"
if "!SERV_DOSVC!"=="1" net start dosvc >>"%LOG%" 2>&1
if "!SERV_BITS!"=="1" net start bits >>"%LOG%" 2>&1
if "!SERV_WUA!"=="1" net start wuauserv >>"%LOG%" 2>&1

goto FINALIZAR

rem ============================================================
rem FINALIZACAO E RELATORIO
rem ============================================================
:FINALIZAR
call :ETAPA "Calculando espaco liberado"
call :OBTER_ESPACO ESPACO_FINAL_BYTES ESPACO_FINAL_GB

for /f "usebackq delims=" %%A in (`powershell.exe -NoProfile -Command "$a=[decimal]'%ESPACO_INICIAL_BYTES%'; $b=[decimal]'%ESPACO_FINAL_BYTES%'; [Math]::Round(($b-$a)/1MB,2).ToString([Globalization.CultureInfo]::InvariantCulture)"`) do set "LIBERADO_MB=%%A"
for /f "usebackq delims=" %%A in (`powershell.exe -NoProfile -Command "$a=[decimal]'%ESPACO_INICIAL_BYTES%'; $b=[decimal]'%ESPACO_FINAL_BYTES%'; [Math]::Round(($b-$a)/1GB,3).ToString([Globalization.CultureInfo]::InvariantCulture)"`) do set "LIBERADO_GB=%%A"

if not defined LIBERADO_MB set "LIBERADO_MB=0"
if not defined LIBERADO_GB set "LIBERADO_GB=0"

call :LOG "Limpeza concluida. Antes: %ESPACO_INICIAL_GB% GB. Depois: %ESPACO_FINAL_GB% GB. Liberado: %LIBERADO_MB% MB."

(
    echo ============================================================
    echo RELATORIO DE LIMPEZA DO WINDOWS
    echo ============================================================
    echo Data: %DATE% %TIME%
    echo Computador: %COMPUTERNAME%
    echo Usuario: %USERNAME%
    echo Modo: %MODO%
    echo.
    echo Espaco livre antes: %ESPACO_INICIAL_GB% GB
    echo Espaco livre depois: %ESPACO_FINAL_GB% GB
    echo Espaco liberado: %LIBERADO_MB% MB ^(%LIBERADO_GB% GB^)
    echo.
    echo Arquivos bloqueados ou em uso foram ignorados.
    echo Arquivos pessoais nao foram removidos.
    echo.
    echo Log detalhado: %LOG%
) >"%RELATORIO%"

cls
color 0A
echo ================================================================================================
echo                                  LIMPEZA CONCLUIDA
echo ================================================================================================
echo.
echo Modo executado:       %MODO%
echo Espaco livre antes:  %ESPACO_INICIAL_GB% GB
echo Espaco livre depois: %ESPACO_FINAL_GB% GB
echo Espaco liberado:     %LIBERADO_MB% MB ^(%LIBERADO_GB% GB^)
echo.
echo Log:       %LOG%
echo Relatorio: %RELATORIO%
echo.
echo [1] Abrir relatorio
echo [2] Abrir configuracoes de armazenamento
echo [3] Voltar ao menu
echo [4] Encerrar
echo.
choice /c 1234 /n /m "Escolha uma opcao [1-4]: "
if errorlevel 4 goto ENCERRAR
if errorlevel 3 (
    call :OBTER_ESPACO ESPACO_INICIAL_BYTES ESPACO_INICIAL_GB
    goto MENU
)
if errorlevel 2 (
    start "" ms-settings:storage
    goto AGUARDAR_FINAL
)
if errorlevel 1 (
    start "" notepad.exe "%RELATORIO%"
    goto AGUARDAR_FINAL
)
goto AGUARDAR_FINAL

:AGUARDAR_FINAL
echo.
echo Pressione qualquer tecla para voltar ao menu...
pause >nul
call :OBTER_ESPACO ESPACO_INICIAL_BYTES ESPACO_INICIAL_GB
goto MENU

rem ============================================================
rem SOMENTE ANALISAR
rem ============================================================
:ANALISAR
cls
color 0B
call :OBTER_ESPACO ESPACO_ATUAL_BYTES ESPACO_ATUAL_GB

echo ================================================================================================
echo                              ANALISE DE ARMAZENAMENTO
echo ================================================================================================
echo.
echo Unidade do sistema: %SystemDrive%
echo Espaco livre atual: %ESPACO_ATUAL_GB% GB
echo.
echo Nenhum arquivo foi removido.
echo Abrindo as configuracoes de armazenamento do Windows...
start "" ms-settings:storage

echo.
echo Pressione qualquer tecla para voltar ao menu...
pause >nul
goto MENU

rem ============================================================
rem FUNCOES
rem ============================================================
:OBTER_ESPACO
set "%~1=0"
set "%~2=0"
for /f "usebackq delims=" %%A in (`powershell.exe -NoProfile -Command "$d=$env:SystemDrive.TrimEnd(':'); [Int64](Get-PSDrive -Name $d).Free"`) do set "%~1=%%A"
for /f "usebackq delims=" %%A in (`powershell.exe -NoProfile -Command "$d=$env:SystemDrive.TrimEnd(':'); [Math]::Round((Get-PSDrive -Name $d).Free/1GB,2).ToString([Globalization.CultureInfo]::InvariantCulture)"`) do set "%~2=%%A"
exit /b 0

:ETAPA
echo [*] %~1...
call :LOG "%~1"
exit /b 0

:LOG
>>"%LOG%" echo [%DATE% %TIME%] %~1
exit /b 0

:LIMPAR_PASTA
set "ALVO=%~1"
if not defined ALVO exit /b 0
if not exist "%ALVO%" (
    call :LOG "Pasta nao encontrada: %ALVO%"
    exit /b 0
)

set "ALVO_PS=%ALVO%"
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "$p=$env:ALVO_PS; if (Test-Path -LiteralPath $p) { Get-ChildItem -LiteralPath $p -Force -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue }" >>"%LOG%" 2>&1
call :LOG "Pasta processada: %ALVO%"
exit /b 0

:LIMPAR_ARQUIVOS
set "PASTA=%~1"
set "FILTRO=%~2"
if not exist "%PASTA%" exit /b 0
del /f /q "%PASTA%\%FILTRO%" >>"%LOG%" 2>&1
call :LOG "Filtro processado: %PASTA%\%FILTRO%"
exit /b 0

:LIMPAR_CACHE_CHROMIUM
set "PERFIS=%~1"
if not exist "%PERFIS%" (
    call :LOG "Navegador nao encontrado em: %PERFIS%"
    exit /b 0
)
for /d %%P in ("%PERFIS%\Default" "%PERFIS%\Profile *") do (
    if exist "%%~fP" (
        call :LIMPAR_PASTA "%%~fP\Cache"
        call :LIMPAR_PASTA "%%~fP\Code Cache"
        call :LIMPAR_PASTA "%%~fP\GPUCache"
        call :LIMPAR_PASTA "%%~fP\Service Worker\CacheStorage"
    )
)
exit /b 0

:PARAR_SERVICO
set "%~2=0"
sc query "%~1" | find /i "RUNNING" >nul 2>&1
if not errorlevel 1 (
    net stop "%~1" >>"%LOG%" 2>&1
    if not errorlevel 1 set "%~2=1"
)
exit /b 0

rem ============================================================
rem ENCERRAR
rem ============================================================
:ENCERRAR
cls
color 07
echo ============================================================
echo Programa finalizado.
echo ============================================================
echo.
echo Pressione qualquer tecla para fechar.
pause >nul
endlocal
exit /b 0
