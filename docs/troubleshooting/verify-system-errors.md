# Troubleshooting: verify-system.sh

Guía para diagnosticar y solucionar errores en el script de verificación del sistema.

## Uso del Modo Debug

Para obtener información detallada sobre qué está verificando el script:

```bash
bash scripts/verify-system.sh --debug
```

Esto mostrará:
- Rutas exactas que se están verificando
- Archivos encontrados en cada directorio
- Valores de variables durante la ejecución
- Comandos ejecutados internamente

## Errores Comunes

### 1. "Not found config/betteragents.json"

**Causa:** El script no se está ejecutando desde el directorio correcto.

**Solución:**
```bash
# Asegúrate de estar en el directorio raíz del proyecto
cd /ruta/a/BetterAgents
bash scripts/verify-system.sh
```

**Debug:**
```bash
bash scripts/verify-system.sh --debug
# Verifica las líneas:
# [DEBUG] Script directory: ...
# [DEBUG] Project root: ...
```

---

### 2. "Only X agents (expected 13)"

**Causa:** Faltan archivos de agentes o hay archivos extra.

**Solución:**
```bash
# Verifica qué agentes existen
ls -1 .kiro/steering/agents/*.md

# Deberías ver 13 archivos:
# - agentx.md
# - architect.md
# - coder.md
# - critic.md
# - data-scientist.md
# - devops.md
# - product-manager.md
# - researcher.md
# - security.md
# - teacher.md
# - tester.md
# - ux-designer.md
# - writer.md
```

**Debug:**
```bash
bash scripts/verify-system.sh --debug 2>&1 | grep "Found.*agent files"
```

---

### 3. "agentx: Faltan secciones"

**Causa:** El archivo agentx.md no tiene la estructura esperada.

**Solución:**
```bash
# Verifica que agentx.md tenga la sección ## ROLE DEFINITION
grep "^## ROLE" .kiro/steering/agents/agentx.md
```

**Estructura esperada para agentx.md:**
```markdown
## ROLE DEFINITION
...contenido...
```

**Debug:**
```bash
bash scripts/verify-system.sh --debug 2>&1 | grep -A 5 "Checking agent: agentx"
```

---

### 4. "[agent]: Faltan secciones"

**Causa:** Un agente especializado no tiene las secciones `## Role` y `## Expertise`.

**Solución:**
```bash
# Verifica la estructura del agente
grep "^##" .kiro/steering/agents/[agent].md | head -5
```

**Estructura esperada:**
```markdown
## Role
...descripción del rol...

## Expertise
...áreas de expertise...
```

**Debug:**
```bash
bash scripts/verify-system.sh --debug 2>&1 | grep -A 3 "Checking agent: [agent]"
```

---

### 5. "Sistema de memoria: X archivos JSON encontrados"

**Causa:** No se encuentran exactamente 4 archivos JSON en `.kiro/memory/`.

**Solución:**
```bash
# Verifica qué archivos JSON existen
ls -1 .kiro/memory/*.json

# Deberías tener:
# - active-context.json
# - decision-log.json
# - patterns.json
# - progress.json
```

**Si faltan archivos:**
```bash
# Copia los templates
cp templates/memory/*.json .kiro/memory/
```

**Debug:**
```bash
bash scripts/verify-system.sh --debug 2>&1 | grep -A 10 "Memory JSON files"
```

---

### 6. "Skills folder not found"

**Causa:** No existe el directorio `.kiro/skills/`.

**Solución:**
```bash
# Verifica si existe
ls -la .kiro/skills/

# Si no existe, créalo
mkdir -p .kiro/skills/
```

**Debug:**
```bash
bash scripts/verify-system.sh --debug 2>&1 | grep "skills"
```

---

### 7. Errores de sintaxis bash

**Síntomas:**
```
verify-system.sh: line X: syntax error near unexpected token 'Y'
```

**Causa:** Error de sintaxis en el script (paréntesis, comillas, o estructuras mal cerradas).

**Solución:**
```bash
# Verifica la sintaxis del script
bash -n scripts/verify-system.sh

# Si hay error, revisa la línea indicada
sed -n 'X,Xp' scripts/verify-system.sh  # donde X es el número de línea
```

**Errores comunes:**
- `fi` sin `if` correspondiente
- `done` sin `for`/`while` correspondiente
- Comillas sin cerrar
- Paréntesis desbalanceados

---

### 8. "command not found: grep/find/ls"

**Causa:** Comandos básicos no están en el PATH.

**Solución:**
```bash
# Verifica tu PATH
echo $PATH

# Usa rutas absolutas si es necesario
/bin/ls -1 .kiro/memory/*.json
```

---

## Verificación Manual Paso a Paso

Si el script falla completamente, puedes verificar manualmente:

### 1. Estructura de directorios
```bash
# Verifica que existan los directorios principales
test -d .kiro/steering/agents && echo "✅ Agents" || echo "❌ Agents"
test -d .kiro/memory && echo "✅ Memory" || echo "❌ Memory"
test -d .kiro/skills && echo "✅ Skills" || echo "❌ Skills"
test -d scripts && echo "✅ Scripts" || echo "❌ Scripts"
```

### 2. Archivos de configuración
```bash
# Verifica archivos críticos
test -f config/betteragents.json && echo "✅ Config" || echo "❌ Config"
test -f .gitignore && echo "✅ Gitignore" || echo "❌ Gitignore"
```

### 3. Agentes
```bash
# Cuenta agentes
ls -1 .kiro/steering/agents/*.md 2>/dev/null | wc -l
# Debería mostrar: 13
```

### 4. Memoria
```bash
# Cuenta archivos JSON
find .kiro/memory -maxdepth 1 -name "*.json" -type f | wc -l
# Debería mostrar: 4
```

### 5. Skills
```bash
# Cuenta skills
ls -1 .kiro/skills/ 2>/dev/null | wc -l
# Debería mostrar: 56 (o el número que tengas instalado)
```

---

## Logs y Diagnóstico Avanzado

### Guardar output completo
```bash
bash scripts/verify-system.sh --debug > verify-output.log 2>&1
```

### Buscar errores específicos
```bash
# Buscar líneas con ERROR
grep -i "error" verify-output.log

# Buscar líneas con WARNING
grep -i "warning" verify-output.log

# Ver solo secciones con problemas
grep -E "❌|⚠️" verify-output.log
```

### Verificar permisos
```bash
# Verifica que los scripts sean ejecutables
ls -la scripts/*.sh

# Si no son ejecutables:
chmod +x scripts/*.sh
```

---

## Solución de Problemas por Sección

### Sección 1: File Structure
- Verifica `.kiro/steering/agents/`
- Verifica `.kiro/memory/`
- Verifica `.kiro/skills/`

### Sección 2: Análisis de Agentes
- Revisa formato de cada archivo `.md`
- Verifica headers `## Role` y `## Expertise`
- Para agentx: verifica `## ROLE DEFINITION`

### Sección 3: Skills Recomendados
- Busca comandos `npx skills add` en archivos de agentes
- Verifica sintaxis correcta (con espacio, no `skillsadd`)

### Sección 4: Skills Instalados
- Verifica `.kiro/skills/` existe
- Cuenta subdirectorios en `.kiro/skills/`

### Sección 5-9: Otras verificaciones
- Usa `--debug` para ver qué está verificando
- Revisa rutas y archivos específicos mencionados

---

## Contacto y Soporte

Si después de seguir esta guía sigues teniendo problemas:

1. Ejecuta: `bash scripts/verify-system.sh --debug > debug.log 2>&1`
2. Revisa `debug.log` para identificar el problema exacto
3. Busca el error en esta guía
4. Si no encuentras solución, reporta el issue con el log completo

---

**Última actualización:** 2026-02-16
