#!/bin/bash

# Strict mode for better error handling
set -euo pipefail

# =============================================================================
# Enhanced UI Utilities for Bashmenu
# =============================================================================
# Descripción: Utilidades visuales mejoradas con animaciones y efectos
# Versión:     2.1
# Autor:       JESUS MARIA VILLALOBOS
# =============================================================================

# =============================================================================
# Box Drawing Characters (Unicode)
# =============================================================================

# Single line box drawing
readonly BOX_TL="┌"  # Top-left
readonly BOX_TR="┐"  # Top-right
readonly BOX_BL="└"  # Bottom-left
readonly BOX_BR="┘"  # Bottom-right
readonly BOX_H="─"   # Horizontal
readonly BOX_V="│"   # Vertical
readonly BOX_VR="├"  # Vertical-right
readonly BOX_VL="┤"  # Vertical-left
readonly BOX_HU="┴"  # Horizontal-up
readonly BOX_HD="┬"  # Horizontal-down
readonly BOX_C="┼"   # Cross

# Double line box drawing
readonly BOX_D_TL="╔"
readonly BOX_D_TR="╗"
readonly BOX_D_BL="╚"
readonly BOX_D_BR="╝"
readonly BOX_D_H="═"
readonly BOX_D_V="║"

# Rounded corners
readonly BOX_R_TL="╭"
readonly BOX_R_TR="╮"
readonly BOX_R_BL="╰"
readonly BOX_R_BR="╯"

# =============================================================================
# Gradient Colors (256-color support)
# =============================================================================

# Cyan gradient
readonly GRADIENT_CYAN_1='\033[38;5;51m'
readonly GRADIENT_CYAN_2='\033[38;5;45m'
readonly GRADIENT_CYAN_3='\033[38;5;39m'
readonly GRADIENT_CYAN_4='\033[38;5;33m'

# Green gradient
readonly GRADIENT_GREEN_1='\033[38;5;46m'
readonly GRADIENT_GREEN_2='\033[38;5;40m'
readonly GRADIENT_GREEN_3='\033[38;5;34m'
readonly GRADIENT_GREEN_4='\033[38;5;28m'

# Purple gradient
readonly GRADIENT_PURPLE_1='\033[38;5;141m'
readonly GRADIENT_PURPLE_2='\033[38;5;135m'
readonly GRADIENT_PURPLE_3='\033[38;5;129m'
readonly GRADIENT_PURPLE_4='\033[38;5;93m'

# Orange/Pink gradient
readonly GRADIENT_SUNSET_1='\033[38;5;226m'
readonly GRADIENT_SUNSET_2='\033[38;5;220m'
readonly GRADIENT_SUNSET_3='\033[38;5;214m'
readonly GRADIENT_SUNSET_4='\033[38;5;208m'

# Neon colors
readonly NEON_GREEN='\033[38;5;46m'
readonly NEON_PINK='\033[38;5;201m'
readonly NEON_CYAN='\033[38;5;51m'
readonly NEON_YELLOW='\033[38;5;226m'

# =============================================================================
# Spinner Animations
# =============================================================================

# Spinner styles
declare -a SPINNER_DOTS=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
declare -a SPINNER_LINE=('|' '/' '-' '\')
declare -a SPINNER_ARROW=('←' '↖' '↑' '↗' '→' '↘' '↓' '↙')
declare -a SPINNER_BOX=('◰' '◳' '◲' '◱')
declare -a SPINNER_BOUNCE=('⠁' '⠂' '⠄' '⡀' '⢀' '⠠' '⠐' '⠈')
declare -a SPINNER_CIRCLE=('◜' '◠' '◝' '◞' '◡' '◟')
declare -a SPINNER_PULSE=('▁' '▂' '▃' '▄' '▅' '▆' '▇' '█' '▇' '▆' '▅' '▄' '▃' '▂')
declare -a SPINNER_GROW=('▏' '▎' '▍' '▌' '▋' '▊' '▉' '█')

# =============================================================================
# Progress Bar Characters
# =============================================================================

readonly PROGRESS_FULL="█"
readonly PROGRESS_PARTIAL="▓"
readonly PROGRESS_EMPTY="░"
readonly PROGRESS_LEFT="▐"
readonly PROGRESS_RIGHT="▌"

# =============================================================================
# Functions: Box Drawing
# =============================================================================

# draw_box() - Draw a box with optional title and content
# Usage: draw_box <width> <height> <title> [style]
# Style: single (default), double, rounded
draw_box() {
    local width="${1:-50}"
    local height="${2:-10}"
    local title="${3:-}"
    local style="${4:-single}"
    
    local tl tr bl br h v
    
    case "$style" in
        double)
            tl="$BOX_D_TL" tr="$BOX_D_TR" bl="$BOX_D_BL" br="$BOX_D_BR"
            h="$BOX_D_H" v="$BOX_D_V"
            ;;
        rounded)
            tl="$BOX_R_TL" tr="$BOX_R_TR" bl="$BOX_R_BL" br="$BOX_R_BR"
            h="$BOX_H" v="$BOX_V"
            ;;
        *)
            tl="$BOX_TL" tr="$BOX_TR" bl="$BOX_BL" br="$BOX_BR"
            h="$BOX_H" v="$BOX_V"
            ;;
    esac
    
    # Top border with title
    if [[ -n "$title" ]]; then
        local title_len=${#title}
        local padding=$(( (width - title_len - 4) / 2 ))
        local remaining=$(( width - title_len - 4 - padding ))
        
        echo -n "$tl"
        printf "%${padding}s" | tr ' ' "$h"
        echo -n " $title "
        printf "%${remaining}s" | tr ' ' "$h"
        echo "$tr"
    else
        echo -n "$tl"
        printf "%$((width-2))s" | tr ' ' "$h"
        echo "$tr"
    fi
    
    # Empty lines
    for ((i=0; i<height-2; i++)); do
        echo -n "$v"
        printf "%$((width-2))s" ""
        echo "$v"
    done
    
    # Bottom border
    echo -n "$bl"
    printf "%$((width-2))s" | tr ' ' "$h"
    echo "$br"
}

# draw_box_with_content() - Draw box with content inside
# Usage: draw_box_with_content <title> <content> [width] [style]
draw_box_with_content() {
    local title="$1"
    local content="$2"
    local width="${3:-60}"
    local style="${4:-single}"
    
    local tl tr bl br h v
    
    case "$style" in
        double)
            tl="$BOX_D_TL" tr="$BOX_D_TR" bl="$BOX_D_BL" br="$BOX_D_BR"
            h="$BOX_D_H" v="$BOX_D_V"
            ;;
        rounded)
            tl="$BOX_R_TL" tr="$BOX_R_TR" bl="$BOX_R_BL" br="$BOX_R_BR"
            h="$BOX_H" v="$BOX_V"
            ;;
        *)
            tl="$BOX_TL" tr="$BOX_TR" bl="$BOX_BL" br="$BOX_BR"
            h="$BOX_H" v="$BOX_V"
            ;;
    esac
    
    # Top border with title
    local title_len=${#title}
    local padding=$(( (width - title_len - 4) / 2 ))
    local remaining=$(( width - title_len - 4 - padding ))
    
    echo -n "$tl"
    printf "%${padding}s" | tr ' ' "$h"
    echo -n " $title "
    printf "%${remaining}s" | tr ' ' "$h"
    echo "$tr"
    
    # Content lines
    while IFS= read -r line; do
        local line_len=${#line}
        local padding_right=$(( width - line_len - 4 ))
        echo -n "$v "
        echo -n "$line"
        printf "%${padding_right}s" ""
        echo " $v"
    done <<< "$content"
    
    # Bottom border
    echo -n "$bl"
    printf "%$((width-2))s" | tr ' ' "$h"
    echo "$br"
}

# =============================================================================
# Functions: Spinners
# =============================================================================

# show_spinner() - Display animated spinner
# Usage: show_spinner <message> <style> &
# Styles: dots, line, arrow, box, bounce, circle, pulse, grow
show_spinner() {
    local message="${1:-Loading}"
    local style="${2:-dots}"
    local delay=0.1
    
    # Select spinner array based on style
    local -n spinner_array
    case "$style" in
        line) spinner_array=SPINNER_LINE ;;
        arrow) spinner_array=SPINNER_ARROW ;;
        box) spinner_array=SPINNER_BOX ;;
        bounce) spinner_array=SPINNER_BOUNCE ;;
        circle) spinner_array=SPINNER_CIRCLE ;;
        pulse) spinner_array=SPINNER_PULSE; delay=0.05 ;;
        grow) spinner_array=SPINNER_GROW; delay=0.08 ;;
        *) spinner_array=SPINNER_DOTS ;;
    esac
    
    local i=0
    tput civis # Hide cursor
    
    while true; do
        echo -ne "\r${NEON_CYAN}${spinner_array[$i]}${NC} $message"
        i=$(( (i + 1) % ${#spinner_array[@]} ))
        sleep "$delay"
    done
}

# stop_spinner() - Stop the spinner
stop_spinner() {
    kill "$1" 2>/dev/null
    wait "$1" 2>/dev/null
    tput cnorm # Show cursor
    echo -ne "\r\033[K" # Clear line
}

# =============================================================================
# Functions: Progress Bars
# =============================================================================

# show_progress_bar() - Display progress bar
# Usage: show_progress_bar <current> <total> <width> [label]
show_progress_bar() {
    local current="$1"
    local total="$2"
    local width="${3:-50}"
    local label="${4:-Progress}"
    
    local percentage=$(( current * 100 / total ))
    local filled=$(( current * width / total ))
    local empty=$(( width - filled ))
    
    # Color based on percentage
    local bar_color
    if [[ $percentage -lt 33 ]]; then
        bar_color="$RED"
    elif [[ $percentage -lt 66 ]]; then
        bar_color="$YELLOW"
    else
        bar_color="$GREEN"
    fi
    
    # Build progress bar
    echo -ne "\r${CYAN}$label:${NC} ["
    echo -ne "${bar_color}"
    printf "%${filled}s" | tr ' ' "$PROGRESS_FULL"
    echo -ne "${NC}"
    printf "%${empty}s" | tr ' ' "$PROGRESS_EMPTY"
    echo -ne "] ${bar_color}${percentage}%${NC}"
}

# animated_progress_bar() - Animated progress bar simulation
# Usage: animated_progress_bar <duration> <label>
animated_progress_bar() {
    local duration="${1:-5}"
    local label="${2:-Processing}"
    local width=50
    local steps=100
    local delay=$(awk "BEGIN {print $duration / $steps}")
    
    for ((i=0; i<=steps; i++)); do
        show_progress_bar "$i" "$steps" "$width" "$label"
        sleep "$delay"
    done
    echo "" # New line after completion
}

# =============================================================================
# Functions: Gradient Text
# =============================================================================

# print_gradient() - Print text with gradient effect
# Usage: print_gradient <text> <gradient_name>
# Gradients: cyan, green, purple, sunset
print_gradient() {
    local text="$1"
    local gradient="${2:-cyan}"
    local length=${#text}
    
    # Select gradient colors
    local -a colors
    case "$gradient" in
        green)
            colors=("$GRADIENT_GREEN_1" "$GRADIENT_GREEN_2" "$GRADIENT_GREEN_3" "$GRADIENT_GREEN_4")
            ;;
        purple)
            colors=("$GRADIENT_PURPLE_1" "$GRADIENT_PURPLE_2" "$GRADIENT_PURPLE_3" "$GRADIENT_PURPLE_4")
            ;;
        sunset)
            colors=("$GRADIENT_SUNSET_1" "$GRADIENT_SUNSET_2" "$GRADIENT_SUNSET_3" "$GRADIENT_SUNSET_4")
            ;;
        *)
            colors=("$GRADIENT_CYAN_1" "$GRADIENT_CYAN_2" "$GRADIENT_CYAN_3" "$GRADIENT_CYAN_4")
            ;;
    esac
    
    local num_colors=${#colors[@]}
    local chars_per_color=$(( (length + num_colors - 1) / num_colors ))
    
    local color_index=0
    for ((i=0; i<length; i++)); do
        if [[ $((i % chars_per_color)) -eq 0 ]] && [[ $i -gt 0 ]]; then
            color_index=$(( (color_index + 1) % num_colors ))
        fi
        echo -ne "${colors[$color_index]}${text:$i:1}"
    done
    echo -e "${NC}"
}

# =============================================================================
# Functions: Typing Effect
# =============================================================================

# typing_effect() - Animated typing effect
# Usage: typing_effect <text> [speed]
# Speed: slow (0.1s), normal (0.05s), fast (0.02s)
typing_effect() {
    local text="$1"
    local speed="${2:-normal}"
    
    local delay
    case "$speed" in
        slow) delay=0.1 ;;
        fast) delay=0.02 ;;
        *) delay=0.05 ;;
    esac
    
    for ((i=0; i<${#text}; i++)); do
        echo -n "${text:$i:1}"
        sleep "$delay"
    done
    echo ""
}

# =============================================================================
# Functions: Screen Transitions
# =============================================================================

# fade_transition() - Smooth fade transition
# Usage: fade_transition
fade_transition() {
    local lines=$(tput lines)
    
    # Fade out
    for ((i=0; i<5; i++)); do
        tput cup 0 0
        for ((j=0; j<lines; j++)); do
            echo ""
        done
        sleep 0.05
    done
    
    clear
}

# slide_transition() - Slide transition effect
# Usage: slide_transition <direction>
# Direction: up, down, left, right
slide_transition() {
    local direction="${1:-up}"
    local lines=$(tput lines)
    
    case "$direction" in
        up)
            for ((i=0; i<lines; i++)); do
                tput cup "$i" 0
                tput el
                sleep 0.01
            done
            ;;
        down)
            for ((i=lines; i>=0; i--)); do
                tput cup "$i" 0
                tput el
                sleep 0.01
            done
            ;;
    esac
    
    clear
}

# =============================================================================
# Functions: Banners and Headers
# =============================================================================

# print_banner() - Print stylized banner
# Usage: print_banner <text> [style]
# Styles: simple, double, neon
print_banner() {
    local text="$1"
    local style="${2:-simple}"
    local width=60
    
    case "$style" in
        double)
            echo -e "${CYAN}"
            echo -n "$BOX_D_TL"
            printf "%$((width-2))s" | tr ' ' "$BOX_D_H"
            echo "$BOX_D_TR"
            
            local padding=$(( (width - ${#text} - 2) / 2 ))
            echo -n "$BOX_D_V"
            printf "%${padding}s" ""
            echo -n "$text"
            printf "%$(( width - ${#text} - padding - 2 ))s" ""
            echo "$BOX_D_V"
            
            echo -n "$BOX_D_BL"
            printf "%$((width-2))s" | tr ' ' "$BOX_D_H"
            echo -e "$BOX_D_BR${NC}"
            ;;
        neon)
            print_gradient "$text" "cyan"
            ;;
        *)
            echo -e "${CYAN}"
            printf "%${width}s\n" | tr ' ' '='
            local padding=$(( (width - ${#text}) / 2 ))
            printf "%${padding}s%s\n" "" "$text"
            printf "%${width}s\n" | tr ' ' '='
            echo -e "${NC}"
            ;;
    esac
}

# =============================================================================
# Functions: Notification Banners
# =============================================================================

# show_notification_banner() - Show in-terminal notification
# Usage: show_notification_banner <message> <type> [duration]
# Types: info, success, warning, error
show_notification_banner() {
    local message="$1"
    local type="${2:-info}"
    local duration="${3:-3}"
    
    local icon color
    case "$type" in
        success)
            icon="✓"
            color="$GREEN"
            ;;
        warning)
            icon="⚠"
            color="$YELLOW"
            ;;
        error)
            icon="✗"
            color="$RED"
            ;;
        *)
            icon="ℹ"
            color="$CYAN"
            ;;
    esac
    
    # Save cursor position
    tput sc
    
    # Move to top of screen
    tput cup 0 0
    
    # Print notification
    echo -e "${color}${BOX_TL}${BOX_H}${BOX_H} ${icon} ${message} ${BOX_H}${BOX_H}${BOX_TR}${NC}"
    
    # Restore cursor position
    tput rc
    
    # Auto-hide after duration
    if [[ $duration -gt 0 ]]; then
        (
            sleep "$duration"
            tput sc
            tput cup 0 0
            tput el
            tput rc
        ) &
    fi
}

# =============================================================================
# Export Functions
# =============================================================================

export -f draw_box
export -f draw_box_with_content
export -f show_spinner
export -f stop_spinner
export -f show_progress_bar
export -f animated_progress_bar
export -f print_gradient
export -f typing_effect
export -f fade_transition
export -f slide_transition
export -f print_banner
export -f show_notification_banner
