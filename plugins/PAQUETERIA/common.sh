#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="${PAQUETERIA_PROJECT_DIR:-$HOME/paqueteria}"
DEPLOY_DIR="$PROJECT_DIR/SCRIPTS/deployment"

INFO_COLOR="\033[0;34m"
SUCCESS_COLOR="\033[0;32m"
WARN_COLOR="\033[0;33m"
ERROR_COLOR="\033[0;31m"
RESET_COLOR="\033[0m"

info() { echo -e "${INFO_COLOR}[INFO]${RESET_COLOR} $1"; }
success() { echo -e "${SUCCESS_COLOR}[EXITO]${RESET_COLOR} $1"; }
warning() { echo -e "${WARN_COLOR}[AVISO]${RESET_COLOR} $1"; }
error() { echo -e "${ERROR_COLOR}[ERROR]${RESET_COLOR} $1" >&2; }

require_project_dir() {
    if [[ ! -d "$PROJECT_DIR" ]]; then
        error "No se encontró el directorio del proyecto: $PROJECT_DIR"
        exit 1
    fi
}

require_deployment_script() {
    local script_name="$1"
    local target="$DEPLOY_DIR/$script_name"

    if [[ ! -x "$target" ]]; then
        if [[ -f "$target" ]]; then
            chmod +x "$target" 2>/dev/null || true
        fi
    fi

    if [[ ! -x "$target" ]]; then
        error "No se encontró o no es ejecutable: $target"
        exit 1
    fi
}

run_deployment_script() {
    local script_name="$1"
    shift || true

    require_project_dir
    require_deployment_script "$script_name"

    ( cd "$PROJECT_DIR" && "$DEPLOY_DIR/$script_name" "$@" )
}

run_deployment_script_sudo() {
    local script_name="$1"
    shift || true

    require_project_dir
    require_deployment_script "$script_name"

    local quoted_args=""
    if [[ $# -gt 0 ]]; then
        local arg
        for arg in "$@"; do
            quoted_args+=" $(printf '%q' "$arg")"
        done
    fi

    sudo bash -c "cd '$PROJECT_DIR' && '$DEPLOY_DIR/$script_name'$quoted_args"
}

prompt_optional_value() {
    local prompt_message="$1"
    local default_value="$2"
    local input

    read -r -p "$prompt_message [$default_value]: " input
    if [[ -z "$input" ]]; then
        echo "$default_value"
    else
        echo "$input"
    fi
}

confirm_or_abort() {
    local message="${1:-¿Continuar?}"
    read -r -p "$message (s/N): " answer
    case "${answer,,}" in
        s|si|sí) return 0 ;;
        *)
            warning "Acción cancelada por el usuario"
            exit 0
            ;;
    esac
}

ensure_command() {
    local cmd="$1"
    if ! command -v "$cmd" >/dev/null 2>&1; then
        error "Se requiere el comando '$cmd' para ejecutar este script"
        exit 1
    fi
}

trap_ctrl_c() {
    local cleanup_message="${1:-Operación interrumpida por el usuario}"
    trap 'warning "$cleanup_message"; exit 130' INT
}

docker_compose_cmd() {
    if command -v docker >/dev/null 2>&1 && docker compose version >/dev/null 2>&1; then
        echo "docker compose"
        return
    fi

    if command -v docker-compose >/dev/null 2>&1; then
        echo "docker-compose"
        return
    fi

    error "No se encontró docker compose"
    exit 1
}

detect_compose_file() {
    if [[ -f "$PROJECT_DIR/docker-compose.prod.yml" ]]; then
        echo "docker-compose.prod.yml"
    elif [[ -f "$PROJECT_DIR/docker-compose.yml" ]]; then
        echo "docker-compose.yml"
    else
        error "No se encontró docker-compose.yml ni docker-compose.prod.yml en $PROJECT_DIR"
        exit 1
    fi
}

docker_compose() {
    ensure_command docker
    require_project_dir
    local cmd
    cmd="$(docker_compose_cmd)"
    local file
    file="$(detect_compose_file)"
    ( cd "$PROJECT_DIR" && $cmd -f "$file" "$@" )
}


