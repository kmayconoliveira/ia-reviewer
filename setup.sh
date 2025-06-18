#!/bin/bash

# setup.sh - Script de configuração inicial do IA Reviewer
# Este script configura o ambiente e verifica dependências

set -euo pipefail

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

# Detect OS
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "linux"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos" 
    elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
        echo "windows"
    else
        echo "unknown"
    fi
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Install dependencies based on OS
install_dependencies() {
    local os="$1"
    
    log_step "Verificando dependências..."
    
    # Check GitHub CLI
    if ! command_exists gh; then
        log_warn "GitHub CLI (gh) não encontrado. Instalando..."
        case "$os" in
            "linux")
                log_info "Instalando GitHub CLI no Linux..."
                curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
                echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
                sudo apt update
                sudo apt install -y gh
                ;;
            "macos")
                log_info "Instalando GitHub CLI no macOS..."
                if command_exists brew; then
                    brew install gh
                else
                    log_error "Homebrew não encontrado. Instale o Homebrew primeiro: https://brew.sh/"
                    exit 1
                fi
                ;;
            "windows")
                log_info "No Windows, instale o GitHub CLI com: winget install GitHub.cli"
                log_warn "Execute este comando manualmente e rode o script novamente."
                exit 1
                ;;
        esac
    else
        log_info "✓ GitHub CLI encontrado"
    fi
    
    # Check curl
    if ! command_exists curl; then
        log_warn "curl não encontrado. Instalando..."
        case "$os" in
            "linux")
                sudo apt install -y curl
                ;;
            "macos")
                log_info "curl já deveria estar disponível no macOS"
                ;;
        esac
    else
        log_info "✓ curl encontrado"
    fi
    
    # Check jq
    if ! command_exists jq; then
        log_warn "jq não encontrado. Instalando..."
        case "$os" in
            "linux")
                sudo apt install -y jq
                ;;
            "macos")
                if command_exists brew; then
                    brew install jq
                else
                    log_error "Homebrew não encontrado"
                    exit 1
                fi
                ;;
            "windows")
                log_info "No Windows, instale jq manualmente ou use chocolatey: choco install jq"
                ;;
        esac
    else
        log_info "✓ jq encontrado"
    fi
    
    # Check base64
    if ! command_exists base64; then
        log_warn "base64 não encontrado"
        case "$os" in
            "linux")
                sudo apt install -y coreutils
                ;;
            "macos")
                log_info "base64 já deveria estar disponível no macOS"
                ;;
            "windows")
                log_info "base64 já deveria estar disponível no Windows moderno"
                ;;
        esac
    else
        log_info "✓ base64 encontrado"
    fi
}

# Setup project structure
setup_project() {
    log_step "Configurando estrutura do projeto..."
    
    # Create artifacts directory
    if [ ! -d "artifacts" ]; then
        mkdir -p artifacts
        log_info "✓ Diretório artifacts/ criado"
    else
        log_info "✓ Diretório artifacts/ já existe"
    fi
    
    # Make ghcat.sh executable
    if [ -f "tools/ghcat.sh" ]; then
        chmod +x tools/ghcat.sh
        log_info "✓ tools/ghcat.sh tornado executável"
    else
        log_error "Arquivo tools/ghcat.sh não encontrado"
        exit 1
    fi
}

# Test installation
test_installation() {
    log_step "Testando instalação..."
    
    # Test ghcat.sh
    if ./tools/ghcat.sh --help >/dev/null 2>&1; then
        log_info "✓ ghcat.sh funcionando corretamente"
    else
        log_error "Erro ao executar ghcat.sh"
        exit 1
    fi
    
    # Test GitHub CLI authentication
    if gh auth status >/dev/null 2>&1; then
        log_info "✓ GitHub CLI autenticado"
    else
        log_warn "GitHub CLI não está autenticado"
        log_info "Execute: gh auth login"
    fi
}

# Main setup function
main() {
    echo "🤖 IA Reviewer - Setup"
    echo "===================="
    echo
    
    # Detect OS
    local os
    os=$(detect_os)
    log_info "Sistema operacional detectado: $os"
    
    # Install dependencies
    install_dependencies "$os"
    
    # Setup project
    setup_project
    
    # Test installation
    test_installation
    
    echo
    log_info "🎉 Setup concluído com sucesso!"
    echo
    log_info "Próximos passos:"
    log_info "1. Autentique com GitHub (se necessário): gh auth login"
    log_info "2. Teste o projeto: ./tools/ghcat.sh --help"
    log_info "3. Leia a documentação: cat README.md"
    echo
    log_info "Para revisar um PR, use os guias em ai_review_pt.md ou ai_review_en.md"
}

# Run main function
main "$@" 