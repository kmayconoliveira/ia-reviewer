# 🤖 IA Review - Guia de Revisão de Pull Request

> **Objetivo:** Fornecer uma revisão concisa e de alta qualidade focada em qualidade de código, prevenção de bugs e melhorias arquiteturais.

## 🚀 Processo de Revisão

### 1. Preparação
```bash
# Buscar informações do PR
gh pr view <PR_NUMBER> --repo <OWNER/REPO> > temp_pr_info.txt

# Buscar diff completo
gh pr diff <PR_NUMBER> --repo <OWNER/REPO> > temp_pr_diff.txt

# Examinar arquivos modificados
tools/ghcat.sh <OWNER/REPO> <CAMINHO_ARQUIVO> <BRANCH>
```

### 2. Análise Estruturada

#### 📝 Resumo Executivo (máximo 2 frases)
- O que o PR faz?
- Qual o impacto principal?

#### 🏗️ Análise Arquitetural
- [ ] Separação de camadas respeitada?
- [ ] Código na camada/pasta correta?
- [ ] Princípios SOLID seguidos?

#### 🐛 Prevenção de Bugs
- [ ] Tratamento de erros adequado?
- [ ] Casos edge considerados?
- [ ] Validações necessárias implementadas?

#### 🔄 Qualidade de Código
- [ ] Nomenclatura clara e consistente?
- [ ] Funções focadas e coesas?
- [ ] Duplicação eliminada?

---

## 📋 Diretrizes de Revisão

<PR_REVIEW_GUIDELINES>

### 🎯 Princípios Fundamentais

#### 1. **Integridade Arquitetural em Primeiro Lugar**

**Separação de Camadas:**
- ✅ **Camada de Superfície**: Apenas roteamento/validação/segurança
- ✅ **Camada de Lógica**: Regras de negócio e operações
- ✅ **Camada de Adaptadores**: Comunicação com recursos externos

**Sinais de Alerta:**
- ❌ Lógica de negócio em endpoints ou adaptadores
- ❌ Chamadas diretas de banco/API externa fora dos adaptadores
- ❌ Responsabilidades misturadas

**Exemplo de Violação:**
```javascript
// ❌ RUIM: Lógica de negócio no endpoint
app.post('/users', (req, res) => {
  const user = req.body;
  // Validação de regra de negócio no endpoint
  if (user.age < 18) {
    return res.status(400).json({error: 'Usuário deve ser maior de idade'});
  }
  // Acesso direto ao banco no endpoint
  db.users.insert(user);
  res.json({success: true});
});

// ✅ BOM: Separação adequada
app.post('/users', userController.create); // Superfície
userService.createUser(userData); // Lógica
userRepository.save(user); // Adaptador
```

#### 2. **Qualidade como Investimento**

**Mentalidade:**
- 💰 Pagar dívida técnica enquanto é barato
- 📈 Celebrar melhorias incrementais
- ⚖️ Balancear perfeccionismo com pragmatismo
- 🔄 Pensar em juros compostos (dívida e qualidade se acumulam)

**Perguntas-chave:**
1. "Esta é a solução mais simples que poderia funcionar?"
2. "Isso segue nossa arquitetura de três camadas?"
3. "Será fácil de mudar quando os requisitos evoluírem?"
4. "Revela intenção (o quê/por quê) não apenas implementação (como)?"

#### 3. **Três Propósitos da Revisão**
1. 🐛 **Capturar bugs** - Funciona corretamente?
2. 🧠 **Compartilhar conhecimento** - Aprender/ensinar padrões
3. 🔄 **Convergir padrões** - Manter consistência

### ✅ Lista de Verificação Prática

#### **Organização do Código**
- [ ] Vocabulário de negócio > vocabulário técnico na nomenclatura
- [ ] Serviços são stateless e focados em operações específicas
- [ ] Adaptadores isolam dependências externas
- [ ] Sem variáveis globais ou DOM como fonte de dados
- [ ] Manipuladores de requisição são enxutos (apenas infraestrutura)

#### **Tratamento de Erros e Observabilidade**
- [ ] Erros inesperados borbulham até manipuladores catch-all
- [ ] Erros de negócio esperados são tratados graciosamente
- [ ] Logging adequado com `loggingAdapter` (não `console.log`)
- [ ] Observabilidade integrada, não adicionada como repensamento

#### **Especificidades JavaScript/Node**
- [ ] Declarações de funções nomeadas preferidas
- [ ] `async/await` > `Promises` > `callbacks`
- [ ] Testes de integração para serviços novos/modificados
- [ ] Tratamento de erros padronizado

#### **Considerações Frontend**
- [ ] Componentes focados em apresentação
- [ ] Serviços lidam com lógica de negócio
- [ ] Acesso ao backend isolado em objetos similares a adaptadores
- [ ] Tratamento de erros padronizado (padrão `ErrorModal`)

### 🚨 Sinais de Alerta

| **Problema** | **Descrição** | **Solução** |
|--------------|---------------|-------------|
| 🔴 **Lógica misturada** | Lógica de negócio em endpoints | Mover para serviços |
| 🔴 **Duplicação** | Código repetido de erro/logging | Extrair para utilitários |
| 🔴 **Acesso direto** | Chamadas diretas DB/API | Usar adaptadores |
| 🔴 **Try-catch complexo** | Blocos que deveriam ser middleware | Refatorar para middleware |
| 🔴 **Carga cognitiva** | Código que aumenta complexidade sem benefício | Simplificar |
| 🔴 **YAGNI** | Soluções procurando problemas | Remover/simplificar |

</PR_REVIEW_GUIDELINES>

---

## 🛠️ Uso de Ferramentas

### GitHub CLI (`gh`)
```bash
# Buscar informações do PR
gh pr view <PR_NUMBER> --repo <OWNER/REPO>

# Ver diff
gh pr diff <PR_NUMBER> --repo <OWNER/REPO>

# Listar arquivos modificados
gh pr diff <PR_NUMBER> --repo <OWNER/REPO> --name-only
```

**⚠️ Importante:** Sempre redirecione a saída para arquivo temporário para evitar quebras.

### Ferramenta ghcat.sh
```bash
# Buscar arquivo específico
tools/ghcat.sh <OWNER/REPO> <CAMINHO_ARQUIVO> [BRANCH]

# Modo verbose para debug
tools/ghcat.sh -v <OWNER/REPO> <CAMINHO_ARQUIVO>

# Validar repositório
tools/ghcat.sh --validate <OWNER/REPO> <CAMINHO_ARQUIVO>
```

---

## 📝 Template de Revisão

```markdown
# Revisão PR #<NUMERO> - <TITULO>

## 📄 Resumo
[Descreva brevemente o que o PR faz em 1-2 frases]

## 🏗️ Análise Arquitetural
- ✅ **Pontos Positivos:** [liste o que está bem]
- ⚠️ **Atenção:** [liste pontos que merecem atenção]
- ❌ **Problemas:** [liste problemas que devem ser corrigidos]

## 🐛 Prevenção de Bugs
[Liste possíveis bugs ou melhorias preventivas]

## 💡 Sugestões de Melhoria

### Arquivo: `src/example.js`
**Linha 42-50:**
```javascript
// ❌ Código atual
if (user.type == 'admin') {
  // lógica
}

// ✅ Sugestão
if (user.type === 'admin') {
  // lógica
}
```

## 🎯 Conclusão
[Resumo final da revisão e recomendação]
```

---

## 💡 Dicas para Revisão Eficaz

### **Foque no Essencial**
1. **Arquitetura** - Está na camada certa?
2. **Bugs** - Pode quebrar em produção?
3. **Manutenibilidade** - Será fácil de mudar?

### **Seja Específico**
- 📍 Referencie números de linha
- 💬 Cite trechos de código
- 🔧 Sugira alternativas com exemplos

### **Mantenha o Tom Construtivo**
- ✅ "Considere extrair esta lógica para um serviço"
- ❌ "Este código está horrível"

### **Lembre-se do Contexto**
- 🎯 O código serve ao negócio
- ⚡ Qualidade permite velocidade
- 🏠 Estamos construindo uma "casa" para habitar

---

## 📂 Salvando a Revisão

```bash
# Salvar revisão estruturada
cat > artifacts/pr_review_<PR_NUMBER>.md << EOF
# Revisão PR #<NUMERO>
[Conteúdo da revisão seguindo o template]
EOF
```

---

> **Lema:** *"Foco na qualidade, sem enrolação."*
> 
> Seja conciso, específico e construtivo. Cada revisão é uma oportunidade de melhorar a qualidade e compartilhar conhecimento.
