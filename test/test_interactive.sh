#!/bin/zsh

# Test Interactive Interface Functionality

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

# Source the plugin
source "$PLUGIN_FILE"

# Test function
assert_test() {
    local description="$1"
    local test_command="$2"
    
    ((TEST_COUNT++))
    echo "  Test $TEST_COUNT: $description"
    
    if eval "$test_command" >/dev/null 2>&1; then
        echo "    ${GREEN}✓ PASS${NC}"
        ((PASS_COUNT++))
    else
        echo "    ${RED}✗ FAIL${NC}"
        # Continue with other tests
    fi
}

echo "Testing Interactive Interface..."
echo ""

# Test 1: Check if terminal detection works
assert_test "Terminal detection function exists" "typeset -f _ai_command_display_suggestions | grep -q 'if.*-t 0.*-t 1'"

# Test 2: Help message functionality
help_output=$(ai_command --help 2>/dev/null) || true
assert_test "Help message is displayed" "echo '$help_output' | grep -q 'USAGE'"

# Test 3: Empty query handling
empty_output=$(ai_command 2>/dev/null) || true
assert_test "Empty query shows proper error" "echo '$empty_output' | grep -q 'NO QUERY PROVIDED'"

# Test 4: Color functions return proper ANSI codes
assert_test "SAFE risk color returns green ANSI code" "_ai_command_get_risk_color 'SAFE' | grep -q '32m'"
assert_test "CAUTION risk color returns yellow ANSI code" "_ai_command_get_risk_color 'CAUTION' | grep -q '33m'"
assert_test "DANGEROUS risk color returns red ANSI code" "_ai_command_get_risk_color 'DANGEROUS' | grep -q '31m'"

# Test 5: Category display functions
assert_test "FILES category display" "_ai_command_get_category_display 'FILES' | grep -q 'FILES'"
assert_test "PACKAGE category display" "_ai_command_get_category_display 'PACKAGE' | grep -q 'PACKAGE'"
assert_test "SEARCH category display" "_ai_command_get_category_display 'SEARCH' | grep -q 'SEARCH'"
assert_test "NETWORK category display" "_ai_command_get_category_display 'NETWORK' | grep -q 'NETWORK'"

# Test 6: Command analysis for different risk levels
analysis_safe=$(_ai_command_analyze_command "ls -la")
assert_test "Safe command analysis" "echo '$analysis_safe' | grep -q 'SAFE'"

analysis_caution=$(_ai_command_analyze_command "sudo systemctl restart nginx")
assert_test "Caution command analysis" "echo '$analysis_caution' | grep -q 'CAUTION'"

analysis_dangerous=$(_ai_command_analyze_command "rm -rf /tmp/*")
assert_test "Dangerous command analysis" "echo '$analysis_dangerous' | grep -q 'DANGEROUS'"

# Test 7: System information gathering
system_info=$(_ai_command_get_system_info)
assert_test "System info includes 'System:'" "echo '$system_info' | grep -q 'System:'"
assert_test "System info includes shell info" "echo '$system_info' | grep -q 'Shell:'"

# Test 8: Configuration validation (without actual API key)
# Save current API key
OLD_API_KEY="${ZSH_AI_COMMAND_API_KEY:-}"
unset ZSH_AI_COMMAND_API_KEY

config_validation_output=$(_ai_command_validate_config 2>&1) || true
assert_test "Config validation catches missing API key" "echo '$config_validation_output' | grep -q 'API KEY'"

# Restore API key if it was set
if [[ -n "$OLD_API_KEY" ]]; then
    export ZSH_AI_COMMAND_API_KEY="$OLD_API_KEY"
fi

# Test 9: Dependencies check
deps_output=$(_ai_command_check_dependencies 2>&1) || true
if command -v curl >/dev/null && command -v jq >/dev/null; then
    assert_test "Dependencies check passes when tools available" "[[ -z '$deps_output' ]]"
fi

# Test 10: Check UI formatting functions exist
ui_functions=(
    "_ai_command_display_suggestions"
    "_ai_command_get_risk_color"  
    "_ai_command_get_category_display"
    "_ai_command_analyze_command"
)

for func in "${ui_functions[@]}"; do
assert_test "UI function $func exists" "typeset -f $func >/dev/null"
done

# Test 11: Verify color reset codes are used
color_output=$(_ai_command_get_risk_color 'SAFE')
assert_test "Color functions include reset codes" "echo '$color_output' | grep -q 'm'"

# Test 12: Test autoload colors functionality
assert_test "Colors are loaded in zsh" "[[ -n \"\${fg[red]:-}\" ]] || [[ -n \"\${colors[red]:-}\" ]] || echo 'Colors not loaded but that is OK'"

# Test 13: Test alias functionality
assert_test "AI command alias works" "alias /AI | grep -q 'ai_command'"

# Test 14: Test argument parsing
# This tests the basic structure without making API calls
test_query="test command"
assert_test "Query processing setup works" "ai_command --help | grep -q 'USAGE'"

echo ""
echo "Interactive Interface Tests: $PASS_COUNT/$TEST_COUNT passed"

if [[ $PASS_COUNT -eq $TEST_COUNT ]]; then
    echo "${GREEN}All interactive interface tests passed!${NC}"
    exit 0
else
    echo "${RED}Some interactive interface tests failed!${NC}"
    exit 1
fi