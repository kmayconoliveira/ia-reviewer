# 🤖 IA Reviewer - Demonstração Rápida (PowerShell)
# Execute este script para ver o IA Reviewer em ação

Write-Host "🤖 IA Reviewer - Demo Instantâneo" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

# Verificar dependências
Write-Host "🔍 Verificando dependências..." -ForegroundColor Yellow

try {
    $ghVersion = gh --version
    Write-Host "✅ GitHub CLI encontrado: $($ghVersion[0])" -ForegroundColor Green
} catch {
    Write-Host "❌ GitHub CLI (gh) não encontrado. Execute: winget install GitHub.cli" -ForegroundColor Red
    exit 1
}

try {
    gh auth status 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ GitHub CLI autenticado!" -ForegroundColor Green
    } else {
        Write-Host "❌ GitHub CLI não autenticado. Execute: gh auth login" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "❌ Erro ao verificar autenticação do GitHub CLI" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Demonstrar análise de PR real
Write-Host "🎯 Analisando PR real do Microsoft VSCode..." -ForegroundColor Cyan
Write-Host "PR #251854 - prompts: allow loading instructions on demand" -ForegroundColor White
Write-Host ""

# Criar diretório artifacts se não existir
if (!(Test-Path "artifacts")) {
    New-Item -ItemType Directory -Path "artifacts" | Out-Null
}

# Buscar informações da PR
Write-Host "📋 Buscando informações da PR..." -ForegroundColor Yellow

try {
    gh pr view 251854 --repo microsoft/vscode > artifacts/demo_pr_info.txt 2>$null
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Informações da PR salvas em artifacts/demo_pr_info.txt" -ForegroundColor Green
        
        # Mostrar preview das informações
        Write-Host ""
        Write-Host "📄 Preview das informações:" -ForegroundColor Cyan
        Write-Host "==========================" -ForegroundColor Cyan
        Get-Content artifacts/demo_pr_info.txt | Select-Object -First 15
        Write-Host "..."
        Write-Host "(arquivo completo em artifacts/demo_pr_info.txt)" -ForegroundColor Gray
        Write-Host ""
        
        # Buscar diff se a PR ainda existir
        Write-Host "🔍 Buscando diferenças do código..." -ForegroundColor Yellow
        gh pr diff 251854 --repo microsoft/vscode > artifacts/demo_pr_diff.txt 2>$null
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Diff da PR salvo em artifacts/demo_pr_diff.txt" -ForegroundColor Green
        } else {
            Write-Host "ℹ️ Diff não disponível (PR pode ter sido merged ou fechada)" -ForegroundColor Blue
        }
        
    } else {
        Write-Host "ℹ️ PR específica não está mais disponível, mas o processo funcionou!" -ForegroundColor Blue
        Write-Host "📝 Em uso real, você faria:" -ForegroundColor White
        Write-Host "   gh pr view <NUMERO> --repo <OWNER/REPO>" -ForegroundColor Gray
    }
} catch {
    Write-Host "❌ Erro ao buscar informações da PR: $_" -ForegroundColor Red
}

Write-Host ""
Write-Host "🎯 PRÓXIMOS PASSOS:" -ForegroundColor Green
Write-Host "==================" -ForegroundColor Green
Write-Host "1. Execute no Cursor Chat:" -ForegroundColor White
Write-Host "   'Analise @https://github.com/microsoft/vscode/pull/[numero-pr-atual]'" -ForegroundColor Gray
Write-Host ""
Write-Host "2. Para suas próprias PRs:" -ForegroundColor White
Write-Host "   'gh pr view <NUMERO> --repo <SEU-OWNER/REPO>'" -ForegroundColor Gray
Write-Host ""
Write-Host "3. Use os guias de revisão:" -ForegroundColor White
Write-Host "   'Get-Content ai_review_pt.md' (português)" -ForegroundColor Gray
Write-Host "   'Get-Content ai_review_en.md' (inglês)" -ForegroundColor Gray
Write-Host ""
Write-Host "✨ Demo concluída! O IA Reviewer está pronto para uso." -ForegroundColor Green
Write-Host "📁 Verifique os arquivos gerados na pasta artifacts/" -ForegroundColor Cyan 