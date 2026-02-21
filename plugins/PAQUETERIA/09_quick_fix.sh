#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

trap_ctrl_c "Quick Fix cancelado"

info "🔧 Quick Fix - Soluciones Rápidas"
echo "-------------------------------------------"
echo "1) Reiniciar todo (contenedores + servicios)"
echo "2) Limpiar Docker (imágenes, volúmenes no usados)"
echo "3) Resetear a último commit estable (main)"
echo "4) Liberar espacio en disco"
echo "5) Reparar permisos del proyecto"
echo "q) Cancelar"
echo "-------------------------------------------"

read -r -p "Selecciona una opción: \" option

case "$option" in
    1)
        confirm_or_abort "¿Reiniciar todos los servicios?"
        info "Deteniendo contenedores..."
        docker_compose down
        info "Iniciando contenedores..."
        docker_compose up -d
        sleep 3
        info "Reiniciando Nginx..."
        sudo systemctl restart nginx
        echo ""
        docker_compose ps
        success "Servicios reiniciados"
        ;;
    2)
        confirm_or_abort "¿Limpiar Docker? (elimina imágenes y volúmenes no usados)"
        info "Limpiando Docker..."
        docker system prune -af --volumes
        success "Docker limpio"
        ;;
    3)
        confirm_or_abort "¿Resetear a último commit de main? (DESCARTA CAMBIOS LOCALES)"
        require_project_dir
        cd "$PROJECT_DIR"
        info "Fetching origin..."
        git fetch origin
        info "Reseteando a origin/main..."
        git reset --hard origin/main
        info "Reconstruyendo contenedores..."
        docker_compose up -d --build
        success "Reset completado a origin/main"
        ;;
    4)
        confirm_or_abort "¿Liberar espacio? (logs antiguos + Docker + journald)"
        info "Limpiando Docker..."
        docker system prune -f
        info "Eliminando logs antiguos..."
        sudo find /var/log -name "*.log" -mtime +7 -delete 2>/dev/null || true
        info "Limpiando journald..."
        sudo journalctl --vacuum-time=7d 2>/dev/null || true
        echo ""
        df -h /
        success "Espacio liberado"
        ;;
    5)
        confirm_or_abort "¿Reparar permisos del proyecto?"
        require_project_dir
        info "Reparando permisos de $PROJECT_DIR..."
        sudo chown -R ubuntu:ubuntu "$PROJECT_DIR"
        chmod +x "$PROJECT_DIR"/SCRIPTS/deployment/*.sh 2>/dev/null || true
        success "Permisos reparados"
        ;;
    q|Q)
        warning "Operación cancelada"
        exit 0
        ;;
    *)
        error "Opción inválida"
        exit 1
        ;;
esac

echo ""
info "💡 Ejecuta '05_health_check.sh' para verificar el sistema"
