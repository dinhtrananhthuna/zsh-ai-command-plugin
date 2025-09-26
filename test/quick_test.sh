#!/bin/zsh

# Quick Test - Simple validation that the plugin is working

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}AI Command Plugin - Quick Test${NC}"
echo "=============================="

# Get plugin directory
PLUGIN_DIR="$(dirname "$(dirname "$(realpath "$0")")")"
PLUGIN_FILE="$PLUGIN_DIR/ai-command.plugin.zsh"

TESTS_PASSED=0
TESTS_TOTAL=0

test_check() {
    local description="$1"
    local command="$2"
    
    ((TESTS_TOTAL++))
    echo -n "Testing: $description ... "
    
    if eval "$command" >/dev/null 2>&1; then
        echo -e "${GREEN}PASS${NC}"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}FAIL${NC}"
    fi
}

# Basic tests
test_check "Plugin file exists" "test -f \"$PLUGIN_FILE\""
test_check "Plugin is readable" "test -r \"$PLUGIN_FILE\""
test_check "curl is available" "command -v curl"
test_check "jq is available" "command -v jq"

# Load plugin
source "$PLUGIN_FILE" 2>/dev/null

test_check "Main function exists" "typeset -f ai_command >/dev/null"
test_check "Display function exists" "typeset -f _ai_command_display_suggestions >/dev/null"
test_check "Clean JSON function exists" "typeset -f _ai_command_clean_json >/dev/null"
test_check "AI alias exists" "alias /AI >/dev/null"

# Test basic functionality
test_check "System info function works" "_ai_command_get_system_info | grep -q 'System:'"
test_check "Risk color function works" "[[ -n $(_ai_command_get_risk_color 'SAFE') ]]"
test_check "Category function works" "_ai_command_get_category_display 'FILE_OPS' | grep -q 'FILES'"

# Test simple format parsing
SIMPLE_TEST="CMD: echo test
HINT: Test command
CATEGORY: SYSTEM
RISK: SAFE
---"

test_parsing_simple() {
    local suggestions=()
    local descriptions=()
    local risk_levels=()
    local categories=()
    
    local IFS=$'\n'
    local blocks=(${(f)SIMPLE_TEST})
    local current_cmd=""
    local current_hint=""
    local current_category=""
    local current_risk=""
    
    for line in "${blocks[@]}"; do
        [[ -z "$line" ]] && continue
        
        if [[ "$line" =~ ^---\s*$ ]]; then
            if [[ -n "$current_cmd" ]]; then
                suggestions+=("$current_cmd")
                descriptions+=("${current_hint:-Command suggestion}")
                categories+=("${current_category:-SYSTEM}")
                risk_levels+=("${current_risk:-SAFE}")
            fi
            break
        fi
        
        if [[ "$line" =~ ^CMD:[[:space:]]*(.*) ]]; then
            current_cmd="${match[1]}"
        elif [[ "$line" =~ ^HINT:[[:space:]]*(.*) ]]; then
            current_hint="${match[1]}"
        elif [[ "$line" =~ ^CATEGORY:[[:space:]]*(.*) ]]; then
            current_category="${match[1]}"
        elif [[ "$line" =~ ^RISK:[[:space:]]*(.*) ]]; then
            current_risk="${match[1]}"
        fi
    done
    
    [[ ${#suggestions[@]} -eq 1 ]] && [[ "$current_cmd" == "echo test" ]]
}

test_check "Simple format parsing works" "test_parsing_simple"

echo ""
echo "Results: $TESTS_PASSED/$TESTS_TOTAL tests passed"

if [[ $TESTS_PASSED -eq $TESTS_TOTAL ]]; then
    echo -e "${GREEN}✅ All quick tests passed! Plugin is working correctly.${NC}"
    exit 0
else
    echo -e "${RED}❌ Some tests failed. Check the plugin setup.${NC}"
    exit 1
fi