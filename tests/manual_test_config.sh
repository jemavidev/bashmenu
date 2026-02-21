#!/bin/bash

# Manual test for config.sh module
# Run: bash tests/manual_test_config.sh

set -e

echo "=== Testing config.sh module ==="
echo ""

# Load the module
source src/core/config.sh

# Test 1: Load defaults
echo "Test 1: Load configuration with defaults"
load_configuration
if [[ "$BASHMENU_CONFIG_LOADED" == "true" ]]; then
    echo "✓ Configuration loaded"
else
    echo "✗ Configuration not loaded"
    exit 1
fi

# Test 2: Check default values
echo ""
echo "Test 2: Check default values"
if [[ "$BASHMENU_THEME" == "modern" ]]; then
    echo "✓ Default theme is 'modern'"
else
    echo "✗ Default theme incorrect: $BASHMENU_THEME"
    exit 1
fi

# Test 3: get_config function
echo ""
echo "Test 3: get_config function"
result=$(get_config "BASHMENU_THEME")
if [[ "$result" == "modern" ]]; then
    echo "✓ get_config returns correct value"
else
    echo "✗ get_config failed: $result"
    exit 1
fi

# Test 4: set_config function
echo ""
echo "Test 4: set_config function"
set_config "BASHMENU_TEST_VAR" "test_value"
if [[ "$BASHMENU_TEST_VAR" == "test_value" ]]; then
    echo "✓ set_config works"
else
    echo "✗ set_config failed"
    exit 1
fi

# Test 5: is_config_enabled function
echo ""
echo "Test 5: is_config_enabled function"
set_config "BASHMENU_TEST_BOOL" "true"
if is_config_enabled "BASHMENU_TEST_BOOL"; then
    echo "✓ is_config_enabled works for true"
else
    echo "✗ is_config_enabled failed for true"
    exit 1
fi

set_config "BASHMENU_TEST_BOOL" "false"
if ! is_config_enabled "BASHMENU_TEST_BOOL"; then
    echo "✓ is_config_enabled works for false"
else
    echo "✗ is_config_enabled failed for false"
    exit 1
fi

# Test 6: validate_config function
echo ""
echo "Test 6: validate_config function"
set_config "BASHMENU_ENABLE_CACHE" "invalid"
validate_config
if [[ "$BASHMENU_ENABLE_CACHE" == "true" ]]; then
    echo "✓ validate_config corrects invalid boolean"
else
    echo "✗ validate_config failed: $BASHMENU_ENABLE_CACHE"
    exit 1
fi

# Test 7: Load from .env file
echo ""
echo "Test 7: Load from .env file"
cat > /tmp/test_bashmenu.env << 'EOF'
BASHMENU_TEST_FROM_FILE=loaded_value
BASHMENU_CUSTOM_VAR=custom_value
EOF

load_env_file /tmp/test_bashmenu.env
if [[ "$BASHMENU_TEST_FROM_FILE" == "loaded_value" ]]; then
    echo "✓ load_env_file works"
else
    echo "✗ load_env_file failed: $BASHMENU_TEST_FROM_FILE"
    exit 1
fi

rm -f /tmp/test_bashmenu.env

# Test 8: Priority order (ENV > file)
echo ""
echo "Test 8: Priority order (ENV overrides file)"
export BASHMENU_PRIORITY_TEST="from_env"
cat > /tmp/test_bashmenu.env << 'EOF'
BASHMENU_PRIORITY_TEST=from_file
EOF

load_env_file /tmp/test_bashmenu.env
if [[ "$BASHMENU_PRIORITY_TEST" == "from_env" ]]; then
    echo "✓ ENV variables have priority"
else
    echo "✗ Priority order failed: $BASHMENU_PRIORITY_TEST"
    exit 1
fi

rm -f /tmp/test_bashmenu.env

echo ""
echo "=== All tests passed! ==="
echo ""
echo "Configuration summary:"
print_config | head -20
