#!/usr/bin/env bash
# Security tests - File permissions

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

# Test 1: Script files have correct permissions
test_script_permissions() {
    echo "Test 1: Script file permissions"
    
    local issues=0
    
    # Check all .sh files
    while IFS= read -r script; do
        local perms
        perms=$(stat -c "%a" "$script" 2>/dev/null || stat -f "%Lp" "$script" 2>/dev/null)
        
        # Should be 755 or 644
        if [[ "$perms" != "755" ]] && [[ "$perms" != "644" ]]; then
            echo "  ⚠ Incorrect permissions: $script ($perms)"
            ((issues++))
        fi
    done < <(find "$SCRIPT_DIR/src" -name "*.sh" 2>/dev/null)
    
    if [[ $issues -eq 0 ]]; then
        echo "✓ PASS: All scripts have correct permissions"
        return 0
    else
        echo "✗ FAIL: $issues files with incorrect permissions"
        return 1
    fi
}

# Test 2: Config files are not world-writable
test_config_permissions() {
    echo "Test 2: Config file permissions"
    
    local config_files=(
        "$SCRIPT_DIR/config/config.conf"
        "$SCRIPT_DIR/config/scripts.conf"
    )
    
    local issues=0
    
    for file in "${config_files[@]}"; do
        if [[ -f "$file" ]]; then
            local perms
            perms=$(stat -c "%a" "$file" 2>/dev/null || stat -f "%Lp" "$file" 2>/dev/null)
            
            # Should not be world-writable (last digit should be 0, 4, or 5)
            local last_digit="${perms: -1}"
            if [[ "$last_digit" =~ [267] ]]; then
                echo "  ⚠ World-writable: $file ($perms)"
                ((issues++))
            fi
        fi
    done
    
    if [[ $issues -eq 0 ]]; then
        echo "✓ PASS: Config files not world-writable"
        return 0
    else
        echo "✗ FAIL: $issues world-writable config files"
        return 1
    fi
}

# Test 3: User directory permissions
test_user_dir_permissions() {
    echo "Test 3: User directory permissions"
    
    local test_dir="/tmp/bashmenu_perm_test_$$"
    mkdir -p "$test_dir/.bashmenu"
    
    local perms
    perms=$(stat -c "%a" "$test_dir/.bashmenu" 2>/dev/null || stat -f "%Lp" "$test_dir/.bashmenu" 2>/dev/null)
    
    rm -rf "$test_dir"
    
    # Should be 755 or 700
    if [[ "$perms" == "755" ]] || [[ "$perms" == "700" ]]; then
        echo "✓ PASS: User directory has correct permissions"
        return 0
    else
        echo "✗ FAIL: Incorrect permissions ($perms)"
        return 1
    fi
}

# Test 4: No setuid/setgid bits
test_no_setuid() {
    echo "Test 4: No setuid/setgid bits"
    
    local issues=0
    
    while IFS= read -r file; do
        local perms
        perms=$(stat -c "%a" "$file" 2>/dev/null || stat -f "%Lp" "$file" 2>/dev/null)
        
        # Check for setuid (4xxx) or setgid (2xxx)
        if [[ "$perms" =~ ^[42] ]]; then
            echo "  ⚠ Setuid/setgid found: $file ($perms)"
            ((issues++))
        fi
    done < <(find "$SCRIPT_DIR/src" -type f 2>/dev/null)
    
    if [[ $issues -eq 0 ]]; then
        echo "✓ PASS: No setuid/setgid bits found"
        return 0
    else
        echo "✗ FAIL: $issues files with setuid/setgid"
        return 1
    fi
}

# Test 5: Executable files are scripts
test_executable_files() {
    echo "Test 5: Executable files validation"
    
    local issues=0
    
    while IFS= read -r file; do
        if [[ -x "$file" ]] && [[ -f "$file" ]]; then
            # Should have shebang
            local first_line
            first_line=$(head -n1 "$file")
            
            if [[ ! "$first_line" =~ ^#! ]]; then
                echo "  ⚠ Executable without shebang: $file"
                ((issues++))
            fi
        fi
    done < <(find "$SCRIPT_DIR/src" -type f 2>/dev/null)
    
    if [[ $issues -eq 0 ]]; then
        echo "✓ PASS: All executables have shebang"
        return 0
    else
        echo "✗ FAIL: $issues executables without shebang"
        return 1
    fi
}

# Run all tests
main() {
    local passed=0
    local failed=0
    
    echo "================================"
    echo "Security Tests - Permissions"
    echo "================================"
    echo ""
    
    test_script_permissions && ((passed++)) || ((failed++))
    test_config_permissions && ((passed++)) || ((failed++))
    test_user_dir_permissions && ((passed++)) || ((failed++))
    test_no_setuid && ((passed++)) || ((failed++))
    test_executable_files && ((passed++)) || ((failed++))
    
    echo ""
    echo "================================"
    echo "Test Results"
    echo "================================"
    echo "Passed: $passed"
    echo "Failed: $failed"
    echo "Total:  $((passed + failed))"
    echo ""
    
    if [[ $failed -eq 0 ]]; then
        echo "✓ All security tests passed!"
        return 0
    else
        echo "✗ Some tests failed"
        return 1
    fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
