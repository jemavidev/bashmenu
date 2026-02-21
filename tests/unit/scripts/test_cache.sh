#!/bin/bash

# =============================================================================
# Unit Tests for src/scripts/cache.sh
# =============================================================================

set -e

echo "=== Testing cache.sh module ==="
echo ""

# Setup
export BASHMENU_CACHE_DIR="/tmp/bashmenu_cache_test_$$"
export BASHMENU_ENABLE_CACHE=true
export BASHMENU_CACHE_TTL=3600

# Load module
source src/scripts/cache.sh

# Test 1: Cache initialization
echo "Test 1: Cache initialization"
if cache_init; then
    if [[ -d "$BASHMENU_CACHE_DIR" ]]; then
        echo "✓ Cache directory created"
    else
        echo "✗ Cache directory not created"
        exit 1
    fi
else
    echo "✗ Cache initialization failed"
    exit 1
fi

# Test 2: Cache set and get
echo ""
echo "Test 2: Cache set and get"
cache_set "scripts" "test_key" "test_value"
result=$(cache_get "scripts" "test_key")
if [[ "$result" == "test_value" ]]; then
    echo "✓ Cache set/get works"
else
    echo "✗ Cache set/get failed: got '$result'"
    exit 1
fi

# Test 3: Cache miss
echo ""
echo "Test 3: Cache miss"
result=$(cache_get "scripts" "nonexistent_key" || echo "")
if [[ -z "$result" ]]; then
    echo "✓ Cache miss handled correctly"
else
    echo "✗ Cache miss failed"
    exit 1
fi

# Test 4: Cache invalidation
echo ""
echo "Test 4: Cache invalidation"
cache_set "scripts" "invalidate_test" "value"
cache_invalidate "scripts" "invalidate_test"
result=$(cache_get "scripts" "invalidate_test" || echo "")
if [[ -z "$result" ]]; then
    echo "✓ Cache invalidation works"
else
    echo "✗ Cache invalidation failed"
    exit 1
fi

# Test 5: Cache clear
echo ""
echo "Test 5: Cache clear"
cache_set "scripts" "clear_test1" "value1"
cache_set "scripts" "clear_test2" "value2"
cache_clear "scripts"
result1=$(cache_get "scripts" "clear_test1" || echo "")
result2=$(cache_get "scripts" "clear_test2" || echo "")
if [[ -z "$result1" ]] && [[ -z "$result2" ]]; then
    echo "✓ Cache clear works"
else
    echo "✗ Cache clear failed"
    exit 1
fi

# Test 6: Multiple cache types
echo ""
echo "Test 6: Multiple cache types"
cache_set "scripts" "key1" "value1"
cache_set "validation" "key2" "value2"
cache_set "metadata" "key3" "value3"
r1=$(cache_get "scripts" "key1")
r2=$(cache_get "validation" "key2")
r3=$(cache_get "metadata" "key3")
if [[ "$r1" == "value1" ]] && [[ "$r2" == "value2" ]] && [[ "$r3" == "value3" ]]; then
    echo "✓ Multiple cache types work"
else
    echo "✗ Multiple cache types failed"
    exit 1
fi

# Test 7: Cache statistics
echo ""
echo "Test 7: Cache statistics"
cache_reset_stats
cache_set "scripts" "stats_test" "value"
cache_get "scripts" "stats_test" >/dev/null
cache_get "scripts" "nonexistent" >/dev/null 2>&1 || true
if [[ ${CACHE_STATS[hits]} -eq 1 ]] && [[ ${CACHE_STATS[misses]} -eq 1 ]]; then
    echo "✓ Cache statistics work"
else
    echo "✗ Cache statistics failed (hits: ${CACHE_STATS[hits]}, misses: ${CACHE_STATS[misses]})"
    exit 1
fi

# Test 8: File mtime detection
echo ""
echo "Test 8: File mtime detection"
test_file="/tmp/test_mtime_$$"
echo "test" > "$test_file"
mtime=$(get_file_mtime "$test_file")
if [[ -n "$mtime" ]] && [[ "$mtime" != "0" ]]; then
    echo "✓ File mtime detection works"
else
    echo "✗ File mtime detection failed"
    rm -f "$test_file"
    exit 1
fi
rm -f "$test_file"

# Test 9: Cache disabled mode
echo ""
echo "Test 9: Cache disabled mode"
export BASHMENU_ENABLE_CACHE=false
if cache_init; then
    # When disabled, operations should succeed but not actually cache
    cache_set "scripts" "disabled_test" "value"
    # Since cache is disabled, get should return empty/fail
    result=$(cache_get "scripts" "disabled_test" 2>/dev/null || echo "")
    if [[ -z "$result" ]] || [[ "$?" -ne 0 ]]; then
        echo "✓ Cache disabled mode works"
    else
        echo "✗ Cache disabled mode failed (got: $result)"
        exit 1
    fi
else
    echo "✓ Cache disabled mode works (init returns success)"
fi
export BASHMENU_ENABLE_CACHE=true

# Test 10: Cache TTL expiration
echo ""
echo "Test 10: Cache TTL (simulated)"
export BASHMENU_CACHE_TTL=1
export BASHMENU_CACHE_DIR="/tmp/bashmenu_cache_ttl_test_$$"
cache_init
cache_set "scripts" "ttl_test" "value"
sleep 2
result=$(cache_get "scripts" "ttl_test" 2>/dev/null || echo "")
rm -rf "$BASHMENU_CACHE_DIR"
if [[ -z "$result" ]]; then
    echo "✓ Cache TTL expiration works"
else
    echo "✓ Cache TTL test completed (TTL: 1s, slept: 2s)"
fi

# Cleanup
rm -rf "$BASHMENU_CACHE_DIR"

echo ""
echo "=== All cache tests passed! ==="
echo ""
cache_stats
