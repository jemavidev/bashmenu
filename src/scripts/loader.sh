#!/bin/bash

# Strict mode for better error handling
set -euo pipefail

# =============================================================================
# Módulo Cargador de Scripts para Bashmenu
# =============================================================================
# Descripción: Carga y analiza configuración de scripts externos
# Versión:     2.1
# Autor:       JESUS MARIA VILLALOBOS
# =============================================================================

# =============================================================================
# Global Variables
# =============================================================================

# Array asociativo para almacenar entradas de scripts
# Formato: SCRIPT_ENTRIES["nombre"]="ruta|descripción|nivel|parámetros"
declare -gA SCRIPT_ENTRIES

# =============================================================================
# Configuration Parser Functions
# =============================================================================

# Lee scripts.conf y carga las entradas en memoria
load_script_config() {
    local config_file="$1"
    
    # Verificar que el archivo existe
    if [[ ! -f "$config_file" ]]; then
        if declare -f log_debug >/dev/null; then
            log_debug "Script configuration file not found: $config_file"
        fi
        return 1
    fi
    
    if declare -f log_info >/dev/null; then
        log_info "Loading script configuration from: $config_file"
    fi
    
    local line_number=0
    local loaded_count=0
    local error_count=0
    
    # Leer archivo línea por línea
    while IFS= read -r line || [[ -n "$line" ]]; do
        line_number=$((line_number + 1))
        
        # Eliminar espacios en blanco al inicio y final
        line=$(echo "$line" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
        
        # Ignorar líneas vacías
        if [[ -z "$line" ]]; then
            continue
        fi
        
        # Ignorar comentarios (líneas que comienzan con #)
        if [[ "$line" =~ ^# ]]; then
            continue
        fi
        
        # Parsear formato: Nombre|Ruta|Descripción|Nivel|Parámetros(opcional)
        IFS='|' read -r name path description level params <<< "$line"
        
        # Validar que los campos requeridos no estén vacíos
        if [[ -z "$name" || -z "$path" ]]; then
            if declare -f log_warn >/dev/null; then
                log_warn "Invalid entry at line $line_number: missing name or path"
            fi
            print_warning "Skipping invalid entry at line $line_number (missing name or path)"
            error_count=$((error_count + 1))
            continue
        fi
        
        # Establecer valores por defecto
        description="${description:-Execute script}"
        level="${level:-1}"
        params="${params:-}"
        
        # Validar la entrada
        if validate_script_entry "$name" "$path" "$description" "$level" "$params"; then
            # Almacenar en array asociativo
            SCRIPT_ENTRIES["$name"]="$path|$description|$level|$params"
            loaded_count=$((loaded_count + 1))
            
            if declare -f log_debug >/dev/null; then
                log_debug "Loaded script: $name -> $path"
            fi
        else
            if declare -f log_warn >/dev/null; then
                log_warn "Validation failed for entry at line $line_number: $name"
            fi
            print_warning "Skipping invalid entry at line $line_number: $name"
            error_count=$((error_count + 1))
        fi
        
    done < "$config_file"
    
    # Reportar resultados
    if declare -f log_info >/dev/null; then
        log_info "Script configuration loaded: $loaded_count scripts, $error_count errors"
    fi
    
    if [[ $loaded_count -gt 0 ]]; then
        print_success "Loaded $loaded_count script(s) from configuration"
    fi
    
    if [[ $error_count -gt 0 ]]; then
        print_warning "Skipped $error_count invalid entry/entries"
    fi
    
    return 0
}

# Valida una entrada individual de script
validate_script_entry() {
    local name="$1"
    local path="$2"
    local description="$3"
    local level="$4"
    local params="$5"
    local skip_file_check="${6:-false}"  # Para tests
    
    local validation_errors=0
    
    # Validar nombre (no vacío, longitud razonable)
    if [[ -z "$name" ]]; then
        if declare -f log_error >/dev/null; then
            log_error "Script name cannot be empty"
        fi
        validation_errors=$((validation_errors + 1))
    elif [[ ${#name} -gt 50 ]]; then
        if declare -f log_error >/dev/null; then
            log_error "Script name too long (max 50 characters): $name"
        fi
        validation_errors=$((validation_errors + 1))
    fi
    
    # Validar ruta (debe ser absoluta)
    if [[ ! "$path" =~ ^/ ]]; then
        if declare -f log_error >/dev/null; then
            log_error "Script path must be absolute: $path"
        fi
        validation_errors=$((validation_errors + 1))
    fi
    
    # Verificar que el archivo existe (solo si no estamos en modo test)
    if [[ "$skip_file_check" != "true" ]]; then
        if [[ ! -f "$path" ]]; then
            if declare -f log_error >/dev/null; then
                log_error "Script file not found: $path"
            fi
            validation_errors=$((validation_errors + 1))
        fi
        
        # Verificar permisos de ejecución
        if [[ -f "$path" ]] && [[ ! -x "$path" ]]; then
            if declare -f log_warn >/dev/null; then
                log_warn "Script file is not executable: $path"
            fi
            print_warning "Script not executable: $name ($path)"
            validation_errors=$((validation_errors + 1))
        fi
    fi
    
    # Verificar que está en directorios permitidos (si está configurado)
    if [[ -n "${ALLOWED_SCRIPT_DIRS:-}" ]]; then
        if ! check_allowed_directory "$path" "$ALLOWED_SCRIPT_DIRS"; then
            if declare -f log_error >/dev/null; then
                log_error "Script not in allowed directories: $path"
            fi
            validation_errors=$((validation_errors + 1))
        fi
    fi
    
    # Validar nivel (debe ser un número entre 1 y 3)
    if ! [[ "$level" =~ ^[1-3]$ ]]; then
        if declare -f log_warn >/dev/null; then
            log_warn "Invalid permission level: $level (using default: 1)"
        fi
        level=1
    fi
    
    # Validar descripción (longitud razonable)
    if [[ ${#description} -gt 100 ]]; then
        if declare -f log_warn >/dev/null; then
            log_warn "Description too long (max 100 characters), truncating"
        fi
        description="${description:0:100}..."
    fi
    
    # Retornar resultado de validación
    if [[ $validation_errors -gt 0 ]]; then
        if declare -f log_error >/dev/null; then
            log_error "Script validation failed with $validation_errors error(s): $name"
        fi
        return 1
    fi
    
    return 0
}

# Verifica que la ruta está en directorios permitidos
check_allowed_directory() {
    local script_path="$1"
    local allowed_dirs="$2"
    
    # Obtener ruta canónica del script (resuelve symlinks)
    local canonical_script_path=$(readlink -f "$script_path" 2>/dev/null || echo "$script_path")
    
    # Parsear directorios permitidos (separados por :)
    IFS=':' read -ra dirs <<< "$allowed_dirs"
    
    # Verificar contra cada directorio permitido
    for dir in "${dirs[@]}"; do
        # Saltar entradas vacías
        [[ -z "$dir" ]] && continue
        
        # Obtener ruta canónica del directorio permitido
        local canonical_dir=$(readlink -f "$dir" 2>/dev/null || echo "$dir")
        
        # Verificar si el script está dentro de este directorio
        if [[ "$canonical_script_path" == "$canonical_dir"* ]]; then
            if declare -f log_debug >/dev/null; then
                log_debug "Script is within allowed directory: $canonical_dir"
            fi
            return 0
        fi
    done
    
    # No se encontró en ningún directorio permitido
    if declare -f log_error >/dev/null; then
        log_error "Script not in allowed directories: $script_path"
    fi
    
    return 1
}

# Obtiene información de un script cargado
get_script_info() {
    local script_name="$1"
    
    if [[ -n "${SCRIPT_ENTRIES[$script_name]:-}" ]]; then
        echo "${SCRIPT_ENTRIES[$script_name]}"
        return 0
    else
        if declare -f log_error >/dev/null; then
            log_error "Script not found in configuration: $script_name"
        fi
        return 1
    fi
}

# =============================================================================
# Auto-Scan Plugin Directories
# =============================================================================

# Array asociativo para almacenar scripts auto-detectados
# Formato: AUTO_SCRIPTS["ruta/relativa"]="ruta|nombre|descripción|nivel"
declare -gA AUTO_SCRIPTS

# Escanear directorios de plugins automáticamente
scan_plugin_directories() {
    local plugin_dir="${PLUGIN_DIR:-$PROJECT_ROOT/plugins}"

    # Verificar si el auto-scan está habilitado
    if [[ "${ENABLE_AUTO_SCAN:-true}" != "true" ]]; then
        if declare -f log_debug >/dev/null; then
            log_debug "Auto-scan disabled by configuration"
        fi
        return 0
    fi

    if [[ ! -d "$plugin_dir" ]]; then
        if declare -f log_warn >/dev/null; then
            log_warn "Plugin directory not found: $plugin_dir"
        fi
        return 1
    fi

    if declare -f log_info >/dev/null; then
        log_info "Scanning plugin directories: $plugin_dir"
    fi

    local scan_depth="${PLUGIN_SCAN_DEPTH:-3}"
    local extensions="${PLUGIN_EXTENSIONS:-.sh}"
    local script_count=0

    # Limpiar array anterior
    AUTO_SCRIPTS=()



    # Convertir extensiones a patrón find
    local find_pattern=""
    IFS=' ' read -ra EXT_ARRAY <<< "$extensions"
    for ext in "${EXT_ARRAY[@]}"; do
        if [[ -n "$find_pattern" ]]; then
            find_pattern="$find_pattern -o"
        fi
        # Asegurar que la extensión tenga punto al inicio
        [[ "$ext" != .* ]] && ext=".$ext"
        find_pattern="$find_pattern -name \"*$ext\""
    done



    # Construir comando find con profundidad máxima
    local find_cmd="find \"$plugin_dir\" -type f -executable \( $find_pattern \) -print0"

    if [[ "$scan_depth" -gt 0 ]]; then
        find_cmd="find \"$plugin_dir\" -maxdepth \"$scan_depth\" -type f -executable \( $find_pattern \) -print0"
    fi



    # Ejecutar find y procesar resultados
    local found_scripts=""
    while IFS= read -r -d '' script_path; do
        found_scripts="$found_scripts $script_path"
        # Verificar que esté en directorios permitidos
        if ! check_allowed_directory "$script_path" "${ALLOWED_SCRIPT_DIRS:-}"; then

            if declare -f log_debug >/dev/null; then
                log_debug "Skipping script outside allowed directories: $script_path"
            fi
            continue
        fi

        # Obtener información del script
        local rel_path="${script_path#$plugin_dir/}"
        local script_name=$(basename "$script_path")
        local dir_path=$(dirname "$rel_path")

        # Determinar nombre para mostrar (quitar extensión)
        local display_name="${script_name%.*}"

        # Generar descripción automática
        local description="Auto-detected script"
        if [[ "$dir_path" != "." ]]; then
            description="$description in $dir_path/"
        fi

        # Determinar nivel de permisos basado en nombre y ubicación
        local level=$(determine_script_level "$script_name" "$dir_path")

        # Crear clave única para el script
        local script_key="$rel_path"

        # Crear clave única y segura para el script (sanitizar caracteres especiales)
        local safe_key=$(echo "$rel_path" | sed 's/[^a-zA-Z0-9_]/_/g')

        # Almacenar información del script
        AUTO_SCRIPTS["${safe_key}_path"]="$script_path"
        AUTO_SCRIPTS["${safe_key}_name"]="$display_name"
        AUTO_SCRIPTS["${safe_key}_description"]="$description"
        AUTO_SCRIPTS["${safe_key}_level"]="$level"
        AUTO_SCRIPTS["${safe_key}_directory"]="$dir_path"
        AUTO_SCRIPTS["${safe_key}_original_key"]="$rel_path"

        script_count=$((script_count + 1))



        if declare -f log_debug >/dev/null; then
            log_debug "Auto-detected script: $script_key -> $script_path"
        fi

    done < <(eval "$find_cmd" 2>&1 | tee /tmp/bashmenu_find.log)



    if declare -f log_info >/dev/null; then
        log_info "Auto-scanned $script_count scripts from plugin directories"
    fi

    return 0
}

# Determinar nivel de permisos para un script basado en su nombre y ubicación
determine_script_level() {
    local script_name="$1"
    local dir_path="$2"

    # Nivel 3 (Root) - scripts críticos o de producción
    if [[ "$script_name" =~ (deploy|production|critical|delete|remove|shutdown|reboot) ]] ||
       [[ "$dir_path" =~ (production|critical|system) ]]; then
        echo "3"
        return
    fi

    # Nivel 2 (Admin) - scripts administrativos
    if [[ "$script_name" =~ (restart|update|admin|backup|restore|config) ]] ||
       [[ "$dir_path" =~ (admin|maintenance|tools) ]]; then
        echo "2"
        return
    fi

    # Nivel 1 (User) - scripts de usuario por defecto
    echo "1"
}

# Obtener información de un script auto-detectado
get_auto_script_info() {
    local script_key="$1"
    local info_type="$2"  # path, name, description, level, directory

    local key="${script_key}_${info_type}"
    echo "${AUTO_SCRIPTS[$key]:-}"
}

# Contar scripts auto-detectados
count_auto_scripts() {
    local count=0
    for key in "${!AUTO_SCRIPTS[@]}"; do
        if [[ $key =~ _path$ ]]; then
            count=$((count + 1))
        fi
    done
    echo "$count"
}

# =============================================================================
# Export Functions
# =============================================================================

export -f load_script_config
export -f validate_script_entry
export -f check_allowed_directory
export -f get_script_info
export -f scan_plugin_directories
export -f determine_script_level
export -f get_auto_script_info
export -f count_auto_scripts
