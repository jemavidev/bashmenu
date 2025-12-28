#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

trap_ctrl_c "Despliegue cancelado"

info "🍱 PAQUETERÍA v4.0 - Despliegue"
echo "-------------------------------------------"
echo "1) Deploy producción (Docker compose)"
echo "2) Deploy hot reload / desarrollo"
echo "3) Configuración completa del servidor"
echo "q) Cancelar"
echo "-------------------------------------------"

read -r -p "Selecciona una opción: " selection

case "$selection" in
    1)
        info "Commits recientes disponibles:"
        echo "-------------------------------------------"
        cd "$PROJECT_DIR"
        git log --oneline --decorate -n 20 --color=always
        echo "-------------------------------------------"
        echo ""
        
        commit=$(prompt_optional_value "Commit hash o branch (vacío = último de main)" "")
        
        if [[ -z "$commit" ]]; then
            branch="main"
            confirm_or_abort "¿Desplegar último commit de main?"
            info "Desplegando último commit de main"
        else
            confirm_or_abort "¿Desplegar commit/branch: $commit?"
            branch="$commit"
            info "Desplegando $commit"
        fi
        
        ensure_command git
        ensure_command docker
        run_deployment_script "deploy.sh" "$branch"
        success "Deploy completado"
        ;;
    2)
        branch=$(prompt_optional_value "Branch o tag para hot reload" "main")
        confirm_or_abort "¿Iniciar modo desarrollo (hot reload)?"
        ensure_command git
        ensure_command docker
        if [[ -x "$DEPLOY_DIR/dev-up.sh" ]]; then
            run_deployment_script "dev-up.sh" "$branch"
            success "Entorno de desarrollo actualizado"
        else
            error "No se encontró dev-up.sh en $DEPLOY_DIR"
            exit 1
        fi
        ;;
    3)
        info "Esta opción requiere privilegios de administrador"
        domain=$(prompt_optional_value "Dominio" "paquetex.papyrus.com.co")
        email=$(prompt_optional_value "Email de Let's Encrypt" "admin@papyrus.com.co")
        confirm_or_abort "¿Configurar producción (Nginx, systemd, SSL)?"
        ensure_command sudo
        run_deployment_script_sudo "setup-production.sh" "$domain" "$email" "$PROJECT_DIR"
        success "Configuración de servidor completada"
        ;;
    q|Q)
        warning "Acción cancelada"
        exit 0
        ;;
    *)
        error "Opción inválida"
        exit 1
        ;;
esac
