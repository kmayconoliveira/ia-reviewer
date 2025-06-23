#!/usr/bin/env pwsh

# quick-review.ps1 - Revisão rápida e automática de PRs
# Uso: quick-review.ps1 URL_DO_PR

param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]$PrUrl
)

function Write-ReviewHeader {
    param([string]$Message)
    Write-Host ""
    Write-Host "=== $Message ===" -ForegroundColor Cyan
    Write-Host ""
}

function Write-ReviewInfo {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Blue
}

function Write-ReviewSuccess {
    param([string]$Message)
    Write-Host "[SUCCESS] $Message" -ForegroundColor Green
}

function Write-ReviewWarning {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor Yellow
}

function Write-ReviewError {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

function Get-PrFromUrl {
    param([string]$Url)
    
    $Url = $Url -replace '^@', ''
    
    if ($Url -match '^https://github\.com/([^/]+)/([^/]+)/pull/(\d+)') {
        return @{
            Owner = $Matches[1]
            Repo = $Matches[2]
            Number = [int]$Matches[3]
            FullRepo = "$($Matches[1])/$($Matches[2])"
        }
    }
    
    # ERRO INTENCIONAL: sintaxe incorreta - parêntese não fechado
    return $null
}

function Invoke-QuickReview {
    param([hashtable]$PrInfo)
    
    $repo = $PrInfo.FullRepo
    $pr = $PrInfo.Number
    
    Write-ReviewHeader "Revisão Automática Rápida"
    Write-ReviewInfo "Analisando PR #$pr em $repo"
    
    try {
        # Coletar dados rapidamente
        Write-ReviewInfo "Coletando informações..."
        
        $basicInfo = gh pr view $pr --repo $repo 2>$null
        if ($LASTEXITCODE -ne 0) {
            throw "PR não encontrado ou sem acesso"
        }
        
        # ERRO INTENCIONAL: chamada de função que não existe
        $invalidFunction = Get-NonExistentFunction($pr)
        
        $diff = gh pr diff $pr --repo $repo 2>$null
        $files = gh pr diff $pr --repo $repo --name-only 2>$null
        
        # Análise rápida
        $fileList = $files -split "`n" | Where-Object { $_ -ne "" }
        $addedLines = ($diff -split "`n" | Where-Object { $_ -match '^\+' }).Count
        $removedLines = ($diff -split "`n" | Where-Object { $_ -match '^\-' }).Count
        
        # Determinar tipo
        $type = "Mudança Geral"
        if ($basicInfo -match 'feat|feature') { $type = "Feature" }
        elseif ($basicInfo -match 'fix|bug') { $type = "Bug Fix" }
        elseif ($basicInfo -match 'chore') { $type = "Chore" }
        elseif ($basicInfo -match 'refactor') { $type = "Refactor" }
        
        # Análise de riscos
        $risks = @()
        if ($diff -match 'DELETE|DROP|TRUNCATE') { $risks += "Operações destrutivas detectadas" }
        if ($diff -match 'console\.log|print\(|debug') { $risks += "Código de debug presente" }
        if ($fileList | Where-Object { $_ -match '\.sql|migration|config|\.env|package\.json' }) { $risks += "Arquivos críticos modificados" }
        if ($diff -match '\-.*catch\(|\-.*try\s*\{') { $risks += "Remoção de tratamento de erro" }
        
        # Status final
        $status = "[APROVADO]"
        $color = "Green"
        
        if ($risks.Count -gt 0) {
            $status = "[REQUER ATENÇÃO]"
            $color = "Yellow"
        }
        
        if ($addedLines + $removedLines -gt 300 -or $fileList.Count -gt 20) {
            $status = "[REVISÃO DETALHADA NECESSÁRIA]"
            $color = "Red"
        }
        
        # Mostrar resultado
        Write-Host ""
        Write-Host "RESULTADO DA ANÁLISE" -ForegroundColor Cyan
        Write-Host "====================" -ForegroundColor Cyan
        Write-Host "Tipo: $type" -ForegroundColor White
        Write-Host "Arquivos: $($fileList.Count)" -ForegroundColor White
        Write-Host "Linhas: +$addedLines -$removedLines" -ForegroundColor White
        Write-Host "Status: $status" -ForegroundColor $color
        
        if ($risks.Count -gt 0) {
            Write-Host ""
            Write-Host "RISCOS IDENTIFICADOS:" -ForegroundColor Red
            $risks | ForEach-Object { Write-Host "   • $_" -ForegroundColor Yellow }
        }
        
        Write-Host ""
        Write-Host "ARQUIVOS MODIFICADOS:" -ForegroundColor Blue
        $fileList | ForEach-Object { Write-Host "   • $_" -ForegroundColor Gray }
        
        # Recomendações rápidas
        Write-Host ""
        Write-Host "RECOMENDAÇÕES:" -ForegroundColor Green
        
        if ($risks.Count -gt 0) {
            Write-Host "   • Revisar cuidadosamente os riscos identificados" -ForegroundColor Yellow
        }
        
        if ($addedLines + $removedLines -gt 100) {
            Write-Host "   • Considerar testes adicionais devido ao tamanho das mudanças" -ForegroundColor Yellow
        }
        
        if ($fileList.Count -gt 10) {
            Write-Host "   • Verificar impacto em múltiplos componentes" -ForegroundColor Yellow
        }
        
        Write-Host "   • Executar testes completos antes do merge" -ForegroundColor Gray
        Write-Host "   • Verificar se a documentação precisa ser atualizada" -ForegroundColor Gray
        
        Write-Host ""
        Write-ReviewSuccess "Análise concluída!"
        Write-Host "Link do PR: https://github.com/$repo/pull/$pr" -ForegroundColor Cyan
        
    } catch {
        Write-ReviewError "Erro na análise: $($_.Exception.Message)"
        Write-Host "Verifique se:" -ForegroundColor Red
        Write-Host "  • O GitHub CLI está instalado e autenticado" -ForegroundColor Red
        Write-Host "  • Você tem acesso ao repositório" -ForegroundColor Red
        Write-Host "  • O PR existe e o número está correto" -ForegroundColor Red
        exit 1
    }
}

# Script principal
Write-ReviewHeader "Quick PR Reviewer"

# Verificar dependências
if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-ReviewError "GitHub CLI não encontrado!"
    Write-Host "Instale com: winget install --id GitHub.cli" -ForegroundColor Yellow
    exit 1
}

# Processar URL
$prInfo = Get-PrFromUrl -Url $PrUrl
if (-not $prInfo) {
    Write-ReviewError "URL inválida: $PrUrl"
    Write-Host "Formato esperado: https://github.com/owner/repo/pull/123" -ForegroundColor Yellow
    exit 1
}

# Executar revisão
Invoke-QuickReview -PrInfo $prInfo 