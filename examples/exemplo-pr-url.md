# 🎯 Exemplo: Análise Automática de PR via URL

Este exemplo mostra como usar a nova funcionalidade de reconhecimento automático de URLs de Pull Requests.

## ✨ Funcionalidade

Quando você mencionar uma URL de PR com `@`, o sistema reconhece automaticamente e executa a análise:

**Formatos reconhecidos:**
- `@https://github.com/owner/repo/pull/123`
- `https://github.com/owner/repo/pull/123`
- `owner/repo#123`

## 🚀 Como Usar

### No Cursor Chat

Simplesmente mencione a URL com `@`:

```
Analise esta PR: @https://github.com/Octadesk-Tech/chat-bot-service/pull/648
```

O sistema automaticamente:
1. ✅ Extrai `owner/repo` e número do PR
2. ✅ Busca informações do PR via GitHub CLI
3. ✅ Lista arquivos modificados
4. ✅ Aplica critérios de revisão arquitetural
5. ✅ Gera relatório estruturado

### Linha de Comando

**No Linux/Mac:**
```bash
# Análise básica
tools/ghpr.sh @https://github.com/microsoft/vscode/pull/12345

# Análise completa com diff
tools/ghpr.sh -d -f @https://github.com/microsoft/vscode/pull/12345

# Salvar em arquivo
tools/ghpr.sh -d -f -o review_12345.txt @https://github.com/microsoft/vscode/pull/12345
```

**No Windows:**
```powershell
# Análise básica
tools/ghpr.ps1 -Url "@https://github.com/microsoft/vscode/pull/12345"

# Análise completa com diff
tools/ghpr.ps1 -Url "@https://github.com/microsoft/vscode/pull/12345" -Diff -Files

# Salvar em arquivo
tools/ghpr.ps1 -Url "@https://github.com/microsoft/vscode/pull/12345" -Diff -Files -Output "review_12345.txt"
```

## 📋 Exemplo de Saída

```markdown
# Revisão PR #648 - Chat Bot Service

## 📄 Resumo
Este PR adiciona autenticação JWT ao serviço de chat bot.

## 🏗️ Análise Arquitetural
- ✅ **Pontos Positivos:** 
  - Middleware de auth na camada correta
  - Separação clara entre validação e lógica de negócio
  - Uso adequado do padrão Repository

- ⚠️ **Atenção:** 
  - Duplicação de código de validação JWT em linhas 45-60
  - Error handling poderia ser mais específico

- ❌ **Problemas:** 
  - Lógica de autorização misturada com endpoint

## 🐛 Prevenção de Bugs
- Race condition possível no refresh de tokens
- Falta validação de input em `/auth/refresh`
- Token expiration não está sendo tratado adequadamente

## 💡 Sugestões Específicas
### Arquivo: `src/middleware/auth.js` (Linhas 45-60)
```javascript
// ❌ Código atual
const validateToken = (token) => {
  // lógica duplicada aqui
}

// ✅ Sugestão
// Extrair para service/auth/tokenValidator.js
```

## 🎯 Ação Requerida
- [ ] Extrair lógica de validação JWT para service
- [ ] Implementar tratamento de race conditions
- [ ] Adicionar validação de input no endpoint refresh
- [ ] Mover lógica de autorização para middleware específico
```

## 🛠️ Vantagens da Nova Funcionalidade

1. **⚡ Velocidade**: Análise instantânea via URL
2. **🎯 Precisão**: Extração automática de informações
3. **🌐 Multiplataforma**: Funciona em Linux, Mac e Windows
4. **📝 Padronização**: Relatórios estruturados consistentes
5. **🔄 Integração**: Funciona direto no Cursor Chat

## 💡 Dicas de Uso

- Use `@` no início da URL para trigger automático
- Combine com análise manual de arquivos específicos via `tools/ghcat.sh`
- Salve relatórios na pasta `artifacts/` para histórico
- Use flags específicas (`-d`, `-f`) para controlar saída

---

🚀 **Próximos passos**: Teste com suas próprias PRs e veja a mágica acontecendo! 