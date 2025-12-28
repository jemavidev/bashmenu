#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

trap_ctrl_c "Diagnóstico cancelado"

require_project_dir

info "🔍 Verificación completa del servidor"
echo "-------------------------------------------"

echo "💻 Información del sistema"
echo "  Hostname: $(hostname)"
echo "  OS: $(lsb_release -d | cut -f2 2>/dev/null || echo 'Desconocido')"
echo "  Kernel: $(uname -r)"
echo "  Uptime: $(uptime -p | sed 's/up //')"

load_avg=$(awk '{print $1" "$2" "$3}' /proc/loadavg)
mem_usage=$(free -h | awk 'NR==2 {print $3"/"$2}')
disk_usage=$(df -h / | awk 'NR==2 {print $3"/"$2" ("$5" usado)"}')

echo ""
echo "📊 Recursos"
echo "  Load Average: $load_avg"
echo "  Memoria: $mem_usage"
echo "  Disco raíz: $disk_usage"

echo ""
echo "🐳 Docker"
ensure_command docker
echo "  Versión: $(docker --version 2>/dev/null | awk '{print $3}' | tr -d ',')"
echo "  Compose: $(docker_compose_cmd)"
running=$(docker_compose ps --filter "status=running" -q | wc -l)
echo "  Contenedores activos: $running"

echo ""
echo "📦 Repositorio Git"
ensure_command git
cd "$PROJECT_DIR"
echo "  Branch actual: $(git branch --show-current)"
echo "  Último commit: $(git log -1 --pretty=format:'%h - %s (%cr)')"
changes=$(git status --porcelain | wc -l)
if [[ $changes -eq 0 ]]; then
    echo "  Estado: limpio"
else
    echo "  Cambios pendientes: $changes archivo(s)"
fi

echo ""
echo "🌐 Servicios"
if sudo systemctl is-active --quiet nginx; then
    echo "  Nginx: activo"
else
    echo "  Nginx: inactivo"
fi
if sudo systemctl is-active --quiet paqueteria.service 2>/dev/null; then
    echo "  paqueteria.service: activo"
else
    echo "  paqueteria.service: inactivo"
fi

echo ""
echo "🔒 Certificados"
domain="${PAQUETERIA_DOMAIN:-paquetex.papyrus.com.co}"
cert_path="/etc/letsencrypt/live/$domain/fullchain.pem"
if sudo test -f "$cert_path"; then
    expiry=$(sudo openssl x509 -enddate -noout -in "$cert_path" | cut -d= -f2)
    echo "  SSL ($domain): válido hasta $expiry"
else
    echo "  SSL ($domain): no encontrado"
fi

echo ""
echo "🌍 Conectividad"
if curl -sSf http://127.0.0.1:8000/health >/dev/null 2>&1; then
    echo "  Health local (8000): OK"
else
    echo "  Health local (8000): ERROR"
fi
if curl -sSf "https://$domain" >/dev/null 2>&1; then
    echo "  Dominio público: OK"
else
    echo "  Dominio público: Revisar"
fi

echo ""
echo "🧰 Herramientas instaladas"
for tool in docker git compose certbot aws; do
    if command -v "$tool" >/dev/null 2>&1; then
        echo "  $tool: disponible"
    else
        echo "  $tool: no encontrado"
    fi
done

echo ""
echo "🔧 Verificación oficial"
if [[ -x "/usr/local/bin/verify-paqueteria.sh" ]]; then
    sudo /usr/local/bin/verify-paqueteria.sh
else
    warning "Script verify-paqueteria.sh no encontrado"
fi

echo ""
echo "🔧 Análisis y Recomendaciones"
echo "-------------------------------------------"

RECOMMENDATIONS=()

# Analizar cambios pendientes
if [[ $changes -gt 0 ]]; then
    RECOMMENDATIONS+=("⚠️  Hay $changes archivo(s) con cambios - considera hacer commit o stash")
fi

# Analizar contenedores
if [[ $running -lt 5 ]]; then
    RECOMMENDATIONS+=("❌ Solo $running contenedores activos - ejecuta '06_restart_app.sh' opción 2")
fi

# Analizar disco
disk_pct=$(echo "$disk_usage" | cut -d'/' -f1 | sed 's/[^0-9.]//g')
if (( $(echo "$disk_pct > 20" | bc -l 2>/dev/null || echo 0) )); then
    RECOMMENDATIONS+=("⚠️  Uso de disco elevado ($disk_usage) - ejecuta 'docker system prune -af'")
fi

# Analizar servicios
if ! sudo systemctl is-active --quiet nginx; then
    RECOMMENDATIONS+=("❌ Nginx inactivo - ejecuta 'sudo systemctl restart nginx'")
fi

if ! sudo systemctl is-active --quiet paqueteria.service 2>/dev/null; then
    RECOMMENDATIONS+=("ℹ️  paqueteria.service inactivo (normal si usas solo Docker)")
fi

# Mostrar recomendaciones
if [[ ${#RECOMMENDATIONS[@]} -eq 0 ]]; then
    success "✅ No se encontraron problemas - sistema óptimo"
else
    for rec in "${RECOMMENDATIONS[@]}"; do
        echo "  $rec"
    done
    echo ""
    info "💡 Ejecuta '05_health_check.sh' para auto-fix interactivo"
fi

echo ""
success "Diagnóstico finalizado"
