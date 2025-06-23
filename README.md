# 🤖 IA Reviewer - Sistema Completo de Análise de PRs

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Cursor Compatible](https://img.shields.io/badge/Cursor-Compatible-blue.svg)](https://cursor.sh/)
[![PowerShell](https://img.shields.io/badge/PowerShell-Windows-blue.svg)](https://docs.microsoft.com/powershell/)

> **🎯 Sistema completo para análise automática de Pull Requests com IA + comentário direto no GitHub**

## 🚀 O que é o IA Reviewer?

Sistema inteligente que **analisa automaticamente PRs do GitHub** e pode **comentar diretamente na PR** com análise profissional estruturada. Funciona perfeitamente com **Cursor Chat** para análise instantânea.

### ✨ Características Principais
- 🤖 **Análise automática** com IA especializada em code review
- 💬 **Comentário direto no GitHub** - sem copiar/colar
- 🎯 **Cursor Integration** - funciona direto no chat do Cursor
- 📊 **Score objetivo** (0-10) baseado em critérios estruturados
- 🏗️ **Análise arquitetural** focada em qualidade
- 🐛 **Detecção de bugs** e problemas potenciais
- 📝 **Relatórios profissionais** com Markdown + emojis + badges

---

## ⚡ Como Usar (Super Simples)

### 1. Setup (uma vez só):
```powershell
winget install --id GitHub.cli
gh auth login
```

### 2. Usar no Cursor Chat:
1. **Abra o projeto IA Reviewer no Cursor** (Ctrl+O)
2. **Abra o Chat** (Ctrl+L) 
3. **Digite:**
```
analise a PR @https://github.com/owner/repo/pull/123
```

**🎯 O que acontece automaticamente:**
1. ✅ Analisa código automaticamente
2. ✅ Mostra relatório profissional completo
3. ✅ Pergunta se quer comentar na PR
4. ✅ Se confirmar, comenta automaticamente no GitHub!

---

## 📦 Setup Rápido (2 minutos)

### 1. Instalar GitHub CLI
```powershell
winget install --id GitHub.cli
```

### 2. Autenticar
```powershell
gh auth login
```

### 3. Testar
```powershell
.\demo.ps1
```

**Pronto!** 🎉 Sistema funcionando.

---

## 🎯 Exemplo de Uso no Cursor Chat

```
Usuário: analise esta PR @https://github.com/facebook/react/pull/456

Cursor: [Executa análise automaticamente]
        [Mostra relatório completo]
        
        🤖 Análise concluída! 
        Deseja subir o comentário desta análise para o GitHub na PR?
        - Digite 'sim' ou 's' para comentar automaticamente
        - Digite 'não' ou 'n' para apenas exibir a análise

Usuário: sim

Cursor: [Comenta automaticamente na PR]
        ✅ Comentário postado com sucesso na PR!
```

### 📊 Exemplo de Análise Gerada:
- **Score:** 6/10
- **Arquitetura:** 3/3 ✅ 
- **Bugs:** 1/3 ⚠️ (risco de breaking changes)
- **Sugestões específicas** com código
- **Checklist de ação** priorizado

---

## 📊 Formato de Análise Gerada

### Exemplo de Relatório:
```markdown
# 🔍 Revisão PR #1601 - chore(deps-dev): bump prettier from 2.1.0 to 3.6.0

## 📄 Resumo Executivo
Esta PR atualiza o Prettier de 2.1.0 para 3.6.0, uma mudança de major version.

## 🏆 Score da PR: 6/10

### Critérios de Avaliação:
- 🏗️ **Arquitetura (3 pts):** 3/3 - Não afeta arquitetura
- 🐛 **Qualidade/Bugs (3 pts):** 1/3 - Risco de breaking changes
- 📝 **Legibilidade (2 pts):** 2/2 - Mudança clara
- 🧪 **Testabilidade (1 pt):** 0/1 - Precisa validar formatação
- ⚡ **Performance (1 pt):** 1/1 - Sem impacto

## 🏗️ Análise Arquitetural
- ✅ **Pontos Positivos:** Dependency dev-only
- ⚠️ **Requer Atenção:** Major version bump 2.x → 3.x
- ❌ **Problemas Críticos:** Sem testes de compatibilidade

## 💡 Sugestões Concretas
### Arquivo: `package.json` (Linha 142)
```json
// ⚠️ Atenção - Major version bump
"prettier": "^3.6.0"

// ✅ Sugestão - Testar compatibilidade primeiro
// npm run lint && npm run format
```

## 🎯 Checklist de Ação
- [ ] [CRÍTICO] Executar testes de formatação
- [ ] [ALTO] Verificar breaking changes do Prettier 3.x
- [ ] [MÉDIO] Validar integração com ESLint
```

---

## 🎮 Comentário Automático no GitHub

### Como Funciona:
1. **Análise da PR** → Sistema analisa código
2. **Pergunta automática** → "Deseja comentar no GitHub?"
3. **Confirmação** → Usuário diz "sim"
4. **Comentário automático** → Posta análise na PR

### Formato do Comentário:
```markdown
## 🤖 Análise Automática de PR

> **Status:** ⚠️ REQUER ATENÇÃO  
> **Analisado em:** 20/12/2024 15:30  
> **Ferramenta:** IA Reviewer v2.0

### 📊 Informações da PR
- **Repositório:** `owner/repo`
- **PR:** [#123](https://github.com/owner/repo/pull/123)
- **Score:** ![Score](https://img.shields.io/badge/Score-6%2F10-yellow)

[...análise completa aqui...]

### 🔧 Próximos Passos
- [ ] Executar testes finais
- [ ] Revisar pontos destacados
- [ ] Solicitar aprovação da equipe

---
*Análise gerada automaticamente pelo IA Reviewer*
```

---

## 📁 Estrutura do Projeto

```
ia-reviewer/
├── 📄 README.md                           # Este guia
├── 🤖 .cursorrules                        # Regras do Cursor Chat
├── 📋 ai_review_pt.md                     # Critérios de análise
│
├── 🛠️ Scripts Principais
│   ├── review-pr-with-comment.ps1         # 🥇 Principal (com comentário)
│   ├── review-pr.ps1                      # 🥈 Análise sem comentário
│   ├── quick-review.ps1                   # 🥉 Análise rápida
│   └── ai-pr-reviewer.ps1                 # 🔧 Análise detalhada
│
├── 🧪 Testes
│   ├── test-dependencies.ps1              # Teste completo
│   └── test-comment-system.ps1            # Teste de comentários
│
├── 🛠️ tools/
│   ├── gh-comment.ps1                     # Comentário automático
│   ├── ghpr.ps1                           # Info de PR (Windows)
│   └── ghcat.sh                           # Buscar arquivos GitHub
│
├── 📚 examples/
│   └── exemplo-comentario-automatico.md   # Exemplo completo
│
├── 📄 Documentação
│   ├── RESUMO-SISTEMA-COMENTARIO.md       # Resumo do sistema
│   └── SETUP-COMENTARIO-AUTOMATICO.md     # Setup detalhado
│
└── 📁 artifacts/                          # Análises salvas (auto-criada)
```

---

## 🧪 Testes e Validação

### Testar Sistema Completo
```powershell
# Teste de dependências
.\test-dependencies.ps1

# Teste de comentários
.\test-comment-system.ps1

# Demo completa
.\demo.ps1
```

### Validar Funcionamento
```powershell
# 1. GitHub CLI funcionando?
gh --version

# 2. Autenticação OK?
gh auth status

# 3. Teste com PR real
.\review-pr-with-comment.ps1 "https://github.com/microsoft/vscode/pull/12345" --detailed --auto-comment
```

---

## 🆘 Solução de Problemas

### Erros Comuns:

| **Erro** | **Causa** | **Solução** |
|----------|-----------|-------------|
| `gh: command not found` | GitHub CLI não instalado | `winget install GitHub.cli` |
| `authentication required` | Não autenticado | `gh auth login` |
| `PR not found` | PR não existe/privada | Verificar URL e permissões |
| `permission denied` | Sem permissão para comentar | Verificar acesso ao repositório |

### Debug Avançado:
```powershell
# Verificar autenticação
gh auth status

# Testar acesso ao repositório
gh repo view owner/repo

# Modo verbose
.\review-pr-with-comment.ps1 "URL" --detailed --auto-comment --verbose
```

---

## 🎯 Casos de Uso

### 👨‍💻 **Desenvolvedor Individual**
```
analise minha PR @https://github.com/meu-repo/projeto/pull/42
```
*Revisar sua própria PR antes de pedir review da equipe*

### 👥 **Equipe de Desenvolvimento** 
```
analise esta PR @https://github.com/empresa/projeto/pull/123
```
*Análise + comentário automático em PRs da equipe*

### 🤖 **PRs do Dependabot**
```
analise dependabot @https://github.com/projeto/repo/pull/456
```
*Verificar breaking changes em atualizações de dependências*

### 📱 **Workflow Simples:**
1. Abrir PR no GitHub
2. Copiar URL da PR  
3. No Cursor Chat: `analise a PR @URL`
4. Confirmar comentário: "sim"
5. ✅ Análise postada automaticamente!

---

## 🚀 Recursos Avançados

### Modos de Operação:
- **Interativo** - Pergunta antes de comentar
- **Automático** - Comenta direto (CI/CD)
- **Draft** - Cria comentário como draft
- **Verbose** - Modo debug detalhado

### Personalização:
- **Critérios customizáveis** em `ai_review_pt.md`
- **Templates de comentário** personalizáveis
- **Integração com ferramentas** próprias

### Formatos de Saída:
- **Markdown** profissional
- **JSON** para integração
- **Plain text** para simplicidade
- **HTML** para relatórios

---

## 📈 Benefícios

### ⚡ **Velocidade**
- **Análise manual:** 30-60 minutos
- **IA Reviewer:** 2-3 minutos

### 🎯 **Qualidade**
- Critérios consistentes sempre aplicados
- Detecção automática de problemas comuns
- Sugestões específicas e acionáveis

### 🤖 **Automação**
- Integração com Cursor Chat
- Comentário automático no GitHub
- Zero configuração após setup

### 📊 **Profissionalismo**
- Relatórios estruturados
- Formato padrão da equipe
- Métricas objetivas (score 0-10)

---

## 📜 License

MIT License - Veja [LICENSE](LICENSE) para detalhes.

---

## 🤝 Contribuição

Contribuições são bem-vindas! Por favor:

1. Fork o projeto
2. Crie uma branch para sua feature
3. Commit suas mudanças
4. Push para a branch
5. Abra um Pull Request

---

## 🛠️ Ferramentas Principais

### 🥇 **review-pr-with-comment.ps1** - PRINCIPAL
**Análise completa + comentário automático**
```powershell
# Modo interativo (pergunta antes de comentar)
.\review-pr-with-comment.ps1 "URL_DA_PR" --detailed --auto-comment

# Modo automático (comenta direto)
.\review-pr-with-comment.ps1 "URL_DA_PR" --detailed --auto-comment --force-comment
```

### 🥈 **review-pr.ps1** - ANÁLISE SEM COMENTÁRIO
**Apenas análise, sem comentar**
```powershell
.\review-pr.ps1 "URL_DA_PR" --detailed
```

### 🥉 **quick-review.ps1** - ANÁLISE RÁPIDA
**Análise expressa para decisões rápidas**
```powershell
.\quick-review.ps1 "URL_DA_PR"
```

### 🔧 **ai-pr-reviewer.ps1** - ANÁLISE DETALHADA
**Análise técnica profunda**
```powershell
.\ai-pr-reviewer.ps1 -Url "URL_DA_PR" -Output "review.md"
```

---

**🎉 Pronto para começar?** Execute `.\demo.ps1` e veja a mágica acontecer! ✨ 