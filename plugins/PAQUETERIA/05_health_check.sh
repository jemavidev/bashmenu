#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

trap_ctrl_c "Health check cancelado"

info "🏥 Health Check con Auto-Fix"
echo "-------------------------------------------"

ISSUES_FOUND=0

# Check 1: Aplicación respondiendo
check_app() {
    local url="${1:-http://127.0.0.1:8000/health}"
    if curl -sSf "$url" >/dev/null 2>&1; then
        success "Aplicación responde en $url"
    else
        error "Aplicación no responde en $url"
        ISSUES_FOUND=$((ISSUES_FOUND + 1))
        
        read -r -p "¿Ver logs de la aplicación? (s/N): " fix
        if [[ "${fix,,}" == "s" ]]; then
            docker_compose logs --tail=50 app
        fi
    fi
}

# Check 2: Servicios systemd
check_systemd() {
    local service="$1"
    if sudo systemctl is-active --quiet "$service"; then
        success "Servicio $service activo"
    else
        warning "Servicio $service inactivo"
        ISSUES_FOUND=$((ISSUES_FOUND + 1))
        
        read -r -p "¿Reiniciar $service? (s/N): " fix
        if [[ "${fix,,}" == "s" ]]; then
            sudo systemctl restart "$service"
            success "Servicio $service reiniciado"
        fi
    fi
}

# Check 3: Contenedores Docker
check_containers() {
    info "Verificando contenedores Docker"
    local expected=7
    local running=$(docker_compose ps --filter "status=running" -q | wc -l)
    
    if [[ $running -lt $expected ]]; then
        error "Solo $running/$expected contenedores activos"
        ISSUES_FOUND=$((ISSUES_FOUND + 1))
        
        read -r -p "¿Reiniciar contenedores? (s/N): " fix
        if [[ "${fix,,}" == "s" ]]; then
            docker_compose up -d
            sleep 3
            local new_running=$(docker_compose ps --filter "status=running" -q | wc -l)
            success "Contenedores reiniciados: $new_running activos"
        fi
    else
        success "$running contenedor(es) en ejecución"
    fi
}

# Check 4: SSL
check_ssl() {
    local domain="${1:-paquetex.papyrus.com.co}"
    local cert_path="/etc/letsencrypt/live/$domain/fullchain.pem"
    if sudo test -f "$cert_path"; then
        local expiry
        expiry=$(sudo openssl x509 -enddate -noout -in "$cert_path" | cut -d= -f2)
        success "Certificado SSL presente (expira: $expiry)"
    else
        warning "Certificado SSL no encontrado para $domain"
        ISSUES_FOUND=$((ISSUES_FOUND + 1))
    fi
}

# Check 5: Espacio en disco
check_disk() {
    local usage
    usage=$(df -h / | awk 'NR==2 {print $5}' | tr -d '%')
    if [[ "$usage" =~ ^[0-9]+$ && $usage -lt 80 ]]; then
        success "Uso de disco saludable: ${usage}%"
    else
        warning "Uso de disco elevado: ${usage}%"
        ISSUES_FOUND=$((ISSUES_FOUND + 1))
        
        read -r -p "¿Limpiar logs y caché de Docker? (s/N): " fix
        if [[ "${fix,,}" == "s" ]]; then
            info "Limpiando Docker..."
            docker system prune -f
            info "Limpiando logs antiguos..."
            sudo find /var/log -name "*.log" -mtime +7 -delete 2>/dev/null || true
            local new_usage=$(df -h / | awk 'NR==2 {print $5}')
            success "Limpieza completada. Uso actual: $new_usage"
        fi
    fi
}

require_project_dir

# Ejecutar todos los checks
check_app
check_systemd nginx
check_systemd paqueteria.service
check_containers
check_ssl
check_disk

echo ""
echo "========================================="
if [[ $ISSUES_FOUND -eq 0 ]]; then
    success "✅ Sistema saludable - 0 problemas encontrados"
else
    warning "⚠️  Se encontraron $ISSUES_FOUND problema(s)"
    info "Ejecuta '08_verify_system.sh' para diagnóstico completo"
fi
echo "========================================="
