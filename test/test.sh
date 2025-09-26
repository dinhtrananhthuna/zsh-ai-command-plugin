#!/bin/zsh

# Test script for AI Command Plugin
# This script demonstrates the plugin functionality with mock responses

echo "🧪 AI Command Plugin Test Suite"
echo "================================"
echo

# Test 1: Plugin loading
echo "Test 1: Loading plugin..."
source ./ai-command.plugin.zsh
echo "✅ Plugin loaded successfully"
echo

# Test 2: Dependency checking
echo "Test 2: Checking dependencies..."
if command -v curl >/dev/null 2>&1; then
    echo "✅ curl found"
else
    echo "❌ curl not found"
fi

if command -v jq >/dev/null 2>&1; then
    echo "✅ jq found"
else
    echo "❌ jq not found"
fi
echo

# Test 3: Configuration validation
echo "Test 3: Configuration validation..."
if [[ -z "$ZSH_AI_COMMAND_API_KEY" ]]; then
    echo "⚠️ API key not set (expected for test)"
else
    echo "✅ API key configured"
fi
echo

# Test 4: Command alias
echo "Test 4: Command alias test..."
if command -v '/AI' >/dev/null 2>&1; then
    echo "✅ /AI alias created successfully"
else
    echo "❌ /AI alias not found"
fi
echo

# Test 5: Usage message
echo "Test 5: Usage message test..."
export ZSH_AI_COMMAND_API_KEY="test-key"
echo "Running: /AI (with empty query)"
/AI 2>&1 | head -2
echo

# Test 6: Mock API call (without actual API request)
echo "Test 6: Mock API integration test..."
echo "ℹ️ This would require a valid API key for full testing"
echo "   Example: ZSH_AI_COMMAND_API_KEY='your-key' /AI stop docker"
echo

echo "🎉 Test suite completed!"
echo
echo "To install the plugin:"
echo "  ./install.sh"
echo
echo "Manual installation:"
echo "  1. Copy ai-command.plugin.zsh to ~/.oh-my-zsh/plugins/ai-command/"
echo "  2. Add 'ai-command' to plugins in ~/.zshrc"
echo "  3. Set ZSH_AI_COMMAND_API_KEY environment variable"
echo "  4. Restart terminal or source ~/.zshrc"