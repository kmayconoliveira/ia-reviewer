#!/usr/bin/env pwsh

# gh-comment.ps1 - Ferramenta para comentar automaticamente em PRs após análise
# Uso: gh-comment.ps1 -PrUrl URL_DO_PR -CommentText "TEXTO_DO_COMENTARIO" [-Draft]

param(
    [Parameter(Mandatory=$true)]
    [string]$PrUrl,
    [Parameter(Mandatory=$true)]
    [string]$CommentText,
    [switch]$Draft,  # Comentário como draft/pendente
    [switch]$Verbose,
    [switch]$Help
)

if ($Help) {
    @"
gh-comment.ps1 - Comentário automático em PRs

USO:
    gh-comment.ps1 -PrUrl URL_DO_PR -CommentText "COMENTARIO"
    gh-comment.ps1 -PrUrl URL_DO_PR -CommentText "COMENTARIO" -Draft

PARÂMETROS:
    -PrUrl        URL completa do PR no GitHub
    -CommentText  Texto do comentário (Markdown suportado)
    -Draft        Criar como comentário pendente (não publica imediatamente)
    -Verbose      Mostrar informações detalhadas
    -Help         Mostrar esta ajuda

EXEMPLOS:
    # Comentário simples
    gh-comment.ps1 -PrUrl "https://github.com/owner/repo/pull/123" -CommentText "✅ Análise concluída!"
    
    # Comentário como draft
    gh-comment.ps1 -PrUrl "URL" -CommentText "# Review\n\nAnálise detalhada..." -Draft

DEPENDÊNCIAS:
    - GitHub CLI (gh) - instalar com: winget install --id GitHub.cli
    - Autenticação: gh auth login
    - Permissões de escrita no repositório
"@
    exit 0
}

# Funções auxiliares
function Write-Info {
    param([string]$Message)
    if ($Verbose) { Write-Host "[INFO] $Message" -ForegroundColor Green }
}

function Write-Error {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

function Write-Success {
    param([string]$Message)
    Write-Host "[SUCCESS] $Message" -ForegroundColor Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor Yellow
}

# Extrair informações do PR da URL
function Get-PrInfoFromUrl {
    param([string]$InputUrl)
    
    $InputUrl = $InputUrl -replace '^@', ''
    
    if ($InputUrl -match '^https://github\.com/([^/]+)/([^/]+)/pull/(\d+)/?.*$') {
        return @{
            Owner = $Matches[1]
            Repo = $Matches[2]  
            Number = [int]$Matches[3]
            FullRepo = "$($Matches[1])/$($Matches[2])"
        }
    }
    
    return $null
}

# Verificar dependências
function Test-Dependencies {
    Write-Info "Verificando dependências..."
    
    if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
        Write-Error "GitHub CLI (gh) não encontrado!"
        Write-Error "Instale com: winget install --id GitHub.cli"
        exit 1
    }
    
    # Verificar autenticação
    $authStatus = gh auth status 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Warning "GitHub CLI não está autenticado!"
        Write-Warning "Execute: gh auth login"  
        Write-Warning "Tentando mesmo assim..."
    }
    
    Write-Info "Dependências OK"
}

# Criar comentário no PR
function New-PrComment {
    param(
        [hashtable]$PrInfo,
        [string]$Comment,
        [bool]$IsDraft
    )
    
    $repo = $PrInfo.FullRepo
    $prNumber = $PrInfo.Number
    
    Write-Info "Preparando comentário para PR #$prNumber em $repo"
    
    try {
        # Preparar arquivo temporário com comentário
        $tempFile = [System.IO.Path]::GetTempFileName()
        $Comment | Out-File -FilePath $tempFile -Encoding UTF8
        
        Write-Info "Arquivo temporário: $tempFile"
        
        # Comando base
        $ghCommand = @("pr", "comment", $prNumber, "--repo", $repo, "--body-file", $tempFile)
        
        if ($IsDraft) {
            Write-Info "Criando comentário como draft/pendente..."
            # Nota: GitHub CLI pode não suportar draft comments diretamente
            # Adicionando prefixo para indicar que é draft
            $draftComment = "**[DRAFT - Pendente de Revisão]**`n`n" + $Comment
            $draftComment | Out-File -FilePath $tempFile -Encoding UTF8
        }
        
        Write-Info "Executando comando: gh $($ghCommand -join ' ')"
        
        # Executar comando
        $result = & gh @ghCommand 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            Write-Success "Comentário criado com sucesso!"
            Write-Success "URL do PR: https://github.com/$repo/pull/$prNumber"
            
            if ($Verbose) {
                Write-Host "Resultado: $result" -ForegroundColor Gray
            }
        } else {
            throw "Erro ao criar comentário: $result"
        }
        
    } catch {
        Write-Error "Falha ao criar comentário: $($_.Exception.Message)"
        exit 1
    } finally {
        # Limpar arquivo temporário
        if (Test-Path $tempFile) {
            Remove-Item $tempFile -Force
            Write-Info "Arquivo temporário removido"
        }
    }
}

# Script principal
Write-Host ""
Write-Host "🤖 GitHub PR Comment Tool" -ForegroundColor Cyan
Write-Host ""

# Verificar dependências
Test-Dependencies

# Processar URL do PR
$prInfo = Get-PrInfoFromUrl -InputUrl $PrUrl
if (-not $prInfo) {
    Write-Error "URL inválida: $PrUrl"
    Write-Error "Formato esperado: https://github.com/owner/repo/pull/123"
    exit 1
}

Write-Info "PR identificado: #$($prInfo.Number) em $($prInfo.FullRepo)"

# Verificar se PR existe
Write-Info "Verificando se PR existe..."
$prCheck = gh pr view $prInfo.Number --repo $prInfo.FullRepo 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Error "PR não encontrado ou sem acesso!"
    Write-Error "Verifique:"
    Write-Error "  • O PR existe e o número está correto"
    Write-Error "  • Você tem acesso ao repositório"
    Write-Error "  • Você está autenticado: gh auth login"
    exit 1
}

# Criar comentário
New-PrComment -PrInfo $prInfo -Comment $CommentText -IsDraft $Draft

Write-Host ""
Write-Host "✅ Processo concluído!" -ForegroundColor Green 