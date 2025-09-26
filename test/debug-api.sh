#!/bin/zsh

# Debug script to test API connection
echo "🔍 AI Command Plugin - API Debug Tool"
echo "====================================="

# Check if plugin is loaded
if ! command -v ai_command >/dev/null 2>&1; then
    echo "Loading plugin..."
    source ./ai-command.plugin.zsh
fi

echo
echo "📋 Configuration Check:"
echo "======================"
echo "API Base URL: ${ZSH_AI_COMMAND_API_BASE_URL:-'Not set'}"
echo "Model: ${ZSH_AI_COMMAND_MODEL:-'Not set'}"
echo "Max Tokens: ${ZSH_AI_COMMAND_MAX_TOKENS:-'Not set'}"
echo "Temperature: ${ZSH_AI_COMMAND_TEMPERATURE:-'Not set'}"

if [[ -n "$ZSH_AI_COMMAND_API_KEY" ]]; then
    echo "API Key: Set (${#ZSH_AI_COMMAND_API_KEY} characters)"
else
    echo "API Key: ❌ NOT SET"
    echo
    echo "Please set your API key first:"
    echo "export ZSH_AI_COMMAND_API_KEY='your-api-key-here'"
    exit 1
fi

echo
echo "🌐 Testing API Connection:"
echo "========================="

# Test basic connectivity to the API endpoint
api_host=$(echo "$ZSH_AI_COMMAND_API_BASE_URL" | sed 's|https\?://||' | cut -d'/' -f1)
echo "Testing connectivity to $api_host..."

if ping -c 1 -W 3 "$api_host" >/dev/null 2>&1; then
    echo "✅ Network connectivity OK"
else
    echo "❌ Network connectivity issue - cannot reach $api_host"
fi

# Test HTTP response
echo "Testing HTTP response from API endpoint..."
http_status=$(curl -s -o /dev/null -w "%{http_code}" "$ZSH_AI_COMMAND_API_BASE_URL/")
echo "HTTP Status from base URL: $http_status"

echo
echo "🧪 Testing API Call with Debug Mode:"
echo "==================================="
export ZSH_AI_COMMAND_DEBUG=1

echo "Running: /AI test connection"
/AI test connection

echo
echo "💡 Common Issues and Solutions:"
echo "=============================="
echo "1. 'No valid response from API':"
echo "   - Check your API key is valid"
echo "   - Verify the API base URL is correct"
echo "   - Ensure the model name exists"
echo
echo "2. 'Authentication failed':"
echo "   - Double-check your API key"
echo "   - Make sure the key has proper permissions"
echo
echo "3. 'Model not found':"
echo "   - Verify the model name is correct for your API provider"
echo "   - Check if the model is available in your account"
echo
echo "4. For Digital Ocean users:"
echo "   - Make sure your endpoint URL ends with /v1"
echo "   - Verify your model name matches your deployment"
echo
echo "🔧 Quick fixes to try:"
echo "====================="
echo "# For OpenAI (default):"
echo "export ZSH_AI_COMMAND_API_BASE_URL='https://api.openai.com/v1'"
echo "export ZSH_AI_COMMAND_MODEL='gpt-3.5-turbo'"
echo
echo "# For Digital Ocean:"
echo "export ZSH_AI_COMMAND_API_BASE_URL='https://your-endpoint.digitalocean.com/v1'"
echo "export ZSH_AI_COMMAND_MODEL='your-model-name'"