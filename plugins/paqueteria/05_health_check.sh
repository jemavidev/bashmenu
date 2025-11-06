#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

trap_ctrl_c "Health check cancelado"

info "🏥 Health Check completo"
echo "-------------------------------------------"

check_app() {
    local url="${1:-http://127.0.0.1:8000/health}";
    if curl -sSf "$url" >/dev/null 2>&1; then
        success "Aplicación responde en $url"
    else
        error "Aplicación no responde en $url"
    fi
}

check_systemd() {
    local service="$1"
    if sudo systemctl is-active --quiet "$service"; then
        success "Servicio $service activo"
    else
        warning "Servicio $service inactivo"
    fi
}

check_ssl() {
    local domain="${1:-paquetex.papyrus.com.co}"
    local cert_path="/etc/letsencrypt/live/$domain/fullchain.pem"
    if sudo test -f "$cert_path"; then
        local expiry
        expiry=$(sudo openssl x509 -enddate -noout -in "$cert_path" | cut -d= -f2)
        success "Certificado SSL presente (expira: $expiry)"
    else
        warning "Certificado SSL no encontrado para $domain"
    fi
}

check_disk() {
    local usage
    usage=$(df -h / | awk 'NR==2 {print $5}' | tr -d '%')
    if [[ "$usage" =~ ^[0-9]+$ && $usage -lt 80 ]]; then
        success "Uso de disco saludable: ${usage}%"
    else
        warning "Uso de disco elevado: ${usage}%"
    fi
}

require_project_dir

check_app
check_systemd nginx
check_systemd paqueteria.service

info "Verificando contenedores Docker"
running=$(docker_compose ps --filter "status=running" -q | wc -l)
if [[ $running -gt 0 ]]; then
    success "$running contenedor(es) en ejecución"
else
    error "No hay contenedores en ejecución"
fi

check_ssl
check_disk

echo ""
success "Health check completado"
