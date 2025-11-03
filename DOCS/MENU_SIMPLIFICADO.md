# Menú Simplificado - Bashmenu v2.0

## Cambios Realizados

El menú principal ha sido completamente simplificado para incluir solo 5 comandos básicos y esenciales.

## Nuevo Menú Principal

```
--------------------------------------------------
     System Administration Menu [14:30:45]
--------------------------------------------------

  1  List Files (ls)         Show files in current directory
  2  List Detailed (ll)      Detailed file listing
  3  Disk Space (df)         Show disk usage
  4  Memory (free)           Show memory usage
  5  Processes (ps)          Show running processes
  6  Exit                    Exit the menu

Navigate: ↑↓ or 1-6 • Enter select • q quit
```

## Comandos Incluidos

### 1. List Files (ls -la)

- Muestra todos los archivos del directorio actual
- Incluye archivos ocultos
- Muestra permisos, propietario, tamaño y fecha

### 2. List Detailed (ll)

- Lista detallada con tamaños legibles (KB, MB, GB)
- Con colores para mejor visualización
- Excluye . y ..

### 3. Disk Space (df -h)

- Uso de disco de todos los filesystems
- Resumen del filesystem raíz
- Porcentajes de uso

### 4. Memory (free -h)

- Memoria total, usada y disponible
- Porcentaje de uso
- Barra visual de uso

### 5. Processes (ps aux)

- Top 15 procesos por uso de CPU
- Resumen de procesos totales y en ejecución
- Información de usuario, PID, %CPU, %MEM

## Archivos Modificados

### 1. src/commands.sh

**Antes**: ~300 líneas con múltiples comandos complejos
**Ahora**: ~170 líneas con solo 5 comandos simples

**Eliminado**:

- ❌ cmd_system_info()
- ❌ cmd_disk_usage()
- ❌ cmd_dashboard()
- ❌ cmd_quick_status()
- ❌ cmd_show_help()
- ❌ get_system_info()

**Mantenido**:

- ✅ cmd_list_files()
- ✅ cmd_list_detailed()
- ✅ cmd_disk_free()
- ✅ cmd_memory_free()
- ✅ cmd_process_list()
- ✅ get_user_level()
- ✅ cleanup_old_backups()

### 2. src/menu.sh

**Cambio en initialize_menu()**:

**Antes**:

```bash
add_menu_item "System Information" "cmd_system_info" ...
add_menu_item "Disk Usage" "cmd_disk_usage" ...
add_menu_item "Dashboard" "cmd_dashboard" ...
add_menu_item "Quick Status" "cmd_quick_status" ...
load_plugins()  # Cargaba plugin adicional
```

**Ahora**:

```bash
add_menu_item "List Files (ls)" "cmd_list_files" ...
add_menu_item "List Detailed (ll)" "cmd_list_detailed" ...
add_menu_item "Disk Space (df)" "cmd_disk_free" ...
add_menu_item "Memory (free)" "cmd_memory_free" ...
add_menu_item "Processes (ps)" "cmd_process_list" ...
# No carga plugins
```

### 3. config/config.conf

**Cambio**:

```bash
# Antes
ENABLE_PLUGINS=true

# Ahora
ENABLE_PLUGINS=false  # Comandos ahora son built-in
```

### 4. plugins/system_tools.sh

**Estado**: Ya no se carga (ENABLE_PLUGINS=false)
**Razón**: Funciones movidas al core (src/commands.sh)

## Comparación

### Antes

- **Menú principal**: 5 opciones (System Info, Disk Usage, Dashboard, Quick Status, Exit)
- **Plugin**: 5 opciones adicionales (ls, ll, df, free, ps)
- **Total**: 10 opciones
- **Código**: ~550 líneas en commands.sh
- **Complejidad**: Alta (dashboard con auto-refresh, health checks, etc.)

### Ahora

- **Menú principal**: 6 opciones (ls, ll, df, free, ps, Exit)
- **Plugin**: Deshabilitado
- **Total**: 6 opciones
- **Código**: ~170 líneas en commands.sh
- **Complejidad**: Baja (comandos directos y simples)

**Reducción**: ~69% menos código

## Ventajas

### Simplicidad

✅ Solo comandos esenciales
✅ Sin duplicación de funcionalidad
✅ Menú más corto y directo
✅ Más fácil de navegar

### Performance

✅ Carga más rápida (no carga plugins)
✅ Menos memoria utilizada
✅ Ejecución instantánea de comandos
✅ Sin dependencias complejas

### Mantenibilidad

✅ Menos código que mantener
✅ Todo en un solo lugar (src/commands.sh)
✅ Más fácil de debuggear
✅ Menos puntos de fallo

### Usabilidad

✅ Comandos que se usan diariamente
✅ Resultados inmediatos
✅ Sin esperas largas
✅ Interfaz clara y directa

## Estructura del Código

### src/commands.sh (Nuevo)

```bash
#!/bin/bash

# Fallback logging functions
log_warn() { ... }
log_info() { ... }
log_error() { ... }
log_debug() { ... }

# Core Commands (5)
cmd_list_files() { ... }
cmd_list_detailed() { ... }
cmd_disk_free() { ... }
cmd_memory_free() { ... }
cmd_process_list() { ... }

# Utility Functions (2)
get_user_level() { ... }
cleanup_old_backups() { ... }

# Export Functions
export -f cmd_list_files
export -f cmd_list_detailed
export -f cmd_disk_free
export -f cmd_memory_free
export -f cmd_process_list
export -f get_user_level
export -f cleanup_old_backups
```

## Formato de Salida

Todos los comandos usan el formato estándar:

```
--------------------------------------------------
              Título del Comando
--------------------------------------------------

[Contenido del comando]

--------------------------------------------------
[Resumen o tip]
```

## Testing

Para probar el nuevo menú:

```bash
# Ejecutar bashmenu
./bashmenu

# Probar cada comando
# Presionar 1, 2, 3, 4, 5 para cada opción
# Presionar 6 para salir
```

## Migración

Si tenías scripts que dependían de los comandos antiguos:

**Comandos Removidos → Alternativas**:

- `cmd_system_info` → Usar `cmd_list_files` + `cmd_disk_free` + `cmd_memory_free`
- `cmd_disk_usage` → Usar `cmd_disk_free`
- `cmd_dashboard` → Usar comandos individuales según necesidad
- `cmd_quick_status` → Usar `cmd_memory_free` + `cmd_disk_free`
- `cmd_show_help` → Documentación en README.md

## Conclusión

El menú ahora es:

- ✅ **Más simple**: Solo 5 comandos esenciales
- ✅ **Más rápido**: Sin carga de plugins
- ✅ **Más limpio**: 69% menos código
- ✅ **Más directo**: Comandos de uso diario

**Perfecto para administración básica de sistemas** 🎯
