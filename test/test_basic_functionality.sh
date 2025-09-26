#!/bin/zsh

# Test Basic Functionality of AI Command Plugin

# Get plugin directory
PLUGIN_DIR="$(dirname "$(dirname "$(realpath "$0")")")"
PLUGIN_FILE="$PLUGIN_DIR/ai-command.plugin.zsh"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Test counter
TEST_COUNT=0
PASS_COUNT=0

# Test function
assert_test() {
    local description="$1"
    local command="$2"
    local expected_result="$3"  # 0 for success, 1 for failure
    
    ((TEST_COUNT++))
    echo "  Test $TEST_COUNT: $description"
    
    if eval "$command" >/dev/null 2>&1; then
        actual_result=0
    else
        actual_result=1
    fi
    
    if [[ $actual_result -eq $expected_result ]]; then
        echo "    ${GREEN}✓ PASS${NC}"
        ((PASS_COUNT++))
    else
        echo "    ${RED}✗ FAIL - Expected $expected_result, got $actual_result${NC}"
        # Don't return 1, just continue with other tests
    fi
}

echo "Testing Basic Functionality..."
echo ""

# Test 1: Plugin file exists
assert_test "Plugin file exists" "test -f \"$PLUGIN_FILE\"" 0

# Test 2: Plugin file is readable
assert_test "Plugin file is readable" "test -r \"$PLUGIN_FILE\"" 0

# Test 3: Dependencies check function exists
source "$PLUGIN_FILE" 2>/dev/null
assert_test "Dependencies check function exists" "typeset -f _ai_command_check_dependencies >/dev/null" 0

# Test 4: Config validation function exists
assert_test "Config validation function exists" "typeset -f _ai_command_validate_config >/dev/null" 0

# Test 5: Main AI command function exists
assert_test "Main AI command function exists" "typeset -f ai_command >/dev/null" 0

# Test 6: Display suggestions function exists
assert_test "Display suggestions function exists" "typeset -f _ai_command_display_suggestions >/dev/null" 0

# Test 7: JSON cleaning function exists
assert_test "JSON cleaning function exists" "typeset -f _ai_command_clean_json >/dev/null" 0

# Test 8: System info function exists
assert_test "System info function exists" "typeset -f _ai_command_get_system_info >/dev/null" 0

# Test 9: Command analysis function exists
assert_test "Command analysis function exists" "typeset -f _ai_command_analyze_command >/dev/null" 0

# Test 10: Risk color function exists
assert_test "Risk color function exists" "typeset -f _ai_command_get_risk_color >/dev/null" 0

# Test 11: Category display function exists
assert_test "Category display function exists" "typeset -f _ai_command_get_category_display >/dev/null" 0

# Test 12: Alias is created
assert_test "AI alias is created" "alias /AI >/dev/null" 0

# Test 13: Dependencies are available
assert_test "curl is available" "command -v curl >/dev/null" 0
assert_test "jq is available" "command -v jq >/dev/null" 0

# Test 14: Environment variables are working
assert_test "System info function works" "_ai_command_get_system_info | grep -q 'System:'" 0

# Test 15: Risk color function returns colors
assert_test "Risk color function works for SAFE" "[[ -n $(_ai_command_get_risk_color 'SAFE') ]]" 0
assert_test "Risk color function works for CAUTION" "[[ -n $(_ai_command_get_risk_color 'CAUTION') ]]" 0
assert_test "Risk color function works for DANGEROUS" "[[ -n $(_ai_command_get_risk_color 'DANGEROUS') ]]" 0

# Test 16: Category display function works
assert_test "Category display works for PACKAGE" "_ai_command_get_category_display 'PACKAGE' | grep -q 'PACKAGE'" 0
assert_test "Category display works for FILES" "_ai_command_get_category_display 'FILE_OPS' | grep -q 'FILES'" 0

# Test 17: Command analysis function works
ANALYSIS_OUTPUT=$(_ai_command_analyze_command "ls -la")
assert_test "Command analysis returns proper format" "echo '$ANALYSIS_OUTPUT' | grep -q '|'" 0

echo ""
echo "Basic Functionality Tests: $PASS_COUNT/$TEST_COUNT passed"

if [[ $PASS_COUNT -eq $TEST_COUNT ]]; then
    echo "${GREEN}All basic functionality tests passed!${NC}"
    exit 0
else
    echo "${RED}Some basic functionality tests failed!${NC}"
    exit 1
fi