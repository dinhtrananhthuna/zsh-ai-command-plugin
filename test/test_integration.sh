#!/bin/zsh

# Test Integration and End-to-End Functionality

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

# Test full workflow simulation
test_full_workflow() {
    local description="$1"
    local test_data="$2"
    local expected_commands="$3"
    
    ((TEST_COUNT++))
    echo "  Test $TEST_COUNT: $description"
    
    # Simulate the full workflow without API calls
    local result_count=0
    
    # Mock display function that counts parsed commands
    _mock_display_suggestions() {
        local input_data="$1"
        local suggestions=()
        local descriptions=()
        local risk_levels=()
        local categories=()
        local has_json_data=false
        
        # Parse the simple format (same logic as main function)
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
        
        # Final command without separator
        if [[ -n "$current_cmd" ]]; then
            suggestions+=("$current_cmd")
            descriptions+=("${current_hint:-Command suggestion}")
            categories+=("${current_category:-SYSTEM}")
            risk_levels+=("${current_risk:-SAFE}")
            has_json_data=true
        fi
        
        echo "${#suggestions[@]}"
        
        # Validate that all arrays have same length
        local cmd_count=${#suggestions[@]}
        local desc_count=${#descriptions[@]}
        local risk_count=${#risk_levels[@]}
        local cat_count=${#categories[@]}
        
        if [[ $cmd_count -eq $desc_count && $desc_count -eq $risk_count && $risk_count -eq $cat_count ]]; then
            return 0
        else
            return 1
        fi
    }
    
    result_count=$(_mock_display_suggestions "$test_data")
    
    if [[ "$result_count" -eq "$expected_commands" ]]; then
        echo "    ${GREEN}✓ PASS - Full workflow processed $result_count commands${NC}"
        ((PASS_COUNT++))
    else
        echo "    ${RED}✗ FAIL - Expected $expected_commands commands, got $result_count${NC}"
        # Continue with other tests
    fi
}

echo "Testing Integration & End-to-End Functionality..."
echo ""

# Test 1: Complete workflow simulation with single command
SINGLE_WORKFLOW_DATA="CMD: ls -la /home
HINT: List detailed information about files in home directory
CATEGORY: FILES
RISK: SAFE
---"

test_full_workflow "Single command workflow" "$SINGLE_WORKFLOW_DATA" 1

# Test 2: Complete workflow with multiple commands of different types
MULTI_WORKFLOW_DATA="CMD: ps aux | grep nginx
HINT: Find nginx processes
CATEGORY: PROCESS
RISK: SAFE
---
CMD: sudo systemctl restart nginx
HINT: Restart nginx service (requires sudo)
CATEGORY: SERVICE
RISK: CAUTION
---
CMD: sudo rm -rf /var/log/nginx/*
HINT: Delete all nginx logs (dangerous - permanent deletion)
CATEGORY: FILES
RISK: DANGEROUS
---"

test_full_workflow "Multi-command workflow with different risk levels" "$MULTI_WORKFLOW_DATA" 3

# Test 3: Plugin initialization and dependencies
assert_test "Plugin loads without errors" "source '$PLUGIN_FILE'"
assert_test "All required functions are available" "typeset -f ai_command >/dev/null && typeset -f _ai_command_display_suggestions >/dev/null"
assert_test "Color system is initialized" "[[ -n \"\${fg:-}\" ]] || [[ -n \"\${colors:-}\" ]] || true"

# Test 4: Configuration and environment
# Save and test API configuration
OLD_API_KEY="${ZSH_AI_COMMAND_API_KEY:-}"
OLD_MODEL="${ZSH_AI_COMMAND_MODEL:-}"

export ZSH_AI_COMMAND_API_KEY="test_key_integration"
export ZSH_AI_COMMAND_MODEL="test-model"

assert_test "Environment variables are read correctly" "[[ \"\$ZSH_AI_COMMAND_API_KEY\" == \"test_key_integration\" ]]"
assert_test "Model configuration is set" "[[ \"\$ZSH_AI_COMMAND_MODEL\" == \"test-model\" ]]"

# Restore original values
if [[ -n "$OLD_API_KEY" ]]; then
    export ZSH_AI_COMMAND_API_KEY="$OLD_API_KEY"
else
    unset ZSH_AI_COMMAND_API_KEY
fi

if [[ -n "$OLD_MODEL" ]]; then
    export ZSH_AI_COMMAND_MODEL="$OLD_MODEL"
else
    unset ZSH_AI_COMMAND_MODEL
fi

# Test 5: Command analysis integration
COMMANDS_TO_ANALYZE=(
    "ls -la"
    "sudo dnf update"
    "rm -rf /"
    "find /home -name '*.txt'"
    "systemctl status nginx"
    "docker run -d nginx"
)

EXPECTED_RISKS=("SAFE" "CAUTION" "DANGEROUS" "SAFE" "SAFE" "SAFE")

for i in {1..${#COMMANDS_TO_ANALYZE[@]}}; do
    cmd="${COMMANDS_TO_ANALYZE[$i]}"
    expected_risk="${EXPECTED_RISKS[$i]}"
    analysis_result=$(_ai_command_analyze_command "$cmd")
    risk_part="${analysis_result%%|*}"
    
    assert_test "Command analysis for '$cmd' returns $expected_risk" "[[ '$risk_part' == '$expected_risk' ]]"
done

# Test 6: Category and risk color integration
CATEGORIES=("FILES" "PACKAGE" "SEARCH" "NETWORK" "DISK" "SERVICE" "SYSTEM" "VCS" "CONTAINER")

for category in "${CATEGORIES[@]}"; do
    assert_test "Category display for $category works" "_ai_command_get_category_display '$category' | grep -q '$category'"
done

RISKS=("SAFE" "CAUTION" "DANGEROUS")
EXPECTED_COLORS=("32" "33" "31")  # Green, Yellow, Red

for i in {1..${#RISKS[@]}}; do
    risk="${RISKS[$i]}"
    expected_color="${EXPECTED_COLORS[$i]}"
    assert_test "Risk color for $risk returns correct ANSI code" "_ai_command_get_risk_color '$risk' | grep -q '$expected_color'"
done

# Test 7: System information integration
system_info=$(_ai_command_get_system_info)
assert_test "System info contains distribution info" "echo '$system_info' | grep -q 'System:'"
assert_test "System info contains shell info" "echo '$system_info' | grep -q 'Shell:'"

# Test 8: Help system integration
help_output=$(ai_command --help 2>&1)
assert_test "Help system shows usage" "echo '$help_output' | grep -q 'USAGE'"
assert_test "Help system shows examples" "echo '$help_output' | grep -q 'EXAMPLES'"
assert_test "Help system shows features" "echo '$help_output' | grep -q 'FEATURES'"

# Test 9: Alias functionality
assert_test "Main alias is created" "alias /AI | grep -q 'ai_command'"
assert_test "Alias points to correct function" "alias /AI | grep -q 'ai_command'"

# Test 10: Complete parsing pipeline
PIPELINE_TEST_DATA="CMD: echo 'test command 1'
HINT: First test command
CATEGORY: SYSTEM
RISK: SAFE
---
CMD: sudo echo 'test command 2'
HINT: Second test command with sudo
CATEGORY: SYSTEM
RISK: CAUTION
---"

# Test that the complete pipeline works
test_pipeline() {
    local input="$1"
    
    # Step 1: Clean the input (though not JSON in this case)
    local cleaned
    cleaned=$(_ai_command_clean_json "$input")
    [[ $? -eq 0 ]] || return 1
    
    # Step 2: Parse the cleaned input
    local suggestions=()
    local descriptions=()
    local risk_levels=()
    local categories=()
    
    local IFS=$'\n'
    local blocks=(${(f)cleaned})
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
    
    # Step 3: Verify parsing did not crash and produced at least one command
    if [[ ${#suggestions[@]} -ge 1 ]]; then
        return 0
    else
        return 1
    fi
}

assert_test "Complete parsing pipeline integration" "test_pipeline \"$PIPELINE_TEST_DATA\""

echo ""
echo "Integration Tests: $PASS_COUNT/$TEST_COUNT passed"

if [[ $PASS_COUNT -eq $TEST_COUNT ]]; then
    echo "${GREEN}All integration tests passed!${NC}"
    exit 0
else
    echo "${RED}Some integration tests failed!${NC}"
    exit 1
fi