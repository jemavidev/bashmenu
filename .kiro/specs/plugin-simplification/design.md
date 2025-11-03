# Design Document - Sistema Simplificado de Scripts para Bashmenu

## Overview

Este diseño transforma el sistema de plugins de Bashmenu en un mecanismo simple y directo para ejecutar scripts personalizados. El usuario solo necesita:

1. Colocar sus scripts en `/opt/bashmenu/plugins/`
2. Configurar entradas de menú en `scripts.conf`
3. Ejecutar `bashmenu` y ver sus scripts en el menú

El diseño elimina la complejidad del sistema de plugins actual y se enfoca en la simplicidad y seguridad.

## Architecture

### Flujo de Inicialización

```
Inicio de Bashmenu
    ↓
Cargar config.conf
    ↓
Leer scripts.conf
    ↓
Validar cada entrada
    ↓
Verificar existencia de scripts
    ↓
Verificar permisos de ejecución
    ↓
Verificar rutas permitidas (ALLOWED_SCRIPT_DIRS)
    ↓
Registrar entradas válidas en el menú
    ↓
Mostrar menú al usuario
```

### Flujo de Ejecución de Script

```
Usuario selecciona opción
    ↓
¿Script requiere parámetros?
    ├─ Sí → Solicitar parámetros al usuario
    │        ↓
    │        Validar y sanitizar entrada
    │        ↓
    └─ No → Continuar
    ↓
Re-validar script (existencia, permisos, ruta)
    ↓
Ejecutar script con parámetros (si aplica)
    ↓
Capturar stdout/stderr en tiempo real
    ↓
Mostrar código de salida
    ↓
Registrar en log
    ↓
Esperar Enter del usuario
    ↓
Regresar al menú
```

## Components and Interfaces

### 1. Script Configuration Parser (`src/script_loader.sh`)

**Propósito**: Leer y parsear el archivo `scripts.conf`

**Funciones principales**:

```bash
# Lee scripts.conf y carga las entradas en memoria
load_script_config() {
    local config_file="$1"
    # Lee línea por línea
    # Ignora comentarios (#) y líneas vacías
    # Parsea formato: Nombre|Ruta|Descripción|Nivel|Parámetros(opcional)
    # Almacena en array asociativo global: SCRIPT_ENTRIES
}

# Valida una entrada individual de script
validate_script_entry() {
    local name="$1"
    local path="$2"
    local description="$3"
    local level="$4"
    local params="$5"
    
    # Verifica que la ruta sea absoluta
    # Verifica que el archivo existe
    # Verifica permisos de ejecución
    # Verifica que está en ALLOWED_SCRIPT_DIRS
    # Retorna 0 si válido, 1 si inválido
}
```

**Estructura de datos**:

```bash
# Array asociativo para almacenar entradas de scripts
declare -A SCRIPT_ENTRIES
# Formato: SCRIPT_ENTRIES["nombre"]="ruta|descripción|nivel|parámetros"

# Ejemplo:
# SCRIPT_ENTRIES["Git Pull"]="/opt/bashmenu/plugins/git_operations.sh|Pull from repository|1|pull"
# SCRIPT_ENTRIES["Docker Build"]="/opt/bashmenu/plugins/docker_manager.sh|Build containers|2|build"
```

### 2. Script Validator (`src/script_validator.sh`)

**Propósito**: Validar scripts antes de la ejecución

**Funciones principales**:

```bash
# Valida que un script puede ejecutarse de forma segura
validate_script_execution() {
    local script_path="$1"
    
    # 1. Verificar que el archivo existe
    # 2. Verificar que es un archivo regular (no directorio, no symlink)
    # 3. Verificar permisos de ejecución
    # 4. Verificar que está en directorio permitido
    # 5. Verificar sintaxis bash (bash -n)
    
    # Retorna 0 si válido, código de error específico si inválido
}

# Verifica que la ruta está en directorios permitidos
check_allowed_directory() {
    local script_path="$1"
    local allowed_dirs="$2"  # ALLOWED_SCRIPT_DIRS
    
    # Resuelve ruta absoluta (maneja symlinks)
    # Compara con cada directorio permitido
    # Retorna 0 si permitido, 1 si bloqueado
}

# Sanitiza parámetros de entrada del usuario
sanitize_parameters() {
    local params="$1"
    
    # Elimina caracteres peligrosos: ; & | $ ` \ " '
    # Escapa espacios
    # Limita longitud máxima
    # Retorna parámetros sanitizados
}
```

### 3. Script Executor (`src/script_executor.sh`)

**Propósito**: Ejecutar scripts de forma segura y mostrar salida

**Funciones principales**:

```bash
# Ejecuta un script y muestra salida en tiempo real
execute_script() {
    local script_path="$1"
    local script_name="$2"
    local params="$3"
    
    # 1. Mostrar header con nombre del script
    # 2. Re-validar script antes de ejecutar
    # 3. Ejecutar con parámetros
    # 4. Capturar stdout (normal) y stderr (rojo)
    # 5. Capturar código de salida
    # 6. Registrar en log
    # 7. Mostrar resumen de ejecución
    # 8. Esperar Enter del usuario
}

# Solicita parámetros al usuario si son necesarios
prompt_for_parameters() {
    local script_name="$1"
    local default_params="$2"
    
    # Muestra prompt con parámetros por defecto
    # Lee entrada del usuario
    # Permite cancelar con Ctrl+C o entrada vacía
    # Retorna parámetros ingresados
}

# Muestra salida del script con colores
display_script_output() {
    local script_path="$1"
    local params="$2"
    
    # Ejecuta script y procesa salida línea por línea
    # stdout → color normal
    # stderr → color rojo
    # Muestra en tiempo real usando 'tee' o similar
}
```

### 4. Integration with Menu System (`src/menu.sh` modifications)

**Modificaciones necesarias**:

```bash
# En initialize_menu(), agregar carga de scripts
initialize_menu() {
    # ... código existente ...
    
    # Cargar scripts externos si están configurados
    if [[ -f "$CONFIG_DIR/scripts.conf" ]]; then
        load_script_config "$CONFIG_DIR/scripts.conf"
        register_external_scripts
    fi
    
    # Deshabilitar plugins si hay scripts externos
    if [[ ${#SCRIPT_ENTRIES[@]} -gt 0 ]]; then
        ENABLE_PLUGINS=false
        log_info "External scripts loaded, plugins disabled"
    fi
}

# Registra scripts externos como entradas de menú
register_external_scripts() {
    for script_name in "${!SCRIPT_ENTRIES[@]}"; do
        local entry="${SCRIPT_ENTRIES[$script_name]}"
        IFS='|' read -r path desc level params <<< "$entry"
        
        # Crear función wrapper para cada script
        create_script_wrapper "$script_name" "$path" "$params"
        
        # Agregar al menú
        add_menu_item "$script_name" "exec_$script_name" "$desc" "$level"
    done
}

# Crea función wrapper dinámica para cada script
create_script_wrapper() {
    local name="$1"
    local path="$2"
    local default_params="$3"
    
    # Crea función con nombre único: exec_<nombre_script>
    # La función llama a execute_script con los parámetros correctos
    eval "exec_${name//[^a-zA-Z0-9_]/_}() {
        execute_script '$path' '$name' '$default_params'
    }"
}
```

## Data Models

### scripts.conf Format

```bash
# =============================================================================
# Bashmenu External Scripts Configuration
# =============================================================================
# Format: Display Name|Absolute Path|Description|Required Level|Parameters
#
# Fields:
#   - Display Name: Text shown in menu
#   - Absolute Path: Full path to script (must be in ALLOWED_SCRIPT_DIRS)
#   - Description: Brief description of what the script does
#   - Required Level: Permission level (1=user, 2=admin, 3=root)
#   - Parameters: Optional default parameters to pass to script
#
# Examples:
# Git Pull|/opt/bashmenu/plugins/git_operations.sh|Pull from repository|1|pull
# Docker Build|/opt/bashmenu/plugins/docker_manager.sh|Build containers|2|build
# =============================================================================

# Your scripts here:
Git Operations|/opt/bashmenu/plugins/git_operations.sh|Manage Git repositories|1|
Docker Manager|/opt/bashmenu/plugins/docker_manager.sh|Manage Docker containers|2|
```

### Configuration Variables (config.conf)

```bash
# Directorio de scripts permitidos (múltiples separados por :)
ALLOWED_SCRIPT_DIRS="/opt/bashmenu/plugins:/opt/scripts:/usr/local/bin"

# Habilitar sistema de scripts externos
ENABLE_EXTERNAL_SCRIPTS=true

# Habilitar sistema de plugins (deshabilitado por defecto)
ENABLE_PLUGINS=false

# Timeout para ejecución de scripts (segundos, 0=sin límite)
SCRIPT_EXECUTION_TIMEOUT=300

# Registrar salida completa de scripts en log
LOG_SCRIPT_OUTPUT=true
```

## Error Handling

### Categorías de Errores

1. **Configuration Errors** (durante carga):
   - scripts.conf no existe → Advertencia, continuar sin scripts externos
   - scripts.conf tiene sintaxis inválida → Error, mostrar línea problemática
   - Entrada malformada → Advertencia, omitir entrada específica

2. **Validation Errors** (durante carga):
   - Script no existe → Advertencia, omitir entrada
   - Script sin permisos de ejecución → Advertencia, omitir entrada
   - Script fuera de directorios permitidos → Error de seguridad, omitir entrada
   - Ruta no absoluta → Error, omitir entrada

3. **Execution Errors** (durante ejecución):
   - Script eliminado después de carga → Error, mostrar mensaje al usuario
   - Permisos cambiados → Error, mostrar mensaje al usuario
   - Script falla con código de salida != 0 → Advertencia, mostrar código de salida
   - Timeout de ejecución → Error, terminar script y notificar

### Manejo de Errores

```bash
# Función centralizada de manejo de errores
handle_script_error() {
    local error_type="$1"
    local script_name="$2"
    local details="$3"
    
    case "$error_type" in
        "not_found")
            print_error "Script not found: $script_name"
            log_error "Script execution failed: $script_name not found"
            ;;
        "no_permission")
            print_error "Permission denied: $script_name"
            log_error "Script execution failed: $script_name no execute permission"
            ;;
        "not_allowed")
            print_error "Security: Script not in allowed directories"
            log_error "Security violation: $script_name not in ALLOWED_SCRIPT_DIRS"
            ;;
        "execution_failed")
            print_error "Script failed with exit code: $details"
            log_error "Script $script_name failed with exit code $details"
            ;;
        "timeout")
            print_error "Script execution timeout"
            log_error "Script $script_name exceeded timeout limit"
            ;;
    esac
    
    echo ""
    echo "Press Enter to return to menu..."
    read -s
}
```

## Testing Strategy

### Unit Tests

1. **Script Configuration Parser**:
   - Test parsing de líneas válidas
   - Test ignorar comentarios y líneas vacías
   - Test manejo de formato incorrecto
   - Test campos opcionales (parámetros)

2. **Script Validator**:
   - Test validación de rutas absolutas vs relativas
   - Test verificación de existencia de archivos
   - Test verificación de permisos
   - Test verificación de directorios permitidos
   - Test sanitización de parámetros

3. **Script Executor**:
   - Test ejecución exitosa de script
   - Test captura de stdout/stderr
   - Test captura de código de salida
   - Test timeout de ejecución
   - Test cancelación por usuario

### Integration Tests

1. **End-to-End Flow**:
   - Instalar Bashmenu en servidor de prueba
   - Crear scripts.conf con 2 scripts de ejemplo
   - Iniciar Bashmenu y verificar que aparecen en menú
   - Ejecutar cada script y verificar salida
   - Verificar logs

2. **Security Tests**:
   - Intentar ejecutar script fuera de ALLOWED_SCRIPT_DIRS
   - Intentar ejecutar script sin permisos
   - Intentar inyectar comandos mediante parámetros
   - Verificar que todas las validaciones funcionan

3. **Error Handling Tests**:
   - Eliminar script después de carga, intentar ejecutar
   - Crear scripts.conf con entradas inválidas
   - Ejecutar script que falla (exit 1)
   - Ejecutar script que excede timeout

### Manual Testing Checklist

- [ ] Instalación limpia en servidor Ubuntu/Debian
- [ ] Instalación limpia en servidor CentOS/RHEL
- [ ] Crear scripts personalizados y agregarlos al menú
- [ ] Ejecutar scripts con y sin parámetros
- [ ] Verificar salida en tiempo real
- [ ] Verificar logs después de ejecución
- [ ] Probar con scripts que fallan
- [ ] Probar con scripts de larga duración
- [ ] Verificar que plugins antiguos están deshabilitados
- [ ] Verificar ejemplos incluidos funcionan correctamente

## Example Scripts

### git_operations.sh

```bash
#!/bin/bash
# Git Operations Script
# Usage: ./git_operations.sh [pull|status|log]

operation="${1:-status}"
repo_path="/opt/myapp"

cd "$repo_path" || exit 1

case "$operation" in
    pull)
        echo "Pulling latest changes..."
        git pull origin main
        ;;
    status)
        echo "Repository status:"
        git status
        ;;
    log)
        echo "Recent commits:"
        git log --oneline -10
        ;;
    *)
        echo "Usage: $0 [pull|status|log]"
        exit 1
        ;;
esac
```

### docker_manager.sh

```bash
#!/bin/bash
# Docker Manager Script
# Usage: ./docker_manager.sh [build|ps|logs]

operation="${1:-ps}"

case "$operation" in
    build)
        echo "Building Docker containers..."
        docker-compose build
        ;;
    ps)
        echo "Running containers:"
        docker ps
        ;;
    logs)
        echo "Recent logs:"
        docker-compose logs --tail=50
        ;;
    restart)
        echo "Restarting containers..."
        docker-compose restart
        ;;
    *)
        echo "Usage: $0 [build|ps|logs|restart]"
        exit 1
        ;;
esac
```

## Installation Updates

### Modificaciones a install.sh

1. Crear directorio `/opt/bashmenu/plugins/examples/`
2. Copiar scripts de ejemplo a ese directorio
3. Establecer permisos de ejecución en scripts de ejemplo
4. Crear `scripts.conf.example` en `/opt/bashmenu/config/`
5. Actualizar mensaje final de instalación con instrucciones

### Mensaje de Instalación

```
Installation Completed Successfully!

Next Steps:
1. Review example scripts in: /opt/bashmenu/plugins/examples/
2. Copy scripts.conf.example to scripts.conf:
   cp /opt/bashmenu/config/scripts.conf.example /opt/bashmenu/config/scripts.conf
3. Edit scripts.conf to add your custom scripts
4. Place your scripts in: /opt/bashmenu/plugins/
5. Run 'bashmenu' to see your scripts in the menu

Example scripts included:
- git_operations.sh (Git management)
- docker_manager.sh (Docker management)
```

## Security Considerations

1. **Path Validation**: Todas las rutas deben ser absolutas y verificadas contra ALLOWED_SCRIPT_DIRS
2. **Parameter Sanitization**: Todos los parámetros de usuario deben ser sanitizados antes de pasar al script
3. **Execution Permissions**: Verificar permisos antes de cada ejecución
4. **Logging**: Registrar todos los intentos de ejecución (exitosos y fallidos)
5. **Timeout**: Implementar timeout para prevenir scripts que se cuelgan
6. **No Shell Injection**: Usar arrays de bash para pasar parámetros, no concatenación de strings

## Performance Considerations

1. **Lazy Loading**: Cargar y validar scripts solo durante inicialización, no en cada iteración del menú
2. **Caching**: Cachear resultados de validación para evitar verificaciones repetidas
3. **Async Output**: Mostrar salida de scripts en tiempo real sin buffering
4. **Log Rotation**: Implementar rotación de logs para evitar archivos enormes

## Migration Path

Para usuarios existentes de Bashmenu:

1. El sistema de plugins antiguo permanece disponible pero deshabilitado por defecto
2. Si `scripts.conf` existe y tiene entradas, los plugins se deshabilitan automáticamente
3. Los usuarios pueden migrar plugins existentes a scripts externos copiándolos a `/opt/bashmenu/plugins/`
4. Documentación clara sobre diferencias entre plugins y scripts externos
5. Herramienta de migración opcional: `bashmenu --migrate-plugins`
