#!/bin/bash
# 🤖 IA Reviewer - Demonstração Rápida
# Execute este script para ver o IA Reviewer em ação

echo "🤖 IA Reviewer - Demo Instantâneo"
echo "=================================="
echo ""

# Verificar dependências
echo "🔍 Verificando dependências..."
if ! command -v gh &> /dev/null; then
    echo "❌ GitHub CLI (gh) não encontrado. Execute: winget install GitHub.cli"
    exit 1
fi

if ! gh auth status &> /dev/null; then
    echo "❌ GitHub CLI não autenticado. Execute: gh auth login"
    exit 1
fi

echo "✅ Dependências OK!"
echo ""

# Demonstrar análise de PR real
echo "🎯 Analisando PR real do Microsoft VSCode..."
echo "PR #251854 - prompts: allow loading instructions on demand"
echo ""

# Criar diretório artifacts se não existir
mkdir -p artifacts

# Buscar informações da PR
echo "📋 Buscando informações da PR..."
gh pr view 251854 --repo microsoft/vscode > artifacts/demo_pr_info.txt 2>/dev/null

if [ $? -eq 0 ]; then
    echo "✅ Informações da PR salvas em artifacts/demo_pr_info.txt"
    
    # Mostrar preview das informações
    echo ""
    echo "📄 Preview das informações:"
    echo "=========================="
    head -15 artifacts/demo_pr_info.txt
    echo "..."
    echo "(arquivo completo em artifacts/demo_pr_info.txt)"
    echo ""
    
    # Buscar diff se a PR ainda existir
    echo "🔍 Buscando diferenças do código..."
    gh pr diff 251854 --repo microsoft/vscode > artifacts/demo_pr_diff.txt 2>/dev/null
    
    if [ $? -eq 0 ]; then
        echo "✅ Diff da PR salvo em artifacts/demo_pr_diff.txt"
    else
        echo "ℹ️ Diff não disponível (PR pode ter sido merged ou fechada)"
    fi
    
else
    echo "ℹ️ PR específica não está mais disponível, mas o processo funcionou!"
    echo "📝 Em uso real, você faria:"
    echo "   gh pr view <NUMERO> --repo <OWNER/REPO>"
fi

echo ""
echo "🎯 PRÓXIMOS PASSOS:"
echo "=================="
echo "1. Execute no Cursor Chat:"
echo "   'Analise @https://github.com/microsoft/vscode/pull/[numero-pr-atual]'"
echo ""
echo "2. Para suas próprias PRs:"
echo "   'gh pr view <NUMERO> --repo <SEU-OWNER/REPO>'"
echo ""
echo "3. Use os guias de revisão:"
echo "   'cat ai_review_pt.md' (português)"
echo "   'cat ai_review_en.md' (inglês)"
echo ""
echo "✨ Demo concluída! O IA Reviewer está pronto para uso."
echo "📁 Verifique os arquivos gerados na pasta artifacts/" 