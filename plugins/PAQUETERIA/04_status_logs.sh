#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

trap_ctrl_c "Operación cancelada"

ensure_command docker

info "📊 Estado y Logs de la aplicación"
echo "-------------------------------------------"
echo "1) Ver estado de contenedores"
echo "2) Mostrar últimos logs"
echo "3) Seguir logs en tiempo real"
echo "4) Estadísticas rápidas de recursos"
echo "q) Salir"
echo "-------------------------------------------"

read -r -p "Selecciona una opción: " option

case "$option" in
    1)
        info "Estado de contenedores"
        docker_compose ps
        ;;
    2)
        service=$(prompt_optional_value "Servicio a consultar" "app")
        lines=$(prompt_optional_value "Número de líneas" "50")
        info "Últimos $lines logs de $service"
        docker_compose logs --tail="$lines" "$service"
        ;;
    3)
        service=$(prompt_optional_value "Servicio a seguir" "app")
        info "Capturando logs en tiempo real (Ctrl+C para salir)"
        docker_compose logs -f "$service"
        ;;
    4)
        info "Estadísticas de recursos"
        docker stats --no-stream
        ;;
    q|Q)
        warning "Sin cambios"
        exit 0
        ;;
    *)
        error "Opción no válida"
        exit 1
        ;;
esac

echo ""
success "Operación completada"
