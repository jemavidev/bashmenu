#!/bin/bash

# BetterAgentX - Script de Complete System Verification
# Analiza agentes, skills, y compatibilidad
#
# Usage:
#   bash verify-system.sh           # Normal mode
#   bash verify-system.sh --debug   # Debug mode (verbose output)
#   bash verify-system.sh --help    # Show help

# Parse arguments
DEBUG_MODE=false
if [ "$1" = "--debug" ]; then
    DEBUG_MODE=true
    set -x  # Enable bash debug mode
elif [ "$1" = "--help" ]; then
    echo "BetterAgentX System Verification"
    echo ""
    echo "Usage:"
    echo "  bash verify-system.sh           # Normal mode"
    echo "  bash verify-system.sh --debug   # Debug mode (shows all commands)"
    echo "  bash verify-system.sh --help    # Show this help"
    echo ""
    exit 0
fi

set -e

# Get project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Debug function
debug() {
    if [ "$DEBUG_MODE" = true ]; then
        echo -e "\033[0;35m[DEBUG]\033[0m $1" >&2
    fi
}

# Colores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

print_success() { echo -e "${GREEN}✅ $1${NC}"; }
print_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
print_error() { echo -e "${RED}❌ $1${NC}"; }
print_section() { echo -e "${CYAN}━━━ $1 ━━━${NC}"; }

debug "Script started from: $(pwd)"
debug "Script directory: $SCRIPT_DIR"
debug "Project root: $PROJECT_ROOT"

echo "🔍 BetterAgentX - Complete System Verification"
if [ "$DEBUG_MODE" = true ]; then
    echo "🐛 DEBUG MODE ENABLED"
fi
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Verificar directorio
if [ ! -f "$PROJECT_ROOT/config/betteragents.json" ]; then
    print_error "Not found config/betteragents.json"
    print_error "Make sure you're in the BetterAgentX root directory"
    debug "Looking for: $PROJECT_ROOT/config/betteragents.json"
    debug "Current directory: $(pwd)"
    exit 1
fi

debug "Configuration file found: $PROJECT_ROOT/config/betteragents.json"

ISSUES_FOUND=0
WARNINGS_FOUND=0

# ============================================
# 1. VERIFY FILE STRUCTURE
# ============================================
print_section "1. File Structure"
echo ""

# Verificar agentes
if [ -d "$PROJECT_ROOT/.kiro/steering/agents" ]; then
    AGENT_COUNT=$(ls -1 "$PROJECT_ROOT/.kiro/steering/agents"/*.md 2>/dev/null | wc -l)
    debug "Found $AGENT_COUNT agent files in $PROJECT_ROOT/.kiro/steering/agents"
    if [ "$AGENT_COUNT" -eq 13 ]; then
        print_success "13 agents found (12 specialized + AgentX)"
    else
        print_error "Only $AGENT_COUNT agents (expected 13)"
        debug "Agent files found:"
        if [ "$DEBUG_MODE" = true ]; then
            ls -1 "$PROJECT_ROOT/.kiro/steering/agents"/*.md 2>/dev/null || echo "  None"
        fi
        ISSUES_FOUND=$((ISSUES_FOUND + 1))
    fi
else
    print_error "Carpeta de agentes no encontrada"
    debug "Expected path: $PROJECT_ROOT/.kiro/steering/agents"
    ISSUES_FOUND=$((ISSUES_FOUND + 1))
fi

# Verificar memoria
if [ -d "$PROJECT_ROOT/.kiro/memory" ]; then
    MEMORY_COUNT=$(find "$PROJECT_ROOT/.kiro/memory" -maxdepth 1 -name "*.json" -type f 2>/dev/null | wc -l)
    debug "Memory JSON files found: $MEMORY_COUNT"
    if [ "$DEBUG_MODE" = true ]; then
        echo "  Memory files:"
        find "$PROJECT_ROOT/.kiro/memory" -maxdepth 1 -name "*.json" -type f 2>/dev/null | while read f; do
            echo "    - $(basename $f)"
        done
    fi
    if [ "$MEMORY_COUNT" -eq 4 ]; then
        print_success "Sistema de memoria completo (4 archivos JSON)"
    else
        print_warning "Sistema de memoria: $MEMORY_COUNT archivos JSON encontrados"
        debug "Expected: 4 JSON files (active-context.json, decision-log.json, patterns.json, progress.json)"
    fi
else
    print_warning "Sistema de memoria no found"
    debug "Expected path: $PROJECT_ROOT/.kiro/memory"
    WARNINGS_FOUND=$((WARNINGS_FOUND + 1))
fi

# Verificar skills
if [ -d "$PROJECT_ROOT/.kiro/skills" ]; then
    print_success "Skills folder present"
else
    print_warning "Skills folder not found"
    WARNINGS_FOUND=$((WARNINGS_FOUND + 1))
fi

# Verificar symlink (legacy check for .agents/skills)
if [ -L "$PROJECT_ROOT/.agents/skills" ]; then
    print_success "Legacy symlink present (.agents/skills)"
else
    print_info "No legacy symlink (using .kiro/skills directly)"
fi

echo ""

# ============================================
# 2. VERIFICAR AGENTES
# ============================================
print_section "2. Análisis de Agentes"
echo ""

AGENTS_OK=0
AGENTS_ISSUES=0

for agent_file in "$PROJECT_ROOT/.kiro/steering/agents"/*.md; do
    agent_name=$(basename "$agent_file" .md)
    debug "Checking agent: $agent_name"
    
    # AgentX tiene estructura diferente (es el orquestador)
    if [ "$agent_name" = "agentx" ]; then
        has_role=$(grep -ciE "^## ROLE" "$agent_file" 2>/dev/null || echo "0")
        debug "  agentx ROLE sections found: $has_role"
        if [ "$has_role" -gt 0 ] 2>/dev/null; then
            print_success "$agent_name: Estructura completa (orchestrator)"
            AGENTS_OK=$((AGENTS_OK + 1))
        else
            print_warning "$agent_name: Faltan secciones"
            debug "  Expected: ## ROLE DEFINITION"
            if [ "$DEBUG_MODE" = true ]; then
                echo "  First 10 lines of $agent_file:"
                head -10 "$agent_file" | grep "^##" || echo "  No ## headers found"
            fi
            AGENTS_ISSUES=$((AGENTS_ISSUES + 1))
            WARNINGS_FOUND=$((WARNINGS_FOUND + 1))
        fi
        continue
    fi
    
    # Verificar secciones requeridas para agentes especializados
    has_role=$(grep -ciE "^## Role" "$agent_file" 2>/dev/null || echo "0")
    has_expertise=$(grep -ciE "^## Expertise" "$agent_file" 2>/dev/null || echo "0")
    
    # Remove any whitespace/newlines
    has_role=$(echo "$has_role" | tr -d '[:space:]')
    has_expertise=$(echo "$has_expertise" | tr -d '[:space:]')
    
    debug "  $agent_name - Role: $has_role, Expertise: $has_expertise"
    
    if [ "$has_role" -gt 0 ] 2>/dev/null && [ "$has_expertise" -gt 0 ] 2>/dev/null; then
        print_success "$agent_name: Estructura completa"
        AGENTS_OK=$((AGENTS_OK + 1))
    else
        print_warning "$agent_name: Faltan secciones"
        debug "  Expected: ## Role and ## Expertise"
        if [ "$DEBUG_MODE" = true ]; then
            echo "  Headers found in $agent_file:"
            grep "^##" "$agent_file" | head -5 || echo "  No ## headers found"
        fi
        AGENTS_ISSUES=$((AGENTS_ISSUES + 1))
        WARNINGS_FOUND=$((WARNINGS_FOUND + 1))
    fi
done

echo ""
print_info "Agentes OK: $AGENTS_OK/13"
if [ "$AGENTS_ISSUES" -gt 0 ]; then
    print_warning "Agentes con issues: $AGENTS_ISSUES"
fi

echo ""

# ============================================
# 3. VERIFICAR SKILLS RECOMENDADOS
# ============================================
print_section "3. Skills Recomendados en Agentes"
echo ""

# Extraer todos los recommended skills
TOTAL_SKILLS=$(grep -hc "npx skills.*add" "$PROJECT_ROOT/.kiro/steering/agents"/*.md 2>/dev/null | awk '{s+=$1} END {print s}')
if [ -z "$TOTAL_SKILLS" ]; then
    TOTAL_SKILLS=0
fi
print_info "Total de recommended skills: $TOTAL_SKILLS"

# Verificar sintaxis correcta
WRONG_SYNTAX=$(grep -hc "npx skillsadd" "$PROJECT_ROOT/.kiro/steering/agents"/*.md 2>/dev/null | awk '{s+=$1} END {print s}')
if [ -z "$WRONG_SYNTAX" ]; then
    WRONG_SYNTAX=0
fi
if [ "$WRONG_SYNTAX" -gt 0 ] 2>/dev/null; then
    print_error "Encontrados $WRONG_SYNTAX comandos con sintaxis incorrecta (skillsadd)"
    print_info "Debería ser: 'npx skills add' (con espacio)"
    ISSUES_FOUND=$((ISSUES_FOUND + 1))
else
    print_success "Sintaxis de comandos correcta"
fi

# Listar skills únicos recomendados
if [ "$TOTAL_SKILLS" -gt 0 ] 2>/dev/null; then
    echo ""
    print_info "Skills únicos recomendados:"
    grep -h "npx skills" "$PROJECT_ROOT/.kiro/steering/agents"/*.md 2>/dev/null | \
        sed 's/.*npx skills add //' | \
        sed 's/npx skillsadd //' | \
        sort -u | \
        head -10 | \
        while read skill; do
            echo "  • $skill"
        done
fi

echo ""

# ============================================
# 4. VERIFICAR SKILLS INSTALADOS
# ============================================
print_section "4. Skills Instalados"
echo ""

# Check project skills directory
if [ -d "$PROJECT_ROOT/.kiro/skills" ]; then
    INSTALLED_SKILLS=$(ls -1 "$PROJECT_ROOT/.kiro/skills" 2>/dev/null | wc -l)
    
    if [ "$INSTALLED_SKILLS" -gt 0 ]; then
        print_success "$INSTALLED_SKILLS skills installed in project"
    else
        print_warning "No skills in project directory"
        WARNINGS_FOUND=$((WARNINGS_FOUND + 1))
    fi
else
    print_warning "Project skills directory not found"
    WARNINGS_FOUND=$((WARNINGS_FOUND + 1))
fi

echo ""

# ============================================
# 5. VERIFICAR COMPLEMENTARIEDAD
# ============================================
print_section "5. Análisis de Complementariedad"
echo ""

print_info "Verificando workflows complementarios..."

# Workflow típico: Architect -> Critic -> Coder -> Tester -> Writer
WORKFLOW_AGENTS=("architect" "critic" "coder" "tester" "writer")
WORKFLOW_OK=true

for agent in "${WORKFLOW_AGENTS[@]}"; do
    if [ -f "$PROJECT_ROOT/.kiro/steering/agents/$agent.md" ]; then
        print_success "$agent presente"
    else
        print_error "$agent faltante"
        WORKFLOW_OK=false
        ISSUES_FOUND=$((ISSUES_FOUND + 1))
    fi
done

echo ""
if [ "$WORKFLOW_OK" = true ]; then
    print_success "Workflow básico completo"
else
    print_error "Workflow básico incompleto"
fi

echo ""

# ============================================
# 6. VERIFICAR SCRIPTS
# ============================================
print_section "6. Scripts del Sistema"
echo ""

SCRIPTS=("$PROJECT_ROOT/scripts/init.sh" "$PROJECT_ROOT/scripts/verify-system.sh" "$PROJECT_ROOT/scripts/update-skills.sh" "$PROJECT_ROOT/scripts/memory-stats.sh" "$PROJECT_ROOT/scripts/open-dashboard.sh" "$PROJECT_ROOT/scripts/update-dashboard.sh")
SCRIPTS_OK=0

for script in "${SCRIPTS[@]}"; do
    if [ -f "$script" ]; then
        if [ -x "$script" ]; then
            print_success "$(basename $script) (ejecutable)"
            SCRIPTS_OK=$((SCRIPTS_OK + 1))
        else
            print_warning "$(basename $script) (no ejecutable)"
            print_info "Ejecuta: chmod +x $script"
            WARNINGS_FOUND=$((WARNINGS_FOUND + 1))
        fi
    else
        print_error "$(basename $script) no found"
        ISSUES_FOUND=$((ISSUES_FOUND + 1))
    fi
done

echo ""

# ============================================
# 7. VERIFICAR DOCUMENTACIÓN
# ============================================
print_section "7. Documentación"
echo ""

DOCS=("$PROJECT_ROOT/README.md" "$PROJECT_ROOT/docs/installation/linux.md" "$PROJECT_ROOT/changelog.md" "$PROJECT_ROOT/contributing.md" "$PROJECT_ROOT/license" "$PROJECT_ROOT/docs/guides/skills-management.md")
DOCS_OK=0

for doc in "${DOCS[@]}"; do
    if [ -f "$doc" ]; then
        SIZE=$(du -h "$doc" | cut -f1)
        print_success "$(basename $doc) ($SIZE)"
        DOCS_OK=$((DOCS_OK + 1))
    else
        print_warning "$(basename $doc) no found"
        WARNINGS_FOUND=$((WARNINGS_FOUND + 1))
    fi
done

echo ""

# ============================================
# 8. VERIFICAR CONFIGURACIÓN
# ============================================
print_section "8. Configuración"
echo ""

if [ -f "$PROJECT_ROOT/config/.betteragents-config" ]; then
    print_success "Archivo de configuración presente"
    
    # Verificar configuración
    AUTO_UPDATE=$(grep "AUTO_UPDATE_SKILLS" "$PROJECT_ROOT/config/.betteragents-config" | cut -d'=' -f2)
    UPDATE_FREQ=$(grep "UPDATE_CHECK_FREQUENCY" "$PROJECT_ROOT/config/.betteragents-config" | cut -d'=' -f2)
    
    print_info "Auto-actualización: $AUTO_UPDATE"
    print_info "Frecuencia de verificación: $UPDATE_FREQ días"
else
    print_warning "Archivo de configuración no found"
    WARNINGS_FOUND=$((WARNINGS_FOUND + 1))
fi

if [ -f "$PROJECT_ROOT/.gitignore" ]; then
    print_success "Archivo .gitignore presente"
else
    print_warning "Archivo .gitignore no found"
    WARNINGS_FOUND=$((WARNINGS_FOUND + 1))
fi

echo ""

# ============================================
# 9. VERIFICAR COMPATIBILIDAD DE SKILLS
# ============================================
print_section "9. Compatibilidad de Skills por Agente"
echo ""

# Mapeo de agentes y sus recommended skills
declare -A AGENT_SKILLS=(
    ["architect"]="architecture-patterns api-design-principles microservices-patterns"
    ["coder"]="vercel-react-best-practices next-best-practices typescript-advanced-types"
    ["critic"]="systematic-debugging verification-before-completion"
    ["tester"]="webapp-testing e2e-testing-patterns"
    ["writer"]="doc-coauthoring writing-skills"
    ["researcher"]="find-skills competitor-alternatives"
    ["teacher"]="skill-creator prompt-engineering-patterns"
    ["devops"]="docker-expert deployment-pipeline-design"
    ["security"]="code-reviewer auth-implementation-patterns"
    ["ux-designer"]="frontend-design web-design-guidelines ui-ux-pro-max"
    ["data-scientist"]="sql-optimization-patterns postgresql-table-design"
    ["product-manager"]="writing-plans executing-plans brainstorming"
)

COMPATIBILITY_OK=0
COMPATIBILITY_ISSUES=0

for agent in "${!AGENT_SKILLS[@]}"; do
    if [ -f "$PROJECT_ROOT/.kiro/steering/agents/$agent.md" ]; then
        skills_count=$(echo "${AGENT_SKILLS[$agent]}" | wc -w)
        print_success "$agent: $skills_count recommended skills"
        COMPATIBILITY_OK=$((COMPATIBILITY_OK + 1))
    else
        print_error "$agent: agente no found"
        COMPATIBILITY_ISSUES=$((COMPATIBILITY_ISSUES + 1))
    fi
done

echo ""

# ============================================
# RESUMEN FINAL
# ============================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 VERIFICATION SUMMARY"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

print_info "Agentes: $AGENTS_OK/12 OK"
print_info "Scripts: $SCRIPTS_OK/${#SCRIPTS[@]} OK"
print_info "Documentación: $DOCS_OK/${#DOCS[@]} OK"
print_info "Compatibilidad: $COMPATIBILITY_OK/${#AGENT_SKILLS[@]} OK"
echo ""

if [ "$ISSUES_FOUND" -eq 0 ] && [ "$WARNINGS_FOUND" -eq 0 ]; then
    print_success "✨ Sistema completamente funcional"
    print_success "No se encontraron problemas"
    echo ""
    print_info "The system is ready to use:"
    echo "  kiro ."
    exit 0
elif [ "$ISSUES_FOUND" -eq 0 ]; then
    print_warning "⚠️  Sistema funcional con advertencias"
    print_warning "Advertencias encontradas: $WARNINGS_FOUND"
    echo ""
    print_info "El sistema funciona pero hay mejoras recomendadas"
    exit 0
else
    print_error "❌ Se encontraron problemas críticos"
    print_error "Problemas: $ISSUES_FOUND"
    print_warning "Advertencias: $WARNINGS_FOUND"
    echo ""
    print_info "Revisa los errores arriba y corrígelos"
    exit 1
fi
