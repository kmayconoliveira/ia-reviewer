# install-windows.ps1 - Script de instalação para Windows
# Execute com: PowerShell -ExecutionPolicy Bypass -File install-windows.ps1

Write-Host "🤖 IA Reviewer - Instalação Windows" -ForegroundColor Green
Write-Host "=================================" -ForegroundColor Green
Write-Host ""

# Função para verificar se um comando existe
function Test-CommandExists {
    param($command)
    $null = Get-Command $command -ErrorAction SilentlyContinue
    return $?
}

# Função para instalar via WinGet
function Install-WithWinGet {
    param($package, $name)
    Write-Host "📦 Instalando $name via WinGet..." -ForegroundColor Yellow
    try {
        winget install $package --accept-source-agreements --accept-package-agreements
        Write-Host "✅ $name instalado com sucesso!" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "❌ Erro ao instalar $name via WinGet" -ForegroundColor Red
        return $false
    }
}

# Verificar se o WinGet está disponível
if (-not (Test-CommandExists "winget")) {
    Write-Host "❌ WinGet não encontrado. Atualize o Windows ou instale manualmente." -ForegroundColor Red
    Write-Host "   Acesse: https://github.com/microsoft/winget-cli/releases" -ForegroundColor Yellow
    exit 1
}

Write-Host "🔍 Verificando dependências..." -ForegroundColor Blue

# Verificar e instalar GitHub CLI
if (Test-CommandExists "gh") {
    Write-Host "✅ GitHub CLI já instalado" -ForegroundColor Green
} else {
    Install-WithWinGet "GitHub.cli" "GitHub CLI"
}

# Verificar e instalar jq
if (Test-CommandExists "jq") {
    Write-Host "✅ jq já instalado" -ForegroundColor Green
} else {
    Install-WithWinGet "jqlang.jq" "jq"
}

# Verificar curl
if (Test-CommandExists "curl") {
    Write-Host "✅ curl já disponível" -ForegroundColor Green
} else {
    Write-Host "⚠️  curl não encontrado, instalando..." -ForegroundColor Yellow
    Install-WithWinGet "curl.curl" "curl"
}

# Verificar base64 (normalmente disponível como certutil)
if (Test-CommandExists "certutil") {
    Write-Host "✅ base64 (certutil) disponível" -ForegroundColor Green
} else {
    Write-Host "⚠️  Funcionalidade base64 pode não estar disponível" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "🎉 Instalação concluída!" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Próximos passos:" -ForegroundColor Blue
Write-Host "1. Feche e reabra o PowerShell/Terminal" -ForegroundColor White
Write-Host "2. Autentique com GitHub: gh auth login" -ForegroundColor White
Write-Host "3. Teste a instalação: gh --version" -ForegroundColor White
Write-Host "4. Execute o setup: .\setup.sh" -ForegroundColor White
Write-Host ""
Write-Host "🔧 Para usar o Bash no Windows:" -ForegroundColor Blue
Write-Host "   - Instale Git Bash: winget install Git.Git" -ForegroundColor White
Write-Host "   - Ou use WSL: wsl --install" -ForegroundColor White 