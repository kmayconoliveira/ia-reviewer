# 🤖 IA PR Reviewer - Sistema Automático de Revisão de Pull Requests

Sistema completo para análise automática e inteligente de Pull Requests do GitHub, com múltiplas ferramentas especializadas.

## 🚀 Funcionalidades

- ✅ **Análise automática de complexidade** - Identifica o nível de dificuldade das mudanças
- 🔍 **Detecção de riscos** - Identifica operações perigosas e problemas potenciais  
- 📊 **Estatísticas detalhadas** - Conta linhas, arquivos, commits
- 🏷️ **Classificação automática** - Identifica o tipo de mudança (Feature, Bug Fix, etc.)
- 💡 **Recomendações personalizadas** - Sugestões baseadas na análise
- 📄 **Relatórios em Markdown** - Output profissional para documentação
- ⚡ **Modo rápido e detalhado** - Escolha o nível de análise

## 📦 Instalação

### Pré-requisitos

1. **GitHub CLI** (obrigatório)
```powershell
winget install --id GitHub.cli
```

2. **Autenticação no GitHub**
```powershell
gh auth login
```

### Configuração

1. Clone ou baixe os scripts
2. Coloque todos os arquivos `.ps1` no mesmo diretório
3. Execute com PowerShell

## 🎯 Como Usar

### 1. Revisão Rápida (Recomendado)

```powershell
# Análise rápida e visual
powershell -ExecutionPolicy Bypass -File review-pr.ps1 "https://github.com/owner/repo/pull/123"

# Ou com @
powershell -ExecutionPolicy Bypass -File review-pr.ps1 "@https://github.com/owner/repo/pull/123"
```

### 2. Revisão Detalhada

```powershell
# Análise completa
powershell -ExecutionPolicy Bypass -File review-pr.ps1 "https://github.com/owner/repo/pull/123" -Detailed

# Salvando em arquivo
powershell -ExecutionPolicy Bypass -File review-pr.ps1 "https://github.com/owner/repo/pull/123" -Detailed -Output "review.md"
```

### 3. Ferramentas Específicas

```powershell
# Só análise rápida
powershell -ExecutionPolicy Bypass -File quick-review.ps1 "URL_DO_PR"

# Só análise detalhada
powershell -ExecutionPolicy Bypass -File ai-pr-reviewer.ps1 -Url "URL_DO_PR" -Output "review.md"
```

## 📊 Exemplo de Análise

```
=== Quick PR Reviewer ===

🤖 IA REVIEWER - Analisando PR automaticamente...

RESULTADO DA ANÁLISE
====================
Tipo: Bug Fix
Arquivos: 3
Linhas: +12 -5
Status: [REQUER ATENÇÃO]

RISCOS IDENTIFICADOS:
   • Remoção de tratamento de erro
   • Arquivos críticos modificados

ARQUIVOS MODIFICADOS:
   • src/app/service.js
   • config/database.js
   • package.json

RECOMENDAÇÕES:
   • Revisar cuidadosamente os riscos identificados
   • Executar testes completos antes do merge
   • Verificar se a documentação precisa ser atualizada
```

## 🎯 Tipos de Análise

### Classificação Automática
- **Feature** - Novas funcionalidades
- **Bug Fix** - Correções de bugs
- **Chore** - Tarefas de manutenção
- **Refactor** - Refatoração de código

### Níveis de Complexidade
- **Baixa** - Poucas mudanças, poucos arquivos
- **Média** - Mudanças moderadas
- **Alta** - Mudanças significativas
- **Crítica** - Mudanças extensas que requerem cuidado especial

### Status de Aprovação
- **[APROVADO]** - Pode ser merged com segurança
- **[REQUER ATENÇÃO]** - Tem riscos que precisam ser revisados
- **[REVISÃO DETALHADA NECESSÁRIA]** - Mudanças muito grandes

## 🚨 Detecção de Riscos

O sistema identifica automaticamente:

- 💥 **Operações destrutivas** - DELETE, DROP, TRUNCATE
- 🐛 **Remoção de tratamento de erro** - try/catch removidos
- 📁 **Arquivos críticos** - .sql, migrations, configs, package.json
- 🔍 **Código de debug** - console.log, print, debug statements
- ⚠️ **Mudanças em dependências** - imports/requires modificados

## 📝 Estrutura dos Arquivos

```
ia-reviewer/
├── review-pr.ps1          # Script principal (USE ESTE!)
├── quick-review.ps1       # Análise rápida
├── ai-pr-reviewer.ps1     # Análise detalhada
├── tools/
│   ├── ghpr.ps1           # Ferramenta original GitHub
│   └── ghpr.sh            # Versão bash
└── README-AI-REVIEWER.md  # Esta documentação
```

## 🛠️ Solução de Problemas

### GitHub CLI não encontrado
```powershell
winget install --id GitHub.cli
gh auth login
```

### PR não encontrado
- Verifique se o repositório é público ou você tem acesso
- Confirme se o número do PR está correto
- Teste: `gh pr view 123 --repo owner/repo`

### Problemas de encoding
- Use PowerShell 7+ para melhor suporte a UTF-8
- Os scripts foram otimizados para Windows

### Execution Policy
```powershell
powershell -ExecutionPolicy Bypass -File nome-do-script.ps1
```

## 🎨 Personalização

### Adicionando Novos Tipos de Análise

Edite a função `Get-ChangeAnalysis` em `ai-pr-reviewer.ps1`:

```powershell
# Adicionar novo tipo
if ($BasicInfo -match 'docs|documentation') { $analysis.Type = "Documentation" }
```

### Customizando Detecção de Riscos

Adicione padrões na função `Get-ChangeAnalysis`:

```powershell
# Novo risco
if ($diff -match 'password|secret|token') { 
    $analysis.Risks += "Credenciais detectadas no código" 
}
```

## 📈 Integração com CI/CD

### GitHub Actions

```yaml
name: Auto PR Review
on:
  pull_request:
    opened: true

jobs:
  review:
    runs-on: windows-latest
    steps:
      - uses: actions/checkout@v3
      - name: Review PR
        run: |
          powershell -ExecutionPolicy Bypass -File review-pr.ps1 "https://github.com/${{ github.repository }}/pull/${{ github.event.number }}" -Detailed -Output "review.md"
```

## 🤝 Contribuição

Para melhorar o sistema:

1. Adicione novos padrões de detecção de riscos
2. Melhore a classificação de tipos de mudança
3. Adicione suporte a novas linguagens de programação
4. Otimize a performance para repositórios grandes

## 📄 Licença

Este projeto está sob a mesma licença do projeto principal ia-reviewer.

---

**🎯 Dica Pro:** Use `review-pr.ps1` como seu comando principal. Ele automaticamente escolhe a melhor ferramenta baseada nos seus parâmetros!

**⚡ Comando Favorito:**
```powershell
powershell -ExecutionPolicy Bypass -File review-pr.ps1 "@URL_DO_PR" -Detailed -Output "review.md"
``` 