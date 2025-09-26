#!/bin/zsh

# Test script for complex AI command scenarios
echo "🧪 Testing Complex AI Commands"
echo "==============================="
echo

# Check if plugin is loaded
if ! command -v ai_command >/dev/null 2>&1; then
    echo "Loading plugin..."
    source ./ai-command.plugin.zsh
fi

# Check if API key is set
if [[ -z "$ZSH_AI_COMMAND_API_KEY" ]]; then
    echo "❌ API key not set. Please set ZSH_AI_COMMAND_API_KEY and try again."
    exit 1
fi

echo "✅ Plugin loaded and API key configured"
echo

# Test cases for complex commands
declare -A test_cases
test_cases=(
    ["check process on port 3000"]="Complex port checking command"
    ["kill process running on port 3000"]="Complex port killing command"
    ["clean up cache and temp files"]="Complex cleanup command"
    ["find all files larger than 100MB and delete them"]="Complex file management"
    ["show disk usage and clean up old log files"]="Complex system maintenance"
    ["backup current directory with timestamp"]="Complex backup command"
    ["find running Docker containers and stop them all"]="Complex Docker management"
    ["check system memory usage and kill high memory processes"]="Complex process management"
    ["update system and clean package cache"]="Complex package management"
    ["find duplicate files in home directory"]="Complex file search"
)

echo "🚀 Running complex command tests..."
echo

for query description in "${(@kv)test_cases}"; do
    echo "Test: $description"
    echo "Query: '$query'"
    echo "Running with debug mode..."
    echo "----------------------------------------"
    
    # Enable debug mode for testing
    export ZSH_AI_COMMAND_DEBUG=1
    
    # Run the command (but don't execute it automatically)
    echo "Result:"
    timeout 30s /AI "$query" || echo "Command timed out or failed"
    
    echo
    echo "========================================"
    echo
    
    # Disable debug for cleaner output between tests
    unset ZSH_AI_COMMAND_DEBUG
    
    # Brief pause between tests
    sleep 1
done

echo "🎉 Complex command testing completed!"
echo
echo "Summary of improvements made:"
echo "- Fixed debug output mixing with command suggestions"
echo "- Increased default token limit from 150 to 300"
echo "- Enhanced system prompt with specific complex command examples"
echo "- Improved response parsing for multi-line commands"
echo "- Added better error handling and output separation"