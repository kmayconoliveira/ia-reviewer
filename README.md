# 🤖 IA Reviewer

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Shell Script](https://img.shields.io/badge/Shell-Bash-green.svg)](https://www.gnu.org/software/bash/)
[![Powered by GitHub CLI](https://img.shields.io/badge/Powered%20by-GitHub%20CLI-blue.svg)](https://cli.github.com/)

Micro-agentes inteligentes para revisão automatizada de Pull Requests com foco em qualidade arquitetural e prevenção de bugs.

## ✨ Características

- 🎯 **Guias de revisão estruturados** para manter consistência
- 🛠️ **Ferramenta ghcat robusta** para buscar arquivos do GitHub
- 🌐 **Suporte bilíngue** (português e inglês)
- 🔒 **Compatível com repos privados** via GitHub CLI
- ⚡ **Modo raw otimizado** para repos públicos
- 📝 **Documentação automática** das revisões

## 📋 Pré-requisitos

Antes de usar o projeto, instale as dependências necessárias:

### Ferramentas obrigatórias:
- [GitHub CLI (`gh`)](https://cli.github.com/) - Para autenticação e acesso à API
- `curl` - Para requisições HTTP
- `jq` - Para processamento JSON
- `base64` - Para decodificação de conteúdo

### Instalação das dependências:

**Ubuntu/Debian:**
```bash
# GitHub CLI
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update
sudo apt install gh curl jq coreutils
```

**macOS:**
```bash
brew install gh curl jq coreutils
```

**Windows (PowerShell):**
```powershell
winget install GitHub.cli
# curl, jq e base64 já vêm com versões modernas do Windows
```

### Configuração inicial:
```bash
# Autenticar com GitHub
gh auth login

# Tornar o script executável
chmod +x tools/ghcat.sh
```

## 📁 Estrutura do Projeto

```
ia-reviewer/
├── 📄 README.md              # Este arquivo
├── 📋 ai_review_pt.md         # Guia de revisão de PR (português)
├── 📋 ai_review_en.md         # Guia de revisão de PR (inglês)
├── 🛠️  tools/
│   ├── ghcat.sh              # Ferramenta para buscar arquivos do GitHub
│   ├── ghpr.sh               # Ferramenta para buscar informações de PRs (Linux/Mac)
│   └── ghpr.ps1              # Ferramenta para buscar informações de PRs (Windows)
└── 📁 artifacts/             # Saídas de revisões de PR (criada automaticamente)
```

## 🚀 Como Usar

### 🎯 Uso no Cursor Chat (RECOMENDADO)
**Para usar este projeto diretamente no Cursor Chat, veja o guia completo:** 
📖 **[README-CURSOR.md](README-CURSOR.md)** 

### 1. Revisão de Pull Request

Use os guias como prompts para IA ou checklist manual:

```bash
# Para projetos em português
cat ai_review_pt.md

# Para projetos em inglês  
cat ai_review_en.md
```

### 2. Ferramenta ghpr (NOVO!)

**Reconhecimento automático de URLs de PR:**
Agora quando você mencionar uma PR com `@`, a ferramenta reconhece automaticamente:

**Linux/Mac (Bash):**
```bash
# Análise completa a partir da URL
tools/ghpr.sh @https://github.com/owner/repo/pull/123

# Opções específicas
tools/ghpr.sh -d @https://github.com/owner/repo/pull/123  # com diff
tools/ghpr.sh -f @https://github.com/owner/repo/pull/123  # apenas arquivos
tools/ghpr.sh -o review.txt owner/repo 123               # salvar em arquivo
```

**Windows (PowerShell):**
```powershell
# Análise completa a partir da URL
tools/ghpr.ps1 -Url "@https://github.com/owner/repo/pull/123"

# Opções específicas
tools/ghpr.ps1 -Url "@https://github.com/owner/repo/pull/123" -Diff      # com diff
tools/ghpr.ps1 -Url "@https://github.com/owner/repo/pull/123" -Files     # apenas arquivos
tools/ghpr.ps1 -Repo "owner/repo" -PrNumber 123 -Output "review.txt"     # salvar em arquivo
```

### 3. Ferramenta ghcat.sh

Busque arquivos do GitHub sem problemas de base64:

```bash
# Uso básico
tools/ghcat.sh owner/repo arquivo.txt

# Com branch específica
tools/ghcat.sh owner/repo arquivo.txt nome-da-branch

# Modo raw (mais rápido para repos públicos)
tools/ghcat.sh -r owner/repo arquivo.txt

# Modo verbose para debug
tools/ghcat.sh -v owner/repo arquivo.txt

# Salvar em arquivo
tools/ghcat.sh -o temp.txt owner/repo arquivo.txt

# Validar repositório antes de buscar
tools/ghcat.sh --validate owner/repo arquivo.txt
```

### 4. Fluxo completo de revisão

**Novo fluxo automático:**

**Linux/Mac:**
```bash
# 🎯 NOVO: Análise automática a partir da URL
tools/ghpr.sh @https://github.com/owner/repo/pull/123

# Com mais detalhes
tools/ghpr.sh -d -f @https://github.com/owner/repo/pull/123
```

**Windows:**
```powershell
# 🎯 NOVO: Análise automática a partir da URL
tools/ghpr.ps1 -Url "@https://github.com/owner/repo/pull/123"

# Com mais detalhes
tools/ghpr.ps1 -Url "@https://github.com/owner/repo/pull/123" -Diff -Files
```

**Fluxo tradicional:**
```bash
# 1. Buscar informações do PR
gh pr view 123 --repo owner/repo > artifacts/pr_info_123.txt

# 2. Examinar arquivos modificados
tools/ghcat.sh owner/repo src/main.js feature-branch

# 3. Aplicar critérios dos guias de revisão
# 4. Salvar revisão
echo "Revisão do PR #123..." > artifacts/pr_review_123.md
```

## 🎯 Princípios de Revisão

### Foco Arquitetural
- ✅ Separação de camadas (superfície, lógica, adaptadores)
- ✅ Posicionamento correto do código
- ✅ Eliminação de duplicação (DRY)

### Qualidade como Investimento
- 💰 Pagar dívida técnica enquanto é barato
- 📈 Melhorias incrementais contínuas
- ⚖️ Balancear perfeccionismo com pragmatismo

### Três Propósitos da Revisão
1. 🐛 **Capturar bugs** - Funciona corretamente?
2. 🧠 **Compartilhar conhecimento** - Aprender e ensinar padrões
3. 🔄 **Convergir padrões** - Manter consistência na base de código

## 🛠️ Recursos Avançados do ghcat.sh

- **Detecção automática de dependências** com mensagens claras
- **Logging colorido** com níveis INFO/WARN/ERROR
- **Validação de formato** de repositório
- **Fallback automático** entre modo raw e API
- **Tratamento robusto de erros** com códigos de saída apropriados
- **Suporte a arquivos grandes** via download URLs

## 📝 Exemplos Práticos

### Revisar um PR específico:

**🎯 Novo modo automático:**

**Linux/Mac:**
```bash
# Análise completa automática
tools/ghpr.sh @https://github.com/microsoft/vscode/pull/42

# Com diff e lista de arquivos
tools/ghpr.sh -d -f @https://github.com/microsoft/vscode/pull/42

# Salvar análise completa
tools/ghpr.sh -d -f -o artifacts/pr_analysis_42.txt @https://github.com/microsoft/vscode/pull/42
```

**Windows:**
```powershell
# Análise completa automática
tools/ghpr.ps1 -Url "@https://github.com/microsoft/vscode/pull/42"

# Com diff e lista de arquivos
tools/ghpr.ps1 -Url "@https://github.com/microsoft/vscode/pull/42" -Diff -Files

# Salvar análise completa
tools/ghpr.ps1 -Url "@https://github.com/microsoft/vscode/pull/42" -Diff -Files -Output "artifacts/pr_analysis_42.txt"
```

**Modo tradicional:**
```bash
# Buscar mudanças do PR
gh pr diff 42 --repo microsoft/vscode > temp_diff.txt

# Examinar arquivo modificado
tools/ghcat.sh -v microsoft/vscode src/vs/editor/common/model.ts

# Salvar revisão estruturada
cat > artifacts/pr_review_42.md << EOF
# Revisão PR #42 - Microsoft VSCode

## Resumo
Este PR adiciona funcionalidade X ao editor...

## Análise Arquitetural
- ✅ Código na camada correta
- ⚠️  Duplicação em linhas 150-180
- ❌ Lógica de negócio em endpoint

## Recomendações
1. Extrair lógica duplicada para serviço
2. Mover validação para camada apropriada
EOF
```

## 🤝 Contribuindo

1. Fork o projeto
2. Crie sua feature branch (`git checkout -b feature/nova-funcionalidade`)
3. Commit suas mudanças (`git commit -am 'Adiciona nova funcionalidade'`)
4. Push para a branch (`git push origin feature/nova-funcionalidade`)
5. Abra um Pull Request

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para detalhes.

## 🙏 Agradecimentos

- Baseado nas melhores práticas de revisão de código da comunidade
- Inspirado nos princípios arquiteturais do desenvolvimento moderno
- Focado na filosofia "qualidade sem enrolação"

---

> *"Foco na qualidade, sem enrolação."* 
> 
> Mantenha o código limpo, a arquitetura sólida e as revisões concisas. 

# Instalar GitHub CLI
scoop install gh

# Instalar jq
scoop install jq

# Instalar curl (se necessário)
scoop install curl 

# Instalar GitHub CLI e jq
winget install GitHub.cli jqlang.jq

# Verificar se instalou
gh --version
jq --version 

# Testar cada ferramenta
gh --version
jq --version
curl --version
git --version

# Testar autenticação GitHub
gh auth login

# Testar script do projeto (precisa do Git Bash)
"C:\Program Files\Git\bin\bash.exe" -c "./tools/ghcat.sh --help" 

# Testar funcionalidade real
gh auth status
"C:\Program Files\Git\bin\bash.exe" -c "./tools/ghcat.sh microsoft/vscode README.md" 

# Testar funcionalidade real
"C:\Program Files\Git\bin\bash.exe" -c "./tools/ghcat.sh owner/repo file.txt" 

# Testar uma busca real
"C:\Program Files\Git\bin\bash.exe" -c "./tools/ghcat.sh microsoft/vscode README.md" 

# Listar PRs de um projeto
gh pr list --repo microsoft/vscode

# Buscar arquivo específico  
./tools/ghcat.sh owner/repo path/file.txt

# Ler os guias
cat ai_review_pt.md 