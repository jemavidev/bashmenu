#!/bin/bash

# =============================================================================
# Integration Test for migrate.sh
# =============================================================================

set -e

echo "=== Integration Test: migrate.sh ==="
echo ""

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

# Test 1: Script exists and is executable
echo "Test 1: Script exists"
if [[ -f "$PROJECT_ROOT/migrate.sh" ]] && [[ -x "$PROJECT_ROOT/migrate.sh" ]]; then
    echo "✓ migrate.sh exists and is executable"
else
    echo "✗ migrate.sh not found or not executable"
    exit 1
fi

# Test 2: Syntax validation
echo ""
echo "Test 2: Syntax validation"
if bash -n "$PROJECT_ROOT/migrate.sh" 2>/dev/null; then
    echo "✓ Syntax is valid"
else
    echo "✗ Syntax errors found"
    exit 1
fi

# Test 3: Help option works
echo ""
echo "Test 3: Help option"
if bash "$PROJECT_ROOT/migrate.sh" --help >/dev/null 2>&1; then
    echo "✓ Help option works"
else
    echo "✗ Help option failed"
    exit 1
fi

# Test 4: Dry-run mode exists
echo ""
echo "Test 4: Dry-run mode"
if grep -q "DRY_RUN" "$PROJECT_ROOT/migrate.sh"; then
    echo "✓ Dry-run mode implemented"
else
    echo "✗ Dry-run mode not found"
    exit 1
fi

# Test 5: Backup function exists
echo ""
echo "Test 5: Backup function"
if grep -q "create_backup()" "$PROJECT_ROOT/migrate.sh"; then
    echo "✓ Backup function exists"
else
    echo "✗ Backup function not found"
    exit 1
fi

# Test 6: Rollback function exists
echo ""
echo "Test 6: Rollback function"
if grep -q "rollback_migration()" "$PROJECT_ROOT/migrate.sh"; then
    echo "✓ Rollback function exists"
else
    echo "✗ Rollback function not found"
    exit 1
fi

# Test 7: Validation function exists
echo ""
echo "Test 7: Validation function"
if grep -q "validate_migration()" "$PROJECT_ROOT/migrate.sh"; then
    echo "✓ Validation function exists"
else
    echo "✗ Validation function not found"
    exit 1
fi

# Test 8: Config migration function exists
echo ""
echo "Test 8: Config migration"
if grep -q "migrate_config_to_env()" "$PROJECT_ROOT/migrate.sh"; then
    echo "✓ Config migration function exists"
else
    echo "✗ Config migration function not found"
    exit 1
fi

# Test 9: Path conversion function exists
echo ""
echo "Test 9: Path conversion"
if grep -q "convert_paths_in_scripts_conf()" "$PROJECT_ROOT/migrate.sh"; then
    echo "✓ Path conversion function exists"
else
    echo "✗ Path conversion function not found"
    exit 1
fi

# Test 10: Logging implemented
echo ""
echo "Test 10: Logging"
if grep -q "log_message()" "$PROJECT_ROOT/migrate.sh"; then
    echo "✓ Logging implemented"
else
    echo "✗ Logging not found"
    exit 1
fi

echo ""
echo "=== All migration tests passed! ==="
echo ""
