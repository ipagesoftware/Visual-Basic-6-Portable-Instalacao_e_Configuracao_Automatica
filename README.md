# Visual Basic 6 Portable — Instalação e Configuração Automática
Este projeto fornece uma forma automatizada de preparar e executar uma versão Portable do Microsoft Visual Basic 6.0 no Windows.

A solução utiliza dois scripts:

* `Configurar_VB6.bat`
* `Configurar_VB6.ps1`

O arquivo `.bat` funciona como **instalador/orquestrador**, enquanto o `.ps1` realiza as **configurações específicas do Windows e do Visual Basic 6**.

> **Importante:** o Visual Basic 6.0 Portable utilizado neste projeto é uma versão modificada e não oficial. O projeto não é um instalador oficial da Microsoft e não redistribui uma licença do Visual Basic 6.0.

---

## 📁 Estrutura do projeto

A estrutura esperada é:

```text
VB6-Portable/
│
├── Configurar_VB6.bat
├── Configurar_VB6.ps1
└── Portable.VB6.zip
```

O arquivo `Portable.VB6.zip` deve estar na mesma pasta dos scripts.

Depois da execução, o programa será instalado em:

```text
C:\portable\vb6
```

A estrutura ficará aproximadamente assim:

```text
C:\
└── portable
    └── vb6
        ├── vb6.exe
        ├── ...
        └── ...
```

---

# 🚀 Como funciona

O processo possui duas etapas principais.

```text
Configurar_VB6.bat
        │
        ├── Verifica PowerShell
        │
        ├── Verifica Administrador
        │
        ├── Localiza Portable.VB6.zip
        │
        ├── Cria C:\portable\vb6
        │
        ├── Extrai o arquivo ZIP
        │
        └── Executa Configurar_VB6.ps1
                         │
                         ├── Verifica Administrador
                         ├── Localiza vb6.exe
                         ├── Configura compatibilidade
                         ├── Registra configurações/licenças
                         ├── Cria atalho
                         └── Executa o VB6
```

Dessa forma, cada script possui uma responsabilidade específica.

---

# 1. Configurar_VB6.bat

O arquivo `.bat` é responsável principalmente pela **instalação e preparação do ambiente**.

## 1.1 Ativação dos recursos do CMD

O script inicia com:

```bat
@echo off
setlocal EnableExtensions
chcp 65001 >nul
```

### `@echo off`

Evita que os comandos sejam exibidos enquanto o script está sendo executado.

### `setlocal EnableExtensions`

Ativa as extensões de comandos do Windows somente durante a execução do script.

### `chcp 65001`

Configura o console para utilizar UTF-8.

Isso permite trabalhar corretamente com caracteres como:

```text
ç
ã
é
á
ê
```

---

# 2. Personalização do console

O script configura o tamanho e as cores do terminal:

```bat
mode con: cols=100 lines=40
color 1F
```

O comando:

```bat
color 1F
```

utiliza:

```text
1 = fundo azul
F = texto branco
```

Portanto, o resultado é:

```text
Fundo: azul
Texto: branco
```

O cursor também é ocultado:

```bat
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command ^
    "[Console]::CursorVisible = $false"
```

---

# 3. Verificação do PowerShell

O instalador depende do Windows PowerShell para executar algumas operações.

Por isso, primeiro verifica se ele existe:

```bat
if not exist "%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" (
```

Caso o PowerShell não esteja disponível, o usuário recebe uma mensagem de erro e o processo é interrompido.

---

# 4. Verificação de administrador

Algumas operações realizadas pelo projeto exigem privilégios administrativos.

A verificação é feita através de:

```bat
net session >nul 2>&1
```

Se o script não estiver sendo executado como administrador:

```bat
if %errorlevel% neq 0 (
```

ele solicita elevação através do UAC:

```bat
powershell.exe -NoProfile -ExecutionPolicy Bypass ^
    -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
```

O parâmetro:

```text
-Verb RunAs
```

faz com que o Windows solicite autorização administrativa.

---

# 5. Definição dos arquivos e diretórios

O script define:

```bat
set "PASTA_DOWNLOAD=%~dp0%"
set "VB_FILE=Portable.VB6.zip"
set "PORTABLE_PATH=C:\portable\vb6"
```

### `%~dp0`

Representa o diretório onde o arquivo `.bat` está localizado.

Por exemplo:

```text
D:\VB6\
```

Assim, o instalador pode ser executado de diferentes locais sem precisar alterar o caminho manualmente.

---

# 6. Localização do PowerShell

O segundo script é definido através de:

```bat
set "PS1=%~dp0Configurar_VB6.ps1"
```

Isso significa que o arquivo:

```text
Configurar_VB6.ps1
```

deve estar na mesma pasta do `.bat`.

---

# 7. Verificação do Portable.VB6.zip

Antes de instalar, o script verifica:

```bat
if not exist "%PASTA_DOWNLOAD%%VB_FILE%" (
```

O arquivo esperado é:

```text
Portable.VB6.zip
```

Se ele não estiver presente, a instalação é interrompida.

Isso evita tentar executar uma instalação sem os arquivos necessários.

---

# 8. Criação do diretório

O destino definido é:

```text
C:\portable\vb6
```

O script verifica se o diretório existe:

```bat
if not exist "%PORTABLE_PATH%" (
    mkdir "%PORTABLE_PATH%"
)
```

Caso não exista, ele é criado automaticamente.

---

# 9. Extração do Portable VB6

A extração é feita através do PowerShell:

```bat
powershell.exe -NoProfile -ExecutionPolicy Bypass ^
    -Command "Expand-Archive -LiteralPath '%PASTA_DOWNLOAD%%VB_FILE%' -DestinationPath '%PORTABLE_PATH%' -Force"
```

O comando utilizado é:

```powershell
Expand-Archive
```

Ele extrai:

```text
Portable.VB6.zip
```

para:

```text
C:\portable\vb6
```

O parâmetro:

```text
-Force
```

permite substituir arquivos existentes.

---

# 10. Execução do Configurar_VB6.ps1

Depois da extração, o `.bat` chama o PowerShell:

```bat
powershell.exe ^
    -NoLogo ^
    -NoProfile ^
    -ExecutionPolicy Bypass ^
    -File "%PS1%" ^
    -VB6Path "%PORTABLE_PATH%\vb6.exe"
```

Aqui existe uma informação importante sendo passada para o script PowerShell:

```text
-VB6Path "C:\portable\vb6\vb6.exe"
```

Ou seja, o `.bat` informa exatamente onde está o executável do VB6.

---

# 11. Configurar_VB6.ps1

O PowerShell assume a responsabilidade pelas configurações mais específicas do Windows.

O script recebe um parâmetro obrigatório:

```powershell
param (
    [Parameter(Mandatory = $true)]
    [string]$VB6Path
)
```

Portanto, o script não deve ser executado sem informar o caminho do `vb6.exe`.

Exemplo:

```powershell
.\Configurar_VB6.ps1 -VB6Path "C:\portable\vb6\vb6.exe"
```

---

# 12. Tratamento de erros

Logo no início:

```powershell
$ErrorActionPreference = "Stop"
```

Isso faz com que erros do PowerShell sejam tratados de forma mais rigorosa.

Quando ocorre uma condição inesperada, o script pode interromper a operação em vez de simplesmente continuar silenciosamente.

---

# 13. Verificação de administrador no PowerShell

O script também verifica os privilégios administrativos:

```powershell
$Principal = New-Object Security.Principal.WindowsPrincipal(
    [Security.Principal.WindowsIdentity]::GetCurrent()
)
```

Depois:

```powershell
$Administrador = $Principal.IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator
)
```

Se não houver privilégios administrativos:

```powershell
if (-not $Administrador) {
```

é apresentada uma mensagem de erro.

Essa segunda verificação é importante porque o `.ps1` também pode ser executado diretamente, sem passar pelo `.bat`.

---

# 14. Verificação do VB6.exe

O script verifica se o executável realmente existe:

```powershell
if (-not (Test-Path -LiteralPath $VB6Path)) {
```

Caso não encontre:

```text
VB6.exe
```

o processo é interrompido.

Isso evita registrar configurações para um programa que não existe no caminho informado.

---

# 15. Obtenção do caminho absoluto

Depois da verificação:

```powershell
$VB6Path = (Resolve-Path -LiteralPath $VB6Path).Path
```

O caminho relativo é convertido para um caminho absoluto.

Por exemplo:

```text
C:\portable\vb6\vb6.exe
```

---

# 16. Identificação da pasta do VB6

O script também obtém o diretório:

```powershell
$VB6Directory = Split-Path -Parent $VB6Path
```

Se o executável estiver em:

```text
C:\portable\vb6\vb6.exe
```

então:

```text
$VB6Directory
```

será:

```text
C:\portable\vb6
```

Essa informação será utilizada posteriormente na criação do atalho.

---

# 17. Configuração de compatibilidade

Uma das principais funções do PowerShell é configurar a compatibilidade do VB6.

A chave utilizada é:

```powershell
HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers
```

Caso ela não exista, o script cria a estrutura:

```powershell
New-Item `
    -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags" `
    -Name "Layers" `
    -Force
```

---

# 18. Windows XP SP3 + Administrador

A configuração aplicada é:

```powershell
$Compatibilidade = "~ WINXPSP3 RUNASADMIN"
```

Ela informa ao Windows que o executável deve utilizar:

```text
Windows XP Service Pack 3
```

como camada de compatibilidade e:

```text
Executar como Administrador
```

Essa configuração é aplicada especificamente ao caminho do executável:

```powershell
New-ItemProperty `
    -Path $RegistryPath `
    -Name $VB6Path `
    -PropertyType String `
    -Value $Compatibilidade `
    -Force
```

Assim, a configuração fica associada ao `vb6.exe` informado.

---

# 19. Registro das licenças/configurações do VB6

O script também possui uma função específica:

```powershell
function Registrar-LicencaVB6 {
```

Ela recebe dois parâmetros:

```powershell
[string]$Guid
[string]$Licenca
```

A chave utilizada é:

```text
HKCR\Licenses\
```

com o GUID correspondente.

O registro é realizado utilizando:

```text
reg.exe
```

e:

```text
/reg:32
```

Isso é especialmente relevante em sistemas Windows de 64 bits, pois determinadas informações relacionadas a componentes antigos de 32 bits precisam ser tratadas no contexto apropriado.

---

# 20. Função Registrar-LicencaVB6

A função utiliza:

```powershell
Start-Process
```

para executar:

```text
reg.exe
```

com os argumentos necessários.

A operação possui tratamento de erro:

```powershell
try {
    ...
}
catch {
    ...
}
```

Também é verificado o código de saída:

```powershell
if ($Resultado.ExitCode -eq 0)
```

Assim, o usuário recebe uma indicação:

```text
[OK] Licenca registrada.
```

ou:

```text
[ERRO] Codigo: ...
```

---

# 21. Criação do atalho

Depois das configurações, o PowerShell cria automaticamente um atalho no Desktop.

A função responsável é:

```powershell
function Criar-AtalhoVB6 {
```

O Desktop é obtido através de:

```powershell
$Desktop = [Environment]::GetFolderPath("Desktop")
```

O arquivo será:

```text
Visual Basic 6.lnk
```

---

# 22. Windows Script Host

Para criar o atalho é utilizado:

```powershell
New-Object -ComObject WScript.Shell
```

Depois:

```powershell
$Shortcut = $Shell.CreateShortcut($Atalho)
```

São configurados:

### Programa

```powershell
$Shortcut.TargetPath = $VB6Path
```

### Diretório de trabalho

```powershell
$Shortcut.WorkingDirectory = $VB6Directory
```

### Ícone

```powershell
$Shortcut.IconLocation = "$VB6Path,0"
```

### Descrição

```powershell
$Shortcut.Description = "Microsoft Visual Basic 6.0"
```

Finalmente:

```powershell
$Shortcut.Save()
```

salva o atalho.

---

# 23. Inicialização automática do VB6

Se o atalho for criado corretamente:

```powershell
if ($Criado) {
```

o script executa:

```powershell
Start-Process -FilePath $VB6Path
```

Portanto, ao terminar a configuração, o Visual Basic 6 é iniciado automaticamente.

---

# 🔄 Fluxo completo

O funcionamento pode ser resumido assim:

```text
┌──────────────────────────────┐
│ Configurar_VB6.bat           │
└──────────────┬───────────────┘
               │
               ▼
       Verifica PowerShell
               │
               ▼
      Verifica Administrador
               │
               ▼
     Localiza Portable.VB6.zip
               │
               ▼
     Cria C:\portable\vb6
               │
               ▼
        Extrai arquivos
               │
               ▼
┌──────────────────────────────┐
│ Configurar_VB6.ps1           │
└──────────────┬───────────────┘
               │
               ▼
       Verifica Administrador
               │
               ▼
        Localiza vb6.exe
               │
               ▼
    Configura compatibilidade
               │
               ▼
   Registra configurações VB6
               │
               ▼
       Cria atalho Desktop
               │
               ▼
        Inicia VB6.exe
```

---

# ▶️ Como utilizar

## Método recomendado

Coloque os três arquivos na mesma pasta:

```text
Configurar_VB6.bat
Configurar_VB6.ps1
Portable.VB6.zip
```

Depois execute:

```text
Configurar_VB6.bat
```

O Windows poderá solicitar autorização de administrador.

Clique em:

```text
Sim
```

na janela do UAC.

O instalador irá:

1. verificar o PowerShell;
2. solicitar privilégios administrativos;
3. localizar o arquivo ZIP;
4. criar `C:\portable\vb6`;
5. extrair o Portable VB6;
6. configurar a compatibilidade;
7. registrar as configurações necessárias;
8. criar o atalho no Desktop;
9. iniciar o Visual Basic 6.

---

# 🛠️ Execução manual do PowerShell

Também é possível executar o PowerShell diretamente.

Abra o PowerShell como administrador e execute:

```powershell
.\Configurar_VB6.ps1 -VB6Path "C:\portable\vb6\vb6.exe"
```

Essa opção é útil principalmente para testes e diagnóstico.

---

# ⚠️ Sobre ExecutionPolicy Bypass

Os scripts utilizam:

```text
-ExecutionPolicy Bypass
```

Isso foi utilizado para permitir que o script seja executado sem alterar permanentemente a política de execução do PowerShell do computador.

Exemplo:

```bat
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%PS1%"
```

O uso desse parâmetro deve ser entendido como uma decisão de implantação. Em ambientes corporativos, recomenda-se avaliar as políticas de segurança existentes antes de utilizá-lo.

---

# 🔐 Requisitos

O ambiente precisa possuir:

* Windows;
* Windows PowerShell;
* privilégios de Administrador;
* `Portable.VB6.zip`;
* `Configurar_VB6.bat`;
* `Configurar_VB6.ps1`.

O espaço necessário em disco depende do conteúdo do pacote Portable.

---

# 📌 Por que utilizar dois scripts?

Separar as funções entre BAT e PowerShell possui algumas vantagens.

## BAT

Responsável por:

* interface inicial;
* configuração do CMD;
* elevação para Administrador;
* localização dos arquivos;
* criação do diretório;
* extração do ZIP;
* chamada do PowerShell.

## PowerShell

Responsável por:

* manipulação do Registro;
* configuração de compatibilidade;
* execução do `reg.exe`;
* tratamento de parâmetros;
* criação do atalho;
* inicialização do VB6.

Essa divisão deixa o projeto mais organizado e facilita futuras modificações.

---

# 🧩 Personalização

O destino da instalação pode ser alterado no `.bat`:

```bat
set "PORTABLE_PATH=C:\portable\vb6"
```

Por exemplo:

```bat
set "PORTABLE_PATH=D:\Ferramentas\VB6"
```

Nesse caso, também será necessário garantir que a chamada do PowerShell continue apontando para:

```text
%PORTABLE_PATH%\vb6.exe
```

---

# 📂 Alterando o nome do ZIP

O nome do pacote pode ser alterado através de:

```bat
set "VB_FILE=Portable.VB6.zip"
```

Por exemplo:

```bat
set "VB_FILE=VB6_Portable.zip"
```

O arquivo deverá estar na mesma pasta do instalador.

---

# 🖥️ Resultado esperado

Ao final da operação, deverá existir:

```text
C:\portable\vb6\vb6.exe
```

e um atalho:

```text
Desktop
└── Visual Basic 6.lnk
```

Ao utilizar o atalho, o Windows utilizará as configurações de compatibilidade definidas pelo script.

---

# 🧪 Diagnóstico

Caso algo não funcione, verifique inicialmente:

### VB6 não encontrado

Confirme:

```text
C:\portable\vb6\vb6.exe
```

### ZIP não encontrado

Confirme que:

```text
Portable.VB6.zip
```

está na mesma pasta do:

```text
Configurar_VB6.bat
```

### Erro de permissão

Execute:

```text
Configurar_VB6.bat
```

e permita a elevação de privilégios no UAC.

### PowerShell não encontrado

Verifique se o Windows PowerShell está instalado em:

```text
C:\Windows\System32\WindowsPowerShell\v1.0\
```

---

# 📜 Licenciamento e distribuição

Este projeto de scripts deve ser separado do conteúdo proprietário do Visual Basic 6.0.

Os scripts de automação podem ser disponibilizados conforme a licença escolhida para este repositório, mas a distribuição de arquivos, componentes ou licenças do Microsoft Visual Basic 6.0 deve observar os respectivos direitos e termos aplicáveis.

O projeto não deve ser interpretado como um instalador oficial da Microsoft.

---

# 👨‍💻 Objetivo do projeto

O objetivo é facilitar a preparação de um ambiente portátil para desenvolvimento legado em **Visual Basic 6**, reduzindo a necessidade de realizar manualmente diversas configurações no Windows.

A automação permite transformar várias etapas manuais em um único processo:

```text
ZIP
 ↓
BAT
 ↓
PowerShell
 ↓
Configuração do Windows
 ↓
Atalho
 ↓
VB6
```

---

## 📌 Resumo dos arquivos

| Arquivo              | Função                      |
| -------------------- | --------------------------- |
| `Configurar_VB6.bat` | Instalador e orquestrador   |
| `Configurar_VB6.ps1` | Configuração do Windows/VB6 |
| `Portable.VB6.zip`   | Pacote do VB6 Portable      |

---

## ✅ Conclusão

A combinação de **Batch + PowerShell** permite criar um processo simples para preparar o Visual Basic 6 Portable.

O Batch cuida da experiência de instalação e da preparação dos arquivos, enquanto o PowerShell executa as tarefas que exigem maior integração com o Windows.

O resultado é um procedimento automatizado que:

* instala o pacote;
* configura a compatibilidade;
* registra as configurações necessárias;
* cria um atalho;
* inicia o Visual Basic 6.

