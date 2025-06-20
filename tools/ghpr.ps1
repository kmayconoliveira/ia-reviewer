#!/usr/bin/env pwsh

# ghpr.ps1 - Ferramenta para buscar informações de Pull Requests do GitHub
# Uso: ghpr.ps1 URL_DO_PR ou ghpr.ps1 OWNER/REPO PR_NUMBER
# Dependências: gh (GitHub CLI)

param(
    [string]$Url,
    [string]$Repo,
    [int]$PrNumber,
    [switch]$Help,
    [switch]$Diff,
    [switch]$Files,
    [switch]$Verbose,
    [string]$Output
)

# Cores para output
$script:Colors = @{
    Red = "`e[31m"
    Green = "`e[32m"
    Yellow = "`e[33m"
    Blue = "`e[34m"
    Reset = "`e[0m"
}

# Funções de logging
function Write-Info {
    param([string]$Message)
    Write-Host "$($Colors.Green)[INFO]$($Colors.Reset) $Message" -ForegroundColor Green
}

function Write-Warn {
    param([string]$Message)
    Write-Host "$($Colors.Yellow)[WARN]$($Colors.Reset) $Message" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "$($Colors.Red)[ERROR]$($Colors.Reset) $Message" -ForegroundColor Red
}

function Write-Header {
    param([string]$Message)
    Write-Host "$($Colors.Blue)[GHPR]$($Colors.Reset) $Message" -ForegroundColor Blue
}

# Verificar dependências
function Test-Dependencies {
    $missingDeps = @()
    
    if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
        $missingDeps += "gh"
    }
    
    if ($missingDeps.Count -gt 0) {
        Write-Error "Dependências necessárias não encontradas: $($missingDeps -join ', ')"
        Write-Error "Instale-as antes de executar este script."
        exit 1
    }
}

# Exibir ajuda
function Show-Help {
    @"
ghpr.ps1 - Ferramenta para buscar informações de Pull Requests do GitHub

USO:
    ghpr.ps1 -Url URL_DO_PR
    ghpr.ps1 -Url @URL_DO_PR
    ghpr.ps1 -Repo OWNER/REPO -PrNumber PR_NUMBER

PARÂMETROS:
    -Url          URL completa do PR (ex: https://github.com/owner/repo/pull/123)
    -Repo         Repositório no formato 'owner/repo'
    -PrNumber     Número do Pull Request
    -Help         Exibir esta mensagem de ajuda
    -Diff         Exibir diff do PR
    -Files        Listar arquivos modificados
    -Verbose      Saída detalhada para debug
    -Output       Salvar saída em arquivo

EXEMPLOS:
    ghpr.ps1 -Url "https://github.com/microsoft/vscode/pull/123"
    ghpr.ps1 -Url "@https://github.com/microsoft/vscode/pull/123"
    ghpr.ps1 -Repo "microsoft/vscode" -PrNumber 123
    ghpr.ps1 -Repo "microsoft/vscode" -PrNumber 123 -Diff
    ghpr.ps1 -Repo "owner/repo" -PrNumber 456 -Files -Output "pr_files.txt"

DEPENDÊNCIAS:
    - gh (GitHub CLI) - para autenticação e acesso à API

NOTAS:
    - Repositórios privados requerem autenticação GitHub CLI (gh auth login)
    - Use -Diff para ver as mudanças do PR
    - Use -Files para listar apenas os arquivos modificados
"@
}

# Extrair informações da URL do PR
function Get-PrInfoFromUrl {
    param([string]$InputUrl)
    
    # Remover @ do início se presente
    $InputUrl = $InputUrl -replace '^@', ''
    
    # Padrão para URL do GitHub PR
    if ($InputUrl -match '^https://github\.com/([^/]+)/([^/]+)/pull/(\d+)/?.*$') {
        $owner = $Matches[1]
        $repo = $Matches[2]
        $prNum = [int]$Matches[3]
        
        return @{
            Repo = "$owner/$repo"
            PrNumber = $prNum
        }
    }
    
    return $null
}

# Validar formato do repositório
function Test-RepoFormat {
    param([string]$RepoName)
    
    if ($RepoName -notmatch '^[a-zA-Z0-9._-]+/[a-zA-Z0-9._-]+$') {
        Write-Error "Formato de repositório inválido: '$RepoName'"
        Write-Error "Formato esperado: 'owner/repo'"
        exit 1
    }
}

# Buscar informações do PR
function Get-PrInfo {
    param(
        [string]$RepoName,
        [int]$PrNum,
        [bool]$ShowDiff,
        [bool]$ShowFiles
    )
    
    Write-Info "Buscando informações do PR #$PrNum em $RepoName"
    
    # Verificar se o PR existe
    $prCheck = gh pr view $PrNum --repo $RepoName 2>$null
    if ($LASTEXITCODE -ne 0) {
        Write-Error "PR #$PrNum não encontrado no repositório $RepoName"
        Write-Error "Verifique se o PR existe e você tem acesso ao repositório"
        exit 1
    }
    
    $output = @()
    
    Write-Header "=== INFORMAÇÕES DO PR ==="
    $prInfo = gh pr view $PrNum --repo $RepoName
    $output += $prInfo
    
    if ($ShowFiles) {
        $output += ""
        Write-Header "=== ARQUIVOS MODIFICADOS ==="
        $files = gh pr diff $PrNum --repo $RepoName --name-only
        $output += $files
    }
    
    if ($ShowDiff) {
        $output += ""
        Write-Header "=== DIFF DO PR ==="
        $diff = gh pr diff $PrNum --repo $RepoName
        $output += $diff
    }
    
    return $output -join "`n"
}

# Função principal
function Main {
    # Verificar se pediu ajuda
    if ($Help) {
        Show-Help
        exit 0
    }
    
    # Verificar dependências
    Test-Dependencies
    
    $repoName = ""
    $prNum = 0
    
    # Processar URL se fornecida
    if ($Url) {
        $prInfo = Get-PrInfoFromUrl -InputUrl $Url
        if ($prInfo) {
            $repoName = $prInfo.Repo
            $prNum = $prInfo.PrNumber
            Write-Info "URL detectada: $repoName PR #$prNum"
        } else {
            Write-Error "URL de PR inválida: $Url"
            Write-Error "Formato esperado: https://github.com/owner/repo/pull/123"
            exit 1
        }
    } elseif ($Repo -and $PrNumber) {
        # Formato: -Repo owner/repo -PrNumber pr_number
        $repoName = $Repo
        $prNum = $PrNumber
        Test-RepoFormat -RepoName $repoName
        
        if ($prNum -le 0) {
            Write-Error "Número do PR deve ser um inteiro positivo: $prNum"
            exit 1
        }
    } else {
        Write-Error "Argumentos obrigatórios ausentes"
        Write-Error "Use: -Url URL_DO_PR ou -Repo OWNER/REPO -PrNumber PR_NUMBER"
        Show-Help
        exit 1
    }
    
    # Debug output se verbose
    if ($Verbose) {
        Write-Info "Repo: $repoName"
        Write-Info "PR: $prNum"
        Write-Info "Show diff: $($Diff.IsPresent)"
        Write-Info "Show files: $($Files.IsPresent)"
        Write-Info "Output file: $(if ($Output) { $Output } else { "(stdout)" })"
    }
    
    # Buscar informações do PR
    $result = Get-PrInfo -RepoName $repoName -PrNum $prNum -ShowDiff $Diff.IsPresent -ShowFiles $Files.IsPresent
    
    if ($Output) {
        $result | Out-File -FilePath $Output -Encoding UTF8
        Write-Info "Saída salva em: $Output"
    } else {
        Write-Output $result
    }
}

# Executar função principal
Main 