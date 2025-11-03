#!/bin/bash

# =============================================================================
# Funciones de Comandos para Bashmenu
# =============================================================================
# Descripción: Comandos y utilidades de administración del sistema
# Versión:     2.1
# Autor:       JESUS MARIA VILLALOBOS
# =============================================================================

# =============================================================================
# Dashboard Command
# =============================================================================

cmd_dashboard() {
    local refresh_interval=5
    
    while true; do
        clear
        print_header "System Dashboard"
        echo ""
        
        # System Info
        echo -e "${CYAN}System Information:${NC}"
        echo "  Hostname: $(hostname)"
        echo "  Uptime: $(uptime -p | sed 's/up //')"
        echo "  Load Average: $(uptime | awk -F'load average:' '{print $2}')"
        echo "  Users: $(who | wc -l)"
        echo ""
        
        # CPU Usage
        local cpu=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1 | cut -d'.' -f1)
        cpu=${cpu:-0}
        echo -e "${CYAN}CPU Usage:${NC}"
        echo -n "  "
        show_bar $cpu 100
        echo ""
        
        # Memory Usage
        local mem=$(free | awk 'NR==2{printf "%.0f", $3*100/$2}')
        mem=${mem:-0}
        echo -e "${CYAN}Memory Usage:${NC}"
        echo -n "  "
        show_bar $mem 100
        echo ""
        
        # Disk Usage
        local disk=$(df -h / | awk 'NR==2{print $5}' | sed 's/%//')
        disk=${disk:-0}
        echo -e "${CYAN}Disk Usage (/)${NC}"
        echo -n "  "
        show_bar $disk 100
        echo ""
        
        print_separator
        echo -e "${YELLOW}Auto-refresh in ${refresh_interval}s | Press Ctrl+C to exit${NC}"
        
        # Wait for refresh interval or user interrupt
        sleep $refresh_interval || break
    done
    
    echo ""
    echo -e "${success_color}Press Enter to return to menu...${NC}"
    read -s
}

# =============================================================================
# Quick Status Command
# =============================================================================

cmd_quick_status() {
    clear
    print_header "Quick System Status"
    echo ""
    
    # CPU Check
    local cpu=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1 | cut -d'.' -f1)
    cpu=${cpu:-0}
    echo -n "  CPU Usage: "
    if [[ $cpu -lt 70 ]]; then
        echo -e "${GREEN}${cpu}% ✓${NC}"
    elif [[ $cpu -lt 90 ]]; then
        echo -e "${YELLOW}${cpu}% ⚠${NC}"
    else
        echo -e "${RED}${cpu}% ✗${NC}"
    fi
    
    # Memory Check
    local mem=$(free | awk 'NR==2{printf "%.0f", $3*100/$2}')
    mem=${mem:-0}
    echo -n "  Memory Usage: "
    if [[ $mem -lt 70 ]]; then
        echo -e "${GREEN}${mem}% ✓${NC}"
    elif [[ $mem -lt 90 ]]; then
        echo -e "${YELLOW}${mem}% ⚠${NC}"
    else
        echo -e "${RED}${mem}% ✗${NC}"
    fi
    
    # Disk Check
    local disk=$(df -h / | awk 'NR==2{print $5}' | sed 's/%//')
    disk=${disk:-0}
    echo -n "  Disk Usage: "
    if [[ $disk -lt 70 ]]; then
        echo -e "${GREEN}${disk}% ✓${NC}"
    elif [[ $disk -lt 90 ]]; then
        echo -e "${YELLOW}${disk}% ⚠${NC}"
    else
        echo -e "${RED}${disk}% ✗${NC}"
    fi
    
    echo ""
    
    # Service Status (SSH)
    echo -e "${CYAN}Service Status:${NC}"
    if systemctl is-active --quiet sshd 2>/dev/null || systemctl is-active --quiet ssh 2>/dev/null; then
        echo -e "  SSH: ${GREEN}Running ✓${NC}"
    else
        echo -e "  SSH: ${YELLOW}Not running ⚠${NC}"
    fi
    
    echo ""
    print_separator
    echo ""
    echo -e "${success_color}Press Enter to return to menu...${NC}"
    read -s
}

# =============================================================================
# System Information Command
# =============================================================================

cmd_system_info() {
    clear
    print_header "System Information"
    echo ""
    
    echo -e "${CYAN}=== Basic Info ===${NC}"
    echo "Hostname: $(hostname)"
    echo "OS: $(lsb_release -d 2>/dev/null | cut -f2 || uname -s)"
    echo "Kernel: $(uname -r)"
    echo "Architecture: $(uname -m)"
    echo "Uptime: $(uptime -p | sed 's/up //')"
    echo ""
    
    echo -e "${CYAN}=== Hardware Info ===${NC}"
    echo "CPU: $(grep 'model name' /proc/cpuinfo | head -1 | cut -d: -f2 | sed 's/^[ \t]*//')"
    
    # Memory with bar
    local mem_total=$(free -h | awk 'NR==2{print $2}')
    local mem_used=$(free -h | awk 'NR==2{print $3}')
    local mem_percent=$(free | awk 'NR==2{printf "%.0f", $3*100/$2}')
    echo -n "Memory: ${mem_used}/${mem_total} "
    show_bar ${mem_percent:-0} 100
    
    # Disk with bar
    local disk_total=$(df -h / | awk 'NR==2{print $2}')
    local disk_used=$(df -h / | awk 'NR==2{print $3}')
    local disk_percent=$(df -h / | awk 'NR==2{print $5}' | sed 's/%//')
    echo -n "Disk: ${disk_used}/${disk_total} "
    show_bar ${disk_percent:-0} 100
    
    echo ""
    print_separator
    echo ""
    echo -e "${success_color}Press Enter to return to menu...${NC}"
    read -s
}

# =============================================================================
# Export Functions
# =============================================================================

export -f cmd_dashboard
export -f cmd_quick_status
export -f cmd_system_info
