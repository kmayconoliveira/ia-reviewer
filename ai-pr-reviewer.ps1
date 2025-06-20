#!/usr/bin/env pwsh

# ai-pr-reviewer.ps1 - Ferramenta para revisão completa de Pull Requests
# Uso: ai-pr-reviewer.ps1 -Url URL_DO_PR

param(
    [string]$Url,
    [string]$Repo,
    [int]$PrNumber,
    [switch]$Help,
    [switch]$Verbose,
    [string]$Output
)

# Funções de logging
function Write-Info {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Green
}

function Write-Error {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

function Write-Header {
    param([string]$Message)
    Write-Host ""
    Write-Host "=== $Message ===" -ForegroundColor Blue
    Write-Host ""
}

function Write-Success {
    param([string]$Message)
    Write-Host "[SUCCESS] $Message" -ForegroundColor Green
}

# Verificar dependências
function Test-Dependencies {
    if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
        Write-Error "GitHub CLI (gh) não encontrado!"
        Write-Error "Instale com: winget install --id GitHub.cli"
        exit 1
    }
    
    if ($Verbose) {
        Write-Info "Dependências verificadas"
    }
}

# Extrair informações da URL do PR
function Get-PrInfoFromUrl {
    param([string]$InputUrl)
    
    $InputUrl = $InputUrl -replace '^@', ''
    
    if ($InputUrl -match '^https://github\.com/([^/]+)/([^/]+)/pull/(\d+)/?.*$') {
        return @{
            Repo = "$($Matches[1])/$($Matches[2])"
            PrNumber = [int]$Matches[3]
        }
    }
    
    return $null
}

# Buscar informações do PR
function Get-PrCompleteInfo {
    param(
        [string]$RepoName,
        [int]$PrNum
    )
    
    Write-Info "Coletando informações do PR #$PrNum em $RepoName..."
    
    $prData = @{}
    
    # Informações básicas
    Write-Info "Coletando informações básicas..."
    $prData.BasicInfo = gh pr view $PrNum --repo $RepoName
    
    # Diff completo
    Write-Info "Coletando diff..."
    $prData.Diff = gh pr diff $PrNum --repo $RepoName
    
    # Arquivos modificados
    Write-Info "Coletando lista de arquivos..."
    $prData.Files = gh pr diff $PrNum --repo $RepoName --name-only
    
    return $prData
}

# Analisar mudanças
function Get-ChangeAnalysis {
    param([string]$BasicInfo, [string]$Diff, [string]$Files)
    
    $analysis = @{
        Type = "Geral"
        Risks = @()
        Stats = @{}
    }
    
    # Tipo de mudança
    if ($BasicInfo -match 'feat|feature') { $analysis.Type = "Feature" }
    elseif ($BasicInfo -match 'fix|bugfix') { $analysis.Type = "Bug Fix" }
    elseif ($BasicInfo -match 'chore') { $analysis.Type = "Chore" }
    elseif ($BasicInfo -match 'refactor') { $analysis.Type = "Refactor" }
    
    # Estatísticas
    $addedLines = ($Diff -split "`n" | Where-Object { $_ -match '^\+' }).Count
    $removedLines = ($Diff -split "`n" | Where-Object { $_ -match '^\-' }).Count
    $fileCount = ($Files -split "`n" | Where-Object { $_ -ne "" }).Count
    
    $analysis.Stats = @{
        AddedLines = $addedLines
        RemovedLines = $removedLines  
        FileCount = $fileCount
        TotalChanges = $addedLines + $removedLines
    }
    
    # Análise de riscos
    if ($Diff -match 'DELETE|DROP|TRUNCATE') {
        $analysis.Risks += "Operações de DELETE/DROP detectadas"
    }
    
    if ($Diff -match 'console\.log|print\(|debug') {
        $analysis.Risks += "Código de debug detectado"
    }
    
    if ($Files -match '\.sql|migration|config|\.env') {
        $analysis.Risks += "Arquivos críticos modificados"
    }
    
    if ($Diff -match '\-.*catch\(|\-.*try\s*\{') {
        $analysis.Risks += "Remoção de tratamento de erro detectada"
    }
    
    return $analysis
}

# Gerar relatório
function New-ReviewReport {
    param([hashtable]$PrData, [string]$RepoName, [int]$PrNum)
    
    $basicInfo = $PrData.BasicInfo
    $diff = $PrData.Diff
    $files = $PrData.Files
    
    $analysis = Get-ChangeAnalysis -BasicInfo $basicInfo -Diff $diff -Files $files
    
    # Complexidade
    $complexity = "Baixa"
    if ($analysis.Stats.TotalChanges -gt 50 -or $analysis.Stats.FileCount -gt 10) {
        $complexity = "Média"
    }
    if ($analysis.Stats.TotalChanges -gt 200 -or $analysis.Stats.FileCount -gt 20) {
        $complexity = "Alta"
    }
    
    # Status
    $status = "APROVADO"
    if ($analysis.Risks.Count -gt 0) {
        $status = "REQUER ATENÇÃO"
    }
    if ($analysis.Stats.TotalChanges -gt 300) {
        $status = "REVISÃO CUIDADOSA NECESSÁRIA"
    }
    
    $report = @"
# Revisão Automática de PR

## Informações Gerais
- **Repositório:** $RepoName
- **PR:** #$PrNum
- **Tipo:** $($analysis.Type)
- **Complexidade:** $complexity
- **Status:** $status

## Estatísticas
- **Arquivos modificados:** $($analysis.Stats.FileCount)
- **Linhas adicionadas:** +$($analysis.Stats.AddedLines)
- **Linhas removidas:** -$($analysis.Stats.RemovedLines)
- **Total de mudanças:** $($analysis.Stats.TotalChanges)

## Arquivos Modificados
$($files -split "`n" | Where-Object { $_ -ne "" } | ForEach-Object { "- $_" } | Out-String)

## Análise de Riscos
$(if ($analysis.Risks.Count -gt 0) {
    $analysis.Risks | ForEach-Object { "- [ATENÇÃO] $_" } | Out-String
} else {
    "- Nenhum risco crítico identificado"
})

## Recomendações
$(if ($analysis.Stats.TotalChanges -gt 100) { "- Considerar dividir em PRs menores`n" })$(if ($analysis.Risks.Count -gt 0) { "- Atenção especial aos riscos identificados`n" })$(if ($analysis.Stats.FileCount -gt 15) { "- Revisar impacto em múltiplos arquivos`n" })- Executar testes completos antes do merge

## Informações do PR
```
$basicInfo
```

## Principais Mudanças
```diff
$($diff -split "`n" | Select-Object -First 50 | Out-String)
```

---
*Relatório gerado em $(Get-Date -Format "dd/MM/yyyy HH:mm:ss")*
"@

    return $report
}

# Exibir ajuda
function Show-Help {
    @"
ai-pr-reviewer.ps1 - Ferramenta para revisão completa de Pull Requests

USO:
    ai-pr-reviewer.ps1 -Url URL_DO_PR
    ai-pr-reviewer.ps1 -Repo OWNER/REPO -PrNumber PR_NUMBER

EXEMPLOS:
    ai-pr-reviewer.ps1 -Url "https://github.com/owner/repo/pull/123"
    ai-pr-reviewer.ps1 -Repo "owner/repo" -PrNumber 123 -Output "review.md"

DEPENDÊNCIAS:
    - GitHub CLI (gh)
"@
}

# Função principal  
function Main {
    Write-Header "AI PR Reviewer"
    
    if ($Help) {
        Show-Help
        exit 0
    }
    
    Test-Dependencies
    
    $repoName = ""
    $prNum = 0
    
    if ($Url) {
        $prInfo = Get-PrInfoFromUrl -InputUrl $Url
        if ($prInfo) {
            $repoName = $prInfo.Repo
            $prNum = $prInfo.PrNumber
            Write-Success "URL processada: $repoName PR #$prNum"
        } else {
            Write-Error "URL de PR inválida: $Url"  
            exit 1
        }
    } elseif ($Repo -and $PrNumber) {
        $repoName = $Repo
        $prNum = $PrNumber
    } else {
        Write-Error "Parâmetros obrigatórios ausentes"
        Show-Help
        exit 1
    }
    
    try {
        $prData = Get-PrCompleteInfo -RepoName $repoName -PrNum $prNum
        
        Write-Info "Gerando análise..."
        $report = New-ReviewReport -PrData $prData -RepoName $repoName -PrNum $prNum
        
        if ($Output) {
            $report | Out-File -FilePath $Output -Encoding UTF8
            Write-Success "Relatório salvo em: $Output"
        } else {
            Write-Output $report
        }
        
        Write-Header "Revisão Concluída"
        
    } catch {
        Write-Error "Erro durante a análise: $($_.Exception.Message)"
        exit 1
    }
}

# Executar
Main 