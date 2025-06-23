# 🚀 Comandos Principais - IA Reviewer

## ⚡ Comandos Essenciais (Copie e Cole)

### 📦 Setup Inicial
```powershell
# 1. Instalar GitHub CLI
winget install --id GitHub.cli

# 2. Autenticar
gh auth login

# 3. Testar sistema
.\demo.ps1
```

### 🎯 Análise de PR (Mais Usado)
```powershell
# Análise completa + pergunta se quer comentar
.\review-pr-with-comment.ps1 "URL_DA_PR" --detailed --auto-comment

# Apenas análise (sem comentário)
.\review-pr.ps1 "URL_DA_PR" --detailed

# Análise rápida
.\quick-review.ps1 "URL_DA_PR"
```

### 💬 No Cursor Chat
```
analise a PR @https://github.com/owner/repo/pull/123
```

### 🧪 Testes
```powershell
# Testar dependências
.\test-dependencies.ps1

# Testar comentários
.\test-comment-system.ps1

# Demo completa
.\demo.ps1
```

### 🔧 Verificação de Problemas
```powershell
# Verificar GitHub CLI
gh --version
gh auth status

# Testar acesso a repo
gh repo view owner/repo

# Debug verbose
.\review-pr-with-comment.ps1 "URL" --detailed --auto-comment --verbose
```

---

## 📝 Formatos de URL Aceitos
- `https://github.com/owner/repo/pull/123`
- `@https://github.com/owner/repo/pull/123`
- Qualquer URL válida de PR do GitHub

## 🎯 Fluxo Típico
1. **Setup:** `gh auth login` (uma vez só)
2. **Uso:** `.\review-pr-with-comment.ps1 "URL" --detailed --auto-comment`
3. **Resposta:** Digite "sim" para comentar ou "não" para só ver análise
4. **Resultado:** Análise completa + comentário automático no GitHub

## 🆘 Erros Comuns
- **`gh: command not found`** → `winget install GitHub.cli`
- **`authentication required`** → `gh auth login`
- **`PR not found`** → Verificar URL e permissões
- **`permission denied`** → Verificar acesso ao repositório

---

**🎉 Comando mais usado:** `.\review-pr-with-comment.ps1 "URL_DA_PR" --detailed --auto-comment` 