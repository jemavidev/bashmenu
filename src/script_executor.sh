#!/bin/bash

# =============================================================================
# Script Executor Module for Bashmenu
# =============================================================================
# Description: Executes external scripts safely with real-time output
# Version:     1.0
# =============================================================================

# =============================================================================
# Script Execution Functions
# =============================================================================

# Ejecuta un script y muestra salida en tiempo real
execute_script() {
    local script_path="$1"
    local script_name="$2"
    local default_params="$3"
    
    clear
    print_header "Executing: $script_name"
    echo ""
    
    # Re-validar script antes de ejecutar
    if ! validate_script_execution "$script_path"; then
        local error_code=$?
        handle_script_error "validation_failed" "$script_name" "$error_code"
        return 1
    fi
    
    # Solicitar parámetros solo si están configurados
    local params=""
    if [[ -n "$default_params" ]]; then
        params=$(prompt_for_parameters "$script_name" "$default_params")
        
        # Si el usuario canceló, abortar
        if [[ $? -ne 0 ]]; then
            print_warning "Execution cancelled by user"
            echo ""
            echo -e "${success_color}Press Enter to return to menu...${NC}"
            read -s
            return 1
        fi
        
        # Validar y sanitizar parámetros
        if [[ -n "$params" ]]; then
            if ! validate_parameters "$params"; then
                handle_script_error "invalid_parameters" "$script_name" "$params"
                return 1
            fi
            
            params=$(sanitize_parameters "$params")
            echo -e "${CYAN}Parameters:${NC} $params"
            echo ""
        fi
    fi
    
    # Mostrar información de ejecución
    print_separator
    echo -e "${CYAN}Script:${NC} $script_path"
    if [[ -n "$params" ]]; then
        echo -e "${CYAN}Parameters:${NC} $params"
    fi
    echo -e "${CYAN}Started:${NC} $(date '+%Y-%m-%d %H:%M:%S')"
    print_separator
    echo ""
    
    # Registrar inicio de ejecución
    if declare -f log_info >/dev/null; then
        log_info "Executing script: $script_name ($script_path) with params: $params"
    fi
    
    # Ejecutar script y capturar salida
    local start_time=$(date +%s)
    local exit_code=0
    
    if [[ -n "$params" ]]; then
        # Ejecutar con parámetros usando array para evitar word splitting
        display_script_output "$script_path" "$params"
        exit_code=$?
    else
        # Ejecutar sin parámetros
        display_script_output "$script_path" ""
        exit_code=$?
    fi
    
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    # Mostrar resumen de ejecución
    echo ""
    print_separator
    echo -e "${CYAN}Finished:${NC} $(date '+%Y-%m-%d %H:%M:%S')"
    echo -e "${CYAN}Duration:${NC} ${duration}s"
    echo -e "${CYAN}Exit Code:${NC} $exit_code"
    
    if [[ $exit_code -eq 0 ]]; then
        echo -e "${CYAN}Status:${NC} ${GREEN}✓ Success${NC}"
        if declare -f log_info >/dev/null; then
            log_info "Script completed successfully: $script_name (exit code: $exit_code, duration: ${duration}s)"
        fi
    else
        echo -e "${CYAN}Status:${NC} ${RED}✗ Failed${NC}"
        if declare -f log_error >/dev/null; then
            log_error "Script failed: $script_name (exit code: $exit_code, duration: ${duration}s)"
        fi
    fi
    print_separator
    
    # Esperar Enter del usuario
    echo ""
    echo -e "${success_color}Press Enter to return to menu...${NC}"
    read -s
    
    return $exit_code
}

# Solicita parámetros al usuario si son necesarios
prompt_for_parameters() {
    local script_name="$1"
    local default_params="$2"
    
    # Todos los mensajes van a stderr para no contaminar el output
    echo "" >&2
    echo -e "${CYAN}Enter parameters for: $script_name${NC}" >&2
    
    if [[ -n "$default_params" ]]; then
        echo -e "${YELLOW}Default:${NC} $default_params" >&2
        echo -e "${YELLOW}Press Enter to use default, or type new parameters${NC}" >&2
    else
        echo -e "${YELLOW}Press Enter to skip, or type parameters${NC}" >&2
    fi
    
    echo -n "> " >&2
    
    # Leer entrada del usuario con timeout opcional
    local user_input=""
    if [[ "${SESSION_TIMEOUT_ENABLED:-true}" == "true" ]]; then
        local timeout="${INPUT_TIMEOUT:-30}"
        if ! read -t "$timeout" user_input; then
            echo "" >&2
            print_warning "Input timeout, using default parameters" >&2
            echo "$default_params"
            return 0
        fi
    else
        read user_input
    fi
    
    # Si el usuario presionó Ctrl+C o ESC, cancelar
    if [[ $? -ne 0 ]]; then
        return 1
    fi
    
    # Si el usuario no ingresó nada, usar parámetros por defecto
    if [[ -z "$user_input" ]]; then
        echo "$default_params"
        return 0
    fi
    
    # Retornar parámetros ingresados
    echo "$user_input"
    return 0
}

# Muestra salida del script con colores
display_script_output() {
    local script_path="$1"
    local params="$2"
    
    # Crear archivo temporal para stderr
    local stderr_file=$(mktemp)
    
    # Ejecutar script y procesar salida en tiempo real
    if [[ -n "$params" ]]; then
        # Ejecutar con parámetros
        # Usar eval con comillas para manejar parámetros correctamente
        "$script_path" $params 2> >(tee "$stderr_file" >&2)
        local exit_code=$?
    else
        # Ejecutar sin parámetros
        "$script_path" 2> >(tee "$stderr_file" >&2)
        local exit_code=$?
    fi
    
    # Registrar stderr en log si hay contenido
    if [[ -s "$stderr_file" ]]; then
        if declare -f log_warn >/dev/null; then
            log_warn "Script stderr output:"
            while IFS= read -r line; do
                log_warn "  $line"
            done < "$stderr_file"
        fi
    fi
    
    # Limpiar archivo temporal
    rm -f "$stderr_file"
    
    return $exit_code
}

# =============================================================================
# Error Handling Functions
# =============================================================================

# Función centralizada de manejo de errores
handle_script_error() {
    local error_type="$1"
    local script_name="$2"
    local details="$3"
    
    echo ""
    print_separator
    
    case "$error_type" in
        "not_found")
            print_error "Script not found: $script_name"
            echo -e "${YELLOW}The script file does not exist or has been deleted${NC}"
            if declare -f log_error >/dev/null; then
                log_error "Script execution failed: $script_name not found"
            fi
            ;;
        "no_permission")
            print_error "Permission denied: $script_name"
            echo -e "${YELLOW}The script file is not executable${NC}"
            echo -e "${CYAN}Fix with:${NC} chmod +x /path/to/script"
            if declare -f log_error >/dev/null; then
                log_error "Script execution failed: $script_name no execute permission"
            fi
            ;;
        "not_allowed")
            print_error "Security: Script not in allowed directories"
            echo -e "${YELLOW}The script is outside the configured allowed directories${NC}"
            echo -e "${CYAN}Allowed directories:${NC} ${ALLOWED_SCRIPT_DIRS:-Not configured}"
            if declare -f log_error >/dev/null; then
                log_error "Security violation: $script_name not in ALLOWED_SCRIPT_DIRS"
            fi
            ;;
        "execution_failed")
            print_error "Script failed with exit code: $details"
            echo -e "${YELLOW}The script encountered an error during execution${NC}"
            if declare -f log_error >/dev/null; then
                log_error "Script $script_name failed with exit code $details"
            fi
            ;;
        "timeout")
            print_error "Script execution timeout"
            echo -e "${YELLOW}The script exceeded the maximum execution time${NC}"
            echo -e "${CYAN}Timeout:${NC} ${SCRIPT_EXECUTION_TIMEOUT:-300}s"
            if declare -f log_error >/dev/null; then
                log_error "Script $script_name exceeded timeout limit"
            fi
            ;;
        "validation_failed")
            print_error "Script validation failed"
            echo -e "${YELLOW}The script failed security validation (error code: $details)${NC}"
            case "$details" in
                10) echo -e "${CYAN}Reason:${NC} File not found" ;;
                11) echo -e "${CYAN}Reason:${NC} Not a regular file" ;;
                12) echo -e "${CYAN}Reason:${NC} Not readable" ;;
                13) echo -e "${CYAN}Reason:${NC} Not executable" ;;
                14) echo -e "${CYAN}Reason:${NC} Not in allowed directory" ;;
                15) echo -e "${CYAN}Reason:${NC} Syntax error" ;;
                *) echo -e "${CYAN}Reason:${NC} Unknown error" ;;
            esac
            if declare -f log_error >/dev/null; then
                log_error "Script validation failed: $script_name (code: $details)"
            fi
            ;;
        "invalid_parameters")
            print_error "Invalid or dangerous parameters detected"
            echo -e "${YELLOW}The parameters contain potentially dangerous patterns${NC}"
            echo -e "${CYAN}Parameters:${NC} $details"
            if declare -f log_error >/dev/null; then
                log_error "Invalid parameters for script $script_name: $details"
            fi
            ;;
        *)
            print_error "Unknown error occurred"
            echo -e "${YELLOW}Details:${NC} $details"
            if declare -f log_error >/dev/null; then
                log_error "Unknown error for script $script_name: $error_type - $details"
            fi
            ;;
    esac
    
    print_separator
    echo ""
    echo -e "${success_color}Press Enter to return to menu...${NC}"
    read -s
}

# =============================================================================
# Utility Functions
# =============================================================================

# =============================================================================
# Export Functions
# =============================================================================

export -f execute_script
export -f prompt_for_parameters
export -f display_script_output
export -f handle_script_error
