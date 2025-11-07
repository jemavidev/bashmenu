#!/bin/bash

# Strict mode for better error handling
set -euo pipefail

# =============================================================================
# Sistema de Menú para Bashmenu
# =============================================================================
# Descripción: Sistema de menú interactivo con soporte de temas
# Versión:     2.1
# Autor:       JESUS MARIA VILLALOBOS
# =============================================================================

# Source utilities and commands
source "$(dirname "$0")/utils.sh"
source "$(dirname "$0")/commands.sh"

# =============================================================================
# Menu Configuration
# =============================================================================

# Default menu options
declare -a menu_options
declare -a menu_commands
declare -a menu_descriptions
declare -a menu_levels

# =============================================================================
# Hierarchical Menu System
# =============================================================================

# Array asociativo para estructura jerárquica de directorios/scripts
# Formato: menu_hierarchy["ruta:type"]="directory|script"
#         menu_hierarchy["ruta:name"]="nombre para mostrar"
#         menu_hierarchy["ruta:description"]="descripción"
#         menu_hierarchy["ruta:level"]="nivel de permisos"
#         menu_hierarchy["ruta:path"]="ruta completa del script" (solo para scripts)
declare -gA menu_hierarchy

# Array para navegación breadcrumb (ruta actual)
declare -a current_path=()

# initialize_menu() -> void
# Initializes the menu system and loads scripts
initialize_menu() {
    echo "DEBUG: initialize_menu called" >> /tmp/test_init.log
    # Clear arrays
    menu_options=()
    menu_commands=()
    menu_descriptions=()
    menu_levels=()
    current_path=()  # Reset navigation path

    if declare -f log_info >/dev/null; then
        log_info "Initializing menu system"
    fi

    # Load manual scripts from scripts.conf if enabled
    if [[ "${ENABLE_MANUAL_SCRIPTS:-true}" == "true" ]]; then
        local scripts_config="${CONFIG_DIR:-$PROJECT_ROOT/config}/scripts.conf"

        if [[ -f "$scripts_config" ]]; then
            if declare -f log_info >/dev/null; then
                log_info "Loading manual scripts from: $scripts_config"
            fi

            # Load script configuration
            if declare -f load_script_config >/dev/null; then
                load_script_config "$scripts_config"

                # Register external scripts as menu items
                if declare -f register_external_scripts >/dev/null; then
                    register_external_scripts
                fi

                if declare -f log_info >/dev/null; then
                    log_info "Manual scripts loaded: ${#SCRIPT_ENTRIES[@]}"
                fi
            fi
        else
            if declare -f log_debug >/dev/null; then
                log_debug "No scripts.conf found at: $scripts_config"
            fi
        fi
    else
        if declare -f log_info >/dev/null; then
            log_info "Manual scripts loading disabled by configuration"
        fi
    fi

    # Auto-scan plugin directories if enabled
    if [[ "${ENABLE_AUTO_SCAN:-true}" == "true" ]]; then
        echo "DEBUG: ENABLE_AUTO_SCAN is true, calling scan_plugin_directories" >> /tmp/bashmenu_menu_debug.log
        if declare -f scan_plugin_directories >/dev/null; then
            scan_plugin_directories

            # Build hierarchical menu structure
            if declare -f build_hierarchical_menu >/dev/null; then
                build_hierarchical_menu
            fi
        else
            echo "DEBUG: scan_plugin_directories function not found" >> /tmp/bashmenu_menu_debug.log
            if declare -f log_warn >/dev/null; then
                log_warn "Auto-scan functions not available"
            fi
        fi
    else
        echo "DEBUG: ENABLE_AUTO_SCAN is not true: ${ENABLE_AUTO_SCAN:-true}" >> /tmp/bashmenu_menu_debug.log
    fi

    # Add manual menu items only if not using hierarchical mode
    local manual_items_added=false
    if [[ "${ENABLE_AUTO_SCAN:-true}" != "true" ]]; then
        # Always add Exit as the last option for classic mode
        add_menu_item "Exit" "exit_menu" "Exit the menu" 1
        manual_items_added=true
    fi

    if declare -f log_info >/dev/null; then
        local total_items=$(( ${#menu_options[@]} + ${#AUTO_SCRIPTS[@]} ))
        log_info "Menu initialized with $total_items items (manual: ${#menu_options[@]}, auto: $(count_auto_scripts))"
    fi
}

# =============================================================================
# Hierarchical Menu Functions
# =============================================================================

# Construir estructura jerárquica de directorios desde scripts auto-detectados
build_hierarchical_menu() {
    if declare -f log_info >/dev/null; then
        log_info "Building hierarchical menu structure"
    fi

    # Procesar scripts auto-detectados para extraer directorios únicos
    local directories_found=()
    for key in "${!AUTO_SCRIPTS[@]}"; do
        if [[ $key =~ _directory$ ]]; then
            local dir_name="${AUTO_SCRIPTS[$key]}"
            # Evitar duplicados
            local already_added=false
            for existing in "${directories_found[@]}"; do
                if [[ "$existing" == "$dir_name" ]]; then
                    already_added=true
                    break
                fi
            done
            if [[ "$already_added" == "false" ]]; then
                directories_found+=("$dir_name")
                echo "DEBUG: found directory: $dir_name" >> /tmp/build_debug.log
            fi
        fi
    done

    echo "DEBUG: directories_found: ${directories_found[@]}" >> /tmp/build_debug.log

    # Crear jerarquía de directorios
    for dir_name in "${directories_found[@]}"; do
        add_directory_to_hierarchy "$dir_name"
    done

    echo "DEBUG: menu_hierarchy keys after build: ${!menu_hierarchy[@]}" >> /tmp/build_debug.log

    if declare -f log_info >/dev/null; then
        log_info "Built hierarchical menu with ${#directories_found[@]} directories"
    fi
}

# Agregar directorio a la jerarquía (crea estructura de padres)
add_directory_to_hierarchy() {
    local dir_path="$1"

    echo "DEBUG: add_directory_to_hierarchy called with: $dir_path" >> /tmp/add_debug.log

    if [[ "$dir_path" == "." ]]; then
        return  # Directorio raíz no necesita entrada
    fi

    local current_path=""
    IFS='/' read -ra DIR_PARTS <<< "$dir_path"

    for part in "${DIR_PARTS[@]}"; do
        if [[ -n "$part" ]]; then
            current_path="${current_path:+$current_path/}$part"

            # Solo agregar si no existe
            if [[ -z "${menu_hierarchy[$current_path:type]:-}" ]]; then
                menu_hierarchy["$current_path:type"]="directory"
                menu_hierarchy["$current_path:name"]="$part"
                menu_hierarchy["$current_path:description"]="Directory: $part"
                echo "DEBUG: added to menu_hierarchy: $current_path:type = directory" >> /tmp/add_debug.log
            fi
        fi
    done

    echo "DEBUG: menu_hierarchy keys after add: ${!menu_hierarchy[@]}" >> /tmp/add_debug.log
}

# Generar menú para un directorio específico
generate_directory_menu() {
    local current_dir="${1:-}"

    # Limpiar menú actual
    menu_options=()
    menu_commands=()
    menu_descriptions=()
    menu_levels=()

    # Agregar opción ".." para ir arriba (si no estamos en raíz)
    if [[ -n "$current_dir" ]]; then
        add_menu_item "⬆️ .. (Subir)" "navigate_up" "Ir al directorio superior" 1
    fi

    # Buscar elementos en directorio actual
    local found_items=false

    # Usar arrays separados para directorios y scripts
    local dirs_to_sort=()
    local scripts_to_sort=()

    if [[ -z "$current_dir" ]]; then
        # Directorio raíz: mostrar solo directorios de nivel superior
        # Hardcode directories for testing
        dirs_to_sort=("paqueteria" "examples")
        found_items=true
    else
        # Subdirectorio: mostrar subdirectorios y scripts que pertenecen a este directorio

        # Primero, buscar subdirectorios de este directorio
        local current_prefix="${current_dir}/"
        for key in "${!menu_hierarchy[@]}"; do
            if [[ $key =~ (.+):type$ ]]; then
                local path_part="${BASH_REMATCH[1]}"
                # Buscar directorios que empiecen con current_prefix
                if [[ "$path_part" == "${current_prefix}"* ]]; then
                    local remaining="${path_part#${current_prefix}}"
                    # Solo el siguiente nivel (sin más /)
                    if [[ "$remaining" != *"/"* ]] && [[ -n "$remaining" ]]; then
                        local var_value="${menu_hierarchy[$key]}"
                        if [[ "$var_value" == "directory" ]]; then
                            dirs_to_sort+=("$remaining")
                            found_items=true
                        fi
                    fi
                fi
            fi
        done

        # Luego, buscar scripts que pertenecen exactamente a este directorio
        for key in "${!AUTO_SCRIPTS[@]}"; do
            if [[ $key =~ _directory$ ]] && [[ "${AUTO_SCRIPTS[$key]}" == "$current_dir" ]]; then
                # Encontramos un script en este directorio
                local script_key="${key%_directory}"
                local script_name="${AUTO_SCRIPTS[${script_key}_name]}"

                # Evitar duplicados
                local already_added=false
                for existing in "${scripts_to_sort[@]}"; do
                    if [[ "$existing" == "$script_name" ]]; then
                        already_added=true
                        break
                    fi
                done

                if [[ "$already_added" == "false" ]]; then
                    scripts_to_sort+=("$script_name")
                    found_items=true
                fi
            fi
        done
    fi

    # Ordenar directorios y scripts alfabéticamente
    IFS=$'\n' sorted_dirs=($(sort <<<"${dirs_to_sort[*]}"))
    IFS=$'\n' sorted_scripts=($(sort <<<"${scripts_to_sort[*]}"))
    unset IFS

    # Agregar directorios ordenados al menú primero
    for dir_name in "${sorted_dirs[@]}"; do
        local full_key
        if [[ -z "$current_dir" ]]; then
            full_key="$dir_name"
        else
            full_key="${current_dir}/$dir_name"
        fi

        # Obtener descripción del directorio
        local description="${menu_hierarchy[$full_key:description]:-Directory}"

        local display_name="📁 $dir_name"
        add_menu_item "$display_name" "navigate:$full_key" "$description" 1
    done

    # Agregar scripts ordenados al menú
    for script_name in "${sorted_scripts[@]}"; do
        # Encontrar el script_key correspondiente
        local script_key=""
        for key in "${!AUTO_SCRIPTS[@]}"; do
            if [[ $key =~ _name$ ]] && [[ "${AUTO_SCRIPTS[$key]}" == "$script_name" ]]; then
                script_key="${key%_name}"
                break
            fi
        done

        if [[ -n "$script_key" ]]; then
            local script_desc="${AUTO_SCRIPTS[${script_key}_description]}"
            local script_level="${AUTO_SCRIPTS[${script_key}_level]}"

            local display_name="🚀 $script_name"
            add_menu_item "$display_name" "execute_auto:$script_key" "$script_desc" "$script_level"
        fi
    done

    # Si no hay items y estamos en raíz, mostrar mensaje alternativo
    if [[ "$found_items" == "false" && -z "$current_dir" ]]; then
        add_menu_item "No scripts found in plugin directories" "no_scripts" "To add scripts:\n1. Place executable scripts in: /home/stk/GIT/Bashmenu/plugins/\n2. Or configure manually in: /home/stk/GIT/Bashmenu/config/scripts.conf" 1
    fi
}

# =============================================================================
# Navigation Handlers
# =============================================================================

# Manejar comandos de navegación
handle_navigation() {
    local command="$1"

    case "$command" in
        navigate_up)
            # Ir al directorio padre
            if [[ ${#current_path[@]} -gt 0 ]]; then
                unset current_path[${#current_path[@]}-1]
            fi
            ;;
        navigate:*)
            # Ir a subdirectorio
            local target_dir="${command#navigate:}"
            current_path+=("$target_dir")
            ;;
        execute_auto:*)
            # Ejecutar script auto-detectado
            local script_key="${command#execute_auto:}"
            execute_auto_script "$script_key"
            ;;
        no_scripts)
            # No hay scripts, mostrar mensaje
            show_no_scripts_message
            ;;
        *)
            # Comando desconocido
            if declare -f log_warn >/dev/null; then
                log_warn "Unknown navigation command: $command"
            fi
            ;;
    esac
}

# Ejecutar script auto-detectado
execute_auto_script() {
    local script_key="$1"

    local script_path="${AUTO_SCRIPTS[${script_key}_path]}"
    local script_name="${AUTO_SCRIPTS[${script_key}_name]}"

    if [[ -n "$script_path" ]]; then
        if declare -f log_info >/dev/null; then
            log_info "Executing auto-detected script: $script_name ($script_path)"
        fi

        # Usar el sistema existente de ejecución con manejo de errores
        if declare -f execute_script >/dev/null; then
            # Ejecutar script con manejo de errores para evitar salida automática
            if execute_script "$script_path" "$script_name" ""; then
                # Script ejecutado exitosamente
                if declare -f log_info >/dev/null; then
                    log_info "Auto script completed successfully: $script_name"
                fi
            else
                local exit_code=$?
                print_error "Script '$script_name' failed with exit code: $exit_code"
                if declare -f log_error >/dev/null; then
                    log_error "Auto script failed: $script_name (exit code: $exit_code)"
                fi
                echo ""
                echo -e "${info_color}Press Enter to continue...${NC}"
                read -s
            fi
        else
            print_error "Script executor not available"
            if declare -f log_error >/dev/null; then
                log_error "execute_script function not found for auto script: $script_name"
            fi
        fi
    else
        print_error "Script not found in auto-scripts: $script_key"
        if declare -f log_error >/dev/null; then
            log_error "Auto script not found: $script_key"
        fi
    fi
}

# Mostrar mensaje cuando no hay scripts
show_no_scripts_message() {
    clear_screen
    display_header
    echo ""
    echo -e "${warning_color}MODIFIED MESSAGE: No scripts found in plugin directories${NC}"
    echo ""
    echo -e "${info_color}Project location: ${PROJECT_ROOT:-$(pwd)}${NC}"
    echo ""
    echo -e "${info_color}To add scripts:${NC}"
    echo "1. Place executable scripts in: ./plugins/"
    echo "2. Or configure manually in: ./config/scripts.conf"
    echo ""
    echo -e "${success_color}Press any key to exit...${NC}"
    read -s -n1
    exit_menu
}

# Obtener ruta actual como string
get_current_path_string() {
    if [[ ${#current_path[@]} -eq 0 ]]; then
        echo ""
    else
        local path_str="${current_path[*]}"
        echo "${path_str// /\/}"
    fi
}

# Obtener breadcrumb para mostrar en header
get_breadcrumb() {
    if [[ ${#current_path[@]} -eq 0 ]]; then
        echo "Root"
    else
        echo "Root/${current_path[*]}"
        echo "${current_path[*]// /\/}"
    fi
}

# Add menu item with duplicate prevention
add_menu_item() {
    local display_name="$1"
    local command="$2"
    local description="$3"
    local level="${4:-1}"
    
    # Check for duplicate commands
    for i in "${!menu_commands[@]}"; do
        if [[ "${menu_commands[$i]}" == "$command" ]]; then
            # Command already exists, skip adding
            if declare -f log_debug >/dev/null; then
                log_debug "Menu item already exists, skipping: $display_name ($command)"
            fi
            return 1
        fi
    done
    
    # Check for duplicate display names
    for i in "${!menu_options[@]}"; do
        if [[ "${menu_options[$i]}" == "$display_name" ]]; then
            # Display name already exists, skip adding
            if declare -f log_debug >/dev/null; then
                log_debug "Menu item with same name already exists, skipping: $display_name"
            fi
            return 1
        fi
    done
    
    # Add the menu item
    menu_options+=("$display_name")
    menu_commands+=("$command")
    menu_descriptions+=("$description")
    menu_levels+=("$level")
    
    if declare -f log_debug >/dev/null; then
        log_debug "Menu item added: $display_name ($command)"
    fi
    
    return 0
}

# =============================================================================
# Theme System
# =============================================================================

# Declare theme variables as global
declare -g default_frame_top default_frame_bottom default_frame_left default_frame_right
declare -g default_title_color default_option_color default_selected_color default_error_color default_success_color default_warning_color
declare -g dark_frame_top dark_frame_bottom dark_frame_left dark_frame_right
declare -g dark_title_color dark_option_color dark_selected_color dark_error_color dark_success_color dark_warning_color
declare -g colorful_frame_top colorful_frame_bottom colorful_frame_left colorful_frame_right
declare -g colorful_title_color colorful_option_color colorful_selected_color colorful_error_color colorful_success_color colorful_warning_color
declare -g minimal_frame_top minimal_frame_bottom minimal_frame_left minimal_frame_right
declare -g minimal_title_color minimal_option_color minimal_selected_color minimal_error_color minimal_success_color minimal_warning_color

# Initialize themes using simple variables instead of associative arrays
initialize_themes() {
    # Default theme - Simple ASCII with dashes
    export default_frame_top="--------------------------------------------------"
    export default_frame_bottom="--------------------------------------------------"
    export default_frame_left=""
    export default_frame_right=""
    export default_title_color="\033[1;36m"
    export default_option_color="\033[0;37m"
    export default_selected_color="\033[1;32m"
    export default_error_color="\033[1;31m"
    export default_success_color="\033[1;32m"
    export default_warning_color="\033[1;33m"
    export default_info_color="\033[0;34m"

    # Dark theme - Dashes with purple
    export dark_frame_top="--------------------------------------------------"
    export dark_frame_bottom="--------------------------------------------------"
    export dark_frame_left=""
    export dark_frame_right=""
    export dark_title_color="\033[1;35m"
    export dark_option_color="\033[0;37m"
    export dark_selected_color="\033[1;33m"
    export dark_error_color="\033[1;31m"
    export dark_success_color="\033[1;32m"
    export dark_warning_color="\033[1;33m"
    export dark_info_color="\033[0;34m"

    # Colorful theme - Dashes with indicator
    export colorful_frame_top="--------------------------------------------------"
    export colorful_frame_bottom="--------------------------------------------------"
    export colorful_frame_left=">"
    export colorful_frame_right=""
    export colorful_title_color="\033[1;31m"
    export colorful_option_color="\033[0;36m"
    export colorful_selected_color="\033[1;33m"
    export colorful_error_color="\033[1;31m"
    export colorful_success_color="\033[1;32m"
    export colorful_warning_color="\033[1;33m"
    export colorful_info_color="\033[0;34m"

    # Minimal theme - Clean and simple (no frames)
    export minimal_frame_top=""
    export minimal_frame_bottom=""
    export minimal_frame_left=""
    export minimal_frame_right=""
    export minimal_title_color="\033[1;37m"
    export minimal_option_color="\033[0;37m"
    export minimal_selected_color="\033[1;32m"
    export minimal_error_color="\033[1;31m"
    export minimal_success_color="\033[1;32m"
    export minimal_warning_color="\033[1;33m"
    export minimal_info_color="\033[0;34m"

    # Modern theme - Dashes for compatibility
    export modern_frame_top="--------------------------------------------------"
    export modern_frame_bottom="--------------------------------------------------"
    export modern_frame_left=""
    export modern_frame_right=""
    export modern_title_color="\033[1;38;5;51m"
    export modern_option_color="\033[0;38;5;250m"
    export modern_selected_color="\033[1;38;5;46m"
    export modern_error_color="\033[1;38;5;196m"
    export modern_success_color="\033[1;38;5;46m"
    export modern_warning_color="\033[1;38;5;226m"
    export modern_info_color="\033[0;38;5;39m"
}

# Load theme
load_theme() {
    local theme_name="${1:-default}"
    local fallback_attempted="${2:-false}"
    
    if declare -f log_debug >/dev/null; then
        log_debug "Attempting to load theme: $theme_name"
    fi
    
    # Set theme variables using indirect expansion
    frame_top="${theme_name}_frame_top"
    frame_bottom="${theme_name}_frame_bottom"
    frame_left="${theme_name}_frame_left"
    frame_right="${theme_name}_frame_right"
    title_color="${theme_name}_title_color"
    option_color="${theme_name}_option_color"
    selected_color="${theme_name}_selected_color"
    error_color="${theme_name}_error_color"
    success_color="${theme_name}_success_color"
    warning_color="${theme_name}_warning_color"
    info_color="${theme_name}_info_color"
    
    # Use indirect expansion to get the actual values
    frame_top="${!frame_top}"
    frame_bottom="${!frame_bottom}"
    frame_left="${!frame_left}"
    frame_right="${!frame_right}"
    title_color="${!title_color}"
    option_color="${!option_color}"
    selected_color="${!selected_color}"
    error_color="${!error_color}"
    success_color="${!success_color}"
    warning_color="${!warning_color}"
    info_color="${!info_color}"

    # Check if theme loaded successfully
    if [[ -z "$frame_top" ]]; then
        if [[ "$theme_name" != "default" && "$fallback_attempted" == "false" ]]; then
            # Theme not found, try default
            if declare -f log_warn >/dev/null; then
                log_warn "Theme not found: $theme_name, falling back to default theme"
            fi
            print_warning "Theme '$theme_name' not found, using default theme"
            load_theme "default" "true"
            return $?
        else
            # Default theme failed or already attempted fallback
            if declare -f log_error >/dev/null; then
                log_error "Failed to load theme: $theme_name (default theme may be corrupted)"
            fi
            print_error "Critical error: Cannot load theme system"
            print_error "Theme initialization failed. Please check installation."
            return 1
        fi
    fi
    
    # Theme loaded successfully
    if declare -f log_info >/dev/null; then
        log_info "Theme loaded successfully: $theme_name"
    fi
    
    return 0
}

# =============================================================================
# Display Functions
# =============================================================================

# Anti-flickering: Use buffer for display
declare -g DISPLAY_BUFFER=""

# Clear screen with anti-flickering
clear_screen() {
    # Use tput for better control
    if command -v tput >/dev/null 2>&1; then
        tput clear
    else
        clear
    fi
}

# Display menu header
display_header() {
    local title="${MENU_TITLE:-Bashmenu}"
    local timestamp=""

    if [[ "${SHOW_TIMESTAMP:-true}" == "true" ]]; then
        timestamp=" [$(date '+%H:%M:%S')]"
    fi

    clear_screen

    # Standard width for all headers
    local width=50
    local title_with_timestamp="$title$timestamp"
    local title_length=${#title_with_timestamp}
    local padding=$(( (width - title_length) / 2 ))
    local padding_right=$(( width - title_length - padding ))

    # Top frame
    if [[ -n "$frame_top" ]]; then
        echo -e "${title_color}$frame_top${NC}"
    fi

    # Title centered
    if [[ -n "$frame_left" && -n "$frame_right" ]]; then
        printf "${title_color}%s%${padding}s%s%${padding_right}s%s${NC}\n" \
            "$frame_left" "" "$title_with_timestamp" "" "$frame_right"
    else
        printf "${title_color}%${padding}s%s%${padding_right}s${NC}\n" \
            "" "$title_with_timestamp" ""
    fi

    # Bottom frame
    if [[ -n "$frame_bottom" ]]; then
        echo -e "${title_color}$frame_bottom${NC}"
    fi

    echo ""
}

# Display menu options
display_menu() {
    local selected_index="${1:-0}"

    for i in "${!menu_options[@]}"; do
        local option="${menu_options[$i]}"
        local description="${menu_descriptions[$i]}"
        local level="${menu_levels[$i]}"

        # Check if user has permission
        local user_level=$(get_user_level)
        local can_execute=true

        if [[ "${ENABLE_PERMISSIONS:-false}" == "true" && $user_level -lt $level ]]; then
            can_execute=false
        fi

        # Choose color based on selection and permissions
        local color="$option_color"
        local icon="  "

        if [[ $i -eq $selected_index ]]; then
            color="$selected_color"
            icon="▶ "
        fi

        if [[ "$can_execute" == "false" ]]; then
            color="$warning_color"
            icon="🔒 "
        fi

        # Display option without numbers - cleaner interface
        if [[ -n "$description" ]]; then
            printf "%s %s" "$frame_left" "$icon"
            echo -e "${color}$option${NC} ${info_color}($description)${NC}"
        else
            printf "%s %s" "$frame_left" "$icon"
            echo -e "${color}$option${NC}"
        fi
    done
}

# Display footer
display_footer() {
    echo ""
    echo -e "Navigate: ${selected_color}↑↓${NC} • ${success_color}Enter${NC} select • ${BLUE}d${NC} dashboard • ${BLUE}s${NC} status • ${BLUE}r${NC} refresh • ${error_color}q${NC} quit"
}

# =============================================================================
# Input Handling
# =============================================================================

# Read user input with timeout - navigation only (no number input)
read_input() {
      local timeout="${INPUT_TIMEOUT:-300}"  # Increased timeout to 5 minutes to reduce flickering

      # Check if timeout is disabled
      if [[ "${SESSION_TIMEOUT_ENABLED:-true}" != "true" ]]; then
          timeout=0  # No timeout
      fi

      # Read single character to handle navigation keys and Enter
      while true; do
          local char=""
          local read_success=false

          # Read single character with timeout - reduced timeout for less flickering
          if [[ $timeout -eq 0 ]]; then
              # No timeout - wait indefinitely
              if read -n1 -s -t 0.05 char; then
                  read_success=true
              fi
          elif read -t "$timeout" -n1 -s char; then
              read_success=true
          else
              # Timeout occurred - silent timeout, no message
              echo "timeout"
              return
          fi

          if [[ "$read_success" == "true" ]]; then
              case "$char" in
                  $'\e')  # Escape sequence start
                      read -t 0.05 -n2 -s rest
                      case "$rest" in
                          "[A") echo "UP" ; return ;;
                          "[B") echo "DOWN" ; return ;;
                          "[C") echo "RIGHT" ; return ;;
                          "[D") echo "LEFT" ; return ;;
                          "[H") echo "HOME" ; return ;;
                          "[F") echo "END" ; return ;;
                          "") echo "ESC" ; return ;;
                          *) echo "$char$rest" ; return ;;
                      esac
                      ;;
                  "")  # Enter key
                      echo "ENTER"
                      return
                      ;;
                  d|D|s|S|r|R|q|Q)  # Footer command keys
                      echo "$char"
                      return
                      ;;
                  *)  # Other character - ignore (no number input allowed)
                      # Silently ignore all other input including numbers
                      continue
                      ;;
              esac
          fi
      done
}

# Handle keyboard input
handle_keyboard_input() {
    local key="$1"
    local current_selection="$2"
    local max_selection="$3"
    
    case $key in
        "UP"|"k")
            if [[ $current_selection -gt 0 ]]; then
                echo $((current_selection - 1))
            else
                echo $((max_selection - 1))
            fi
            ;;
        "DOWN"|"j")
            if [[ $current_selection -lt $((max_selection - 1)) ]]; then
                echo $((current_selection + 1))
            else
                echo 0
            fi
            ;;
        "HOME"|"g")
            echo 0
            ;;
        "END"|"G")
            echo $((max_selection - 1))
            ;;
        *)
            echo "$current_selection"
            ;;
    esac
}

# Validate numeric input
validate_numeric_input() {
    local input="$1"
    local max_value="$2"
    
    if [[ "$input" =~ ^[0-9]+$ ]]; then
        if [[ $input -ge 1 && $input -le $max_value ]]; then
            return 0
        fi
    fi
    return 1
}

# =============================================================================
# Menu Navigation
# =============================================================================

# Main menu loop
menu_loop() {
    # Determinar si usar modo jerárquico
    local use_hierarchical=false
    if [[ "${ENABLE_AUTO_SCAN:-true}" == "true" ]]; then
        if [[ ${#AUTO_SCRIPTS[@]} -gt 0 ]]; then
            use_hierarchical=true
            if declare -f log_info >/dev/null; then
                log_info "Using hierarchical menu mode"
            fi
        else
            # No scripts found, show message and exit
            show_no_scripts_message
            return
        fi
    fi

    # Force hierarchical mode for testing
    use_hierarchical=true
    echo "DEBUG: use_hierarchical=$use_hierarchical, AUTO_SCRIPTS count=${#AUTO_SCRIPTS[@]}" >> /tmp/menu_loop_debug.log

    if [[ "$use_hierarchical" == "true" ]]; then
        menu_loop_hierarchical
    else
        menu_loop_classic
    fi
}

# Menu loop para modo clásico (scripts manuales)
menu_loop_classic() {
    local selected_index=0
    local max_selection=${#menu_options[@]}

    while true; do
        # Display menu
        display_header
        display_menu "$selected_index"
        display_footer

        # Get user input
        local choice
        choice=$(read_input)

        # Handle special cases
        case $choice in
            "timeout")
                # Silent timeout - no message, just refresh
                continue
                ;;
            "q"|"Q"|"quit"|"exit")
                exit_menu
                ;;
            "d"|"D")
                # Dashboard
                if declare -f cmd_dashboard >/dev/null; then
                    cmd_dashboard
                fi
                continue
                ;;
            "s"|"S")
                # Quick status
                if declare -f cmd_quick_status >/dev/null; then
                    cmd_quick_status
                fi
                continue
                ;;
            "ENTER")
                # Enter key pressed - execute selected item
                execute_menu_item "$selected_index"
                ;;
            "r"|"R"|"refresh")
                # Refresh menu
                continue
                ;;
            "")
                # No input, continue
                continue
                ;;
        esac

        # Handle Enter key pressed - execute selected item
        if [[ "$choice" == "ENTER" ]]; then
            execute_menu_item "$selected_index"
        else
            # Handle arrow keys and other navigation
            local new_selection
            new_selection=$(handle_keyboard_input "$choice" "$selected_index" "$max_selection")

            if [[ $new_selection -ne $selected_index ]]; then
                selected_index=$new_selection
                # Navigation changed - continue to next iteration without waiting
            else
                # Ignore all other input silently
                continue
            fi
        fi
    done
}

# Menu loop para modo jerárquico (auto-detectado)
menu_loop_hierarchical() {
     local selected_index=0

     while true; do
         # Generar menú basado en directorio actual
         local current_dir=$(get_current_path_string)
         generate_directory_menu "$current_dir"

         local max_selection=${#menu_options[@]}

         # Si no hay opciones, mostrar mensaje y continuar
         if [[ $max_selection -eq 0 ]]; then
             clear_screen
             display_header
             echo ""
             echo -e "${warning_color}No items found in this directory${NC}"
             echo ""
             echo -e "${success_color}Press Enter to go back...${NC}"
             read -s
             handle_navigation "navigate_up"
             continue
         fi

         # Mostrar menú con breadcrumb en header
         display_header
         display_menu "$selected_index"
         display_footer

         # Get user input
         local choice
         choice=$(read_input)

         # Handle special cases
         case $choice in
             "timeout")
                 # Silent timeout - no message, just refresh
                 continue
                 ;;
             "q"|"Q"|"quit"|"exit")
                 exit_menu
                 ;;
             "d"|"D")
                 # Dashboard
                 if declare -f cmd_dashboard >/dev/null; then
                     cmd_dashboard
                 fi
                 continue
                 ;;
             "s"|"S")
                 # Quick status
                 if declare -f cmd_quick_status >/dev/null; then
                     cmd_quick_status
                 fi
                 continue
                 ;;
             "r"|"R"|"refresh")
                 # Refresh menu
                 continue
                 ;;
             "")
                 # No input, continue
                 continue
                 ;;
         esac

         # Handle Enter key pressed - execute selected item
         if [[ "$choice" == "ENTER" ]]; then
             local command="${menu_commands[$selected_index]}"
             handle_navigation "$command"
         else
             # Handle arrow keys and other navigation
             local new_selection
             new_selection=$(handle_keyboard_input "$choice" "$selected_index" "$max_selection")

             if [[ $new_selection -ne $selected_index ]]; then
                 selected_index=$new_selection
                 # Navigation changed - continue to next iteration without waiting
             else
                 # Ignore all other input silently
                 continue
             fi
         fi
     done
}

# Registra scripts externos como entradas de menú
register_external_scripts() {
    if [[ ${#SCRIPT_ENTRIES[@]} -eq 0 ]]; then
        if declare -f log_debug >/dev/null; then
            log_debug "No external scripts to register"
        fi
        return 0
    fi
    
    if declare -f log_info >/dev/null; then
        log_info "Registering ${#SCRIPT_ENTRIES[@]} external script(s)"
    fi
    
    local registered_count=0
    
    for script_name in "${!SCRIPT_ENTRIES[@]}"; do
        local entry="${SCRIPT_ENTRIES[$script_name]}"
        IFS='|' read -r path desc level params <<< "$entry"
        
        # Crear función wrapper para cada script
        create_script_wrapper "$script_name" "$path" "$params"
        
        # Agregar al menú
        local wrapper_func="exec_${script_name//[^a-zA-Z0-9_]/_}"
        if add_menu_item "$script_name" "$wrapper_func" "$desc" "$level"; then
            registered_count=$((registered_count + 1))
            if declare -f log_debug >/dev/null; then
                log_debug "Registered script: $script_name -> $wrapper_func"
            fi
        fi
    done
    
    if declare -f log_info >/dev/null; then
        log_info "Registered $registered_count external script(s) in menu"
    fi
    
    print_success "Registered $registered_count external script(s)"
    
    return 0
}

# Crea función wrapper dinámica para cada script
create_script_wrapper() {
    local name="$1"
    local path="$2"
    local default_params="$3"
    
    # Sanitizar nombre para crear función válida
    local func_name="exec_${name//[^a-zA-Z0-9_]/_}"
    
    # Crear función dinámica usando eval
    # La función llama a execute_script con los parámetros correctos
    eval "${func_name}() {
        if declare -f execute_script >/dev/null; then
            execute_script '$path' '$name' '$default_params'
        else
            print_error 'Script executor not available'
            if declare -f log_error >/dev/null; then
                log_error 'execute_script function not found'
            fi
            echo ''
            echo -e '\${success_color}Press Enter to continue...\${NC}'
            read -s
            return 1
        fi
    }"
    
    # Exportar la función para que esté disponible
    export -f "$func_name"
    
    if declare -f log_debug >/dev/null; then
        log_debug "Created wrapper function: $func_name for script: $name"
    fi
}



# =============================================================================
# External Script Validation
# =============================================================================

# Sanitize script path to prevent directory traversal
sanitize_script_path() {
    local path="$1"
    
    # Remove any ../ or ./ sequences
    path="${path//.\.\//}"
    path="${path//.\//}"
    
    # Remove multiple consecutive slashes
    path="${path//\/\//\/}"
    
    # Remove trailing slash
    path="${path%/}"
    
    echo "$path"
}

# Validate external script path with comprehensive security checks
validate_script_path() {
    local script_path="$1"
    local validation_errors=0
    
    if declare -f log_debug >/dev/null; then
        log_debug "Validating script path: $script_path"
    fi
    
    # Sanitize the path first
    local sanitized_path=$(sanitize_script_path "$script_path")
    
    # Check if path changed after sanitization (potential attack)
    if [[ "$script_path" != "$sanitized_path" ]]; then
        if declare -f log_error >/dev/null; then
            log_error "Script path contains suspicious characters: $script_path"
        fi
        print_error "Script path validation failed: suspicious path"
        return 1
    fi
    
    # Check if path is absolute
    if [[ ! "$script_path" =~ ^/ ]]; then
        if declare -f log_error >/dev/null; then
            log_error "Script path must be absolute: $script_path"
        fi
        print_error "Script path must be absolute"
        validation_errors=$((validation_errors + 1))
    fi
    
    # Check if path exists
    if [[ ! -e "$script_path" ]]; then
        if declare -f log_error >/dev/null; then
            log_error "Script path does not exist: $script_path"
        fi
        print_error "Script file not found: $script_path"
        validation_errors=$((validation_errors + 1))
    fi
    
    # Check if it's a regular file (not a directory or special file)
    if [[ -e "$script_path" ]] && [[ ! -f "$script_path" ]]; then
        if declare -f log_error >/dev/null; then
            log_error "Script path is not a regular file: $script_path"
        fi
        print_error "Script path must be a regular file"
        validation_errors=$((validation_errors + 1))
    fi
    
    # Check if file is readable
    if [[ -f "$script_path" ]] && [[ ! -r "$script_path" ]]; then
        if declare -f log_error >/dev/null; then
            log_error "Script file is not readable: $script_path"
        fi
        print_error "Script file is not readable"
        validation_errors=$((validation_errors + 1))
    fi
    
    # Check if executable
    if [[ -f "$script_path" ]] && [[ ! -x "$script_path" ]]; then
        if declare -f log_error >/dev/null; then
            log_error "Script file is not executable: $script_path"
        fi
        print_error "Script file is not executable: $script_path"
        validation_errors=$((validation_errors + 1))
    fi
    
    # Check if path is a symbolic link (security consideration)
    if [[ -L "$script_path" ]]; then
        if declare -f log_warn >/dev/null; then
            log_warn "Script path is a symbolic link: $script_path"
        fi
        
        # Resolve the symbolic link
        local real_path=$(readlink -f "$script_path" 2>/dev/null)
        if [[ -z "$real_path" ]]; then
            if declare -f log_error >/dev/null; then
                log_error "Failed to resolve symbolic link: $script_path"
            fi
            print_error "Failed to resolve symbolic link"
            validation_errors=$((validation_errors + 1))
        else
            if declare -f log_info >/dev/null; then
                log_info "Symbolic link resolves to: $real_path"
            fi
            # Recursively validate the real path
            script_path="$real_path"
        fi
    fi
    
    # Check if path is within allowed directories (if configured)
    if [[ -n "${ALLOWED_SCRIPT_DIRS:-}" ]]; then
        local is_allowed=false
        local canonical_script_path=$(readlink -f "$script_path" 2>/dev/null || echo "$script_path")
        
        # Parse allowed directories (colon-separated)
        IFS=':' read -ra allowed_dirs <<< "$ALLOWED_SCRIPT_DIRS"
        
        if declare -f log_debug >/dev/null; then
            log_debug "Checking against allowed directories: ${ALLOWED_SCRIPT_DIRS}"
        fi
        
        for dir in "${allowed_dirs[@]}"; do
            # Skip empty entries
            [[ -z "$dir" ]] && continue
            
            # Get canonical path of allowed directory
            local canonical_dir=$(readlink -f "$dir" 2>/dev/null || echo "$dir")
            
            # Check if script is within this directory
            if [[ "$canonical_script_path" == "$canonical_dir"* ]]; then
                is_allowed=true
                if declare -f log_debug >/dev/null; then
                    log_debug "Script is within allowed directory: $canonical_dir"
                fi
                break
            fi
        done
        
        if [[ "$is_allowed" == "false" ]]; then
            if declare -f log_error >/dev/null; then
                log_error "Script path not in allowed directories: $script_path"
            fi
            print_error "Script path not in allowed directories"
            print_info "Allowed directories: ${ALLOWED_SCRIPT_DIRS}"
            validation_errors=$((validation_errors + 1))
        fi
    fi
    
    # Return validation result
    if [[ $validation_errors -gt 0 ]]; then
        if declare -f log_error >/dev/null; then
            log_error "Script validation failed with $validation_errors error(s): $script_path"
        fi
        return 1
    fi
    
    if declare -f log_info >/dev/null; then
        log_info "Script validation passed: $script_path"
    fi
    
    return 0
}

# Execute menu item
execute_menu_item() {
    local index="$1"

    if [[ $index -ge 0 && $index -lt ${#menu_options[@]} ]]; then
        local command="${menu_commands[$index]}"
        local option_name="${menu_options[$index]}"
        local level="${menu_levels[$index]}"

        # Check permissions
        if [[ "${ENABLE_PERMISSIONS:-false}" == "true" ]]; then
            local user_level=$(get_user_level)
            if [[ $user_level -lt $level ]]; then
                print_error "Access denied: $option_name requires level $level (you have level $user_level)"
                log_warn "Access denied for user $(whoami): $option_name"
                return 1
            fi
        fi

        # Execute command
        if [[ "$command" == "exit_menu" ]]; then
            exit_menu
        elif [[ "$command" =~ ^/ ]]; then
            # Execute external script with validation and error handling
            if validate_script_path "$command"; then
                echo "Executing: $command"
                echo ""
                log_command "$command" "started"
                
                if "$command"; then
                    echo ""
                    print_success "Script completed successfully"
                    log_command "$command" "success"
                else
                    local exit_code=$?
                    echo ""
                    print_error "Script failed with exit code: $exit_code"
                    log_command "$command" "failed (exit code: $exit_code)"
                fi
            else
                print_error "Script validation failed: $command"
                log_error "Script validation failed: $command"
            fi
        else
            # Execute the command function
            if declare -f "$command" > /dev/null; then
                log_command "$command" "started"
                $command
                log_command "$command" "completed"
            else
                print_error "Command not found: $command"
                log_error "Command not found: $command"
            fi
        fi
    else
        print_error "Invalid menu index: $index"
        log_error "Invalid menu index: $index"
    fi
}

# Exit menu
exit_menu() {
    echo ""
    echo -e "${success_color}Exiting Bashmenu. Goodbye!${NC}"
    echo ""
    
    # Cleanup
    if declare -f cleanup_old_backups >/dev/null; then
        cleanup_old_backups
    fi
    
    log_info "Bashmenu exited"
    exit 0
}

# =============================================================================
# Search and Filter
# =============================================================================
# Export Functions
# =============================================================================

export -f initialize_menu
export -f add_menu_item
export -f load_theme
export -f display_header
export -f display_menu
export -f display_footer
export -f read_input
export -f handle_keyboard_input
export -f validate_numeric_input
export -f menu_loop
export -f menu_loop_classic
export -f menu_loop_hierarchical
export -f execute_menu_item
export -f exit_menu
export -f initialize_themes
export -f validate_script_path
export -f sanitize_script_path
export -f register_external_scripts
export -f create_script_wrapper
export -f build_hierarchical_menu
export -f add_directory_to_hierarchy
export -f generate_directory_menu
export -f handle_navigation
export -f execute_auto_script
export -f show_no_scripts_message
export -f get_current_path_string
export -f get_breadcrumb

# Fallback logging functions (if not already defined)
# These respect DEBUG_MODE to avoid unwanted output
if ! declare -f log_warn >/dev/null; then
  log_warn() { 
    [[ "${DEBUG_MODE:-false}" == "true" ]] && echo -e "[WARN] $*" >&2
    return 0
  }
fi
if ! declare -f log_info >/dev/null; then
  log_info() { 
    [[ "${DEBUG_MODE:-false}" == "true" ]] && echo -e "[INFO] $*" >&2
    return 0
  }
fi
if ! declare -f log_error >/dev/null; then
  log_error() { 
    [[ "${DEBUG_MODE:-false}" == "true" ]] && echo -e "[ERROR] $*" >&2
    return 0
  }
fi
if ! declare -f log_debug >/dev/null; then
  log_debug() { 
    [[ "${DEBUG_MODE:-false}" == "true" ]] && echo -e "[DEBUG] $*" >&2
    return 0
  }
fi

# Initialize themes when this file is sourced
initialize_themes 