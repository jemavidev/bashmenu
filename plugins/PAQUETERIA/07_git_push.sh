#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

trap_ctrl_c "Push cancelado"

ensure_command git

require_project_dir
cd "$PROJECT_DIR"

info "🚀 Git Push controlado"
echo "-------------------------------------------"
git status -sb
echo "-------------------------------------------"

if git diff --cached --quiet && git diff --quiet; then
    warning "No hay cambios para commitear"
    exit 0
fi

read -r -p "¿Deseas hacer 'git add .'? (s/N): " add_all
if [[ "${add_all,,}" == s || "${add_all,,}" == "si" || "${add_all,,}" == "sí" ]]; then
    git add .
    success "Cambios agregados"
else
    info "Saltar git add. Puedes agregar archivos manualmente antes de confirmar."
fi

git status -sb

commit_message=""
while [[ -z "$commit_message" ]]; do
    read -r -p "Mensaje de commit: " commit_message
    if [[ -z "$commit_message" ]]; then
        warning "El mensaje no puede estar vacío"
    fi
done

git commit -m "$commit_message" || {
    warning "No se realizó commit (¿quizás no hubo cambios a comitear?)"
    exit 0
}

branch=$(git branch --show-current)
read -r -p "Remote (default origin): " remote
remote=${remote:-origin}

confirm_or_abort "¿Hacer push a $remote/$branch?"

git push "$remote" "$branch"

success "Push completado a $remote/$branch"
