#!/bin/bash

# =============================================================================
# Módulo Validador de Scripts para Bashmenu
# =============================================================================
# Descripción: Valida scripts antes de ejecución por seguridad e integridad
# Versión:     2.1
# Autor:       JESUS MARIA VILLALOBOS
# =============================================================================

# =============================================================================
# Script Validation Functions
# =============================================================================

# Valida que un script puede ejecutarse de forma segura
validate_script_execution() {
    local script_path="$1"
    
    # Log only if log_debug function exists and log level allows it
    if declare -f log_debug >/dev/null && [[ "${LOG_LEVEL:-1}" -le 0 ]]; then
        log_debug "Validating script for execution: $script_path"
    fi
    
    local validation_errors=0
    
    # 1. Verificar que el archivo existe
    if [[ ! -e "$script_path" ]]; then
        if declare -f log_error >/dev/null; then
            log_error "Script file does not exist: $script_path"
        fi
        print_error "Script file not found: $script_path"
        return 10  # Error code: file not found
    fi
    
    # 2. Verificar que es un archivo regular (no directorio, no dispositivo)
    if [[ ! -f "$script_path" ]]; then
        if declare -f log_error >/dev/null; then
            log_error "Script path is not a regular file: $script_path"
        fi
        print_error "Script path must be a regular file"
        return 11  # Error code: not a regular file
    fi
    
    # 3. Verificar permisos de lectura
    if [[ ! -r "$script_path" ]]; then
        if declare -f log_error >/dev/null; then
            log_error "Script file is not readable: $script_path"
        fi
        print_error "Script file is not readable"
        return 12  # Error code: not readable
    fi
    
    # 4. Verificar permisos de ejecución
    if [[ ! -x "$script_path" ]]; then
        if declare -f log_error >/dev/null; then
            log_error "Script file is not executable: $script_path"
        fi
        print_error "Script file is not executable: $script_path"
        print_info "Fix with: chmod +x $script_path"
        return 13  # Error code: not executable
    fi
    
    # 5. Verificar que está en directorio permitido
    if [[ -n "${ALLOWED_SCRIPT_DIRS:-}" ]]; then
        if ! check_script_in_allowed_directory "$script_path" "$ALLOWED_SCRIPT_DIRS"; then
            if declare -f log_error >/dev/null; then
                log_error "Script not in allowed directories: $script_path"
            fi
            print_error "Security: Script not in allowed directories"
            print_info "Allowed directories: ${ALLOWED_SCRIPT_DIRS}"
            return 14  # Error code: not in allowed directory
        fi
    fi
    
    # 6. Verificar sintaxis bash (si es un script bash)
    if [[ "$script_path" =~ \.sh$ ]] || head -n 1 "$script_path" | grep -q "^#!.*bash"; then
        if ! bash -n "$script_path" 2>/dev/null; then
            if declare -f log_error >/dev/null; then
                log_error "Script has syntax errors: $script_path"
            fi
            print_error "Script has syntax errors"
            print_info "Check with: bash -n $script_path"
            return 15  # Error code: syntax error
        fi
    fi
    
    # Todas las validaciones pasaron
    if declare -f log_info >/dev/null && [[ "${LOG_LEVEL:-1}" -le 1 ]]; then
        log_info "Script validation passed: $script_path"
    fi
    
    return 0
}

# Verifica que la ruta está en directorios permitidos
check_script_in_allowed_directory() {
    local script_path="$1"
    local allowed_dirs="$2"
    
    # Obtener ruta canónica del script (resuelve symlinks)
    local canonical_script_path=$(readlink -f "$script_path" 2>/dev/null)
    
    if [[ -z "$canonical_script_path" ]]; then
        if declare -f log_error >/dev/null; then
            log_error "Failed to resolve canonical path: $script_path"
        fi
        return 1
    fi
    
    if declare -f log_debug >/dev/null && [[ "${LOG_LEVEL:-1}" -le 0 ]]; then
        log_debug "Canonical script path: $canonical_script_path"
    fi
    
    # Parsear directorios permitidos (separados por :)
    IFS=':' read -ra dirs <<< "$allowed_dirs"
    
    # Verificar contra cada directorio permitido
    for dir in "${dirs[@]}"; do
        # Saltar entradas vacías
        [[ -z "$dir" ]] && continue
        
        # Obtener ruta canónica del directorio permitido
        local canonical_dir=$(readlink -f "$dir" 2>/dev/null)
        
        if [[ -z "$canonical_dir" ]]; then
            if declare -f log_warn >/dev/null; then
                log_warn "Failed to resolve allowed directory: $dir"
            fi
            continue
        fi
        
        # Asegurar que el directorio termine con /
        [[ "$canonical_dir" != */ ]] && canonical_dir="$canonical_dir/"
        
        # Verificar si el script está dentro de este directorio
        if [[ "$canonical_script_path" == "$canonical_dir"* ]]; then
            if declare -f log_debug >/dev/null && [[ "${LOG_LEVEL:-1}" -le 0 ]]; then
                log_debug "Script is within allowed directory: $canonical_dir"
            fi
            return 0
        fi
    done
    
    # No se encontró en ningún directorio permitido
    if declare -f log_error >/dev/null; then
        log_error "Script not in any allowed directory: $canonical_script_path"
    fi
    
    return 1
}

# Sanitiza parámetros de entrada del usuario
sanitize_parameters() {
    local params="$1"
    local max_length="${2:-500}"
    
    if declare -f log_debug >/dev/null; then
        log_debug "Sanitizing parameters: $params"
    fi
    
    # Eliminar caracteres peligrosos para shell injection
    # Caracteres bloqueados: ; & | $ ` \ " ' < > ( ) { } [ ]
    local sanitized="$params"
    
    # Eliminar punto y coma (command separator)
    sanitized="${sanitized//;/}"
    
    # Eliminar ampersand (background execution)
    sanitized="${sanitized//&/}"
    
    # Eliminar pipe (command chaining)
    sanitized="${sanitized//|/}"
    
    # Eliminar dollar sign (variable expansion)
    sanitized="${sanitized//$/}"
    
    # Eliminar backticks (command substitution)
    sanitized="${sanitized//\`/}"
    
    # Eliminar backslash (escape character)
    sanitized="${sanitized//\\/}"
    
    # Eliminar comillas dobles y simples
    sanitized="${sanitized//\"/}"
    sanitized="${sanitized//\'/}"
    
    # Eliminar redirecciones
    sanitized="${sanitized//</}"
    sanitized="${sanitized//>/}"
    
    # Eliminar paréntesis (subshell)
    sanitized="${sanitized//(/}"
    sanitized="${sanitized//)/}"
    
    # Eliminar llaves (brace expansion) - usando sed para evitar problemas
    sanitized=$(echo "$sanitized" | tr -d '{}')
    
    # Eliminar corchetes (array/test) - usando sed para evitar problemas
    sanitized=$(echo "$sanitized" | tr -d '[]')
    
    # Limitar longitud máxima
    if [[ ${#sanitized} -gt $max_length ]]; then
        if declare -f log_warn >/dev/null; then
            log_warn "Parameters truncated to $max_length characters"
        fi
        sanitized="${sanitized:0:$max_length}"
    fi
    
    # Eliminar espacios múltiples y espacios al inicio/final
    sanitized=$(echo "$sanitized" | tr -s ' ' | xargs)
    
    if declare -f log_debug >/dev/null; then
        log_debug "Sanitized parameters: $sanitized"
    fi
    
    echo "$sanitized"
}

# Valida que los parámetros son seguros
validate_parameters() {
    local params="$1"
    
    # Lista de patrones peligrosos
    local dangerous_patterns=(
        "rm -rf"
        "rm-rf"
        "dd if="
        "dd if"
        "mkfs"
        "fdisk"
        "shutdown"
        "reboot"
        "init 0"
        "init 6"
        ":(){ :|:& };:"  # Fork bomb
        ":|:&"           # Fork bomb pattern
        "/dev/sd"
        "/dev/hd"
        "curl.*\|.*bash"  # Pipe to bash (escaped pipe)
        "wget.*\|.*bash"  # Pipe to bash (escaped pipe)
        "&&"             # Command chaining (literal &&)
        "\|\|"           # Command chaining (escaped ||)
    )
    
    # Verificar contra patrones peligrosos
    for pattern in "${dangerous_patterns[@]}"; do
        if [[ "$params" =~ $pattern ]]; then
            if declare -f log_error >/dev/null; then
                log_error "Dangerous pattern detected in parameters: $pattern"
            fi
            if declare -f print_error >/dev/null; then
                print_error "Security: Dangerous pattern detected in parameters"
            fi
            return 1
        fi
    done
    
    return 0
}

# =============================================================================
# Export Functions
# =============================================================================

export -f validate_script_execution
export -f check_script_in_allowed_directory
export -f sanitize_parameters
export -f validate_parameters
