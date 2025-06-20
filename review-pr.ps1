#!/usr/bin/env pwsh

# review-pr.ps1 - Script principal para revisão de PRs
# Uso: review-pr.ps1 @URL_DO_PR [--detailed] [--output arquivo.md]

param(
    [Parameter(Position=0)]
    [string]$PrUrl,
    [switch]$Detailed,
    [string]$Output,
    [switch]$Help
)

if ($Help) {
    @"
review-pr.ps1 - Ferramenta completa para revisão de PRs

USO:
    review-pr.ps1 URL_DO_PR                    # Revisão rápida
    review-pr.ps1 URL_DO_PR --detailed         # Revisão detalhada  
    review-pr.ps1 URL_DO_PR --output review.md # Salvar em arquivo

EXEMPLOS:
    review-pr.ps1 "https://github.com/owner/repo/pull/123"
    review-pr.ps1 "@https://github.com/owner/repo/pull/123" --detailed
    review-pr.ps1 "https://github.com/owner/repo/pull/123" --output "review.md"

DEPENDÊNCIAS:
    - GitHub CLI (gh) - instalar com: winget install --id GitHub.cli
    - Autenticação: gh auth login
"@
    exit 0
}

# Verificar se URL foi fornecida (quando não é help)
if (-not $Help -and -not $PrUrl) {
    Write-Host "[ERROR] URL do PR é obrigatória!" -ForegroundColor Red
    Write-Host "Use: review-pr.ps1 'URL_DO_PR' ou review-pr.ps1 -Help" -ForegroundColor Yellow
    exit 1
}

# Verificar dependências
if (-not $Help -and -not (Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-Host "[ERROR] GitHub CLI não encontrado!" -ForegroundColor Red
    Write-Host "Instale com: winget install --id GitHub.cli" -ForegroundColor Yellow
    exit 1
}

# Limpar URL
$PrUrl = $PrUrl -replace '^@', ''

Write-Host ""
Write-Host "🤖 IA REVIEWER - Analisando PR automaticamente..." -ForegroundColor Cyan
Write-Host "URL: $PrUrl" -ForegroundColor Gray
Write-Host ""

if ($Detailed) {
    # Usar ferramenta detalhada
    if ($Output) {
        & "$PSScriptRoot\ai-pr-reviewer.ps1" -Url $PrUrl -Output $Output
    } else {
        & "$PSScriptRoot\ai-pr-reviewer.ps1" -Url $PrUrl
    }
} else {
    # Usar ferramenta rápida
    & "$PSScriptRoot\quick-review.ps1" $PrUrl
    
    if ($Output) {
        Write-Host ""
        Write-Host "[INFO] Para salvar em arquivo, use --detailed --output" -ForegroundColor Blue
    }
}

Write-Host ""
Write-Host "✅ Revisão concluída! Use as recomendações acima para avaliar o PR." -ForegroundColor Green 