# 🤖 Setup: Sistema de Comentário Automático

## 🎯 O que isso faz?

Este sistema permite:
1. **Analisar automaticamente** uma PR do GitHub
2. **Comentar diretamente na PR** com o resultado da análise  
3. **Tudo em um comando** - sem copiar e colar

## ⚡ Setup Rápido (5 minutos)

### 1. Instalar GitHub CLI
```powershell
winget install --id GitHub.cli
```

### 2. Autenticar no GitHub
```powershell
gh auth login
```
- Escolha: **GitHub.com**
- Escolha: **HTTPS**
- Escolha: **Y** (autenticar Git)
- Escolha: **Login with a web browser**
- Cole o código que aparecer

### 3. Testar sistema
```powershell
.\test-comment-system.ps1
```

### 4. Uso básico
```powershell
# Analisar + comentar automaticamente
.\review-pr-with-comment.ps1 "https://github.com/owner/repo/pull/123" --detailed --auto-comment
```

## 🔧 Configuração Detalhada

### Verificar se GitHub CLI está funcionando
```powershell
# Testar comando básico
gh --version

# Testar autenticação
gh auth status

# Testar acesso a repositório
gh repo view microsoft/vscode
```

### Verificar scripts existem
```powershell
# Scripts principais
Get-ChildItem *.ps1 | Select-Object Name

# Scripts auxiliares
Get-ChildItem tools\*.ps1 | Select-Object Name
```

## 📋 Comandos Disponíveis

### 🥇 Comando Principal
```powershell
# Análise detalhada + pergunta se quer comentar
.\review-pr-with-comment.ps1 "URL_DO_PR" --detailed --auto-comment

# Análise detalhada + comentário direto (sem pergunta)
.\review-pr-with-comment.ps1 "URL_DO_PR" --detailed --auto-comment --force-comment
```

### 🎛️ Opções Avançadas
```powershell
# Com comentário draft (para revisar antes)
.\review-pr-with-comment.ps1 "URL_DO_PR" --detailed --auto-comment --draft-comment

# Com verbose (mostra detalhes)
.\review-pr-with-comment.ps1 "URL_DO_PR" --detailed --auto-comment --verbose

# Salvar análise em arquivo também
.\review-pr-with-comment.ps1 "URL_DO_PR" --detailed --auto-comment --output "analise.md"
```

### 🔧 Apenas Comentário (sem análise)
```powershell
# Se você já tem um texto pronto
.\tools\gh-comment.ps1 -PrUrl "URL_DO_PR" -CommentText "✅ Aprovado!"
```

## 🎯 Integração com Cursor

Você pode simplesmente escrever no Cursor:
```
Analise esta PR: https://github.com/owner/repo/pull/123
```

O Cursor automaticamente executará o comando completo com comentário!

## 🔒 Segurança

### ⚠️ Cuidados Importantes
- **Teste primeiro** em repositórios próprios
- Use `--draft-comment` para comentários importantes
- Verifique se tem permissão de escrita no repositório
- **Não teste em repositórios de terceiros** sem permissão

### ✅ Práticas Seguras
```powershell
# 1. Sempre teste o sistema primeiro
.\test-comment-system.ps1

# 2. Use draft para comentários importantes
.\review-pr-with-comment.ps1 "URL" --auto-comment --draft-comment

# 3. Verifique permissões antes
gh repo view owner/repo  # Se der erro, você não tem acesso
```

## 🐛 Resolução de Problemas

### Erro: `gh: command not found`
```powershell
# Instalar GitHub CLI
winget install --id GitHub.cli

# Reiniciar terminal
```

### Erro: `authentication required`
```powershell
# Re-autenticar
gh auth login

# Verificar status
gh auth status
```

### Erro: `permission denied`
```powershell
# Verificar se tem acesso ao repositório
gh repo view owner/repo

# Se repositório é privado, pode precisar de permissões especiais
gh auth login --scopes repo
```

### Erro: `PR not found`
```powershell
# Verificar se URL está correta
# Formato: https://github.com/owner/repo/pull/123

# Verificar se PR existe
gh pr view 123 --repo owner/repo
```

### Scripts não encontrados
```powershell
# Verificar se está na pasta correta
Get-Location

# Listar arquivos
Get-ChildItem *.ps1
```

## 📝 Formato do Comentário

O comentário gerado automaticamente inclui:

```markdown
# 🤖 Análise Automática de PR

**Analisado em:** 15/12/2024 14:30
**PR:** #123 em owner/repo  
**Ferramenta:** IA Reviewer

---

[RESULTADO DA ANÁLISE DETALHADA]

---

*Esta análise foi gerada automaticamente.*

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

## 🚀 Uso Avançado

### Workflow Completo
```powershell
# 1. Análise inicial (rápida, sem comentário)
.\quick-review.ps1 "URL_DO_PR"

# 2. Se tudo ok, análise completa + comentário
.\review-pr-with-comment.ps1 "URL_DO_PR" --detailed --auto-comment

# 3. Se houver problemas, comentário draft para revisar
.\review-pr-with-comment.ps1 "URL_DO_PR" --detailed --auto-comment --draft-comment
```

### Personalizar Comentários
Edite o arquivo `review-pr-with-comment.ps1`, função `New-CommentFromAnalysis()`:

```powershell
# Personalizar cabeçalho
$comment = @"
# 🏢 Review Automático - Empresa XYZ
**Revisor:** Bot IA v2.0
**Timestamp:** $timestamp
---
$AnalysisOutput
---
**Contato:** devops@empresa.com
"@
```

## 📚 Arquivos do Sistema

```
ia-reviewer/
├── review-pr-with-comment.ps1    # ← SCRIPT PRINCIPAL
├── review-pr.ps1                 # Script de análise (sem comentário)
├── quick-review.ps1              # Análise rápida
├── tools/
│   └── gh-comment.ps1            # ← SCRIPT DE COMENTÁRIO
├── test-comment-system.ps1       # ← SCRIPT DE TESTE
├── examples/
│   └── exemplo-comentario-automatico.md
└── .cursor-rules                 # Regras do Cursor
```

## 🎉 Pronto!

Agora você pode:

1. **Analisar + comentar** em um comando
2. **Integrar com Cursor** automaticamente  
3. **Personalizar** comentários conforme necessário
4. **Testar com segurança** usando drafts

**Comando para começar:**
```powershell
.\review-pr-with-comment.ps1 "SUA_URL_DE_PR_AQUI" --detailed --auto-comment --verbose
```

---

**💡 Dicas:**
- Use `--help` em qualquer script para ver opções
- Teste sempre em repositórios próprios primeiro
- Use `--verbose` para debug
- Use `--draft-comment` para comentários importantes 