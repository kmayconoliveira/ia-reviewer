#!/usr/bin/env pwsh

# test-comment-system.ps1 - Teste do sistema de comentário automático
# Uso: test-comment-system.ps1

Write-Host ""
Write-Host "🧪 TESTE DO SISTEMA DE COMENTÁRIO AUTOMÁTICO" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""

# Função de teste
function Test-Component {
    param(
        [string]$Name,
        [scriptblock]$Test
    )
    
    Write-Host "🔍 Testando: $Name" -ForegroundColor Yellow
    
    try {
        $result = & $Test
        if ($result) {
            Write-Host "   ✅ PASSOU: $Name" -ForegroundColor Green
            return $true
        } else {
            Write-Host "   ❌ FALHOU: $Name" -ForegroundColor Red
            return $false
        }
    } catch {
        Write-Host "   ❌ ERRO: $Name - $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

$testResults = @()

# Teste 1: GitHub CLI
$testResults += Test-Component "GitHub CLI instalado" {
    return (Get-Command gh -ErrorAction SilentlyContinue) -ne $null
}

# Teste 2: Autenticação GitHub
$testResults += Test-Component "GitHub CLI autenticado" {
    $authStatus = gh auth status 2>&1
    return $LASTEXITCODE -eq 0
}

# Teste 3: Scripts existem
$testResults += Test-Component "Script review-pr-with-comment.ps1" {
    return Test-Path "$PSScriptRoot\review-pr-with-comment.ps1"
}

$testResults += Test-Component "Script tools/gh-comment.ps1" {
    return Test-Path "$PSScriptRoot\tools\gh-comment.ps1"
}

$testResults += Test-Component "Script review-pr.ps1" {
    return Test-Path "$PSScriptRoot\review-pr.ps1"
}

$testResults += Test-Component "Script quick-review.ps1" {
    return Test-Path "$PSScriptRoot\quick-review.ps1"
}

# Teste 4: Função de URL parsing
$testResults += Test-Component "Parsing de URL do PR" {
    $testUrl = "https://github.com/microsoft/vscode/pull/1234"
    
    # Simular função do script
    if ($testUrl -match '^https://github\.com/([^/]+)/([^/]+)/pull/(\d+)/?.*$') {
        $owner = $Matches[1]
        $repo = $Matches[2]
        $number = [int]$Matches[3]
        
        return ($owner -eq "microsoft") -and ($repo -eq "vscode") -and ($number -eq 1234)
    }
    
    return $false
}

# Teste 5: Testar acesso a um repositório público (sem comentar)
$testResults += Test-Component "Acesso a repositório público" {
    $testResult = gh repo view microsoft/vscode 2>&1
    return $LASTEXITCODE -eq 0
}

# Resultado final
Write-Host ""
Write-Host "📊 RESULTADO DOS TESTES" -ForegroundColor Cyan
Write-Host "========================" -ForegroundColor Cyan

$passed = ($testResults | Where-Object { $_ -eq $true }).Count
$total = $testResults.Count

Write-Host "Testes passaram: $passed/$total" -ForegroundColor $(if ($passed -eq $total) { "Green" } else { "Yellow" })

if ($passed -eq $total) {
    Write-Host ""
    Write-Host "🎉 TODOS OS TESTES PASSARAM!" -ForegroundColor Green
    Write-Host ""
    Write-Host "✅ Sistema pronto para uso!" -ForegroundColor Green
    Write-Host ""
    Write-Host "🚀 Exemplo de uso:" -ForegroundColor Blue
    Write-Host "   .\review-pr-with-comment.ps1 'https://github.com/owner/repo/pull/123' --detailed --auto-comment" -ForegroundColor Gray
    Write-Host ""
    
} else {
    Write-Host ""
    Write-Host "⚠️ ALGUNS TESTES FALHARAM" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "🔧 Ações recomendadas:" -ForegroundColor Blue
    
    if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
        Write-Host "   • Instalar GitHub CLI: winget install --id GitHub.cli" -ForegroundColor Red
    }
    
    $authStatus = gh auth status 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "   • Autenticar GitHub CLI: gh auth login" -ForegroundColor Red
    }
    
    if (-not (Test-Path "$PSScriptRoot\review-pr-with-comment.ps1")) {
        Write-Host "   • Script principal não encontrado - verificar arquivos" -ForegroundColor Red
    }
    
    if (-not (Test-Path "$PSScriptRoot\tools\gh-comment.ps1")) {
        Write-Host "   • Script de comentário não encontrado - verificar pasta tools/" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "📋 COMANDOS DE TESTE MANUAL" -ForegroundColor Cyan
Write-Host ""
Write-Host "# Teste básico (sem comentário):" -ForegroundColor Blue
Write-Host ".\review-pr.ps1 'https://github.com/microsoft/vscode/pull/1' --help" -ForegroundColor Gray
Write-Host ""
Write-Host "# Teste de comentário (repositório próprio - CUIDADO!):" -ForegroundColor Blue  
Write-Host ".\tools\gh-comment.ps1 -PrUrl 'URL_DO_SEU_PR' -CommentText 'Teste de comentário automático ✅' -Verbose" -ForegroundColor Gray
Write-Host ""
Write-Host "# Teste completo com comentário draft:" -ForegroundColor Blue
Write-Host ".\review-pr-with-comment.ps1 'URL_DO_SEU_PR' --detailed --auto-comment --draft-comment --verbose" -ForegroundColor Gray

Write-Host ""
Write-Host "⚠️ IMPORTANTE: Use apenas em PRs de repositórios próprios para testes!" -ForegroundColor Red
Write-Host "" 