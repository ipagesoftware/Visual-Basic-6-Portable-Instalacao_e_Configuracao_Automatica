param (
    [Parameter(Mandatory = $true)]
    [string]$VB6Path
)

$ErrorActionPreference = "Stop"

# ============================================================
# VERIFICA ADMINISTRADOR
# ============================================================

$Principal = New-Object Security.Principal.WindowsPrincipal(
    [Security.Principal.WindowsIdentity]::GetCurrent()
)

$Administrador = $Principal.IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator
)

if (-not $Administrador) {

    Write-Host ""
    Write-Host "ERRO: este script precisa ser executado como Administrador." -ForegroundColor Red
    Write-Host ""

    exit 1
}

# ============================================================
# VERIFICA VB6.EXE
# ============================================================

if (-not (Test-Path -LiteralPath $VB6Path)) {

    Write-Host ""
    Write-Host "ERRO: VB6.exe nao encontrado." -ForegroundColor Red
    Write-Host $VB6Path
    Write-Host ""

    exit 1
}

# Caminho absoluto
$VB6Path = (Resolve-Path -LiteralPath $VB6Path).Path

# Pasta do VB6
$VB6Directory = Split-Path -Parent $VB6Path

# ============================================================
# CABEÇALHO
# ============================================================

Clear-Host

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "           CONFIGURACAO DO VISUAL BASIC 6" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Arquivo:"
Write-Host $VB6Path -ForegroundColor Yellow
Write-Host ""

# ============================================================
# 1. CONFIGURAÇÃO DE COMPATIBILIDADE
# ============================================================

$RegistryPath =
"HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers"

if (-not (Test-Path $RegistryPath)) {

    New-Item `
        -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags" `
        -Name "Layers" `
        -Force | Out-Null
}

# Windows XP SP3 + Administrador
$Compatibilidade = "~ WINXPSP3 RUNASADMIN"

Write-Host "------------------------------------------------------------"
Write-Host "1. COMPATIBILIDADE" -ForegroundColor Cyan
Write-Host "------------------------------------------------------------"
Write-Host ""

Write-Host "[OK] Windows XP Service Pack 3"
Write-Host "[OK] Executar como Administrador"
Write-Host ""

New-ItemProperty `
    -Path $RegistryPath `
    -Name $VB6Path `
    -PropertyType String `
    -Value $Compatibilidade `
    -Force | Out-Null

Write-Host "Compatibilidade registrada." -ForegroundColor Green
Write-Host ""

# ============================================================
# 2. REGISTRO DAS LICENÇAS DO VB6
# ============================================================

Write-Host "------------------------------------------------------------"
Write-Host "2. LICENCAS DO VISUAL BASIC 6" -ForegroundColor Cyan
Write-Host "------------------------------------------------------------"
Write-Host ""

# ------------------------------------------------------------
# Localização do REG.EXE
# ------------------------------------------------------------

$RegExe = "$env:SystemRoot\System32\reg.exe"

if (-not (Test-Path $RegExe)) {

    Write-Host "ERRO: reg.exe nao encontrado." -ForegroundColor Red
    exit 1
}

# ------------------------------------------------------------
# Função para registrar licença
# ------------------------------------------------------------

function Registrar-LicencaVB6 {

    param (
        [string]$Guid,
        [string]$Licenca
    )

    $Chave = "HKCR\Licenses\$Guid"

    Write-Host "Registrando:" -ForegroundColor Yellow
    Write-Host "  $Guid"

    try {

        # Cria a chave
        $Resultado = Start-Process `
            -FilePath $RegExe `
            -ArgumentList @(
            "ADD",
            $Chave,
            "/ve",
            "/d",
            $Licenca,
            "/f",
            "/reg:32"
        ) `
            -Wait `
            -PassThru `
            -NoNewWindow

        if ($Resultado.ExitCode -eq 0) {

            Write-Host "  [OK] Licenca registrada." -ForegroundColor Green
        }
        else {

            Write-Host "  [ERRO] Codigo: $($Resultado.ExitCode)" -ForegroundColor Red
        }

    }
    catch {

        Write-Host "  [ERRO] $($_.Exception.Message)" -ForegroundColor Red
    }

    Write-Host ""
}

# ------------------------------------------------------------
# LICENÇA 1
# ------------------------------------------------------------

Registrar-LicencaVB6 `
    -Guid "6000720D-F342-11D1-AF65-00A0C90DCA10" `
    -Licenca "kefeflhlhlgenelerfleheietfmflelljeqf"

# ------------------------------------------------------------
# LICENÇA 2
# ------------------------------------------------------------

Registrar-LicencaVB6 `
    -Guid "74872840-703A-11d1-A3AF-00A0C90F26FA" `
    -Licenca "mninuglgknogtgjnthmnggjgsmrmgniglish"

# ------------------------------------------------------------
# LICENÇA 3
# ------------------------------------------------------------

Registrar-LicencaVB6 `
    -Guid "74872841-703A-11d1-A3AF-00A0C90F26FA" `
    -Licenca "klglsejeilmereglrfkleeheqkpkelgejgqf"

Write-Host "Licencas do VB6 processadas." -ForegroundColor Green
Write-Host ""

function Criar-AtalhoVB6 {

    try {

        # Desktop do usuário
        $Desktop = [Environment]::GetFolderPath("Desktop")

        # Nome do atalho
        $Atalho = Join-Path $Desktop "Visual Basic 6.lnk"

        # WScript.Shell
        $Shell = New-Object -ComObject WScript.Shell

        # Cria o atalho
        $Shortcut = $Shell.CreateShortcut($Atalho)

        # Programa
        $Shortcut.TargetPath = $VB6Path

        # Pasta de trabalho
        $Shortcut.WorkingDirectory = $VB6Directory

        # Ícone do próprio VB6
        $Shortcut.IconLocation = "$VB6Path,0"

        # Descrição
        $Shortcut.Description = "Microsoft Visual Basic 6.0"

        # Salva
        $Shortcut.Save()

        Write-Host ""
        Write-Host "============================================================" -ForegroundColor Green
        Write-Host " ATALHO CRIADO COM SUCESSO!" -ForegroundColor Green
        Write-Host "============================================================" -ForegroundColor Green
        Write-Host ""

        Write-Host "Atalho:"
        Write-Host $Atalho -ForegroundColor Yellow
        Write-Host ""

        return $true

    }
    catch {

        Write-Host ""
        Write-Host "ERRO AO CRIAR O ATALHO:" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
        Write-Host ""

        return $false
    }
}

$Criado = Criar-AtalhoVB6

if ($Criado) {
    Write-Host ""
    Write-Host "Iniciando Visual Basic 6..." -ForegroundColor Cyan
    Write-Host ""

    Start-Process -FilePath $VB6Path
}
Write-Host ""
Write-Host "Operacao encerrada."
Write-Host ""
Read-Host "Pressione ENTER para sair"