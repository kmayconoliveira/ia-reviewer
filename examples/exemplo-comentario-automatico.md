# 🤖 Exemplo: Comentário Automático em PRs

Este exemplo mostra como usar o sistema de análise + comentário automático no GitHub.

## 🎯 Cenário

Você quer analisar uma PR e automaticamente comentar o resultado diretamente no GitHub, sem precisar copiar e colar.

## 🚀 Comandos Disponíveis

### 1. Análise + Comentário Automático
```powershell
# Análise detalhada + comentário automático
.\review-pr-with-comment.ps1 "https://github.com/owner/repo/pull/123" --detailed --auto-comment

# Análise rápida + comentário automático  
.\review-pr-with-comment.ps1 "https://github.com/owner/repo/pull/123" --auto-comment
```

### 2. Comentário como Draft (Pendente)
```powershell
# Cria comentário como draft para revisar antes de publicar
.\review-pr-with-comment.ps1 "https://github.com/owner/repo/pull/123" --detailed --auto-comment --draft-comment
```

### 3. Análise + Salvar + Comentar
```powershell
# Análise completa: exibe no terminal + salva arquivo + comenta no GitHub
.\review-pr-with-comment.ps1 "https://github.com/owner/repo/pull/123" --detailed --auto-comment --output "review-pr-123.md"
```

### 4. Apenas Comentário (Sem Análise)
```powershell
# Se você já tem um texto e quer apenas comentar
.\tools\gh-comment.ps1 -PrUrl "https://github.com/owner/repo/pull/123" -CommentText "✅ Aprovado para merge!"
```

## 📋 Fluxo Completo

```powershell
# 1. Comando principal (o que você deve usar sempre)
.\review-pr-with-comment.ps1 "https://github.com/owner/repo/pull/123" --detailed --auto-comment --verbose

# Output esperado:
# === 🤖 IA Reviewer - Análise + Comentário Automático ===
# 
# [INFO] URL: https://github.com/owner/repo/pull/123
# [INFO] PR identificado: #123 em owner/repo
# 
# === Executando Análise de PR ===
# [INFO] Usando análise detalhada...
# 
# # Revisão Automática de PR
# ## Informações Gerais
# - Repositório: owner/repo
# - PR: #123
# - Tipo: Feature
# - Complexidade: Média
# - Status: APROVADO
# 
# [SUCCESS] Análise concluída com sucesso!
# 
# === Criando Comentário Automático ===
# [INFO] Preparando comentário...
# [INFO] Executando comentário automático...
# [SUCCESS] Comentário criado com sucesso!
# [SUCCESS] URL do PR: https://github.com/owner/repo/pull/123
# 
# ✅ Processo completo finalizado!
# 📝 Análise executada | 💬 Comentário criado
```

## 🔧 Configuração Inicial

### 1. Instalar GitHub CLI
```powershell
winget install --id GitHub.cli
```

### 2. Autenticar no GitHub
```powershell
gh auth login
```

### 3. Verificar permissões
```powershell
# Verificar se você tem acesso ao repositório
gh repo view owner/repo

# Verificar autenticação
gh auth status
```

## 📝 Formato do Comentário Gerado

O comentário automático inclui:

```markdown
# 🤖 Análise Automática de PR

**Analisado em:** 15/12/2024 14:30
**PR:** #123 em owner/repo
**Ferramenta:** IA Reviewer

---

[RESULTADO DA ANÁLISE AQUI]

---

*Esta análise foi gerada automaticamente. Para dúvidas ou sugestões, consulte a equipe de desenvolvimento.*

**📝 Como usar esta análise:**
- ✅ **Verde:** Pode prosseguir
- ⚠️ **Amarelo:** Requer atenção  
- ❌ **Vermelho:** Deve ser corrigido antes do merge

**🔧 Próximos passos:**
1. Revisar os pontos destacados acima
2. Implementar correções se necessário
3. Executar testes completos
4. Solicitar aprovação final da equipe
```

## ⚡ Integração com Cursor

No Cursor, você pode simplesmente:

```
Analise esta PR: https://github.com/owner/repo/pull/123
```

O Cursor automaticamente executará:
```powershell
.\review-pr-with-comment.ps1 "https://github.com/owner/repo/pull/123" --detailed --auto-comment
```

## 🔒 Segurança e Boas Práticas

### Verificações de Segurança
- ✅ Verificar se URL do PR é válida
- ✅ Verificar se você tem permissões no repositório
- ✅ Verificar autenticação do GitHub CLI
- ✅ Opção de preview do comentário antes de publicar

### Usar Draft Comments
Para comentários importantes, use `--draft-comment`:
```powershell
.\review-pr-with-comment.ps1 "URL_DO_PR" --detailed --auto-comment --draft-comment
```

Isso permite revisar o comentário antes de publicar.

## 🐛 Resolução de Problemas

### Erro: "PR não encontrado"
```powershell
# Verificar se PR existe
gh pr view 123 --repo owner/repo

# Verificar autenticação
gh auth status
```

### Erro: "Permissão negada"
```powershell
# Re-autenticar com mais permissões
gh auth login --scopes repo
```

### Erro: "Script não encontrado"
```powershell
# Verificar se scripts existem
Get-ChildItem *.ps1 | Select-Object Name
Get-ChildItem tools\*.ps1 | Select-Object Name
```

## 🎨 Personalização

### Customizar Comentário
Edite a função `New-CommentFromAnalysis` em `review-pr-with-comment.ps1`:

```powershell
function New-CommentFromAnalysis {
    param([string]$AnalysisOutput, [hashtable]$PrInfo)
    
    $timestamp = Get-Date -Format "dd/MM/yyyy HH:mm"
    
    $comment = @"
# 🏢 Review da Empresa XYZ

**Analisado em:** $timestamp
**Revisor:** IA Reviewer Bot v2.0
**PR:** #$($PrInfo.Number) em $($PrInfo.FullRepo)

---

$AnalysisOutput

---

**📞 Contato:** time-desenvolvimento@empresa.com
"@
    
    return $comment
}
```

## 📚 Referências

- [GitHub CLI - Documentação](https://cli.github.com/manual/)
- [GitHub API - Pull Request Comments](https://docs.github.com/en/rest/pulls/comments)
- [PowerShell - Documentação](https://docs.microsoft.com/powershell/)

---

**💡 Dica:** Use `--verbose` para ver detalhes do processo e `--help` para ver todas as opções disponíveis! 