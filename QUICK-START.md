# ⚡ Quick Start - IA Reviewer

> **Objetivo**: Fazer você usar o IA Reviewer em menos de 2 minutos!

## 🚀 Demonstração Instantânea

### Opção 1: Script Automático (RECOMENDADO)

**Windows (PowerShell):**
```powershell
# Execute e veja a mágica acontecer
.\demo.ps1
```

**Linux/Mac (Bash):**
```bash
# Execute e veja a mágica acontecer
chmod +x demo.sh && ./demo.sh
```

### Opção 2: Comando Manual
```bash
# Analise uma PR real em 1 comando
gh pr view 251854 --repo microsoft/vscode
```

### Opção 3: No Cursor Chat
1. Abra este projeto no Cursor (Ctrl+O)
2. Abra o Chat (Ctrl+L)
3. Cole este prompt:

```
Analise esta PR usando os guias do IA Reviewer:

PR: @https://github.com/microsoft/vscode/pull/251854

Use os critérios de ai_review_pt.md para fazer análise completa.
Salve em artifacts/minha_analise.md
```

## 📋 Setup (só se necessário)

Se os scripts de demo não funcionarem:

```bash
# 1. Instalar GitHub CLI
winget install GitHub.cli

# 2. Autenticar
gh auth login

# 3. Testar
gh --version
```

## 🎯 Próximos Passos

Após ver a demo funcionando:

1. **Use com suas PRs:**
   ```bash
   gh pr view <NUMERO> --repo <SEU-OWNER/REPO>
   ```

2. **No Cursor Chat:**
   ```
   Analise @https://github.com/seu-org/seu-repo/pull/123
   ```

3. **Leia os guias:**
   - `ai_review_pt.md` - Critérios de revisão (português)
   - `ai_review_en.md` - Review criteria (english)

## 📁 Onde Encontrar Resultados

- **Scripts de demo**: `artifacts/demo_pr_info.txt`
- **Análises do Cursor**: `artifacts/pr_review_*.md`  
- **Exemplo completo**: `artifacts/exemplo_analise_pr_vscode.md`

## 🆘 Troubleshooting Rápido

| **Erro** | **Solução** |
|----------|-------------|
| `gh: command not found` | `winget install GitHub.cli` |
| `gh auth required` | `gh auth login` |
| `PR not found` | Use número de PR que existe |
| `Permission denied` | `chmod +x demo.sh` (Linux/Mac) |

## 💡 Dica de Ouro

**Para impressionar colegas:**
1. Abra uma PR da sua equipe
2. Execute: `gh pr view <NUMERO> --repo <OWNER/REPO>`
3. Cole resultado no Cursor Chat com: "Analise usando ai_review_pt.md"
4. Compartilhe análise estruturada em < 30 segundos! 🎉

---

> **Próximo passo**: Experimente com uma PR real da sua equipe e veja como transforma análise manual de horas em análise automatizada de minutos! 