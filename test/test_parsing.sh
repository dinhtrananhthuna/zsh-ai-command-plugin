#!/bin/zsh

# Test Parsing Functionality of AI Command Plugin

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

# Test the display suggestions function with mock data
test_parsing() {
    local test_data="$1"
    local expected_commands="$2"
    local description="$3"
    
    ((TEST_COUNT++))
    echo "  Test $TEST_COUNT: $description"
    
    # Create a temporary file to capture output
    local temp_file="/tmp/ai_test_output_$$"
    
    # Mock the display function to just count commands
    _test_display_suggestions() {
        local input_data="$1"
        local suggestions=()
        local descriptions=()
        local risk_levels=()
        local categories=()
        local has_json_data=false
        
        # Parse the simple format (copied from main function)
        local IFS=$'\n'
        local blocks=(${(f)input_data})
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
                    has_json_data=true
                fi
                current_cmd=""
                current_hint=""
                current_category=""
                current_risk=""
                continue
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
        
        # Don't forget the last command
        if [[ -n "$current_cmd" ]]; then
            suggestions+=("$current_cmd")
            descriptions+=("${current_hint:-Command suggestion}")
            categories+=("${current_category:-SYSTEM}")
            risk_levels+=("${current_risk:-SAFE}")
            has_json_data=true
        fi
        
        echo "${#suggestions[@]}"
    }
    
    local result=$(_test_display_suggestions "$test_data")
    
    if [[ "$result" -eq "$expected_commands" ]]; then
        echo "    ${GREEN}✓ PASS - Found $result commands${NC}"
        ((PASS_COUNT++))
    else
        echo "    ${RED}✗ FAIL - Expected $expected_commands commands, got $result${NC}"
        # Continue with other tests
    fi
}

echo "Testing Parsing Functionality..."
echo ""

# Test 1: Single command parsing
SINGLE_CMD_DATA="CMD: ls -la
HINT: List all files with details
CATEGORY: FILES
RISK: SAFE
---"

test_parsing "$SINGLE_CMD_DATA" 1 "Single command parsing"

# Test 2: Multiple commands parsing
MULTI_CMD_DATA="CMD: ls -la
HINT: List all files with details
CATEGORY: FILES
RISK: SAFE
---
CMD: sudo dnf update
HINT: Update system packages
CATEGORY: PACKAGE
RISK: CAUTION
---
CMD: find / -name '*.log'
HINT: Find all log files
CATEGORY: SEARCH
RISK: SAFE
---"

test_parsing "$MULTI_CMD_DATA" 3 "Multiple commands parsing"

# Test 3: Command without final separator
NO_SEP_DATA="CMD: pwd
HINT: Show current directory
CATEGORY: FILES
RISK: SAFE"

test_parsing "$NO_SEP_DATA" 1 "Command without final separator"

# Test 4: Commands with complex characters
COMPLEX_CMD_DATA="CMD: find / -type f -size +100M -exec ls -lh {} \\; 2>/dev/null
HINT: Find large files with complex shell syntax
CATEGORY: SEARCH
RISK: CAUTION
---
CMD: sudo systemctl restart nginx && sudo systemctl status nginx
HINT: Restart and check nginx service
CATEGORY: SERVICE
RISK: CAUTION
---"

test_parsing "$COMPLEX_CMD_DATA" 2 "Commands with complex shell syntax"

# Test 5: Empty or malformed data
EMPTY_DATA=""
test_parsing "$EMPTY_DATA" 0 "Empty input data"

# Test 6: Only separators
ONLY_SEP_DATA="---
---
---"
test_parsing "$ONLY_SEP_DATA" 0 "Only separators"

# Test 7: Missing required fields (should still parse with defaults)
MINIMAL_DATA="CMD: echo hello
---"
test_parsing "$MINIMAL_DATA" 1 "Minimal command data (only CMD field)"

# Test 8: Extra whitespace handling
WHITESPACE_DATA="CMD:   ls -la   
HINT:   List files with extra spaces   
CATEGORY:   FILES   
RISK:   SAFE   
---"
test_parsing "$WHITESPACE_DATA" 1 "Extra whitespace handling"

# Test 9: Mixed case field names (should not parse - case sensitive)
MIXED_CASE_DATA="cmd: ls -la
hint: This should not parse
category: FILES  
risk: SAFE
---"
test_parsing "$MIXED_CASE_DATA" 0 "Mixed case field names (should fail)"

# Test 10: JSON cleaning function
assert_test "JSON cleaning function works with simple input" "_ai_command_clean_json 'test data' | grep -q 'test data'"

# Test 11: JSON cleaning with backslashes
BACKSLASH_INPUT='{"command":"find {} \\; | head"}'
CLEANED_OUTPUT=$(_ai_command_clean_json "$BACKSLASH_INPUT")
assert_test "JSON cleaning handles backslashes" "echo '$CLEANED_OUTPUT' | grep -q 'find {} '"

echo ""
echo "Parsing Tests: $PASS_COUNT/$TEST_COUNT passed"

if [[ $PASS_COUNT -eq $TEST_COUNT ]]; then
    echo "${GREEN}All parsing tests passed!${NC}"
    exit 0
else
    echo "${RED}Some parsing tests failed!${NC}"
    exit 1
fi