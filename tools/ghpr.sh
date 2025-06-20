#!/bin/bash

# ghpr - Ferramenta para buscar informações de Pull Requests do GitHub
# Uso: ghpr URL_DO_PR ou ghpr OWNER/REPO PR_NUMBER
# Dependências: gh (GitHub CLI), curl, jq

set -euo pipefail

# Cores para output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Funções de logging
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1" >&2
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1" >&2
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

log_header() {
    echo -e "${BLUE}[GHPR]${NC} $1" >&2
}

# Verificar dependências
check_dependencies() {
    local missing_deps=()
    
    command -v gh >/dev/null 2>&1 || missing_deps+=("gh")
    command -v curl >/dev/null 2>&1 || missing_deps+=("curl")
    command -v jq >/dev/null 2>&1 || missing_deps+=("jq")
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        log_error "Dependências necessárias não encontradas: ${missing_deps[*]}"
        log_error "Instale-as antes de executar este script."
        exit 1
    fi
}

# Exibir ajuda
display_help() {
    cat << EOF
ghpr - Ferramenta para buscar informações de Pull Requests do GitHub

USO:
    ghpr URL_DO_PR
    ghpr @URL_DO_PR
    ghpr OWNER/REPO PR_NUMBER

ARGUMENTOS:
    URL_DO_PR     URL completa do PR (ex: https://github.com/owner/repo/pull/123)
    @URL_DO_PR    URL com @ no início (ex: @https://github.com/owner/repo/pull/123)
    OWNER/REPO    Repositório no formato 'owner/repo'
    PR_NUMBER     Número do Pull Request

OPÇÕES:
    -h, --help      Exibir esta mensagem de ajuda
    -d, --diff      Exibir diff do PR
    -f, --files     Listar arquivos modificados
    -v, --verbose   Saída detalhada para debug
    -o, --output    Salvar saída em arquivo

EXEMPLOS:
    ghpr https://github.com/microsoft/vscode/pull/123
    ghpr @https://github.com/microsoft/vscode/pull/123
    ghpr microsoft/vscode 123
    ghpr -d microsoft/vscode 123
    ghpr --files --output pr_files.txt owner/repo 456

DEPENDÊNCIAS:
    - gh (GitHub CLI) - para autenticação e acesso à API
    - curl - para requisições HTTP
    - jq - para parsing JSON

NOTAS:
    - Repositórios privados requerem autenticação GitHub CLI (gh auth login)
    - Use -d para ver as mudanças do PR
    - Use -f para listar apenas os arquivos modificados
EOF
}

# Extrair informações da URL do PR
parse_pr_url() {
    local input="$1"
    
    # Remover @ do início se presente
    input="${input#@}"
    
    # Padrão para URL do GitHub PR
    if [[ "$input" =~ ^https://github\.com/([^/]+)/([^/]+)/pull/([0-9]+)/?.*$ ]]; then
        local owner="${BASH_REMATCH[1]}"
        local repo="${BASH_REMATCH[2]}"
        local pr_number="${BASH_REMATCH[3]}"
        
        echo "$owner/$repo $pr_number"
        return 0
    fi
    
    return 1
}

# Validar formato do repositório
validate_repo_format() {
    local repo="$1"
    if [[ ! "$repo" =~ ^[a-zA-Z0-9._-]+/[a-zA-Z0-9._-]+$ ]]; then
        log_error "Formato de repositório inválido: '$repo'"
        log_error "Formato esperado: 'owner/repo'"
        exit 1
    fi
}

# Buscar informações do PR
fetch_pr_info() {
    local repo="$1"
    local pr_number="$2"
    local show_diff="$3"
    local show_files="$4"
    
    log_info "Buscando informações do PR #$pr_number em $repo"
    
    # Verificar se o PR existe
    if ! gh pr view "$pr_number" --repo "$repo" >/dev/null 2>&1; then
        log_error "PR #$pr_number não encontrado no repositório $repo"
        log_error "Verifique se o PR existe e você tem acesso ao repositório"
        exit 1
    fi
    
    log_header "=== INFORMAÇÕES DO PR ==="
    
    # Buscar informações básicas do PR
    gh pr view "$pr_number" --repo "$repo"
    
    if [ "$show_files" -eq 1 ]; then
        echo
        log_header "=== ARQUIVOS MODIFICADOS ==="
        gh pr diff "$pr_number" --repo "$repo" --name-only
    fi
    
    if [ "$show_diff" -eq 1 ]; then
        echo
        log_header "=== DIFF DO PR ==="
        gh pr diff "$pr_number" --repo "$repo"
    fi
}

# Função principal
main() {
    # Verificar dependências
    check_dependencies
    
    # Opções padrão
    local show_diff=0
    local show_files=0
    local verbose=0
    local output_file=""
    
    # Processar opções
    while [[ $# -gt 0 && "$1" =~ ^- ]]; do
        case "$1" in
            -h|--help)
                display_help
                exit 0
                ;;
            -d|--diff)
                show_diff=1
                shift
                ;;
            -f|--files)
                show_files=1
                shift
                ;;
            -v|--verbose)
                verbose=1
                shift
                ;;
            -o|--output)
                output_file="$2"
                shift 2
                ;;
            *)
                log_error "Opção desconhecida: $1"
                display_help
                exit 1
                ;;
        esac
    done
    
    # Verificar argumentos obrigatórios
    if [ $# -lt 1 ]; then
        log_error "Argumentos obrigatórios ausentes"
        display_help
        exit 1
    fi
    
    local repo=""
    local pr_number=""
    
    # Tentar fazer parse da URL primeiro
    if pr_info=$(parse_pr_url "$1"); then
        read -r repo pr_number <<< "$pr_info"
        log_info "URL detectada: $repo PR #$pr_number"
    elif [ $# -eq 2 ]; then
        # Formato: owner/repo pr_number
        repo="$1"
        pr_number="$2"
        validate_repo_format "$repo"
        
        if ! [[ "$pr_number" =~ ^[0-9]+$ ]]; then
            log_error "Número do PR deve ser um número inteiro: '$pr_number'"
            exit 1
        fi
    else
        log_error "Formato de argumentos inválido"
        log_error "Use: ghpr URL_DO_PR ou ghpr OWNER/REPO PR_NUMBER"
        display_help
        exit 1
    fi
    
    # Debug output se verbose
    if [ "$verbose" -eq 1 ]; then
        log_info "Repo: $repo"
        log_info "PR: $pr_number"
        log_info "Show diff: $show_diff"
        log_info "Show files: $show_files"
        log_info "Output file: ${output_file:-"(stdout)"}"
    fi
    
    # Buscar informações do PR
    if [ -n "$output_file" ]; then
        fetch_pr_info "$repo" "$pr_number" "$show_diff" "$show_files" > "$output_file"
        log_info "Saída salva em: $output_file"
    else
        fetch_pr_info "$repo" "$pr_number" "$show_diff" "$show_files"
    fi
}

# Executar função principal se script for chamado diretamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi 