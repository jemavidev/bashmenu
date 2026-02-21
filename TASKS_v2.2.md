# Bashmenu v2.2 - Task Breakdown

**Timeline:** 6 semanas  
**Equipo:** 1-2 desarrolladores  
**Metodología:** Agile/Iterativo

---

## Fase 1: Limpieza y Estructura (Semana 1-2)

### TASK-001: Setup de Entorno de Desarrollo
**Prioridad:** CRÍTICA  
**Estimación:** 2 horas  
**Asignado:** Dev  
**Dependencias:** Ninguna

**Subtareas:**
- [ ] Instalar ShellCheck
- [ ] Instalar BATS
- [ ] Configurar git hooks (pre-commit)
- [ ] Crear Makefile
- [ ] Configurar VS Code (opcional)
- [ ] Documentar setup en README

**Criterios de Aceptación:**
- ShellCheck funciona en todos los archivos .sh
- BATS ejecuta tests existentes
- Pre-commit hook valida código antes de commit

---

### TASK-002: Crear Nueva Estructura de Directorios
**Prioridad:** CRÍTICA  
**Estimación:** 4 horas  
**Asignado:** Dev  
**Dependencias:** TASK-001

**Subtareas:**
- [ ] Crear estructura de directorios nueva
- [ ] Crear archivos .gitkeep donde necesario
- [ ] Actualizar .gitignore
- [ ] Documentar estructura en DIRECTORY_STRUCTURE_v2.2.md

**Estructura a crear:**
```
src/
├── core/
├── menu/
├── scripts/
├── features/
└── ui/
tests/
├── unit/
├── integration/
├── security/
└── performance/
docs/
├── architecture/
├── api/
├── guides/
├── development/
└── migration/
```

---

### TASK-003: Eliminar Código Legacy
**Prioridad:** CRÍTICA  
**Estimación:** 3 horas  
**Asignado:** Dev  
**Dependencias:** TASK-002

**Archivos a eliminar:**
- [ ] src/menu_legacy.sh (1788 líneas)
- [ ] src/menu.sh (symlink)
- [ ] backup_v2.1_*/
- [ ] OPORTUNIDAD DE MEJORAS.md
- [ ] IMPROVEMENTS_SUMMARY.md
- [ ] REFACTORING_COMPLETE.md
- [ ] REFACTORING_SUMMARY.md
- [ ] demo_ui.sh
- [ ] professional_demo.sh
- [ ] migrate_to_v3.sh
- [ ] rollback_migration.sh

**Validación:**
- [ ] Sistema funciona sin archivos legacy
- [ ] Tests pasan
- [ ] No hay referencias a archivos eliminados

---

### TASK-004: Reubicar Archivos Existentes
**Prioridad:** ALTA  
**Estimación:** 3 horas  
**Asignado:** Dev  
**Dependencias:** TASK-002, TASK-003

**Reubicaciones:**
- [ ] ARCHITECTURE.md → docs/architecture/overview.md
- [ ] CONTRIBUTING.md → docs/development/contributing.md
- [ ] TROUBLESHOOTING.md → docs/guides/troubleshooting.md
- [ ] EXAMPLES.md → docs/guides/examples.md
- [ ] PRD-Bashmenu-v3.0.md → docs/archive/PRD-v3.0.md
- [ ] QUICK_START_V3.md → docs/guides/quick_start.md
- [ ] PROFESSIONAL_UI_GUIDE.md → docs/guides/ui_customization.md
- [ ] fix_permissions.sh → scripts/utils/fix_permissions.sh

**Actualizar referencias:**
- [ ] README.md
- [ ] Todos los archivos que referencien docs movidos

---

### TASK-005: Reorganizar Módulos src/
**Prioridad:** CRÍTICA  
**Estimación:** 6 horas  
**Asignado:** Dev  
**Dependencias:** TASK-004

**Mover archivos:**

**src/core/:**
- [ ] logger.sh → src/core/logger.sh
- [ ] utils.sh → src/core/utils.sh
- [ ] commands.sh → src/core/commands.sh
- [ ] Crear src/core/config.sh (nuevo)
- [ ] Crear src/core/init.sh (nuevo)

**src/menu/:**
- [ ] menu_core.sh → src/menu/core.sh
- [ ] menu_display.sh → src/menu/display.sh
- [ ] menu_input.sh → src/menu/input.sh
- [ ] menu_navigation.sh → src/menu/navigation.sh
- [ ] menu_themes.sh → src/menu/themes.sh
- [ ] menu_loop.sh → src/menu/loop.sh
- [ ] menu_help.sh → src/menu/help.sh

**src/scripts/:**
- [ ] script_loader.sh → src/scripts/loader.sh
- [ ] script_validator.sh → src/scripts/validator.sh
- [ ] script_executor.sh → src/scripts/executor.sh
- [ ] Crear src/scripts/cache.sh (nuevo)
- [ ] Crear src/scripts/registry.sh (nuevo)

**src/ui/:**
- [ ] dialog_wrapper.sh → src/ui/dialog_wrapper.sh
- [ ] fzf_integration.sh → src/ui/fzf_integration.sh
- [ ] notifications.sh → src/ui/notifications.sh
- [ ] Crear src/ui/dashboard.sh (nuevo)

**Actualizar imports:**
- [ ] Actualizar todos los `source` statements
- [ ] Validar que no hay imports rotos

---

### TASK-006: Implementar Sistema .env
**Prioridad:** CRÍTICA  
**Estimación:** 8 horas  
**Asignado:** Dev  
**Dependencias:** TASK-005

**Subtareas:**
- [ ] Crear .bashmenu.env.example
- [ ] Crear src/core/config.sh
- [ ] Implementar load_env_file()
- [ ] Implementar validate_config()
- [ ] Implementar get_config()
- [ ] Implementar set_config()
- [ ] Prioridad: ENV > ~/.bashmenu/.bashmenu.env > /opt/bashmenu/etc/.bashmenu.env
- [ ] Valores por defecto
- [ ] Actualizar .gitignore
- [ ] Tests unitarios

**Variables mínimas:**
```bash
BASHMENU_HOME=/opt/bashmenu
BASHMENU_USER_DIR=~/.bashmenu
BASHMENU_PLUGINS_DIR=~/.bashmenu/plugins
BASHMENU_LOG_DIR=/var/log/bashmenu
BASHMENU_THEME=modern
BASHMENU_LOG_LEVEL=INFO
BASHMENU_ENABLE_CACHE=true
BASHMENU_CACHE_TTL=3600
```

---

### TASK-007: Convertir Paths a Relativos
**Prioridad:** CRÍTICA  
**Estimación:** 6 horas  
**Asignado:** Dev  
**Dependencias:** TASK-006

**Subtareas:**
- [ ] Identificar todos los paths hardcodeados
- [ ] Reemplazar con variables de .env
- [ ] Actualizar config.conf.example
- [ ] Actualizar scripts.conf.example
- [ ] Eliminar paths con información personal
- [ ] Tests de validación

**Antes:**
```bash
/home/stk/GIT/Bashmenu/plugins/script.sh
```

**Después:**
```bash
${BASHMENU_PLUGINS_DIR}/script.sh
```

---

### TASK-008: Actualizar main.sh
**Prioridad:** CRÍTICA  
**Estimación:** 4 horas  
**Asignado:** Dev  
**Dependencias:** TASK-005, TASK-006, TASK-007

**Subtareas:**
- [ ] Actualizar versión a 2.2
- [ ] Cargar .env primero
- [ ] Actualizar imports con nuevas rutas
- [ ] Implementar detección de ubicación
- [ ] Validar paths en startup
- [ ] Mejorar mensajes de error
- [ ] Tests de integración

---

### TASK-009: Crear Script de Migración
**Prioridad:** CRÍTICA  
**Estimación:** 12 horas  
**Asignado:** Dev  
**Dependencias:** TASK-008

**Archivo:** migrate.sh

**Funcionalidades:**
- [ ] Detectar instalación v2.1
- [ ] Modo dry-run
- [ ] Backup completo
- [ ] Migrar config.conf → .bashmenu.env
- [ ] Convertir paths absolutos → relativos
- [ ] Actualizar scripts.conf
- [ ] Mover archivos a nueva estructura
- [ ] Validar migración
- [ ] Rollback automático si falla
- [ ] Log detallado
- [ ] Tests de migración

---

### TASK-010: Tests de Fase 1
**Prioridad:** ALTA  
**Estimación:** 8 horas  
**Asignado:** Dev  
**Dependencias:** TASK-009

**Tests a crear:**
- [ ] tests/unit/core/config.bats (sistema .env)
- [ ] tests/unit/core/init.bats (inicialización)
- [ ] tests/integration/startup.bats (startup completo)
- [ ] tests/integration/migration.bats (migración)
- [ ] tests/security/paths.bats (validación de paths)

**Objetivo:** >40% coverage en módulos core

---

## Fase 2: Funcionalidades Core (Semana 3-4)

### TASK-011: Implementar Sistema de Caching
**Prioridad:** ALTA  
**Estimación:** 10 horas  
**Asignado:** Dev  
**Dependencias:** TASK-010

**Archivo:** src/scripts/cache.sh

**Funcionalidades:**
- [ ] cache_init()
- [ ] cache_get()
- [ ] cache_set()
- [ ] cache_invalidate()
- [ ] cache_clear()
- [ ] Cache de escaneo de directorios
- [ ] Cache de validación de scripts
- [ ] Detección de cambios (mtime)
- [ ] TTL configurable
- [ ] Métricas de hit rate
- [ ] Tests unitarios

**Formato de cache:**
```bash
~/.bashmenu/cache/
├── scripts.cache
├── validation.cache
└── metadata.cache
```

---

### TASK-012: Implementar Búsqueda en Tiempo Real
**Prioridad:** ALTA  
**Estimación:** 12 horas  
**Asignado:** Dev  
**Dependencias:** TASK-011

**Archivo:** src/features/search.sh

**Funcionalidades:**
- [ ] search_init()
- [ ] search_incremental()
- [ ] search_by_name()
- [ ] search_by_description()
- [ ] search_by_tags()
- [ ] highlight_results()
- [ ] UI de búsqueda
- [ ] Navegación con teclado
- [ ] Tecla de atajo 's' o '/'
- [ ] Performance <200ms para 500 scripts
- [ ] Tests unitarios

---

### TASK-013: Implementar Sistema de Favoritos
**Prioridad:** ALTA  
**Estimación:** 8 horas  
**Asignado:** Dev  
**Dependencias:** TASK-011

**Archivo:** src/features/favorites.sh

**Funcionalidades:**
- [ ] favorites_init()
- [ ] favorites_add()
- [ ] favorites_remove()
- [ ] favorites_list()
- [ ] favorites_load()
- [ ] favorites_save()
- [ ] Persistencia en JSON
- [ ] Vista dedicada (tecla 'F')
- [ ] Indicador visual (⭐)
- [ ] Exportar/importar
- [ ] Tests unitarios

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

### TASK-014: Mejorar Sistema de Ayuda
**Prioridad:** MEDIA  
**Estimación:** 10 horas  
**Asignado:** Dev  
**Dependencias:** TASK-012

**Archivo:** src/menu/help.sh (mejorado)

**Funcionalidades:**
- [ ] help_show_contextual()
- [ ] help_show_tutorial()
- [ ] help_show_tips()
- [ ] help_search()
- [ ] Tooltips para opciones
- [ ] Tutorial interactivo
- [ ] Ejemplos de uso
- [ ] Tips aleatorios
- [ ] Búsqueda en ayuda
- [ ] Tests unitarios

---

### TASK-015: Implementar Auditoría JSON
**Prioridad:** ALTA  
**Estimación:** 8 horas  
**Asignado:** Dev  
**Dependencias:** TASK-011

**Archivo:** src/features/audit.sh

**Funcionalidades:**
- [ ] audit_init()
- [ ] audit_log_event()
- [ ] audit_query()
- [ ] audit_export()
- [ ] Formato JSONL (JSON Lines)
- [ ] Campos: timestamp, user, action, script, result, duration
- [ ] Rotación automática
- [ ] Inmutabilidad (append-only)
- [ ] Tests unitarios

**Formato:**
```json
{"timestamp":"2026-02-20T10:30:45.123Z","user":"admin","action":"execute_script","script":"/opt/bashmenu/plugins/deploy.sh","result":"success","duration_ms":1234,"exit_code":0}
```

---

### TASK-016: Tests de Fase 2
**Prioridad:** ALTA  
**Estimación:** 10 horas  
**Asignado:** Dev  
**Dependencias:** TASK-015

**Tests a crear:**
- [ ] tests/unit/scripts/cache.bats
- [ ] tests/unit/features/search.bats
- [ ] tests/unit/features/favorites.bats
- [ ] tests/unit/features/audit.bats
- [ ] tests/integration/search_flow.bats
- [ ] tests/integration/favorites_flow.bats
- [ ] tests/performance/cache.bats
- [ ] tests/performance/search.bats

**Objetivo:** >50% coverage total

---

## Fase 3: Funcionalidades Avanzadas (Semana 4-5)

### TASK-017: Implementar Carga Lazy
**Prioridad:** MEDIA  
**Estimación:** 8 horas  
**Asignado:** Dev  
**Dependencias:** TASK-016

**Archivo:** src/features/lazy_loader.sh

**Funcionalidades:**
- [ ] lazy_init()
- [ ] lazy_load_module()
- [ ] lazy_preload()
- [ ] Módulos core siempre cargados
- [ ] Módulos opcionales on-demand
- [ ] Indicador de carga
- [ ] Precarga inteligente
- [ ] Configuración de módulos
- [ ] Startup time <1s
- [ ] Tests unitarios

---

### TASK-018: Implementar Sistema de Hooks
**Prioridad:** MEDIA  
**Estimación:** 12 horas  
**Asignado:** Dev  
**Dependencias:** TASK-017

**Archivo:** src/features/hooks.sh

**Funcionalidades:**
- [ ] hooks_init()
- [ ] register_hook()
- [ ] unregister_hook()
- [ ] execute_hooks()
- [ ] Hooks: pre_execute, post_execute, on_error, on_load, on_exit
- [ ] Prioridad de ejecución
- [ ] Hooks pueden cancelar ejecución
- [ ] Documentación de API
- [ ] Ejemplos
- [ ] Tests unitarios

**API:**
```bash
register_hook "pre_execute" "my_function" 10
```

---

### TASK-019: Optimización de Performance
**Prioridad:** MEDIA  
**Estimación:** 8 horas  
**Asignado:** Dev  
**Dependencias:** TASK-018

**Subtareas:**
- [ ] Profiling de startup
- [ ] Optimizar loops críticos
- [ ] Reducir forks innecesarios
- [ ] Optimizar cache
- [ ] Benchmarks
- [ ] Validar objetivos:
  - [ ] Startup <1.5s con cache
  - [ ] Búsqueda <200ms
  - [ ] Navegación <100ms

---

### TASK-020: Tests de Fase 3
**Prioridad:** ALTA  
**Estimación:** 8 horas  
**Asignado:** Dev  
**Dependencias:** TASK-019

**Tests a crear:**
- [ ] tests/unit/features/lazy_loader.bats
- [ ] tests/unit/features/hooks.bats
- [ ] tests/performance/startup.bats
- [ ] tests/performance/navigation.bats
- [ ] tests/integration/hooks_flow.bats

**Objetivo:** >60% coverage total

---

## Fase 4: Testing y Documentación (Semana 5-6)

### TASK-021: Completar Suite de Tests
**Prioridad:** CRÍTICA  
**Estimación:** 16 horas  
**Asignado:** Dev  
**Dependencias:** TASK-020

**Tests faltantes:**
- [ ] tests/unit/menu/* (todos los módulos)
- [ ] tests/unit/scripts/* (todos los módulos)
- [ ] tests/unit/ui/* (módulos opcionales)
- [ ] tests/integration/full_workflow.bats
- [ ] tests/security/injection.bats
- [ ] tests/security/permissions.bats
- [ ] tests/security/path_traversal.bats

**Objetivo:** >60% coverage verificado

---

### TASK-022: Ejecutar ShellCheck en Todo el Código
**Prioridad:** CRÍTICA  
**Estimación:** 8 horas  
**Asignado:** Dev  
**Dependencias:** TASK-021

**Subtareas:**
- [ ] Ejecutar shellcheck en todos los archivos
- [ ] Corregir errores críticos
- [ ] Corregir warnings importantes
- [ ] Documentar warnings ignorados
- [ ] Crear .shellcheckrc
- [ ] Integrar en CI/CD

**Objetivo:** 0 errores críticos

---

### TASK-023: Documentación de Arquitectura
**Prioridad:** ALTA  
**Estimación:** 12 horas  
**Asignado:** Dev  
**Dependencias:** TASK-022

**Documentos a crear:**
- [ ] docs/architecture/overview.md
- [ ] docs/architecture/modules.md
- [ ] docs/architecture/data_flow.md
- [ ] docs/architecture/diagrams/ (diagramas)

**Contenido:**
- Arquitectura general
- Módulos y responsabilidades
- Flujo de datos
- Diagramas de secuencia
- Decisiones de diseño

---

### TASK-024: Documentación de API
**Prioridad:** ALTA  
**Estimación:** 10 horas  
**Asignado:** Dev  
**Dependencias:** TASK-023

**Documentos a crear:**
- [ ] docs/api/core_functions.md
- [ ] docs/api/menu_api.md
- [ ] docs/api/hooks_api.md
- [ ] docs/api/plugin_api.md

**Contenido:**
- Todas las funciones públicas
- Parámetros y tipos
- Valores de retorno
- Ejemplos de uso
- Casos de error

---

### TASK-025: Guías de Usuario
**Prioridad:** ALTA  
**Estimación:** 10 horas  
**Asignado:** Dev  
**Dependencias:** TASK-024

**Documentos a crear/actualizar:**
- [ ] docs/guides/installation.md
- [ ] docs/guides/quick_start.md
- [ ] docs/guides/configuration.md
- [ ] docs/guides/creating_plugins.md
- [ ] docs/guides/troubleshooting.md
- [ ] docs/guides/examples.md

---

### TASK-026: Guía de Migración
**Prioridad:** CRÍTICA  
**Estimación:** 6 horas  
**Asignado:** Dev  
**Dependencias:** TASK-025

**Documento:** docs/migration/v2.1_to_v2.2.md

**Contenido:**
- Cambios principales
- Breaking changes
- Proceso de migración
- Script de migración automática
- Troubleshooting
- Rollback

---

### TASK-027: Actualizar README Principal
**Prioridad:** ALTA  
**Estimación:** 4 horas  
**Asignado:** Dev  
**Dependencias:** TASK-026

**Actualizar:**
- [ ] Versión a 2.2
- [ ] Features actualizadas
- [ ] Instalación actualizada
- [ ] Links a nueva documentación
- [ ] Screenshots actualizados
- [ ] Badges (tests, coverage, etc.)

---

### TASK-028: Crear CHANGELOG.md
**Prioridad:** ALTA  
**Estimación:** 3 horas  
**Asignado:** Dev  
**Dependencias:** TASK-027

**Contenido:**
- [ ] v2.2.0 - Cambios principales
- [ ] Breaking changes
- [ ] Nuevas funcionalidades
- [ ] Bug fixes
- [ ] Mejoras de performance
- [ ] Deprecations

---

## Fase 5: Release (Semana 6)

### TASK-029: Testing Multi-Distro
**Prioridad:** CRÍTICA  
**Estimación:** 12 horas  
**Asignado:** Dev  
**Dependencias:** TASK-028

**Distros a validar:**
- [ ] Ubuntu 20.04 LTS
- [ ] Ubuntu 22.04 LTS
- [ ] Debian 11
- [ ] Debian 12
- [ ] CentOS 7
- [ ] Rocky Linux 8
- [ ] Arch Linux

**Validar:**
- Instalación
- Migración desde v2.1
- Todas las funcionalidades
- Performance
- Tests pasan

---

### TASK-030: Crear Instaladores
**Prioridad:** CRÍTICA  
**Estimación:** 8 horas  
**Asignado:** Dev  
**Dependencias:** TASK-029

**Archivos:**
- [ ] install.sh (actualizado)
- [ ] uninstall.sh (nuevo)
- [ ] migrate.sh (finalizado)

**Validar:**
- Instalación system-wide
- Instalación user-level
- Migración automática
- Rollback
- Permisos correctos

---

### TASK-031: Crear Paquetes de Distribución
**Prioridad:** ALTA  
**Estimación:** 6 horas  
**Asignado:** Dev  
**Dependencias:** TASK-030

**Paquetes:**
- [ ] bashmenu-v2.2.tar.gz
- [ ] bashmenu-v2.2.deb (Ubuntu/Debian)
- [ ] bashmenu-v2.2.rpm (CentOS/RHEL)
- [ ] checksums.txt
- [ ] GPG signatures

---

### TASK-032: Release Notes
**Prioridad:** ALTA  
**Estimación:** 4 horas  
**Asignado:** Dev  
**Dependencias:** TASK-031

**Contenido:**
- Resumen de cambios
- Nuevas funcionalidades
- Breaking changes
- Instrucciones de migración
- Known issues
- Agradecimientos

---

### TASK-033: Tag y Release en GitHub
**Prioridad:** CRÍTICA  
**Estimación:** 2 horas  
**Asignado:** Dev  
**Dependencias:** TASK-032

**Acciones:**
- [ ] Crear tag v2.2.0
- [ ] Crear release en GitHub
- [ ] Subir paquetes
- [ ] Publicar release notes
- [ ] Actualizar documentación online

---

## Resumen de Estimaciones

| Fase | Tareas | Horas | Semanas |
|------|--------|-------|---------|
| Fase 1: Limpieza | 10 | 64h | 2 |
| Fase 2: Core Features | 6 | 58h | 1.5 |
| Fase 3: Advanced | 4 | 36h | 1 |
| Fase 4: Testing & Docs | 8 | 69h | 1.5 |
| Fase 5: Release | 5 | 32h | 1 |
| **TOTAL** | **33** | **259h** | **6-7** |

**Nota:** Estimaciones para 1 desarrollador full-time (40h/semana)

---

## Dependencias Críticas

```
TASK-001 (Setup)
  └─> TASK-002 (Estructura)
       └─> TASK-003 (Eliminar Legacy)
            └─> TASK-004 (Reubicar)
                 └─> TASK-005 (Reorganizar)
                      └─> TASK-006 (Sistema .env)
                           └─> TASK-007 (Paths Relativos)
                                └─> TASK-008 (main.sh)
                                     └─> TASK-009 (Migración)
                                          └─> TASK-010 (Tests Fase 1)
                                               └─> [Fase 2, 3, 4, 5]
```

---

## Checkpoints

### Checkpoint 1 (Final Semana 2)
- [ ] Estructura limpia
- [ ] Sistema .env funcional
- [ ] Paths relativos
- [ ] Tests básicos pasan

### Checkpoint 2 (Final Semana 4)
- [ ] Todas las funcionalidades core implementadas
- [ ] Tests >50% coverage
- [ ] Performance cumple objetivos

### Checkpoint 3 (Final Semana 5)
- [ ] Tests >60% coverage
- [ ] Documentación completa
- [ ] ShellCheck sin errores críticos

### Checkpoint 4 (Final Semana 6)
- [ ] Release v2.2.0
- [ ] Validado en múltiples distros
- [ ] Migración automática funcional

