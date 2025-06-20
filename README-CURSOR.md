# 🤖 IA Reviewer para Cursor Chat

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Cursor Compatible](https://img.shields.io/badge/Cursor-Compatible-blue.svg)](https://cursor.sh/)

**Micro-agentes inteligentes para revisão automatizada de Pull Requests diretamente no Cursor Chat** - Transforme seu editor em uma ferramenta poderosa de code review com IA.

## 🎯 O que é este projeto?

Este projeto fornece **guias estruturados e ferramentas** para realizar análises profundas de Pull Requests usando o Cursor Chat. Em vez de revisar código manualmente, você usa prompts especializados e ferramentas automatizadas para obter análises consistentes e de alta qualidade.

## ✨ Por que usar no Cursor Chat?

- 🚀 **Análise instantânea**: Cole um PR e receba análise completa em segundos
- 🎯 **Consistência**: Sempre aplica os mesmos critérios de qualidade
- 🧠 **IA especializada**: Prompts otimizados para análise arquitetural
- 🔧 **Ferramentas integradas**: Acesso direto a arquivos do GitHub
- 📝 **Documentação automática**: Gera relatórios estruturados

## 🚀 Setup Rápido

### 1. Pré-requisitos
```bash
# Instalar GitHub CLI
winget install GitHub.cli

# Autenticar com GitHub
gh auth login

# Tornar script executável (no terminal do Cursor)
chmod +x tools/ghcat.sh
```

### 2. Configurar no Cursor
1. Abra este projeto no Cursor
2. Abra o Chat (Ctrl+L)
3. Agora você tem acesso aos guias e ferramentas!

## 💬 Como Usar no Cursor Chat

### Método 1: Análise Completa de PR

**Prompt para o Cursor Chat:**
```
Analise este Pull Request usando os guias do projeto IA Reviewer:

PR: https://github.com/owner/repo/pull/123

Use os critérios de ai_review_pt.md para fazer uma análise completa focando em:
1. Arquitetura e separação de camadas  
2. Prevenção de bugs
3. Qualidade de código
4. Sugestões específicas com exemplos

Salve a análise em artifacts/pr_review_123.md
```

### Método 2: Análise de Arquivo Específico                                                    

**Prompt para o Cursor Chat:**
```              
Examine este arquivo usando a ferramenta ghcat.sh e os critérios de revisão:

Arquivo: src/services/userService.js
Repositório: company/project
Branch: feature/new-auth

Aplique as diretrizes de ai_review_pt.md e identifique:
- Problemas arquiteturais
- Possíveis bugs
- Melhorias de código
```

### Método 3: Comparação de Implementações

**Prompt para o Cursor Chat:**
```
Compare estas duas implementações usando os critérios do IA Reviewer:

[Cole código 1]
vs
[Cole código 2]

Qual segue melhor nossa arquitetura de três camadas?
Use as diretrizes de ai_review_pt.md para avaliar.
```

## 🎯 Prompts Especializados para Cursor

### 🏗️ Análise Arquitetural
```
Analise a arquitetura deste código usando os princípios do ai_review_pt.md:

[Cole seu código aqui]

Verifique especificamente:
- Separação de camadas (Superfície/Lógica/Adaptadores)
- Posicionamento correto do código
- Violações dos princípios SOLID
- Sugestões de refatoração
```

### 🐛 Caça a Bugs
```
Faça uma análise de prevenção de bugs neste código:

[Cole seu código aqui]

Use a seção "Prevenção de Bugs" do ai_review_pt.md para identificar:
- Casos edge não tratados
- Problemas de tratamento de erro
- Validações faltantes
- Possíveis race conditions
```

### 🔄 Revisão de Qualidade
```
Revise a qualidade deste código usando o checklist do ai_review_pt.md:

[Cole seu código aqui]

Foque em:
- Nomenclatura e clareza
- Duplicação de código
- Complexidade desnecessária
- Padrões inconsistentes
```

## 🛠️ Ferramentas Disponíveis

### ghcat.sh - Buscar Arquivos do GitHub
O Cursor pode usar esta ferramenta para examinar arquivos remotos:

```bash
# Buscar arquivo específico
tools/ghcat.sh owner/repo src/main.js

# Com branch específica  
tools/ghcat.sh owner/repo src/main.js feature-branch

# Modo verbose para debug
tools/ghcat.sh -v owner/repo src/main.js
```

### GitHub CLI Integration
```bash
# Buscar informações do PR
gh pr view 123 --repo owner/repo

# Ver diff completo
gh pr diff 123 --repo owner/repo

# Listar arquivos modificados
gh pr diff 123 --repo owner/repo --name-only
```

## 📋 Templates para Cursor Chat

### Template: Revisão Completa de PR
```
# Revisão PR #[NUMERO] - [TITULO]

## 📄 Resumo
[O que o PR faz em 1-2 frases]

## 🏗️ Análise Arquitetural
- ✅ **Pontos Positivos:**
- ⚠️ **Atenção:**
- ❌ **Problemas:**

## 🐛 Prevenção de Bugs
[Lista de possíveis problemas]

## 💡 Sugestões Específicas
### Arquivo: `src/example.js` (Linhas 42-50)
```javascript
// ❌ Código atual
[código problemático]

// ✅ Sugestão
[código melhorado]
```

## 🎯 Ação Requerida
- [ ] Corrigir [problema específico]
- [ ] Refatorar [área específica]
- [ ] Adicionar [validação/teste específico]
```

## 🚨 Sinais de Alerta para o Cursor

Use estes prompts para identificar problemas comuns:

### "Detector de Código Mal Posicionado"
```
Analise se este código está na camada correta da arquitetura:

[Cole código]

Critérios:
- Superfície: apenas roteamento/validação/segurança
- Lógica: regras de negócio e operações  
- Adaptadores: comunicação com recursos externos

Identifique violações e sugira correções.
```

### "Caçador de Duplicação"
```
Identifique duplicação de código nestes arquivos:

[Cole código ou mencione arquivos]

Procure especialmente por:
- Error handling repetido
- Logging duplicado
- Validações similares
- Padrões de acesso a dados

Sugira abstrações para eliminar duplicação.
```

### "Detector de Complexidade Desnecessária"
```
Analise se este código tem complexidade desnecessária:

[Cole código]

Perguntas-chave:
1. Esta é a solução mais simples que poderia funcionar?
2. Existe over-engineering?
3. O código revela intenção ou apenas implementação?
4. Seria fácil de mudar quando requisitos evoluírem?
```

## 🎯 Fluxo de Trabalho Recomendado

### Para Análise de PR
1. **Cole URL do PR** no Cursor Chat
2. **Cursor busca automaticamente** informações e arquivos
3. **Aplica critérios** dos guias de revisão
4. **Gera relatório** estruturado
5. **Salva em artifacts/** para histórico

### Para Análise de Código Específico
1. **Cole código** diretamente no chat
2. **Especifique tipo de análise** (arquitetura, bugs, qualidade)
3. **Cursor aplica** critérios específicos
4. **Receba sugestões** detalhadas com exemplos

### Para Comparação de Implementações
1. **Cole múltiplas** implementações
2. **Cursor compara** contra padrões estabelecidos  
3. **Recomenda** a melhor abordagem
4. **Explica rationale** arquitetural

## 💡 Dicas de Produtividade

### Atalhos Úteis
- `Ctrl+L`: Abrir Cursor Chat
- `@arquivo.js`: Referenciar arquivo específico no chat
- `#função`: Buscar função específica

### Melhores Práticas
1. **Seja específico**: Mencione arquivos, linhas, funções
2. **Use contexto**: Referencie os guias explicitamente
3. **Itere rapidamente**: Faça perguntas de seguimento
4. **Documente decisões**: Salve análises importantes
5. **Aprenda padrões**: Use como oportunidade educativa

## 🔧 Solução de Problemas

### Erro: "Ferramenta não encontrada"
```bash
# Verificar se GitHub CLI está instalado
gh --version

# Verificar se está autenticado
gh auth status

# Tornar script executável
chmod +x tools/ghcat.sh
```

### Erro: "Repositório não encontrado"
- Verificar se o repositório existe e é acessível
- Confirmar autenticação para repositórios privados
- Validar formato: `owner/repo`

### Performance Lenta
- Use flag `-r` para repos públicos (modo raw)
- Evite analisar arquivos muito grandes
- Processe poucos arquivos por vez

## 🎓 Exemplos Práticos

### Análise Rápida de PR
```
Analise @https://github.com/facebook/react/pull/26172

Foque em:
- Impacto na performance
- Quebras de compatibilidade  
- Qualidade das mudanças
```

### Revisão Arquitetural Específica
```
Examine a arquitetura deste service:

tools/ghcat.sh mycompany/project src/services/paymentService.js

Verifique:
- Separação de responsabilidades
- Dependências externas bem isoladas
- Testabilidade do código
```

### Comparação de Padrões
```
Compare estes dois padrões de error handling:

[Cole padrão atual vs. padrão proposto]

Qual segue melhor nossas diretrizes de ai_review_pt.md?
```

---

🚀 **Próximos passos**: Abra o Cursor Chat (Ctrl+L) e comece a analisar seus PRs com IA especializada!

> **💡 Lembre-se**: Este projeto transforma análise manual de horas em análise automática de minutos, mantendo consistência e qualidade. Use e abuse das ferramentas! 🎯 