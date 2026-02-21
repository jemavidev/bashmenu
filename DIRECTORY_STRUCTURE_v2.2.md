# Bashmenu v2.2 - Nueva Estructura de Directorios

## Estructura Propuesta

```
bashmenu/
├── .bashmenu.env.example        # Template de configuración (versionado)
├── .bashmenu.env                # Config local (gitignored)
├── .gitignore                   # Actualizado
├── bashmenu                     # Ejecutable principal
├── install.sh                   # Instalador mejorado
├── uninstall.sh                 # Desinstalador
├── migrate.sh                   # Script de migración v2.1 → v2.2
│
├── LICENSE                      # MIT License
├── README.md                    # Documentación principal
├── CHANGELOG.md                 # Historial de cambios
├── CONTRIBUTING.md              # Guía de contribución
│
├── src/                         # Código fuente (REORGANIZADO)
│   ├── main.sh                  # Entry point principal
│   │
│   ├── core/                    # Módulos fundamentales
│   │   ├── config.sh            # Gestión de .env y configuración
│   │   ├── logger.sh            # Sistema de logging mejorado
│   │   ├── utils.sh             # Utilidades generales
│   │   └── init.sh              # Inicialización del sistema
│   │
│   ├── menu/                    # Sistema de menú modular
│   │   ├── core.sh              # Estructuras de datos del menú
│   │   ├── display.sh           # Renderizado y visualización
│   │   ├── input.sh             # Manejo de entrada de usuario
│   │   ├── navigation.sh        # Navegación jerárquica
│   │   ├── themes.sh            # Sistema de temas
│   │   ├── loop.sh              # Loop principal del menú
│   │   └── help.sh              # Sistema de ayuda mejorado
│   │
│   ├── scripts/                 # Gestión de scripts externos
│   │   ├── loader.sh            # Carga de scripts (manual + auto)
│   │   ├── validator.sh         # Validación de seguridad
│   │   ├── executor.sh          # Ejecución de scripts
│   │   ├── cache.sh             # Sistema de caching (NUEVO)
│   │   └── registry.sh          # Registro de scripts
│   │
│   ├── features/                # Funcionalidades adicionales (NUEVO)
│   │   ├── search.sh            # Búsqueda en tiempo real
│   │   ├── favorites.sh         # Sistema de favoritos
│   │   ├── hooks.sh             # Sistema de hooks
│   │   ├── audit.sh             # Auditoría JSON estructurada
│   │   └── lazy_loader.sh       # Carga lazy de módulos
│   │
│   └── ui/                      # Componentes UI opcionales
│       ├── dialog_wrapper.sh    # Integración dialog/whiptail
│       ├── fzf_integration.sh   # Integración fzf
│       ├── notifications.sh     # Notificaciones de escritorio
│       └── dashboard.sh         # Dashboard en tiempo real
│
├── config/                      # Configuración
│   ├── config.conf.example      # Template de configuración legacy
│   ├── scripts.conf.example     # Template de scripts
│   └── themes/                  # Temas personalizados
│       └── custom.theme.example
│
├── plugins/                     # Plugins del sistema
│   ├── README.md                # Documentación de plugins
│   ├── examples/                # Scripts de ejemplo
│   │   ├── backup_system.sh
│   │   ├── cleanup_logs.sh
│   │   └── monitor_resources.sh
│   └── .gitkeep
│
├── lib/                         # Librerías externas
│   ├── bats/                    # BATS testing framework
│   └── shellcheck/              # ShellCheck (opcional)
│
├── tests/                       # Suite de tests (REORGANIZADO)
│   ├── unit/                    # Tests unitarios
│   │   ├── core/
│   │   ├── menu/
│   │   ├── scripts/
│   │   └── features/
│   ├── integration/             # Tests de integración
│   │   ├── menu_flow.bats
│   │   ├── script_execution.bats
│   │   └── config_loading.bats
│   ├── security/                # Tests de seguridad
│   │   ├── path_traversal.bats
│   │   ├── injection.bats
│   │   └── permissions.bats
│   ├── performance/             # Tests de performance
│   │   └── benchmarks.bats
│   └── test_helper.bash         # Helpers compartidos
│
├── docs/                        # Documentación completa (REORGANIZADO)
│   ├── README.md                # Índice de documentación
│   │
│   ├── architecture/            # Arquitectura del sistema
│   │   ├── overview.md
│   │   ├── modules.md
│   │   ├── data_flow.md
│   │   └── diagrams/
│   │
│   ├── api/                     # Documentación de API
│   │   ├── core_functions.md
│   │   ├── menu_api.md
│   │   ├── hooks_api.md
│   │   └── plugin_api.md
│   │
│   ├── guides/                  # Guías de usuario
│   │   ├── installation.md
│   │   ├── quick_start.md
│   │   ├── configuration.md
│   │   ├── creating_plugins.md
│   │   └── troubleshooting.md
│   │
│   ├── development/             # Guías de desarrollo
│   │   ├── setup.md
│   │   ├── coding_standards.md
│   │   ├── testing.md
│   │   └── contributing.md
│   │
│   └── migration/               # Guías de migración
│       ├── v2.1_to_v2.2.md
│       └── breaking_changes.md
│
├── scripts/                     # Scripts de desarrollo y utilidades
│   ├── dev/                     # Scripts de desarrollo
│   │   ├── setup_dev.sh         # Setup entorno de desarrollo
│   │   ├── run_tests.sh         # Ejecutar tests
│   │   ├── lint.sh              # Ejecutar shellcheck
│   │   └── coverage.sh          # Reporte de cobertura
│   │
│   ├── build/                   # Scripts de build
│   │   ├── package.sh           # Crear paquetes
│   │   └── release.sh           # Proceso de release
│   │
│   └── utils/                   # Utilidades
│       ├── backup_config.sh
│       └── clean_logs.sh
│
├── .github/                     # GitHub específico
│   ├── workflows/               # GitHub Actions
│   │   ├── tests.yml            # CI para tests
│   │   ├── lint.yml             # CI para linting
│   │   └── release.yml          # CI para releases
│   ├── ISSUE_TEMPLATE/
│   └── PULL_REQUEST_TEMPLATE.md
│
└── dist/                        # Archivos de distribución (generados)
    ├── bashmenu-v2.2.tar.gz
    └── checksums.txt

```

## Archivos a Eliminar (Legacy)

```
❌ src/menu_legacy.sh            # Código legacy (1788 líneas)
❌ src/menu.sh                   # Symlink confuso
❌ backup_v2.1_*/                # Backups antiguos
❌ OPORTUNIDAD DE MEJORAS.md     # Documento obsoleto
❌ IMPROVEMENTS_SUMMARY.md       # Documento obsoleto
❌ REFACTORING_COMPLETE.md       # Documento obsoleto
❌ REFACTORING_SUMMARY.md        # Documento obsoleto
❌ MIGRATION_NOTES.md            # Mover a docs/migration/
❌ demo_ui.sh                    # Demo obsoleto
❌ professional_demo.sh          # Demo obsoleto
❌ fix_permissions.sh            # Mover a scripts/utils/
❌ migrate_to_v3.sh              # Obsoleto
❌ rollback_migration.sh         # Obsoleto
```

## Archivos a Reubicar

```
ARCHITECTURE.md          → docs/architecture/overview.md
CONTRIBUTING.md          → docs/development/contributing.md
TROUBLESHOOTING.md       → docs/guides/troubleshooting.md
EXAMPLES.md              → docs/guides/examples.md
PRD-Bashmenu-v3.0.md     → docs/archive/PRD-v3.0.md (referencia)
QUICK_START_V3.md        → docs/guides/quick_start.md
PROFESSIONAL_UI_GUIDE.md → docs/guides/ui_customization.md
```

## Instalación System-Wide

### Estructura en /opt/bashmenu/

```
/opt/bashmenu/
├── bin/
│   └── bashmenu             # Ejecutable
├── lib/
│   └── bashmenu/            # Librerías del sistema
│       ├── core/
│       ├── menu/
│       ├── scripts/
│       ├── features/
│       └── ui/
├── share/
│   └── bashmenu/
│       ├── plugins/         # Plugins del sistema
│       ├── themes/          # Temas
│       └── docs/            # Documentación
└── etc/
    └── bashmenu/
        ├── .bashmenu.env    # Config global
        └── scripts.conf     # Scripts del sistema
```

### Estructura en ~/.bashmenu/ (Usuario)

```
~/.bashmenu/
├── .bashmenu.env            # Config de usuario (override)
├── config.conf              # Config legacy (compatibilidad)
├── scripts.conf             # Scripts de usuario
├── plugins/                 # Plugins de usuario
├── favorites.json           # Favoritos del usuario
├── cache/                   # Cache de usuario
│   ├── scripts.cache
│   └── menu.cache
└── logs/                    # Logs de usuario
    ├── bashmenu.log
    └── audit.json
```

### Logs en /var/log/bashmenu/ (System-wide)

```
/var/log/bashmenu/
├── bashmenu.log             # Log principal
├── audit.json               # Auditoría estructurada
├── errors.log               # Solo errores
└── archive/                 # Logs rotados
    ├── bashmenu.log.1.gz
    └── audit.json.1.gz
```

## Prioridad de Configuración

```
1. Variables de entorno (ENV)
2. ~/.bashmenu/.bashmenu.env (usuario)
3. /opt/bashmenu/etc/bashmenu/.bashmenu.env (sistema)
4. Valores por defecto en código
```

## Migración Automática

El script `migrate.sh` se encargará de:
1. Detectar instalación v2.1
2. Backup de configuración actual
3. Crear nueva estructura
4. Migrar configuración a .bashmenu.env
5. Convertir paths absolutos a relativos
6. Actualizar scripts.conf
7. Validar migración
8. Rollback si falla

