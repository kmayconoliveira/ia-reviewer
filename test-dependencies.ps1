# test-dependencies.ps1 - Testa se todas as dependências estão instaladas
# Execute com: PowerShell -ExecutionPolicy Bypass -File test-dependencies.ps1

Write-Host "🧪 IA Reviewer - Teste de Dependências" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Green
Write-Host ""

# Função para testar comando
function Test-Dependency {
    param(
        [string]$Command,
        [string]$Name,
        [string]$VersionFlag = "--version",
        [string]$ExpectedOutput = ""
    )
    
    Write-Host "🔍 Testando $Name..." -ForegroundColor Blue -NoNewline
    
    try {
        if ($VersionFlag -eq "special") {
            # Casos especiais
            switch ($Command) {
                "certutil" {
                    $result = certutil -? 2>$null
                    if ($LASTEXITCODE -eq 0) {
                        Write-Host " ✅ OK" -ForegroundColor Green
                        return $true
                    }
                }
            }
        } else {
            # Teste padrão com --version
            $result = & $Command $VersionFlag 2>$null
            if ($LASTEXITCODE -eq 0) {
                Write-Host " ✅ OK" -ForegroundColor Green
                Write-Host "   📝 Versão: $($result | Select-Object -First 1)" -ForegroundColor Gray
                return $true
            }
        }
    }
    catch {
        # Comando não encontrado
    }
    
    Write-Host " ❌ ERRO" -ForegroundColor Red
    Write-Host "   💡 Execute: winget install $ExpectedOutput" -ForegroundColor Yellow
    return $false
}

# Função para testar script personalizado
function Test-CustomScript {
    param([string]$ScriptPath, [string]$Name)
    
    Write-Host "🔍 Testando $Name..." -ForegroundColor Blue -NoNewline
    
    if (Test-Path $ScriptPath) {
        try {
            if ($ScriptPath.EndsWith(".sh")) {
                # Tentar com Git Bash primeiro
                if (Test-Path "C:\Program Files\Git\bin\bash.exe") {
                    $result = & "C:\Program Files\Git\bin\bash.exe" -c "$ScriptPath --help" 2>$null
                } else {
                    Write-Host " ⚠️  Git Bash não encontrado" -ForegroundColor Yellow
                    return $false
                }
            } else {
                $result = & $ScriptPath --help 2>$null
            }
            
            if ($LASTEXITCODE -eq 0) {
                Write-Host " ✅ OK" -ForegroundColor Green
                return $true
            }
        }
        catch {
            # Erro na execução
        }
    }
    
    Write-Host " ❌ ERRO" -ForegroundColor Red
    return $false
}

Write-Host "📋 Testando dependências básicas:" -ForegroundColor Cyan
Write-Host ""

# Testar dependências principais
$dependencies = @(
    @{Name="GitHub CLI"; Command="gh"; Package="GitHub.cli"},
    @{Name="jq (JSON processor)"; Command="jq"; Package="jqlang.jq"},
    @{Name="curl"; Command="curl"; Package="curl.curl"},
    @{Name="Git"; Command="git"; Package="Git.Git"}
)

$allOk = $true
foreach ($dep in $dependencies) {
    $result = Test-Dependency -Command $dep.Command -Name $dep.Name -ExpectedOutput $dep.Package
    if (-not $result) { $allOk = $false }
}

Write-Host ""
Write-Host "🔧 Testando utilitários do sistema:" -ForegroundColor Cyan
Write-Host ""

# Testar base64 (usando certutil no Windows)
$base64Ok = Test-Dependency -Command "certutil" -Name "base64 (certutil)" -VersionFlag "special"
if (-not $base64Ok) { $allOk = $false }

Write-Host ""
Write-Host "📁 Testando scripts do projeto:" -ForegroundColor Cyan
Write-Host ""

# Testar scripts do projeto
$scriptOk = Test-CustomScript -ScriptPath "tools/ghcat.sh" -Name "ghcat.sh"
if (-not $scriptOk) { $allOk = $false }

Write-Host ""
Write-Host "🌐 Testando autenticação GitHub:" -ForegroundColor Cyan
Write-Host ""

Write-Host "🔍 Testando autenticação GitHub..." -ForegroundColor Blue -NoNewline
try {
    $authResult = gh auth status 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host " ✅ OK" -ForegroundColor Green
        Write-Host "   📝 $($authResult | Select-Object -First 1)" -ForegroundColor Gray
    } else {
        Write-Host " ⚠️  Não autenticado" -ForegroundColor Yellow
        Write-Host "   💡 Execute: gh auth login" -ForegroundColor Yellow
        $allOk = $false
    }
}
catch {
    Write-Host " ❌ ERRO" -ForegroundColor Red
    $allOk = $false
}

Write-Host ""
Write-Host "🧪 Testando funcionalidade completa:" -ForegroundColor Cyan
Write-Host ""

Write-Host "🔍 Testando busca de arquivo público..." -ForegroundColor Blue -NoNewline
try {
    # Testar com um repositório público pequeno
    if (Test-Path "C:\Program Files\Git\bin\bash.exe") {
        $testResult = & "C:\Program Files\Git\bin\bash.exe" -c "./tools/ghcat.sh microsoft/vscode README.md" 2>$null | Select-Object -First 5
        if ($testResult -and $testResult.Length -gt 0) {
            Write-Host " ✅ OK" -ForegroundColor Green
            Write-Host "   📝 Conseguiu buscar README do VSCode" -ForegroundColor Gray
        } else {
            Write-Host " ❌ ERRO" -ForegroundColor Red
            $allOk = $false
        }
    } else {
        Write-Host " ⚠️  Git Bash necessário" -ForegroundColor Yellow
        $allOk = $false
    }
}
catch {
    Write-Host " ❌ ERRO" -ForegroundColor Red
    Write-Host "   💡 Verifique se todas as dependências estão instaladas" -ForegroundColor Yellow
    $allOk = $false
}

Write-Host ""
Write-Host "=" * 50 -ForegroundColor Gray

if ($allOk) {
    Write-Host "🎉 SUCESSO! Todas as dependências estão funcionando!" -ForegroundColor Green
    Write-Host ""
    Write-Host "✅ Próximos passos:" -ForegroundColor Blue
    Write-Host "   1. Use: ./tools/ghcat.sh owner/repo file.txt" -ForegroundColor White
    Write-Host "   2. Leia os guias: ai_review_pt.md ou ai_review_en.md" -ForegroundColor White
    Write-Host "   3. Execute: gh pr view NUMERO --repo owner/repo" -ForegroundColor White
} else {
    Write-Host "❌ Algumas dependências estão faltando!" -ForegroundColor Red
    Write-Host ""
    Write-Host "🔧 Para corrigir:" -ForegroundColor Blue
    Write-Host "   1. Execute: .\install-windows.ps1" -ForegroundColor White
    Write-Host "   2. Reinicie o terminal" -ForegroundColor White  
    Write-Host "   3. Execute: gh auth login" -ForegroundColor White
    Write-Host "   4. Teste novamente: .\test-dependencies.ps1" -ForegroundColor White
}

Write-Host "" 