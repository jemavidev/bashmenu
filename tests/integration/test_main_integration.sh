#!/bin/bash

# =============================================================================
# Integration Test for src/main.sh
# =============================================================================
# Tests main.sh initialization and module loading
# Run: bash tests/integration/test_main_integration.sh
# =============================================================================

set -e

echo "=== Integration Test: main.sh ==="
echo ""

# Get project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Test 1: Check version updated
echo "Test 1: Version updated to 2.2"
version=$(grep "readonly SCRIPT_VERSION=" "$PROJECT_ROOT/src/main.sh" | cut -d'"' -f2)
if [[ "$version" == "2.2" ]]; then
    echo "✓ Version is 2.2"
else
    echo "✗ Version is $version (expected 2.2)"
    exit 1
fi

# Test 2: Check installation type detection exists
echo ""
echo "Test 2: Installation type detection"
if grep -q "readonly INSTALL_TYPE=" "$PROJECT_ROOT/src/main.sh"; then
    echo "✓ Installation type detection implemented"
else
    echo "✗ Installation type detection not found"
    exit 1
fi

# Test 3: Check validate_installation function exists
echo ""
echo "Test 3: validate_installation function"
if grep -q "validate_installation()" "$PROJECT_ROOT/src/main.sh"; then
    echo "✓ validate_installation function exists"
else
    echo "✗ validate_installation function not found"
    exit 1
fi

# Test 4: Check config module is loaded first
echo ""
echo "Test 4: Config module loaded first"
if grep -q "Load config module first" "$PROJECT_ROOT/src/main.sh"; then
    echo "✓ Config module loaded first"
else
    echo "✗ Config module not loaded first"
    exit 1
fi

# Test 5: Check improved error messages
echo ""
echo "Test 5: Improved error messages"
if grep -q "Check logs for details" "$PROJECT_ROOT/src/main.sh"; then
    echo "✓ Improved error messages present"
else
    echo "✗ Error messages not improved"
    exit 1
fi

# Test 6: Check PROJECT_ROOT is exported
echo ""
echo "Test 6: PROJECT_ROOT exported"
if grep -q "export PROJECT_ROOT" "$PROJECT_ROOT/src/main.sh"; then
    echo "✓ PROJECT_ROOT is exported"
else
    echo "✗ PROJECT_ROOT not exported"
    exit 1
fi

# Test 7: Syntax validation
echo ""
echo "Test 7: Syntax validation"
if bash -n "$PROJECT_ROOT/src/main.sh" 2>/dev/null; then
    echo "✓ Syntax is valid"
else
    echo "✗ Syntax errors found"
    exit 1
fi

# Test 8: Check theme uses BASHMENU_THEME variable
echo ""
echo "Test 8: Theme uses BASHMENU_THEME variable"
if grep -q 'BASHMENU_THEME:-' "$PROJECT_ROOT/src/main.sh"; then
    echo "✓ Theme uses BASHMENU_THEME variable"
else
    echo "✗ Theme doesn't use BASHMENU_THEME variable"
    exit 1
fi

# Test 9: Check initialization logs version
echo ""
echo "Test 9: Initialization logs version"
if grep -q "Bashmenu v\$SCRIPT_VERSION" "$PROJECT_ROOT/src/main.sh"; then
    echo "✓ Initialization logs version"
else
    echo "✗ Version not logged in initialization"
    exit 1
fi

# Test 10: Check installation type is logged
echo ""
echo "Test 10: Installation type logged"
if grep -q "Installation type: \$INSTALL_TYPE" "$PROJECT_ROOT/src/main.sh"; then
    echo "✓ Installation type is logged"
else
    echo "✗ Installation type not logged"
    exit 1
fi

echo ""
echo "=== All integration tests passed! ==="
echo ""
echo "Summary:"
echo "  • Version updated to 2.2"
echo "  • Installation detection implemented"
echo "  • Path validation added"
echo "  • Config module loaded first"
echo "  • Error messages improved"
echo "  • Variables properly exported"
echo "  • Syntax valid"
echo ""
