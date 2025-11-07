#!/bin/bash
echo "📊 System Resources Monitor"
echo "==========================="
echo ""
echo "Analyzing system resources..."
echo ""

# Simulate monitoring
echo "CPU Usage: $(ps aux --no-headers -o pcpu | awk '{cpu += $1} END {print cpu "%"}')"
echo "Memory Usage: $(free -h | grep Mem | awk '{print $3 "/" $2}')"
echo "Disk Usage: $(df -h / | tail -1 | awk '{print $5}')"
echo ""

echo "Critical services status:"
echo "✅ SSH: $(systemctl is-active ssh 2>/dev/null || echo "Not available")"
echo "✅ Apache/Nginx: $(systemctl is-active apache2 2>/dev/null || systemctl is-active nginx 2>/dev/null || echo "Not available")"
echo "✅ MySQL: $(systemctl is-active mysql 2>/dev/null || systemctl is-active mariadb 2>/dev/null || echo "Not available")"
echo ""

echo "Monitoring completed."
echo ""
read -p "Press Enter to continue..."
