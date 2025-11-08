#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

trap_ctrl_c "Rollback cancelado"

ensure_command git
ensure_command docker

require_project_dir
cd "$PROJECT_DIR"

info "🔄 Rollback a versión anterior"
echo "-------------------------------------------"
echo "Últimos tags disponibles:"
git tag -l --sort=-version:refname | head -10
echo ""
echo "Commits recientes:"
git log --oneline --decorate -n 10
echo "-------------------------------------------"

read -r -p "Ingresa tag o commit (q para salir): " target

if [[ -z "$target" || "$target" == "q" || "$target" == "Q" ]]; then
    warning "Rollback cancelado"
    exit 0
fi

confirm_or_abort "Esto revertirá el estado del repositorio a '$target'. ¿Continuar?"

run_deployment_script "rollback.sh" "$target"

success "Rollback completado a $target"
