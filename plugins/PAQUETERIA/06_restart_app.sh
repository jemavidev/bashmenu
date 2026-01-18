#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

trap_ctrl_c "Reinicio cancelado"

info "🔧 Reinicio de servicios"
echo "-------------------------------------------"
echo "1) Reiniciar contenedores activos"
echo "2) Forzar recreación de contenedores"
echo "3) Reiniciar servicio systemd paqueteria"
echo "4) Reiniciar Nginx"
echo "q) Cancelar"
echo "-------------------------------------------"

read -r -p "Selecciona una opción: " choice

case "$choice" in
    1)
        confirm_or_abort "¿Reiniciar contenedores Docker?"
        docker_compose restart
        docker_compose ps
        ;;
    2)
        confirm_or_abort "Esto recreará todos los contenedores. ¿Continuar?"
        docker_compose down
        docker_compose up -d
        docker_compose ps
        ;;
    3)
        ensure_command sudo
        confirm_or_abort "¿Reiniciar servicio systemd paqueteria?"
        sudo systemctl restart paqueteria.service
        sudo systemctl status paqueteria.service --no-pager -l | head -n 20
        ;;
    4)
        ensure_command sudo
        confirm_or_abort "¿Reiniciar Nginx?"
        sudo systemctl restart nginx
        sudo systemctl status nginx --no-pager -l | head -n 10
        ;;
    q|Q)
        warning "Sin cambios"
        exit 0
        ;;
    *)
        error "Opción inválida"
        exit 1
        ;;
esac

echo ""
success "Operación ejecutada"
