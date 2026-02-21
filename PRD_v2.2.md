# Product Requirements Document (PRD)
# Bashmenu v2.2 "Stable & Enhanced"

**Fecha:** 2026-02-20  
**Versión:** 2.2  
**Estado:** Aprobado para Implementación  
**Autor:** Equipo Bashmenu

---

## 1. Resumen Ejecutivo

Bashmenu v2.2 es una actualización mayor que estabiliza la arquitectura, elimina deuda técnica, e implementa funcionalidades críticas faltantes. El objetivo es tener un producto robusto, bien testeado, y listo para producción.

### Objetivos Principales

1. **Estabilizar arquitectura** - Eliminar código legacy, limpiar estructura
2. **Modernizar configuración** - Sistema .env flexible y portable
3. **Implementar funcionalidades core** - Caching, búsqueda, favoritos, hooks
4. **Aumentar calidad** - Tests >60%, ShellCheck, documentación completa
5. **Mantener compatibilidad** - Migración automática desde v2.1

### Métricas de Éxito

| Métrica | v2.1 | v2.2 Objetivo |
|---------|------|---------------|
| Cobertura de tests | <20% | >60% |
| ShellCheck errors | N/A | 0 críticos |
| Startup time | 2.5s | <1.5s |
| Funcionalidades implementadas | 45% | 75% |
| Documentación | 60% | 90% |

---

## 2. Alcance del Proyecto

### 2.1 En Alcance (v2.2)

#### Arquitectura y Limpieza
- ✅ Eliminar código legacy (menu_legacy.sh, 1788 líneas)
- ✅ Reorganizar estructura de directorios
- ✅ Sistema de configuración .env
- ✅ Paths relativos donde aplique
- ✅ Instalación system-wide mejorada

#### Funcionalidades Nuevas
- ✅ Sistema de caching inteligente
- ✅ Búsqueda en tiempo real
- ✅ Sistema de favoritos
- ✅ Ayuda contextual mejorada
- ✅ Auditoría JSON estructurada
- ✅ Carga lazy de módulos opcionales
- ✅ Sistema de hooks básico

#### Calidad y Testing
- ✅ Tests unitarios (>60% coverage)
- ✅ Tests de integración
- ✅ Tests de seguridad
- ✅ ShellCheck integration
- ✅ CI/CD con GitHub Actions

#### Documentación
- ✅ Arquitectura completa
- ✅ API documentation
- ✅ Guías de usuario
- ✅ Guías de desarrollo
- ✅ Guía de migración

### 2.2 Fuera de Alcance (v2.3+)

- ❌ API de plugins multi-lenguaje (Python, Go, Node.js)
- ❌ Marketplace de plugins
- ❌ Autenticación LDAP/Active Directory
- ❌ Interfaz web
- ❌ Soporte para Windows/WSL

---

## 3. Requisitos Funcionales

### RF-001: Sistema de Configuración .env

**Prioridad:** CRÍTICA  
**Complejidad:** Media

**Descripción:**
Sistema de configuración basado en archivo .env que reemplaza config.conf con variables de entorno estándar.

**Criterios de Aceptación:**
- [ ] Archivo .bashmenu.env.example versionado
- [ ] .bashmenu.env en .gitignore
- [ ] Carga automática de variables
- [ ] Validación de variables requeridas
- [ ] Valores por defecto sensatos
- [ ] Soporte para comentarios
- [ ] Prioridad: ENV > ~/.bashmenu/.bashmenu.env > /opt/bashmenu/etc/.bashmenu.env > defaults

**Variables Mínimas:**
```bash
# Paths
BASHMENU_HOME=/opt/bashmenu
BASHMENU_USER_DIR=~/.bashmenu
BASHMENU_PLUGINS_DIR=~/.bashmenu/plugins
BASHMENU_LOG_DIR=/var/log/bashmenu

# Configuración
BASHMENU_THEME=modern
BASHMENU_LOG_LEVEL=INFO
BASHMENU_ENABLE_CACHE=true
BASHMENU_CACHE_TTL=3600
BASHMENU_ENABLE_PERMISSIONS=false
```

---

### RF-002: Sistema de Caching

**Prioridad:** ALTA  
**Complejidad:** Media

**Descripción:**
Cache inteligente de escaneo de directorios y validación de scripts para mejorar performance.

**Criterios de Aceptación:**
- [ ] Cache de escaneo de directorios
- [ ] Cache de validación de scripts
- [ ] Invalidación automática al detectar cambios (mtime)
- [ ] TTL configurable
- [ ] Comando para limpiar cache manualmente
- [ ] Métricas de hit rate
- [ ] Startup time <1.5s con cache caliente

**Implementación:**
```bash
~/.bashmenu/cache/
├── scripts.cache          # Lista de scripts escaneados
├── validation.cache       # Resultados de validación
└── metadata.cache         # Metadatos (mtime, checksums)
```

---

### RF-003: Búsqueda en Tiempo Real

**Prioridad:** ALTA  
**Complejidad:** Media

**Descripción:**
Búsqueda incremental de scripts por nombre, descripción, o tags.

**Criterios de Aceptación:**
- [ ] Búsqueda incremental mientras se escribe
- [ ] Búsqueda por nombre de script
- [ ] Búsqueda por descripción
- [ ] Búsqueda por tags (si existen)
- [ ] Highlighting de resultados
- [ ] Navegación con teclado en resultados
- [ ] Tecla de atajo: 's' o '/'
- [ ] Escape para cancelar
- [ ] Performance: <200ms para 500 scripts

**UI:**
```
┌─────────────────────────────────────────┐
│ Search: depl█                           │
├─────────────────────────────────────────┤
│ 🚀 Deploy to Production                 │
│ 🚀 Deploy to Staging                    │
│ 📥 Deploy Rollback                      │
├─────────────────────────────────────────┤
│ 3 results found                         │
└─────────────────────────────────────────┘
```

---

### RF-004: Sistema de Favoritos

**Prioridad:** ALTA  
**Complejidad:** Baja

**Descripción:**
Marcar scripts como favoritos para acceso rápido.

**Criterios de Aceptación:**
- [ ] Marcar/desmarcar scripts con tecla 'f'
- [ ] Vista dedicada de favoritos (tecla 'F')
- [ ] Persistencia en ~/.bashmenu/favorites.json
- [ ] Indicador visual en menú (⭐)
- [ ] Acceso rápido desde menú principal
- [ ] Favoritos por usuario
- [ ] Exportar/importar favoritos

**Formato JSON:**
```json
{
  "version": "1.0",
  "favorites": [
    {
      "script": "/path/to/script.sh",
      "name": "Deploy Production",
      "added": "2026-02-20T10:30:00Z"
    }
  ]
}
```

---

### RF-005: Ayuda Contextual Mejorada

**Prioridad:** MEDIA  
**Complejidad:** Media

**Descripción:**
Sistema de ayuda integrado con tooltips, ejemplos, y tutorial interactivo.

**Criterios de Aceptación:**
- [ ] Ayuda contextual con tecla 'h' o '?'
- [ ] Tooltips para cada opción del menú
- [ ] Tutorial interactivo en primer uso
- [ ] Ejemplos de uso para cada script
- [ ] Tips aleatorios en pantalla de inicio
- [ ] Búsqueda en ayuda
- [ ] Ayuda offline (no requiere internet)

**Contenido de Ayuda:**
- Atajos de teclado
- Cómo agregar scripts
- Cómo usar favoritos
- Cómo buscar
- Solución de problemas comunes
- Ejemplos prácticos

---

### RF-006: Auditoría JSON Estructurada

**Prioridad:** ALTA  
**Complejidad:** Media

**Descripción:**
Logs de auditoría en formato JSON estructurado para análisis y compliance.

**Criterios de Aceptación:**
- [ ] Logs en formato JSON
- [ ] Un evento por línea (JSONL)
- [ ] Campos: timestamp, user, action, script, result, duration, error
- [ ] Rotación automática de logs
- [ ] Búsqueda y filtrado
- [ ] Exportación de reportes
- [ ] Inmutabilidad (append-only)

**Formato:**
```json
{
  "timestamp": "2026-02-20T10:30:45.123Z",
  "user": "admin",
  "action": "execute_script",
  "script": "/opt/bashmenu/plugins/deploy.sh",
  "result": "success",
  "duration_ms": 1234,
  "exit_code": 0,
  "parameters": ["production"],
  "session_id": "abc123"
}
```

**Ubicación:**
- System-wide: `/var/log/bashmenu/audit.json`
- User: `~/.bashmenu/logs/audit.json`

---

### RF-007: Carga Lazy de Módulos

**Prioridad:** MEDIA  
**Complejidad:** Media

**Descripción:**
Carga bajo demanda de módulos opcionales para mejorar startup time.

**Criterios de Aceptación:**
- [ ] Módulos core se cargan al inicio
- [ ] Módulos opcionales se cargan on-demand
- [ ] Indicador de carga para módulos pesados
- [ ] Precarga inteligente de módulos frecuentes
- [ ] Configuración de módulos a precargar
- [ ] Startup time <1s con lazy loading

**Módulos Core (siempre cargados):**
- core/config.sh
- core/logger.sh
- core/utils.sh
- menu/core.sh
- menu/display.sh
- menu/input.sh

**Módulos Lazy (carga on-demand):**
- ui/dialog_wrapper.sh (solo si se usa)
- ui/fzf_integration.sh (solo si se usa)
- ui/notifications.sh (solo si se usa)
- features/search.sh (solo al buscar)
- features/favorites.sh (solo al acceder favoritos)

---

### RF-008: Sistema de Hooks Básico

**Prioridad:** MEDIA  
**Complejidad:** Alta

**Descripción:**
Sistema de hooks para extender funcionalidad sin modificar código core.

**Criterios de Aceptación:**
- [ ] Hooks: pre_execute, post_execute, on_error, on_load, on_exit
- [ ] Registro de hooks desde plugins
- [ ] Prioridad de ejecución
- [ ] Hooks pueden cancelar ejecución (pre_execute)
- [ ] Documentación de hooks disponibles
- [ ] Ejemplos de uso

**API de Hooks:**
```bash
# Registrar hook
register_hook "pre_execute" "my_validation_function" 10

# Hook function
my_validation_function() {
    local script_path="$1"
    # Validación custom
    if [[ ! -f "$script_path.approved" ]]; then
        echo "Script not approved"
        return 1  # Cancela ejecución
    fi
    return 0
}
```

**Hooks Disponibles:**
- `pre_execute` - Antes de ejecutar script (puede cancelar)
- `post_execute` - Después de ejecutar script
- `on_error` - Cuando hay error
- `on_load` - Al cargar menú
- `on_exit` - Al salir del sistema

---

### RF-009: Paths Relativos

**Prioridad:** CRÍTICA  
**Complejidad:** Media

**Descripción:**
Convertir paths absolutos hardcodeados a paths relativos basados en variables.

**Criterios de Aceptación:**
- [ ] Eliminar todos los paths hardcodeados
- [ ] Usar variables de entorno para paths base
- [ ] Paths relativos desde $BASHMENU_HOME
- [ ] Compatibilidad con instalación system-wide y user
- [ ] Detección automática de ubicación
- [ ] Validación de paths en startup

**Antes:**
```bash
source /home/stk/GIT/Bashmenu/src/utils.sh
PLUGIN_DIR="/home/stk/GIT/Bashmenu/plugins"
```

**Después:**
```bash
source "${BASHMENU_HOME}/lib/bashmenu/core/utils.sh"
PLUGIN_DIR="${BASHMENU_PLUGINS_DIR}"
```

---

### RF-010: Migración Automática

**Prioridad:** CRÍTICA  
**Complejidad:** Alta

**Descripción:**
Script de migración automática de v2.1 a v2.2 con rollback.

**Criterios de Aceptación:**
- [ ] Detecta instalación v2.1
- [ ] Backup completo antes de migrar
- [ ] Migra configuración a .bashmenu.env
- [ ] Convierte paths absolutos a relativos
- [ ] Actualiza scripts.conf
- [ ] Mueve archivos a nueva estructura
- [ ] Valida migración
- [ ] Rollback automático si falla
- [ ] Log detallado de migración
- [ ] Modo dry-run para preview

**Comando:**
```bash
./migrate.sh                    # Migración normal
./migrate.sh --dry-run          # Preview sin cambios
./migrate.sh --rollback         # Revertir migración
```

---

## 4. Requisitos No Funcionales

### NFR-001: Performance

- Startup time <1.5s con cache caliente
- Startup time <3s con cache frío
- Búsqueda <200ms para 500 scripts
- Navegación <100ms entre menús
- Ejecución de scripts <500ms overhead

### NFR-002: Seguridad

- Zero vulnerabilidades críticas (ShellCheck)
- Validación de todos los inputs
- Paths sanitizados
- Logs inmutables (append-only)
- Permisos correctos en archivos sensibles
- Auditoría completa de acciones

### NFR-003: Compatibilidad

- Bash 4.0+
- Multi-distro: Ubuntu 18.04+, Debian 10+, CentOS 7+, Arch
- Backward compatibility con v2.1
- Migración automática sin pérdida de datos
- Fallback a valores por defecto si config falla

### NFR-004: Mantenibilidad

- Todas las funciones <100 líneas
- Cobertura de tests >60%
- Documentación inline completa
- Código pasa ShellCheck sin errores críticos
- Estructura modular clara

### NFR-005: Usabilidad

- Interfaz intuitiva
- Mensajes de error claros
- Ayuda contextual disponible
- Tutorial para nuevos usuarios
- Documentación completa offline

---

## 5. Dependencias

### Requeridas (Core)
- bash 4.0+
- coreutils (cat, grep, sed, awk, etc.)
- findutils (find)

### Opcionales (Enhanced Features)
- dialog o whiptail (UI mejorada)
- fzf (búsqueda fuzzy)
- jq (procesamiento JSON)
- notify-send (notificaciones de escritorio)
- shellcheck (desarrollo)
- bats (testing)

---

## 6. Riesgos y Mitigaciones

| Riesgo | Probabilidad | Impacto | Mitigación |
|--------|--------------|---------|------------|
| Migración rompe instalaciones existentes | Media | Alto | Script de migración robusto con rollback |
| Performance degradada | Baja | Medio | Benchmarks y optimización |
| Incompatibilidad con distros | Media | Medio | Testing en múltiples distros |
| Usuarios no migran | Alta | Bajo | Mantener v2.1 como LTS 6 meses |
| Tests insuficientes | Media | Alto | Objetivo >60% coverage obligatorio |

---

## 7. Plan de Release

### v2.2.0-alpha (Semana 3)
- Arquitectura limpia
- Sistema .env
- Paths relativos
- Tests básicos

### v2.2.0-beta (Semana 5)
- Todas las funcionalidades implementadas
- Tests >60%
- Documentación completa
- Testing en múltiples distros

### v2.2.0-rc1 (Semana 6)
- Bug fixes
- Performance tuning
- Validación final

### v2.2.0 (Final de Semana 6)
- Release estable
- Anuncio oficial
- Migración recomendada

---

## 8. Criterios de Aceptación Final

- [ ] Todas las funcionalidades implementadas y testeadas
- [ ] Cobertura de tests >60%
- [ ] ShellCheck sin errores críticos
- [ ] Documentación completa
- [ ] Migración automática funcional
- [ ] Validado en Ubuntu, Debian, CentOS, Arch
- [ ] Performance cumple objetivos
- [ ] Backward compatibility verificada
- [ ] Release notes completas
- [ ] Instaladores actualizados

---

**Aprobado por:** Equipo Bashmenu  
**Fecha de Aprobación:** 2026-02-20  
**Próxima Revisión:** Semana 3 (checkpoint)

