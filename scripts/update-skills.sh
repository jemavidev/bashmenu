#!/bin/bash
# Update Skills Registry with Enhanced Keywords
# Expands keywords for all 56 skills based on their content and purpose

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
REGISTRY_FILE="$PROJECT_ROOT/.kiro/settings/skills-registry.json"
SKILLS_DIR="$PROJECT_ROOT/.kiro/steering/skills"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

print_success() { echo -e "${GREEN}✓ $1${NC}"; }
print_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
print_section() { echo -e "${CYAN}━━━ $1 ━━━${NC}"; }

echo "🔄 UPDATING SKILLS KEYWORDS"
echo "==========================="
echo ""

# Backup registry
BACKUP_FILE="${REGISTRY_FILE}.backup-$(date +%Y%m%d-%H%M%S)"
cp "$REGISTRY_FILE" "$BACKUP_FILE"
print_success "Backup created: $BACKUP_FILE"
echo ""

# Define comprehensive keywords for each skill
# Format: skill_name|keyword1,keyword2,keyword3,...

declare -A SKILL_KEYWORDS

# Development Skills
SKILL_KEYWORDS["async-python-patterns"]="async,asyncio,await,python,concurrent,coroutine,asynchronous,asincrono,concurrente,paralelo,parallel,event loop,non-blocking"
SKILL_KEYWORDS["nodejs-backend-patterns"]="nodejs,node,backend,express,fastify,api,rest,server,servidor,middleware,routing"
SKILL_KEYWORDS["modern-javascript-patterns"]="javascript,js,es6,es2015,arrow,promise,async,await,destructuring,spread,modern"
SKILL_KEYWORDS["python-performance-optimization"]="python,performance,optimization,profile,cprofile,memory,speed,optimizar,rendimiento"
SKILL_KEYWORDS["python-testing-patterns"]="python,pytest,test,testing,fixture,mock,tdd,unit test,prueba,testear"
SKILL_KEYWORDS["javascript-testing-patterns"]="javascript,jest,vitest,testing library,test,mock,tdd,unit,integration"
SKILL_KEYWORDS["typescript-advanced-types"]="typescript,types,generic,conditional,mapped,utility,type safety,tipado"
SKILL_KEYWORDS["vercel-react-best-practices"]="react,vercel,next,nextjs,performance,optimization,bundle,ssr,rsc"
SKILL_KEYWORDS["next-best-practices"]="next,nextjs,react,ssr,ssg,isr,app router,pages,routing,metadata"

# Architecture Skills
SKILL_KEYWORDS["architecture-patterns"]="architecture,pattern,clean,hexagonal,ddd,domain,microservices,arquitectura,patron"
SKILL_KEYWORDS["architecture-decision-records"]="adr,decision,architecture,record,documentation,arquitectura,decision"
SKILL_KEYWORDS["api-design-principles"]="api,rest,graphql,design,endpoint,resource,http,restful,diseño"
SKILL_KEYWORDS["microservices-patterns"]="microservices,distributed,service,event-driven,saga,cqrs,microservicios"
SKILL_KEYWORDS["database-migration"]="database,migration,schema,alter,upgrade,downgrade,migracion,base datos"
SKILL_KEYWORDS["sql-optimization-patterns"]="sql,query,optimization,index,explain,performance,database,optimizar,consulta"
SKILL_KEYWORDS["postgresql-table-design"]="postgresql,postgres,table,schema,design,constraint,index,diseño,tabla"

# Design Skills
SKILL_KEYWORDS["accessibility-compliance"]="accessibility,accesible,accesibilidad,wcag,a11y,screen reader,lector pantalla,aria,semantic,semantico,contrast,contraste,keyboard,teclado,navigation,navegacion,inclusive,inclusivo,disability,discapacidad"
SKILL_KEYWORDS["ui-ux-pro-max"]="ui,ux,design,interface,user experience,experiencia usuario,diseño,interfaz,usability,usabilidad,wireframe,prototype,prototipo,figma,sketch"
SKILL_KEYWORDS["ux-designer"]="ux,user experience,design,interface,usability,wireframe,prototype,research,usuario"
SKILL_KEYWORDS["frontend-design"]="frontend,design,ui,interface,component,layout,responsive,diseño,interfaz,componente"
SKILL_KEYWORDS["web-design-guidelines"]="web,design,guidelines,best practices,standards,diseño,guia,estandar"
SKILL_KEYWORDS["canvas-design"]="canvas,design,visual,art,graphic,poster,diseño,grafico,arte,visual"
SKILL_KEYWORDS["interaction-design"]="interaction,animation,transition,microinteraction,motion,interaccion,animacion"
SKILL_KEYWORDS["responsive-design"]="responsive,mobile,tablet,desktop,breakpoint,media query,adaptable,movil"

# Design System Skills
SKILL_KEYWORDS["design-system-patterns"]="design system,component library,tokens,theme,pattern,sistema diseño,biblioteca"
SKILL_KEYWORDS["tailwind-design-system"]="tailwind,css,utility,design system,theme,tokens,sistema diseño"

# Testing Skills
SKILL_KEYWORDS["e2e-testing-patterns"]="e2e,end-to-end,playwright,cypress,integration,test,testing,prueba"
SKILL_KEYWORDS["test-driven-development"]="tdd,test driven,red green refactor,unit test,testing,prueba"
SKILL_KEYWORDS["systematic-debugging"]="debug,debugging,error,bug,troubleshoot,depurar,error,problema"
SKILL_KEYWORDS["webapp-testing"]="webapp,testing,browser,selenium,playwright,test,prueba,navegador"

# Documentation Skills
SKILL_KEYWORDS["doc-coauthoring"]="documentation,docs,writing,coauthor,document,documentacion,escribir,redactar"
SKILL_KEYWORDS["writing-skills"]="writing,documentation,technical writing,docs,redaccion,escribir,documentar"
SKILL_KEYWORDS["changelog-automation"]="changelog,release notes,version,history,automation,historial,version"

# DevOps Skills
SKILL_KEYWORDS["docker-expert"]="docker,container,dockerfile,image,compose,containerization,contenedor"
SKILL_KEYWORDS["deployment-pipeline-design"]="deployment,pipeline,ci,cd,cicd,continuous,deploy,despliegue"
SKILL_KEYWORDS["github-actions-templates"]="github actions,workflow,ci,cd,automation,pipeline,automatizacion"
SKILL_KEYWORDS["monorepo-management"]="monorepo,workspace,turborepo,nx,pnpm,lerna,mono repositorio"

# Security Skills
SKILL_KEYWORDS["auth-implementation-patterns"]="auth,authentication,authorization,jwt,oauth,session,autenticacion,autorizacion"
SKILL_KEYWORDS["security"]="security,vulnerability,owasp,xss,csrf,injection,seguridad,vulnerabilidad"

# General Skills
SKILL_KEYWORDS["brainstorming"]="brainstorm,ideation,creative,idea,planning,lluvia ideas,planificar"
SKILL_KEYWORDS["code-reviewer"]="code review,review,feedback,quality,revision codigo,revisar"
SKILL_KEYWORDS["receiving-code-review"]="code review,feedback,receiving,revision,recibir"
SKILL_KEYWORDS["requesting-code-review"]="code review,request,solicitar,pedir revision"
SKILL_KEYWORDS["verification-before-completion"]="verification,verify,check,validate,verificar,validar,comprobar"
SKILL_KEYWORDS["executing-plans"]="execute,plan,implementation,implementar,ejecutar,plan"
SKILL_KEYWORDS["writing-plans"]="plan,planning,design,specification,planificar,diseñar,especificar"
SKILL_KEYWORDS["skill-creator"]="skill,create,creator,crear,habilidad"
SKILL_KEYWORDS["writing-skills"]="skill,writing,documentation,escribir,documentar,habilidad"

# Error Handling
SKILL_KEYWORDS["error-handling-patterns"]="error,exception,handling,try catch,result,manejo errores,excepcion"

# Marketing Skills
SKILL_KEYWORDS["marketing-ideas"]="marketing,growth,strategy,promotion,ideas,estrategia,promocion,crecimiento"
SKILL_KEYWORDS["competitor-alternatives"]="competitor,alternative,comparison,vs,competidor,alternativa,comparacion"
SKILL_KEYWORDS["copy-editing"]="copy,editing,content,writing,texto,edicion,contenido,redaccion"
SKILL_KEYWORDS["product-marketing-context"]="product,marketing,context,positioning,producto,contexto,posicionamiento"
SKILL_KEYWORDS["seo-audit"]="seo,audit,optimization,search,ranking,auditoria,optimizacion,busqueda"

# Data Science
SKILL_KEYWORDS["data-scientist"]="data,science,analysis,ml,machine learning,statistics,datos,analisis,estadistica"

# Product Management
SKILL_KEYWORDS["product-manager"]="product,management,roadmap,feature,user story,producto,gestion,historia usuario"
SKILL_KEYWORDS["kpi-dashboard-design"]="kpi,dashboard,metrics,analytics,visualization,metricas,tablero,visualizacion"

# Audit
SKILL_KEYWORDS["audit-website"]="audit,website,seo,performance,security,analysis,auditoria,sitio web,analisis"

# Prompt Engineering
SKILL_KEYWORDS["prompt-engineering-patterns"]="prompt,engineering,llm,ai,gpt,optimization,ingeniera prompts"

print_section "Updating Keywords"
echo ""

# Create temporary file with updates
TEMP_FILE=$(mktemp)
cp "$REGISTRY_FILE" "$TEMP_FILE"

updated_count=0
skipped_count=0

# Update each skill
for skill_name in "${!SKILL_KEYWORDS[@]}"; do
    keywords="${SKILL_KEYWORDS[$skill_name]}"
    
    # Check if skill exists in registry
    if jq -e ".skills[\"$skill_name\"]" "$TEMP_FILE" > /dev/null 2>&1; then
        # Convert comma-separated keywords to JSON array
        keywords_json=$(echo "$keywords" | tr ',' '\n' | jq -R . | jq -s .)
        
        # Update keywords in registry
        jq --arg skill "$skill_name" --argjson kw "$keywords_json" \
            '.skills[$skill].keywords = $kw' \
            "$TEMP_FILE" > "${TEMP_FILE}.tmp"
        
        mv "${TEMP_FILE}.tmp" "$TEMP_FILE"
        
        print_success "Updated: $skill_name ($(echo $keywords | tr ',' '\n' | wc -l) keywords)"
        updated_count=$((updated_count + 1))
    else
        echo "  ⚠️  Skipped: $skill_name (not found in registry)"
        skipped_count=$((skipped_count + 1))
    fi
done

echo ""
print_section "Summary"
echo ""
echo "  Updated: $updated_count skills"
echo "  Skipped: $skipped_count skills"
echo ""

# Save updated registry
mv "$TEMP_FILE" "$REGISTRY_FILE"
print_success "Registry updated: $REGISTRY_FILE"

echo ""
print_info "Backup available at: $BACKUP_FILE"
echo ""

print_success "Keywords expansion complete!"
