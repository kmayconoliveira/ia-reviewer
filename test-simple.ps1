# test-simple.ps1 - Teste simples de dependências

Write-Host "🧪 IA Reviewer - Teste de Dependências" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Green
Write-Host ""

# Testar GitHub CLI
Write-Host "🔍 Testando GitHub CLI..." -NoNewline
try {
    $ghVersion = gh --version 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host " ✅ OK" -ForegroundColor Green
        Write-Host "   Versão: $($ghVersion[0])" -ForegroundColor Gray
    } else {
        Write-Host " ❌ ERRO" -ForegroundColor Red
        Write-Host "   Execute: winget install GitHub.cli" -ForegroundColor Yellow
    }
} catch {
    Write-Host " ❌ NÃO ENCONTRADO" -ForegroundColor Red
    Write-Host "   Execute: winget install GitHub.cli" -ForegroundColor Yellow
}

# Testar jq
Write-Host "🔍 Testando jq..." -NoNewline
try {
    $jqVersion = jq --version 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host " ✅ OK" -ForegroundColor Green
        Write-Host "   Versão: $jqVersion" -ForegroundColor Gray
    } else {
        Write-Host " ❌ ERRO" -ForegroundColor Red
        Write-Host "   Execute: winget install jqlang.jq" -ForegroundColor Yellow
    }
} catch {
    Write-Host " ❌ NÃO ENCONTRADO" -ForegroundColor Red
    Write-Host "   Execute: winget install jqlang.jq" -ForegroundColor Yellow
}

# Testar curl
Write-Host "🔍 Testando curl..." -NoNewline
try {
    $curlVersion = curl --version 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host " ✅ OK" -ForegroundColor Green
        Write-Host "   Versão: $($curlVersion[0])" -ForegroundColor Gray
    } else {
        Write-Host " ❌ ERRO" -ForegroundColor Red
        Write-Host "   Execute: winget install curl.curl" -ForegroundColor Yellow
    }
} catch {
    Write-Host " ❌ NÃO ENCONTRADO" -ForegroundColor Red
    Write-Host "   Execute: winget install curl.curl" -ForegroundColor Yellow
}

# Testar Git
Write-Host "🔍 Testando Git..." -NoNewline
try {
    $gitVersion = git --version 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host " ✅ OK" -ForegroundColor Green
        Write-Host "   Versão: $gitVersion" -ForegroundColor Gray
    } else {
        Write-Host " ❌ ERRO" -ForegroundColor Red
        Write-Host "   Execute: winget install Git.Git" -ForegroundColor Yellow
    }
} catch {
    Write-Host " ❌ NÃO ENCONTRADO" -ForegroundColor Red
    Write-Host "   Execute: winget install Git.Git" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "🌐 Testando autenticação GitHub..." -NoNewline
try {
    $authStatus = gh auth status 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host " ✅ AUTENTICADO" -ForegroundColor Green
    } else {
        Write-Host " ⚠️  NÃO AUTENTICADO" -ForegroundColor Yellow
        Write-Host "   Execute: gh auth login" -ForegroundColor Yellow
    }
} catch {
    Write-Host " ❌ ERRO" -ForegroundColor Red
}

Write-Host ""
Write-Host "📁 Testando script do projeto..." -NoNewline
if (Test-Path "tools/ghcat.sh") {
    Write-Host " ✅ ARQUIVO EXISTE" -ForegroundColor Green
    
    # Testar se Git Bash está disponível
    if (Test-Path "C:\Program Files\Git\bin\bash.exe") {
        Write-Host "🔍 Testando execução do script..." -NoNewline
        try {
            $result = & "C:\Program Files\Git\bin\bash.exe" -c "./tools/ghcat.sh --help" 2>$null
            if ($LASTEXITCODE -eq 0) {
                Write-Host " ✅ OK" -ForegroundColor Green
            } else {
                Write-Host " ❌ ERRO NA EXECUÇÃO" -ForegroundColor Red
            }
        } catch {
            Write-Host " ❌ ERRO" -ForegroundColor Red
        }
    } else {
        Write-Host "⚠️  Git Bash não encontrado" -ForegroundColor Yellow
        Write-Host "   Execute: winget install Git.Git" -ForegroundColor Yellow
    }
} else {
    Write-Host " ❌ ARQUIVO NÃO ENCONTRADO" -ForegroundColor Red
}

Write-Host ""
Write-Host "=" * 50 -ForegroundColor Gray
Write-Host "📋 RESUMO:" -ForegroundColor Cyan
Write-Host ""
Write-Host "Para instalar tudo de uma vez:" -ForegroundColor Yellow
Write-Host "winget install GitHub.cli jqlang.jq Git.Git" -ForegroundColor White
Write-Host ""
Write-Host "Depois execute:" -ForegroundColor Yellow
Write-Host "gh auth login" -ForegroundColor White
Write-Host "" 