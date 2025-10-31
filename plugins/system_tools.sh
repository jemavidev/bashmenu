#!/bin/bash

# =============================================================================
# System Tools Plugin for Bashmenu
# =============================================================================
# Description: Additional system administration tools
# Author:      Bashmenu Team
# Version:     1.0
# =============================================================================

# Source utilities if not already sourced
if [[ -z "$RED" ]]; then
    source "$(dirname "$0")/../src/utils.sh"
fi

# =============================================================================
# Plugin Information
# =============================================================================

PLUGIN_NAME="System Tools"
PLUGIN_VERSION="1.0"
PLUGIN_DESCRIPTION="Additional system administration tools"

# =============================================================================
# Plugin Functions
# =============================================================================

# Check system health
cmd_system_health() {
    print_header "System Health Check"
    
    local health_score=100
    local issues=()
    local warnings=()
    
    echo -e "${CYAN}=== Disk Space Check ===${NC}"
    local disk_usage=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')
    if [[ $disk_usage -gt 90 ]]; then
        issues+=("Disk usage is critical: ${disk_usage}%")
        health_score=$((health_score - 20))
    elif [[ $disk_usage -gt 80 ]]; then
        warnings+=("Disk usage is high: ${disk_usage}%")
        health_score=$((health_score - 10))
    else
        print_success "Disk usage is normal: ${disk_usage}%"
    fi
    
    echo -e "\n${CYAN}=== Memory Check ===${NC}"
    local mem_usage=$(free | awk 'NR==2{printf "%.0f", $3*100/$2}')
    if [[ $mem_usage -gt 90 ]]; then
        issues+=("Memory usage is critical: ${mem_usage}%")
        health_score=$((health_score - 20))
    elif [[ $mem_usage -gt 80 ]]; then
        warnings+=("Memory usage is high: ${mem_usage}%")
        health_score=$((health_score - 10))
    else
        print_success "Memory usage is normal: ${mem_usage}%"
    fi
    
    echo -e "\n${CYAN}=== Load Average Check ===${NC}"
    local load_avg=$(uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | sed 's/,//')
    local cpu_cores=$(nproc)
    local load_per_core=$(echo "scale=2; $load_avg / $cpu_cores" | bc)
    
    if (( $(echo "$load_per_core > 1.0" | bc -l) )); then
        issues+=("System load is high: $load_avg (${load_per_core} per core)")
        health_score=$((health_score - 15))
    else
        print_success "System load is normal: $load_avg (${load_per_core} per core)"
    fi
    
    echo -e "\n${CYAN}=== Network Check ===${NC}"
    if ping -c 1 8.8.8.8 >/dev/null 2>&1; then
        print_success "Internet connectivity: OK"
    else
        issues+=("No internet connectivity")
        health_score=$((health_score - 10))
    fi
    
    echo -e "\n${CYAN}=== Service Check ===${NC}"
    local critical_services=("sshd" "systemd")
    for service in "${critical_services[@]}"; do
        if systemctl is-active --quiet "$service"; then
            print_success "$service: Running"
        else
            issues+=("$service is not running")
            health_score=$((health_score - 5))
        fi
    done
    
    # Display results
    echo -e "\n${CYAN}=== Health Summary ===${NC}"
    echo "Health Score: $health_score/100"
    
    if [[ ${#issues[@]} -gt 0 ]]; then
        echo -e "\n${RED}Issues Found:${NC}"
        for issue in "${issues[@]}"; do
            echo -e "  ${RED}✗ $issue${NC}"
        done
    fi
    
    if [[ ${#warnings[@]} -gt 0 ]]; then
        echo -e "\n${YELLOW}Warnings:${NC}"
        for warning in "${warnings[@]}"; do
            echo -e "  ${YELLOW}⚠ $warning${NC}"
        done
    fi
    
    if [[ $health_score -ge 80 ]]; then
        print_success "System health is good"
    elif [[ $health_score -ge 60 ]]; then
        print_warning "System health needs attention"
    else
        print_error "System health is poor - immediate action required"
    fi
}

# System performance benchmark
cmd_system_benchmark() {
    print_header "System Performance Benchmark"
    
    echo -e "${CYAN}=== CPU Benchmark ===${NC}"
    local cpu_start=$(date +%s.%N)
    local cpu_result=$(dd if=/dev/zero bs=1M count=1000 2>/dev/null | md5sum)
    local cpu_end=$(date +%s.%N)
    local cpu_time=$(echo "$cpu_end - $cpu_start" | bc)
    echo "CPU benchmark completed in ${cpu_time}s"
    
    echo -e "\n${CYAN}=== Memory Benchmark ===${NC}"
    local mem_start=$(date +%s.%N)
    local mem_result=$(dd if=/dev/zero bs=1M count=100 2>/dev/null | md5sum)
    local mem_end=$(date +%s.%N)
    local mem_time=$(echo "$mem_end - $mem_start" | bc)
    echo "Memory benchmark completed in ${mem_time}s"
    
    echo -e "\n${CYAN}=== Disk I/O Benchmark ===${NC}"
    local disk_start=$(date +%s.%N)
    local disk_result=$(dd if=/dev/zero of=/tmp/benchmark_test bs=1M count=100 2>/dev/null)
    local disk_end=$(date +%s.%N)
    local disk_time=$(echo "$disk_end - $disk_start" | bc)
    echo "Disk write benchmark completed in ${disk_time}s"
    
    # Cleanup
    rm -f /tmp/benchmark_test
    
    echo -e "\n${CYAN}=== Benchmark Summary ===${NC}"
    echo "CPU Performance: ${cpu_time}s"
    echo "Memory Performance: ${mem_time}s"
    echo "Disk I/O Performance: ${disk_time}s"
    
    print_success "Benchmark completed"
}

# Process analysis
cmd_process_analysis() {
    print_header "Process Analysis"
    
    echo -e "${CYAN}=== Top CPU Consumers ===${NC}"
    ps aux --sort=-%cpu | head -10
    
    echo -e "\n${CYAN}=== Top Memory Consumers ===${NC}"
    ps aux --sort=-%mem | head -10
    
    echo -e "\n${CYAN}=== Longest Running Processes ===${NC}"
    ps -eo pid,ppid,cmd,lstart --sort=start_time | head -10
    
    echo -e "\n${CYAN}=== Zombie Processes ===${NC}"
    ps aux | grep -w Z | grep -v grep || echo "No zombie processes found"
    
    echo -e "\n${CYAN}=== Process Count by User ===${NC}"
    ps hax -o user | sort | uniq -c | sort -nr
}

# Network analysis
cmd_network_analysis() {
    print_header "Network Analysis"
    
    echo -e "${CYAN}=== Network Interfaces ===${NC}"
    ip addr show
    
    echo -e "\n${CYAN}=== Active Connections ===${NC}"
    netstat -tuln | head -15
    
    echo -e "\n${CYAN}=== Routing Table ===${NC}"
    ip route show | head -10
    
    echo -e "\n${CYAN}=== DNS Resolution ===${NC}"
    nslookup google.com 2>/dev/null || echo "DNS resolution test failed"
    
    echo -e "\n${CYAN}=== Network Statistics ===${NC}"
    ss -s
}

# Security check
cmd_security_check() {
    print_header "Security Check"
    
    echo -e "${CYAN}=== Failed Login Attempts ===${NC}"
    grep "Failed password" /var/log/auth.log 2>/dev/null | tail -5 || echo "No failed login attempts found"
    
    echo -e "\n${CYAN}=== Open Ports ===${NC}"
    ss -tuln | grep LISTEN | head -10
    
    echo -e "\n${CYAN}=== SUID Files ===${NC}"
    find /usr/bin /usr/sbin -perm -4000 2>/dev/null | head -10
    
    echo -e "\n${CYAN}=== World Writable Files ===${NC}"
    find /tmp /var/tmp -perm -002 2>/dev/null | head -5
    
    echo -e "\n${CYAN}=== Recent SSH Connections ===${NC}"
    grep "sshd" /var/log/auth.log 2>/dev/null | tail -5 || echo "No SSH log entries found"
}

# =============================================================================
# Plugin Registration
# =============================================================================

# Register plugin commands with the main menu
register_plugin_commands() {
    # Only add plugin commands if external scripts are not loaded
    if [[ -z "${EXTERNAL_SCRIPTS:-}" ]]; then
        # Add new menu items
        add_menu_item "System Health Check" "cmd_system_health" "Check overall system health" 1
        add_menu_item "System Benchmark" "cmd_system_benchmark" "Run system performance tests" 2
        add_menu_item "Process Analysis" "cmd_process_analysis" "Analyze running processes" 1
        add_menu_item "Network Analysis" "cmd_network_analysis" "Analyze network configuration" 2
        add_menu_item "Security Check" "cmd_security_check" "Basic security audit" 2

        log_info "System Tools plugin commands registered"
    fi
}

# Auto-register when plugin is loaded
register_plugin_commands 