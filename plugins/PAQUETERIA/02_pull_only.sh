#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

trap_ctrl_c "Actualización cancelada"

ensure_command git

require_project_dir
cd "$PROJECT_DIR"

info "⚡ Actualizar código (sin rebuild)"
echo "-------------------------------------------"
git status -sb
echo "-------------------------------------------"

branch=$(prompt_optional_value "Branch o tag a sincronizar" "main")

if ! git diff-index --quiet HEAD --; then
    warning "Se detectaron cambios locales"
    echo "Opciones disponibles:"
    echo "  1) Guardar cambios con git stash"
    echo "  2) Descartar cambios locales"
    echo "  3) Cancelar"
    read -r -p "Selecciona una opción [1-3]: " local_choice
    case "$local_choice" in
        1)
            info "Guardando cambios locales en stash"
            git stash push -m "stash antes de pull $(date +%Y-%m-%d_%H:%M:%S)"
            ;;
        2)
            confirm_or_abort "Esto descarta todos los cambios locales. ¿Continuar?"
            git reset --hard HEAD
            ;;
        3)
            warning "Operación cancelada"
            exit 0
            ;;
        *)
            error "Opción inválida"
            exit 1
            ;;
    esac
fi

confirm_or_abort "¿Ejecutar pull sin rebuild?"

run_deployment_script "pull-only.sh" "$branch"

success "Código actualizado"
