#!/bin/bash
# Skills Detection Algorithm - Standalone Version
# Detects relevant skills based on query keywords

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
REGISTRY_FILE="$PROJECT_ROOT/.kiro/settings/skills-registry.json"
CONFIG_FILE="$PROJECT_ROOT/.kiro/settings/skills-on-demand-config.json"
CACHE_DIR="$PROJECT_ROOT/.kiro/cache"
CACHE_FILE="$CACHE_DIR/skills-detection-cache.json"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

print_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
print_section() { echo -e "${CYAN}━━━ $1 ━━━${NC}"; }

# Parse arguments
QUERY="$1"
AGENT="${2:-agentx}"
DEBUG="${3:-false}"

if [ -z "$QUERY" ]; then
    echo "Usage: ./detect-skills.sh \"query\" [agent] [debug]"
    echo ""
    echo "Examples:"
    echo "  ./detect-skills.sh \"Diseña un formulario de login\" ux-designer"
    echo "  ./detect-skills.sh \"Implementa API REST con JWT\" coder"
    echo "  ./detect-skills.sh \"Escribe tests E2E\" tester true"
    exit 1
fi

echo "🔍 SKILLS DETECTION"
echo "==================="
echo ""
print_info "Query: $QUERY"
print_info "Agent: $AGENT"
echo ""

# ============================================
# OPTIMIZATION: Check Cache First
# ============================================
mkdir -p "$CACHE_DIR"

# Create cache key from query + agent
CACHE_KEY=$(echo "$QUERY|$AGENT" | md5sum | cut -d' ' -f1)

if [ -f "$CACHE_FILE" ]; then
    # Check if cache entry exists and is less than 1 hour old
    CACHED_RESULT=$(jq -r --arg key "$CACHE_KEY" '.[$key] // empty' "$CACHE_FILE" 2>/dev/null)
    
    if [ -n "$CACHED_RESULT" ]; then
        CACHED_TIME=$(echo "$CACHED_RESULT" | jq -r '.timestamp')
        CURRENT_TIME=$(date +%s)
        AGE=$((CURRENT_TIME - CACHED_TIME))
        
        # Cache valid for 1 hour (3600 seconds)
        if [ $AGE -lt 3600 ]; then
            if [ "$DEBUG" = "true" ]; then
                print_info "✓ Cache hit (age: ${AGE}s)"
            fi
            echo "$CACHED_RESULT" | jq -r '.skills'
            exit 0
        fi
    fi
fi

# Load configuration
if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ Configuration file not found: $CONFIG_FILE"
    exit 1
fi

THRESHOLD=$(jq -r '.detection.minRelevanceThreshold' "$CONFIG_FILE")
MAX_SKILLS=$(jq -r '.detection.maxSkillsPerCall' "$CONFIG_FILE")
MAX_TOKENS=$(jq -r '.detection.maxTokensPerCall' "$CONFIG_FILE")
KEYWORD_WEIGHT=$(jq -r '.detection.keywordMatchWeight' "$CONFIG_FILE")
AGENT_WEIGHT=$(jq -r '.detection.agentMatchWeight' "$CONFIG_FILE")
PRIORITY_WEIGHT=$(jq -r '.detection.priorityWeight' "$CONFIG_FILE")

if [ "$DEBUG" = "true" ]; then
    print_section "Configuration"
    echo "  Threshold: $THRESHOLD%"
    echo "  Max skills: $MAX_SKILLS"
    echo "  Max tokens: $MAX_TOKENS"
    echo "  Weights: keyword=$KEYWORD_WEIGHT, agent=$AGENT_WEIGHT, priority=$PRIORITY_WEIGHT"
    echo ""
fi

# ============================================
# STEP 1: Extract Keywords
# ============================================
print_section "1. Extracting Keywords"
echo ""

# Normalize query: lowercase, remove accents, split words
NORMALIZED=$(echo "$QUERY" | tr '[:upper:]' '[:lower:]' | \
    sed 's/á/a/g; s/é/e/g; s/í/i/g; s/ó/o/g; s/ú/u/g; s/ñ/n/g' | \
    grep -oE '\b[a-z]{3,}\b' | sort -u)

# Common Spanish-English translations for tech terms
TRANSLATED=$(echo "$NORMALIZED" | sed '
    s/disena/design/g
    s/diseño/design/g
    s/crear/create/g
    s/construir/build/g
    s/implementar/implement/g
    s/implementa/implement/g
    s/desarrollar/develop/g
    s/probar/test/g
    s/testear/test/g
    s/documentar/document/g
    s/escribir/write/g
    s/escribe/write/g
    s/analizar/analyze/g
    s/revisar/review/g
    s/optimizar/optimize/g
    s/optimiza/optimize/g
    s/desplegar/deploy/g
    s/configurar/configure/g
    s/accesible/accessible/g
    s/accesibilidad/accessibility/g
    s/formulario/form/g
    s/boton/button/g
    s/pagina/page/g
    s/sitio/site/g
    s/aplicacion/application/g
    s/usuario/user/g
    s/interfaz/interface/g
    s/componente/component/g
    s/prueba/test/g
    s/error/error/g
    s/base/database/g
    s/datos/data/g
    s/dashboard/dashboard/g
    s/tablero/dashboard/g
    s/servidor/server/g
    s/cliente/client/g
    s/autenticacion/authentication/g
    s/autorizacion/authorization/g
    s/seguridad/security/g
    s/dockeriza/docker/g
    s/dockerizar/docker/g
    s/contenedor/container/g
    s/microservicio/microservice/g
    s/arquitectura/architecture/g
    s/migra/migrate/g
    s/migracion/migration/g
    s/consulta/query/g
    s/lenta/slow/g
    s/lentas/slow/g
    s/rendimiento/performance/g
    s/crea/create/g
    s/componentes/component/g
    s/componente/component/g
    s/react/react/g
    s/kpis/kpi/g
')

# Add common tech terms that should always be included
KEYWORDS="$KEYWORDS react vue angular node python java typescript javascript"

# Combine original and translated keywords
KEYWORDS=$(echo -e "$NORMALIZED\n$TRANSLATED" | sort -u | tr '\n' ' ')

if [ "$DEBUG" = "true" ]; then
    print_info "Keywords extracted: $KEYWORDS"
    echo ""
fi

# ============================================
# STEP 2: Calculate Relevance Scores
# ============================================
print_section "2. Analyzing Skills"
echo ""

# Create temporary file for results
TEMP_RESULTS=$(mktemp)

# OPTIMIZATION: Filter skills by agent FIRST (early filtering)
# This reduces processing from 56 skills to ~10-15 relevant ones
AGENT_FILTER='
    .skills | to_entries[] | 
    select(.value.agents[] == $agent or .value.agents[] == "all") |
    "\(.key)|\(.value.keywords | join(","))|\(.value.agents | join(","))|\(.value.priority)|\(.value.size)"
'

# Analyze only agent-relevant skills
jq -r --arg agent "$AGENT" "$AGENT_FILTER" "$REGISTRY_FILE" | while IFS='|' read -r skill_name skill_keywords skill_agents skill_priority skill_size; do
    
    # Count keyword matches (both directions)
    matches=0
    query_keywords_count=$(echo "$KEYWORDS" | wc -w)
    
    # Count how many query keywords match skill keywords
    for keyword in $KEYWORDS; do
        if echo "$skill_keywords" | grep -qi "$keyword"; then
            matches=$((matches + 1))
        fi
    done
    
    # Calculate keyword score based on query coverage (0-100)
    # This rewards skills that match more of what the user asked for
    if [ $query_keywords_count -gt 0 ]; then
        keyword_score=$((matches * 100 / query_keywords_count))
    else
        keyword_score=0
    fi
    
    # Calculate agent score (0 or 100)
    agent_score=0
    if echo "$skill_agents" | grep -q "$AGENT"; then
        agent_score=100
    fi
    
    # Calculate priority score (0-100)
    case "$skill_priority" in
        critical) priority_score=100 ;;
        high) priority_score=75 ;;
        medium) priority_score=50 ;;
        low) priority_score=25 ;;
        *) priority_score=0 ;;
    esac
    
    # Calculate total relevance using weights
    relevance=$(LC_NUMERIC=C echo "scale=2; ($keyword_score * $KEYWORD_WEIGHT) + ($agent_score * $AGENT_WEIGHT) + ($priority_score * $PRIORITY_WEIGHT)" | bc)
    
    # Output result
    echo "$skill_name|$relevance|$skill_size|$matches|$keyword_score|$agent_score" >> "$TEMP_RESULTS"
done

# Sort by relevance (descending)
sort -t'|' -k2 -rn "$TEMP_RESULTS" > "${TEMP_RESULTS}.sorted"
mv "${TEMP_RESULTS}.sorted" "$TEMP_RESULTS"

if [ "$DEBUG" = "true" ]; then
    print_info "Top 10 skills by relevance:"
    head -10 "$TEMP_RESULTS" | while IFS='|' read -r name rel size matches kw_score ag_score; do
        LC_NUMERIC=C printf "  %-35s %5.1f%% (%d matches, %d tokens)\n" "$name" "$rel" "$matches" "$size"
    done
    echo ""
fi

# ============================================
# STEP 3: Select Skills to Load
# ============================================
print_section "3. Selecting Skills"
echo ""

SELECTED_SKILLS=""
SELECTED_COUNT=0
TOTAL_TOKENS=0

while IFS='|' read -r skill_name relevance size matches kw_score ag_score; do
    # Check threshold
    threshold_check=$(echo "$relevance >= $THRESHOLD" | bc)
    if [ "$threshold_check" -eq 0 ]; then
        if [ "$DEBUG" = "true" ]; then
            print_info "Stopping: relevance ($relevance%) below threshold ($THRESHOLD%)"
        fi
        break
    fi
    
    # Check max skills
    if [ $SELECTED_COUNT -ge $MAX_SKILLS ]; then
        if [ "$DEBUG" = "true" ]; then
            print_info "Stopping: max skills ($MAX_SKILLS) reached"
        fi
        break
    fi
    
    # Check max tokens
    new_total=$((TOTAL_TOKENS + size))
    if [ $new_total -gt $MAX_TOKENS ]; then
        if [ "$DEBUG" = "true" ]; then
            print_info "Skipping $skill_name: would exceed token limit ($new_total > $MAX_TOKENS)"
        fi
        continue
    fi
    
    # Add to selection
    SELECTED_SKILLS="$SELECTED_SKILLS $skill_name"
    SELECTED_COUNT=$((SELECTED_COUNT + 1))
    TOTAL_TOKENS=$new_total
    
    LC_NUMERIC=C printf "  ✓ %-35s %5.1f%% relevance, %6d tokens\n" "$skill_name" "$relevance" "$size"
    
done < "$TEMP_RESULTS"

echo ""

# ============================================
# STEP 4: Summary
# ============================================
print_section "4. Summary"
echo ""

if [ $SELECTED_COUNT -eq 0 ]; then
    echo "  ⚠️  No skills meet threshold ($THRESHOLD%)"
    echo "  💡 Fallback: Would load core skills for $AGENT"
    echo ""
    
    # Show core skills for agent
    CORE_SKILLS=$(jq -r --arg agent "$AGENT" '
        .[$agent].recommended[0:2] | join(", ")
    ' "$PROJECT_ROOT/config/agent-skills.json" 2>/dev/null || echo "N/A")
    
    if [ "$CORE_SKILLS" != "N/A" ]; then
        echo "  Core skills: $CORE_SKILLS"
    fi
else
    echo "  Selected: $SELECTED_COUNT skills"
    echo "  Total tokens: $TOTAL_TOKENS"
    echo "  Skills: $(echo $SELECTED_SKILLS | tr ' ' ',')"
    echo ""
    
    # Calculate savings
    TOTAL_AVAILABLE=$(jq '[.skills[].size] | add' "$REGISTRY_FILE")
    TOKENS_SAVED=$((TOTAL_AVAILABLE - TOTAL_TOKENS))
    EFFICIENCY=$((TOKENS_SAVED * 100 / TOTAL_AVAILABLE))
    
    echo "  💰 Optimization:"
    echo "     Available: $TOTAL_AVAILABLE tokens"
    echo "     Saved: $TOKENS_SAVED tokens ($EFFICIENCY%)"
fi

echo ""

# ============================================
# OPTIMIZATION: Save to Cache
# ============================================
if [ $SELECTED_COUNT -gt 0 ]; then
    SKILLS_CSV=$(echo $SELECTED_SKILLS | tr ' ' ',')
    CACHE_ENTRY=$(jq -n \
        --arg skills "$SKILLS_CSV" \
        --arg timestamp "$(date +%s)" \
        '{skills: $skills, timestamp: ($timestamp | tonumber)}')
    
    # Update cache file
    if [ -f "$CACHE_FILE" ]; then
        jq --arg key "$CACHE_KEY" --argjson entry "$CACHE_ENTRY" \
            '.[$key] = $entry' "$CACHE_FILE" > "${CACHE_FILE}.tmp" && \
            mv "${CACHE_FILE}.tmp" "$CACHE_FILE"
    else
        echo "{\"$CACHE_KEY\": $CACHE_ENTRY}" > "$CACHE_FILE"
    fi
    
    if [ "$DEBUG" = "true" ]; then
        print_info "✓ Cached result for future queries"
    fi
fi

# Cleanup
rm "$TEMP_RESULTS"

# Exit with appropriate code
if [ $SELECTED_COUNT -eq 0 ]; then
    exit 2  # No skills selected (fallback needed)
else
    exit 0  # Success
fi
