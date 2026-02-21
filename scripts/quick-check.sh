#!/bin/bash

# BetterAgentX - Quick Check (Verificación Rápida)
# Verifica rápidamente que todas las funcionalidades estén activas
# Usage: bash scripts/quick-check.sh

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_ok() { echo -e "${GREEN}✅ $1${NC}"; }
print_fail() { echo -e "${RED}❌ $1${NC}"; }
print_warn() { echo -e "${YELLOW}⚠️  $1${NC}"; }
print_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔍 BetterAgentX - Quick Check"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

TOTAL=0
PASSED=0
FAILED=0

check() {
    TOTAL=$((TOTAL + 1))
    if [ $1 -eq 0 ]; then
        print_ok "$2"
        PASSED=$((PASSED + 1))
    else
        print_fail "$2"
        FAILED=$((FAILED + 1))
    fi
}

# 1. Kiro Code
command -v kiro &> /dev/null
check $? "Kiro Code instalado"

# 2. Agentes
AGENTS=$(find .kiro/steering/agents -name "*.md" 2>/dev/null | wc -l)
[ $AGENTS -ge 13 ]
check $? "Agentes instalados ($AGENTS/13)"

# 3. Memoria
MEMORY=$(find .kiro/memory -name "*.json" 2>/dev/null | wc -l)
[ $MEMORY -ge 8 ]
check $? "Sistema de memoria ($MEMORY/8 archivos)"

# 4. Dashboard
[ -f ".kiro/memory/dashboard.html" ]
check $? "Dashboard interactivo"

# 5. Configuración
[ -f ".kiro/settings/betteragents.json" ]
check $? "Configuración principal"

# 6. Hooks
HOOKS=$(find .kiro/hooks -name "*.kiro.hook" 2>/dev/null | wc -l)
[ $HOOKS -gt 0 ]
check $? "Hooks de automatización ($HOOKS hooks)"

# 7. Scripts
SCRIPTS=$(find scripts -name "*.sh" 2>/dev/null | wc -l)
[ $SCRIPTS -ge 20 ]
check $? "Scripts de utilidad ($SCRIPTS scripts)"

# 8. Skills
[ -d ".kiro/skills" ]
check $? "Directorio de skills"

# 9. Cache
[ -f ".kiro/cache/skills-detection-cache.json" ]
check $? "Sistema de cache"

# 10. Métricas
[ -f ".kiro/memory/project-metrics.json" ]
check $? "Métricas del proyecto"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 Resultado: $PASSED/$TOTAL checks pasados"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [ $FAILED -eq 0 ]; then
    print_ok "Sistema 100% funcional! 🎉"
    echo ""
    print_info "Comandos rápidos:"
    echo "  $ kiro .                              # Abrir Kiro Code"
    echo "  $ bash scripts/open-dashboard.sh      # Ver dashboard"
    echo "  $ bash scripts/memory-stats.sh        # Ver estadísticas"
    echo "  $ bash scripts/verify-system.sh       # Verificación completa"
    echo ""
    exit 0
else
    print_warn "$FAILED checks fallaron"
    echo ""
    print_info "Soluciones:"
    echo "  $ bash scripts/init.sh                # Re-instalar"
    echo "  $ bash scripts/activate-all-features.sh  # Re-activar"
    echo "  $ bash scripts/verify-system.sh       # Verificación detallada"
    echo ""
    exit 1
fi
