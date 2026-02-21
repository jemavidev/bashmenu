#!/usr/bin/env bash
# Tests for search.sh module

# Setup test environment
setup_test_env() {
    export TEST_DIR="/tmp/bashmenu_search_test_$$"
    mkdir -p "$TEST_DIR/plugins"
    
    # Create test scripts
    cat > "$TEST_DIR/plugins/deploy_production.sh" << 'EOF'
#!/bin/bash
# Deploy to production server
# Tags: deployment, production
echo "Deploying..."
EOF
    
    cat > "$TEST_DIR/plugins/backup_database.sh" << 'EOF'
#!/bin/bash
# Backup database to S3
# Tags: backup, database
echo "Backing up..."
EOF
    
    cat > "$TEST_DIR/plugins/test_api.sh" << 'EOF'
#!/bin/bash
# Test API endpoints
# Tags: testing, api
echo "Testing..."
EOF
    
    chmod +x "$TEST_DIR/plugins"/*.sh
}

# Cleanup test environment
cleanup_test_env() {
    rm -rf "$TEST_DIR"
}

# Source the module
source "$(dirname "$0")/../../../src/features/search.sh"

# Test 1: search_init
test_search_init() {
    echo "Test 1: search_init"
    search_init
    
    if [[ -z "$SEARCH_QUERY" ]] && [[ ${#SEARCH_RESULTS[@]} -eq 0 ]]; then
        echo "✓ PASS: search_init initializes correctly"
        return 0
    else
        echo "✗ FAIL: search_init failed"
        return 1
    fi
}

# Test 2: search_by_name - exact match
test_search_by_name_exact() {
    echo "Test 2: search_by_name - exact match"
    setup_test_env
    
    local results
    results=$(search_by_name "deploy" "$TEST_DIR/plugins")
    
    if echo "$results" | grep -q "deploy_production.sh"; then
        echo "✓ PASS: Found script by name"
        cleanup_test_env
        return 0
    else
        echo "✗ FAIL: Script not found"
        cleanup_test_env
        return 1
    fi
}

# Test 3: search_by_name - case insensitive
test_search_by_name_case() {
    echo "Test 3: search_by_name - case insensitive"
    setup_test_env
    
    local results
    results=$(search_by_name "DEPLOY" "$TEST_DIR/plugins")
    
    if echo "$results" | grep -q "deploy_production.sh"; then
        echo "✓ PASS: Case-insensitive search works"
        cleanup_test_env
        return 0
    else
        echo "✗ FAIL: Case-insensitive search failed"
        cleanup_test_env
        return 1
    fi
}

# Test 4: search_by_description
test_search_by_description() {
    echo "Test 4: search_by_description"
    setup_test_env
    
    local results
    results=$(search_by_description "database" "$TEST_DIR/plugins")
    
    if echo "$results" | grep -q "backup_database.sh"; then
        echo "✓ PASS: Found script by description"
        cleanup_test_env
        return 0
    else
        echo "✗ FAIL: Description search failed"
        cleanup_test_env
        return 1
    fi
}

# Test 5: search_by_tags
test_search_by_tags() {
    echo "Test 5: search_by_tags"
    setup_test_env
    
    local results
    results=$(search_by_tags "deployment" "$TEST_DIR/plugins")
    
    if echo "$results" | grep -q "deploy_production.sh"; then
        echo "✓ PASS: Found script by tag"
        cleanup_test_env
        return 0
    else
        echo "✗ FAIL: Tag search failed"
        cleanup_test_env
        return 1
    fi
}

# Test 6: search_incremental - name mode
test_search_incremental_name() {
    echo "Test 6: search_incremental - name mode"
    setup_test_env
    
    search_incremental "backup" "$TEST_DIR/plugins" "name"
    local count=${#SEARCH_RESULTS[@]}
    
    if [[ $count -eq 1 ]] && [[ "${SEARCH_RESULTS[0]}" == *"backup_database.sh"* ]]; then
        echo "✓ PASS: Incremental search (name) works"
        cleanup_test_env
        return 0
    else
        echo "✗ FAIL: Incremental search (name) failed (found: $count)"
        cleanup_test_env
        return 1
    fi
}

# Test 7: search_incremental - all mode
test_search_incremental_all() {
    echo "Test 7: search_incremental - all mode"
    setup_test_env
    
    search_incremental "api" "$TEST_DIR/plugins" "all"
    local count=${#SEARCH_RESULTS[@]}
    
    if [[ $count -ge 1 ]]; then
        echo "✓ PASS: Incremental search (all) works (found: $count)"
        cleanup_test_env
        return 0
    else
        echo "✗ FAIL: Incremental search (all) failed"
        cleanup_test_env
        return 1
    fi
}

# Test 8: search_incremental - empty query
test_search_incremental_empty() {
    echo "Test 8: search_incremental - empty query"
    setup_test_env
    
    search_incremental "" "$TEST_DIR/plugins" "all"
    local count=${#SEARCH_RESULTS[@]}
    
    if [[ $count -eq 0 ]]; then
        echo "✓ PASS: Empty query returns no results"
        cleanup_test_env
        return 0
    else
        echo "✗ FAIL: Empty query should return 0 results"
        cleanup_test_env
        return 1
    fi
}

# Test 9: highlight_results
test_highlight_results() {
    echo "Test 9: highlight_results"
    
    local text="deploy_production.sh"
    local highlighted
    highlighted=$(highlight_results "$text" "deploy")
    
    if [[ "$highlighted" == *$'\x1b'* ]]; then
        echo "✓ PASS: Highlighting works"
        return 0
    else
        echo "✗ FAIL: Highlighting failed"
        return 1
    fi
}

# Test 10: search_stats
test_search_stats() {
    echo "Test 10: search_stats"
    
    SEARCH_QUERY="test"
    SEARCH_RESULTS=("script1.sh" "script2.sh")
    SEARCH_SELECTED=1
    
    local stats
    stats=$(search_stats)
    
    if echo "$stats" | grep -q '"current_query": "test"' && \
       echo "$stats" | grep -q '"results_count": 2'; then
        echo "✓ PASS: Stats generation works"
        return 0
    else
        echo "✗ FAIL: Stats generation failed"
        return 1
    fi
}

# Test 11: Performance test (<200ms for 100 scripts)
test_search_performance() {
    echo "Test 11: Performance test"
    setup_test_env
    
    # Create 100 test scripts
    for i in {1..100}; do
        echo "#!/bin/bash" > "$TEST_DIR/plugins/script_$i.sh"
        echo "# Test script $i" >> "$TEST_DIR/plugins/script_$i.sh"
    done
    
    local start end duration
    start=$(date +%s%N 2>/dev/null || date +%s)
    search_incremental "script" "$TEST_DIR/plugins" "all"
    end=$(date +%s%N 2>/dev/null || date +%s)
    
    if [[ "$start" =~ [0-9]{10,} ]]; then
        duration=$(( (end - start) / 1000000 ))
    else
        duration=$(( (end - start) * 1000 ))
    fi
    
    cleanup_test_env
    
    if [[ $duration -lt 200 ]]; then
        echo "✓ PASS: Search completed in ${duration}ms (<200ms)"
        return 0
    else
        echo "⚠ WARNING: Search took ${duration}ms (target: <200ms)"
        return 0  # Don't fail, just warn
    fi
}

# Run all tests
main() {
    local passed=0
    local failed=0
    
    echo "================================"
    echo "Running Search Module Tests"
    echo "================================"
    echo ""
    
    test_search_init && ((passed++)) || ((failed++))
    test_search_by_name_exact && ((passed++)) || ((failed++))
    test_search_by_name_case && ((passed++)) || ((failed++))
    test_search_by_description && ((passed++)) || ((failed++))
    test_search_by_tags && ((passed++)) || ((failed++))
    test_search_incremental_name && ((passed++)) || ((failed++))
    test_search_incremental_all && ((passed++)) || ((failed++))
    test_search_incremental_empty && ((passed++)) || ((failed++))
    test_highlight_results && ((passed++)) || ((failed++))
    test_search_stats && ((passed++)) || ((failed++))
    test_search_performance && ((passed++)) || ((failed++))
    
    echo ""
    echo "================================"
    echo "Test Results"
    echo "================================"
    echo "Passed: $passed"
    echo "Failed: $failed"
    echo "Total:  $((passed + failed))"
    echo ""
    
    if [[ $failed -eq 0 ]]; then
        echo "✓ All tests passed!"
        return 0
    else
        echo "✗ Some tests failed"
        return 1
    fi
}

# Run tests if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
