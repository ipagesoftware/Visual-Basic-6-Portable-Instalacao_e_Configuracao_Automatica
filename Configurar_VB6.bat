@echo off
setlocal EnableExtensions
chcp 65001 >nul
:: Truque para gerar o caractere ESC (invisível/controle) necessário para o ANSI
for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do set "ESC=%%b"
mode con: cols=100 lines=40
:: Cor de fundo azul + texto branco
color 1F
:: Oculta o cursor
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command ^
    "[Console]::CursorVisible = $false"
	
title Configuração de Compatibilidade - Visual Basic 6

:: ============================================================
:: VERIFICA POWERSHELL
:: ============================================================

if not exist "%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" (	
    cls
    echo.
    color 4F
    echo ╔══════════════════════════════════════════════════════════╗
    echo ║                          ATENÇÃO                         ║
    echo ╠══════════════════════════════════════════════════════════╣
    echo ║                                                          ║
    echo ║ ERRO:                                                    ║
    echo ║ PowerShell não encontrado.                               ║
    echo ║                                                          ║
    echo ╚══════════════════════════════════════════════════════════╝
    echo.    
    pause
    exit /b 1		
)

:: ============================================================
:: VERIFICA ADMINISTRADOR
:: ============================================================
net session >nul 2>&1

if %errorlevel% neq 0 (
    echo.
    echo Solicitando privilégios de Administrador...
    echo.

    powershell.exe -NoProfile -ExecutionPolicy Bypass ^
        -Command "Start-Process -FilePath '%~f0' -Verb RunAs"

    exit /b
)


:: ===========================================================
:: CONFIGURAÇÕES DOS ARQUIVOS
:: ===========================================================

set "PASTA_DOWNLOAD=%~dp0%"
set "VB_FILE=Portable.VB6.zip"
set "PORTABLE_PATH=C:\portable\vb6"

:: ============================================================
:: CONFIGURAÇÃO
:: ============================================================

set "PS1=%~dp0Configurar_VB6.ps1"

:: ============================================================
:: VERIFICA SE O ARQUIVO Portable.VB6.zip EXISTE
:: ============================================================


if not exist "%PASTA_DOWNLOAD%%VB_FILE%" (
    cls
    echo.
    color 4F
    echo ╔══════════════════════════════════════════════════════════╗
    echo ║                          ATENÇÃO                         ║
    echo ╠══════════════════════════════════════════════════════════╣
    echo ║                                                          ║
    echo ║ ERRO:                                                    ║
    echo ║ %VB_FILE% não foi encontrado.                     ║
    echo ║                                                          ║
    echo ╚══════════════════════════════════════════════════════════╝
    echo.    
    pause
    exit /b 1
)

:: ===========================================================
:: FUNCAO - INSTALAR VB6
:: ===========================================================

:VB6
cls
echo %ESC%[6;0H
echo.
echo.
echo ╔═══════════════════════════════════════════════════════════════════════════════════════════╗
echo ║                         INSTALANDO PACOTE VISUAL BASIC 6.0 PORTÁTIL                       ║
echo ╠═══════════════════════════════════════════════════════════════════════════════════════════╣
echo ║                                                                                           ║
echo ║ O Visual Basic 6.0 Portable é uma versão modificada e não oficial da linguagem e ambiente ║
echo ║ de desenvolvimento (IDE) Visual Basic 6.0 da Microsoft, compactada para rodar diretamente ║
echo ║ a partir de uma pasta ou pendrive, sem a necessidade de instalação no Windows.            ║
echo ║ O OpenJDK 19 é o ambiente Java que fornece ao B4A as ferramentas necessárias              ║
echo ║                                                                                           ║
echo ║                                                                                           ║
echo ║ Aguarde alguns segundos para a conclusão da instalação.                                   ║
echo ║                                                                                           ║
echo ╚═══════════════════════════════════════════════════════════════════════════════════════════╝
echo.
echo.


if not exist "%PORTABLE_PATH%" (
    mkdir "%PORTABLE_PATH%"
)

powershell.exe -NoProfile -ExecutionPolicy Bypass ^
    -Command "Expand-Archive -LiteralPath '%PASTA_DOWNLOAD%%VB_FILE%' -DestinationPath '%PORTABLE_PATH%' -Force"

if errorlevel 1 (
    cls
    echo.
    color 4F
    echo ╔══════════════════════════════════════════════════════════╗
    echo ║                        ATENÇÃO                           ║
    echo ╠══════════════════════════════════════════════════════════╣
    echo ║                                                          ║
    echo ║ ERRO:                                                    ║
    echo ║ Falha ao instalar o Visual Basic 6.0 portátil.           ║
    echo ║                                                          ║
    echo ╚══════════════════════════════════════════════════════════╝
    color 1F
    echo.
    ::del /q "%DESTINO%.download" >nul 2>&1
    exit /b 1  
)
:: ============================================================
:: EXECUTA POWERSHELL
:: ============================================================

powershell.exe ^
    -NoLogo ^
    -NoProfile ^
    -ExecutionPolicy Bypass ^
    -File "%PS1%" ^
    -VB6Path "%PORTABLE_PATH%\vb6.exe"

echo.
echo.
echo %PORTABLE_PATH%\vb6.exe
pause
exit /b/1
cls
echo.
color 1F
echo.
echo ========================================================
echo Processo concluido.
echo ========================================================
echo.

pause
exit /b
