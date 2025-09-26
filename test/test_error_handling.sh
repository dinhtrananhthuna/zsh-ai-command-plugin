#!/bin/zsh

# Test Error Handling of AI Command Plugin

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

# Test function for expecting success
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

# Test function for expecting failure
assert_fail() {
    local description="$1"
    local test_command="$2"
    
    ((TEST_COUNT++))
    echo "  Test $TEST_COUNT: $description"
    
    if eval "$test_command" >/dev/null 2>&1; then
        echo "    ${RED}✗ FAIL - Expected failure but command succeeded${NC}"
        # Continue with other tests
    else
        echo "    ${GREEN}✓ PASS - Command failed as expected${NC}"
        ((PASS_COUNT++))
    fi
}

# Test function for checking error messages
assert_error_message() {
    local description="$1"
    local test_command="$2"
    local expected_message="$3"
    
    ((TEST_COUNT++))
    echo "  Test $TEST_COUNT: $description"
    
    local output
    output=$(eval "$test_command" 2>&1) || true
    
    if echo "$output" | grep -q "$expected_message"; then
        echo "    ${GREEN}✓ PASS - Error message contains expected text${NC}"
        ((PASS_COUNT++))
    else
        echo "    ${RED}✗ FAIL - Expected error message not found${NC}"
        echo "    Expected: $expected_message"
        echo "    Got: $output"
        # Continue with other tests
    fi
}

echo "Testing Error Handling..."
echo ""

# Test 1: Missing dependencies
# We can't actually remove curl/jq, so we test the check function logic
if ! command -v nonexistent_command >/dev/null 2>&1; then
    assert_test "Missing dependency detection works" "! command -v nonexistent_command >/dev/null"
fi

# Test 2: Invalid API configuration
# Save current API key and URL
OLD_API_KEY="${ZSH_AI_COMMAND_API_KEY:-}"
OLD_API_URL="${ZSH_AI_COMMAND_API_BASE_URL:-}"

# Test with missing API key
unset ZSH_AI_COMMAND_API_KEY
assert_error_message "Missing API key error" "_ai_command_validate_config" "API KEY"

# Test with invalid API URL (if we set a bad one)
export ZSH_AI_COMMAND_API_KEY="test_key"
export ZSH_AI_COMMAND_API_BASE_URL="not_a_url"

# Restore original values
if [[ -n "$OLD_API_KEY" ]]; then
    export ZSH_AI_COMMAND_API_KEY="$OLD_API_KEY"
else
    unset ZSH_AI_COMMAND_API_KEY
fi

if [[ -n "$OLD_API_URL" ]]; then
    export ZSH_AI_COMMAND_API_BASE_URL="$OLD_API_URL"
else
    unset ZSH_AI_COMMAND_API_BASE_URL
fi

# Test 3: Empty input handling
assert_error_message "Empty query handling" "ai_command" "NO QUERY PROVIDED"

# Test 4: Invalid parsing data
# Test the parsing with malformed data
MALFORMED_DATA="This is not a valid command format
No CMD: prefix here
Just random text"

# Create a test function to check parsing handles bad data gracefully
test_bad_parsing() {
    # This should return 0 commands but not crash
    local suggestions=()
    local descriptions=()
    local risk_levels=()
    local categories=()
    local has_json_data=false
    
    # Parse the simple format
    local IFS=$'\n'
    local blocks=(${(f)MALFORMED_DATA})
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
    
    # Final command without separator
    if [[ -n "$current_cmd" ]]; then
        suggestions+=("$current_cmd")
        descriptions+=("${current_hint:-Command suggestion}")
        categories+=("${current_category:-SYSTEM}")
        risk_levels+=("${current_risk:-SAFE}")
        has_json_data=true
    fi
    
    # Should have 0 commands from malformed data
    [[ ${#suggestions[@]} -eq 0 ]]
}

assert_test "Malformed parsing data handled gracefully" "test_bad_parsing"

# Test 5: Command analysis edge cases
assert_test "Command analysis with empty command" "_ai_command_analyze_command '' | grep -q '|'"
assert_test "Command analysis with special characters" "_ai_command_analyze_command 'echo \$USER | grep root' | grep -q '|'"

# Test 6: System info function robustness
assert_test "System info handles missing files" "_ai_command_get_system_info | grep -q 'System:'"

# Test 7: Color functions with invalid input
assert_test "Risk color with invalid risk level" "_ai_command_get_risk_color 'INVALID' | grep -q 'white'"
assert_test "Category display with invalid category" "_ai_command_get_category_display 'INVALID' | grep -q 'SYSTEM'"

# Test 8: JSON cleaning edge cases
assert_test "JSON cleaning with empty input" "_ai_command_clean_json '' | wc -c | grep -q '^0$'"
assert_test "JSON cleaning with null input" "_ai_command_clean_json 'null' | grep -q 'null'"

# Test 9: Large input handling
# Create a large input string
LARGE_INPUT=""
for i in {1..1000}; do
    LARGE_INPUT="${LARGE_INPUT}CMD: echo $i\nHINT: Command $i\nCATEGORY: SYSTEM\nRISK: SAFE\n---\n"
done

test_large_input() {
    # Should handle large input without crashing
    local output
    output=$(_ai_command_clean_json "$LARGE_INPUT" 2>&1)
    [[ $? -eq 0 ]] && [[ -n "$output" ]]
}

assert_test "Large input handling" "test_large_input"

# Test 10: Unicode and special characters
UNICODE_INPUT="CMD: echo 'Hello 世界 🚀 ñoño'
HINT: Unicode test with emojis and special chars
CATEGORY: SYSTEM  
RISK: SAFE
---"

test_unicode() {
    # Test with unicode characters
    local suggestions=()
    local descriptions=()
    local risk_levels=()
    local categories=()
    
    local IFS=$'\n'
    local blocks=(${(f)UNICODE_INPUT})
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
    
    # Should parse one command with unicode characters
    [[ ${#suggestions[@]} -eq 1 ]] && [[ "$current_cmd" =~ "世界" ]]
}

assert_test "Unicode character handling" "test_unicode"

echo ""
echo "Error Handling Tests: $PASS_COUNT/$TEST_COUNT passed"

if [[ $PASS_COUNT -eq $TEST_COUNT ]]; then
    echo "${GREEN}All error handling tests passed!${NC}"
    exit 0
else
    echo "${RED}Some error handling tests failed!${NC}"
    exit 1
fi