#!/bin/bash

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
# Export Functions
# =============================================================================

export -f load_script_config
export -f validate_script_entry
export -f check_allowed_directory
export -f get_script_info
