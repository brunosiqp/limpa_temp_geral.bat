@echo off
title Limpeza de Tralha - C:
color 0A

echo Limpando arquivos temporarios...

echo.
echo Limpando TEMP do usuario...
del /s /f /q "%temp%\*.*"
rd /s /q "%temp%"
mkdir "%temp%"

echo.
echo Limpando AppData Local Temp...
del /s /f /q "C:\Users\%username%\AppData\Local\Temp\*.*"
rd /s /q "C:\Users\%username%\AppData\Local\Temp"
mkdir "C:\Users\%username%\AppData\Local\Temp"

echo.
echo Limpando cache do Windows...
del /s /f /q "C:\Windows\Temp\*.*"

echo.
echo Limpando cache do Prefetch...
del /s /f /q "C:\Windows\Prefetch\*.*"

echo.
echo Limpando cache do Windows Update...
net stop wuauserv
del /s /f /q "C:\Windows\SoftwareDistribution\Download\*.*"
net start wuauserv

echo.
echo Limpando cache do Edge/Chrome...

del /s /f /q "C:\Users\%username%\AppData\Local\Google\Chrome\User Data\Default\Cache\*.*"
del /s /f /q "C:\Users\%username%\AppData\Local\Microsoft\Edge\User Data\Default\Cache\*.*"

echo.
echo Limpeza finalizada guri.
pause