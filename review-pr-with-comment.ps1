#!/usr/bin/env pwsh

# review-pr-with-comment.ps1 - Script para análise e comentário automático de PRs
# Uso: review-pr-with-comment.ps1 URL_DO_PR [--detailed] [--auto-comment] [--draft-comment]

param(
    [Parameter(Position=0)]
    [string]$PrUrl,
    [switch]$Detailed,
    [switch]$AutoComment,  # Comentar automaticamente após análise
    [switch]$DraftComment, # Criar comentário como draft
    [switch]$ForceComment, # Comentar sem confirmação (não-interativo)
    [switch]$Verbose,
    [string]$Output,
    [switch]$Help
)

if ($Help) {
    @"
review-pr-with-comment.ps1 - Análise completa + comentário automático

USO:
    review-pr-with-comment.ps1 URL_DO_PR                           # Só análise
    review-pr-with-comment.ps1 URL_DO_PR --auto-comment            # Análise + pergunta se quer comentar
    review-pr-with-comment.ps1 URL_DO_PR --detailed --auto-comment # Análise detalhada + pergunta se quer comentar
    review-pr-with-comment.ps1 URL_DO_PR --auto-comment --force-comment # Análise + comentário direto (sem pergunta)

PARÂMETROS:
    URL_DO_PR       URL completa do PR no GitHub
    --detailed      Usar análise detalhada (ai-pr-reviewer.ps1)
    --auto-comment  Mostrar opção de comentário (com confirmação)
    --force-comment Comentar diretamente sem confirmação
    --draft-comment Criar comentário como draft/pendente
    --verbose       Mostrar informações detalhadas
    --output        Salvar análise em arquivo
    --help          Mostrar esta ajuda

EXEMPLOS:
    # Análise simples
    review-pr-with-comment.ps1 "https://github.com/owner/repo/pull/123"
    
    # Análise + comentário automático
    review-pr-with-comment.ps1 "https://github.com/owner/repo/pull/123" --auto-comment
    
    # Análise detalhada + comentário draft
    review-pr-with-comment.ps1 "https://github.com/owner/repo/pull/123" --detailed --auto-comment --draft-comment

DEPENDÊNCIAS:
    - GitHub CLI (gh) - instalar com: winget install --id GitHub.cli
    - Autenticação: gh auth login
    - Scripts: review-pr.ps1, quick-review.ps1, ai-pr-reviewer.ps1, tools/gh-comment.ps1
"@
    exit 0
}

# Verificar se URL foi fornecida
if (-not $PrUrl) {
    Write-Host "[ERROR] URL do PR é obrigatória!" -ForegroundColor Red
    Write-Host "Use: review-pr-with-comment.ps1 'URL_DO_PR' ou review-pr-with-comment.ps1 -Help" -ForegroundColor Yellow
    exit 1
}

# Funções auxiliares
function Write-Info {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Blue
}

function Write-Success {
    param([string]$Message)
    Write-Host "[SUCCESS] $Message" -ForegroundColor Green
}

function Write-Error {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

function Write-Header {
    param([string]$Message)
    Write-Host ""
    Write-Host "=== $Message ===" -ForegroundColor Cyan
    Write-Host ""
}

# Extrair informações do PR
function Get-PrInfoFromUrl {
    param([string]$InputUrl)
    
    $InputUrl = $InputUrl -replace '^@', ''
    
    if ($InputUrl -match '^https://github\.com/([^/]+)/([^/]+)/pull/(\d+)/?.*$') {
        return @{
            Owner = $Matches[1]
            Repo = $Matches[2]
            Number = [int]$Matches[3]
            FullRepo = "$($Matches[1])/$($Matches[2])"
            Url = $InputUrl
        }
    }
    
    return $null
}

# Capturar saída da análise
function Invoke-PrAnalysis {
    param([string]$PrUrl, [bool]$UseDetailed)
    
    Write-Header "Executando Análise de PR"
    
    $originalOutput = $Host.UI.RawUI.BufferSize
    
    if ($UseDetailed) {
        Write-Info "Usando análise detalhada..."
        $analysisOutput = & "$PSScriptRoot\ai-pr-reviewer.ps1" -Url $PrUrl 2>&1 | Out-String
    } else {
        Write-Info "Usando análise rápida..."
        $analysisOutput = & "$PSScriptRoot\quick-review.ps1" $PrUrl 2>&1 | Out-String
    }
    
    return $analysisOutput
}

# Gerar comentário formatado para GitHub
function New-CommentFromAnalysis {
    param([string]$AnalysisOutput, [hashtable]$PrInfo)
    
    $timestamp = Get-Date -Format "dd/MM/yyyy HH:mm"
    
    # Analisar o resultado para determinar status
    $status = "✅ APROVADO"
    $statusColor = "brightgreen"
    
    if ($AnalysisOutput -match "REQUER ATENÇÃO|WARNING|ATENÇÃO") {
        $status = "⚠️ REQUER ATENÇÃO"
        $statusColor = "yellow" 
    }
    
    if ($AnalysisOutput -match "REVISÃO CUIDADOSA|PROBLEMA|ERROR|CRÍTICO") {
        $status = "❌ REQUER CORREÇÃO"
        $statusColor = "red"
    }
    
    $comment = @"
## 🤖 Análise Automática de PR

> **Status:** $status  
> **Analisado em:** $timestamp  
> **Ferramenta:** IA Reviewer v2.0

### 📊 Informações da PR
- **Repositório:** \`$($PrInfo.FullRepo)\`
- **PR:** [#$($PrInfo.Number)]($($PrInfo.Url))
- **Status:** ![Status](https://img.shields.io/badge/Status-$(if($statusColor -eq 'brightgreen'){'Aprovado'}elseif($statusColor -eq 'yellow'){'Atenção'}else{'Correção'})-$statusColor)

---

### 📋 Resultado da Análise

``````
$AnalysisOutput
``````

---

### 📝 Interpretação dos Resultados

| Símbolo | Significado | Ação Recomendada |
|---------|-------------|-------------------|
| ✅ | **Aprovado** | Pode prosseguir com merge |
| ⚠️ | **Atenção** | Revisar pontos destacados |
| ❌ | **Bloqueio** | Corrigir antes do merge |

### 🔧 Próximos Passos

#### Se **Aprovado** ✅
- [ ] Executar testes finais
- [ ] Solicitar aprovação da equipe
- [ ] Realizar merge

#### Se **Requer Atenção** ⚠️
- [ ] Revisar pontos destacados na análise
- [ ] Considerar melhorias sugeridas
- [ ] Re-executar testes se necessário

#### Se **Requer Correção** ❌
- [ ] **Não fazer merge** até correções
- [ ] Implementar correções obrigatórias
- [ ] Re-submeter para nova análise

---

### 🔄 Re-análise

Para uma nova análise após correções, execute:
``````bash
# Análise rápida
./quick-review.ps1 "$($PrInfo.Url)"

# Análise completa
./review-pr-with-comment.ps1 "$($PrInfo.Url)" --detailed --auto-comment
``````

---

<details>
<summary>ℹ️ Sobre esta análise</summary>

- **Ferramenta:** IA Reviewer - Sistema automatizado de análise de PRs
- **Timestamp:** $timestamp
- **Versão:** 2.0
- **Repositório da ferramenta:** [ia-reviewer](https://github.com/seu-usuario/ia-reviewer)

Esta análise foi gerada automaticamente. Para dúvidas:
- 📧 Contate a equipe de desenvolvimento
- 🐛 Reporte problemas da ferramenta
- 📖 Consulte a documentação

</details>
"@

    return $comment
}

# Script principal
Write-Header "🤖 IA Reviewer - Análise + Comentário Automático"

# Limpar URL
$PrUrl = $PrUrl -replace '^@', ''
Write-Info "URL: $PrUrl"

# Verificar dependências básicas
if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-Error "GitHub CLI não encontrado!"
    Write-Error "Instale com: winget install --id GitHub.cli"
    exit 1
}

# Extrair informações do PR
$prInfo = Get-PrInfoFromUrl -InputUrl $PrUrl
if (-not $prInfo) {
    Write-Error "URL inválida: $PrUrl"
    Write-Error "Formato esperado: https://github.com/owner/repo/pull/123"
    exit 1
}

Write-Info "PR identificado: #$($prInfo.Number) em $($prInfo.FullRepo)"

# FASE 1: Executar análise
try {
    $analysisResult = Invoke-PrAnalysis -PrUrl $PrUrl -UseDetailed $Detailed
    
    # Mostrar resultado da análise
    Write-Host $analysisResult
    
    Write-Success "Análise concluída com sucesso!"
    
} catch {
    Write-Error "Erro na análise: $($_.Exception.Message)"
    exit 1
}

# FASE 2: Comentário automático (se solicitado)
if ($AutoComment) {
    Write-Header "Opção de Comentário Automático"
    
    # Verificar se script de comentário existe
    $commentScript = "$PSScriptRoot\tools\gh-comment.ps1"
    if (-not (Test-Path $commentScript)) {
        Write-Error "Script de comentário não encontrado: $commentScript"
        Write-Error "Certifique-se de que tools/gh-comment.ps1 existe"
        exit 1
    }
    
    try {
        # Gerar comentário formatado
        $commentText = New-CommentFromAnalysis -AnalysisOutput $analysisResult -PrInfo $prInfo
        
        # Mostrar preview do comentário
        Write-Host ""
        Write-Host "📝 PREVIEW DO COMENTÁRIO:" -ForegroundColor Cyan
        Write-Host "========================" -ForegroundColor Cyan
        Write-Host $commentText -ForegroundColor Gray
        Write-Host "========================" -ForegroundColor Cyan
        Write-Host ""
        
        # Determinar se deve perguntar ou comentar diretamente
        if ($ForceComment) {
            Write-Info "🚀 Modo força ativado - comentando diretamente..."
            $response = "S"
        } else {
            # Pergunta de confirmação
            Write-Host "❓ Deseja comentar automaticamente nesta PR?" -ForegroundColor Yellow
            Write-Host "   URL: $($prInfo.Url)" -ForegroundColor Gray
            Write-Host ""
            Write-Host "Opções:" -ForegroundColor Blue
            Write-Host "  [S] Sim - Comentar agora" -ForegroundColor Green
            Write-Host "  [D] Draft - Comentar como rascunho" -ForegroundColor Yellow
            Write-Host "  [N] Não - Pular comentário" -ForegroundColor Red
            Write-Host ""
            
            $response = Read-Host "Digite sua escolha (S/D/N)"
        }
        
        switch ($response.ToUpper()) {
            "S" {
                Write-Info "✅ Usuário confirmou - criando comentário..."
                
                $commentParams = @(
                    "-PrUrl", $PrUrl,
                    "-CommentText", $commentText
                )
                
                if ($Verbose) {
                    $commentParams += "-Verbose"
                }
                
                # Executar comentário
                & $commentScript @commentParams
                
                Write-Success "Comentário criado no PR!"
                Write-Success "Confira em: $($prInfo.Url)"
            }
            
            "D" {
                Write-Info "📝 Usuário escolheu draft - criando comentário como rascunho..."
                
                $commentParams = @(
                    "-PrUrl", $PrUrl,
                    "-CommentText", $commentText,
                    "-Draft"
                )
                
                if ($Verbose) {
                    $commentParams += "-Verbose"
                }
                
                # Executar comentário como draft
                & $commentScript @commentParams
                
                Write-Success "Comentário draft criado no PR!"
                Write-Success "Confira e publique em: $($prInfo.Url)"
            }
            
            "N" {
                Write-Info "❌ Usuário cancelou - pulando comentário"
                Write-Info "A análise foi concluída, mas o comentário foi cancelado pelo usuário"
            }
            
            default {
                Write-Warning "Opção inválida '$response' - pulando comentário"
                Write-Info "Use S (Sim), D (Draft) ou N (Não)"
            }
        }
        
    } catch {
        Write-Error "Erro ao processar comentário: $($_.Exception.Message)"
        Write-Error "A análise foi concluída, mas houve problema com o comentário"
        exit 1
    }
}

# Salvar em arquivo se solicitado
if ($Output) {
    Write-Header "Salvando Resultado"
    try {
        $analysisResult | Out-File -FilePath $Output -Encoding UTF8
        Write-Success "Análise salva em: $Output"
    } catch {
        Write-Error "Erro ao salvar arquivo: $($_.Exception.Message)"
    }
}

Write-Host ""
Write-Host "✅ Processo completo finalizado!" -ForegroundColor Green
Write-Host "📝 Análise executada | 💬 Comentário $(if ($AutoComment) { 'criado' } else { 'não solicitado' })" -ForegroundColor Gray 