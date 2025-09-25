#!/bin/zsh

# AI Command Plugin for Oh My Zsh
# Allows users to get AI-generated command suggestions using natural language

# Default configuration
export ZSH_AI_COMMAND_API_BASE_URL="${ZSH_AI_COMMAND_API_BASE_URL:-https://api.openai.com/v1}"
export ZSH_AI_COMMAND_MODEL="${ZSH_AI_COMMAND_MODEL:-gpt-3.5-turbo}"
export ZSH_AI_COMMAND_MAX_TOKENS="${ZSH_AI_COMMAND_MAX_TOKENS:-150}"
export ZSH_AI_COMMAND_TEMPERATURE="${ZSH_AI_COMMAND_TEMPERATURE:-0.3}"

# Colors for output
if [[ -n "$ZSH_VERSION" ]]; then
    autoload -U colors && colors
fi

# Function to check if required dependencies are available
_ai_command_check_dependencies() {
    if ! command -v curl >/dev/null 2>&1; then
        echo "${fg[red]}Error: curl is required but not installed.${reset_color}"
        return 1
    fi
    
    if ! command -v jq >/dev/null 2>&1; then
        echo "${fg[red]}Error: jq is required but not installed. Please install jq to use this plugin.${reset_color}"
        return 1
    fi
    
    return 0
}

# Function to validate configuration
_ai_command_validate_config() {
    if [[ -z "$ZSH_AI_COMMAND_API_KEY" ]]; then
        echo "${fg[red]}Error: ZSH_AI_COMMAND_API_KEY is not set.${reset_color}"
        echo "${fg[yellow]}Please set your OpenAI API key:${reset_color}"
        echo "export ZSH_AI_COMMAND_API_KEY='your-api-key-here'"
        return 1
    fi
    
    return 0
}

# Function to get system information for better AI context
_ai_command_get_system_info() {
    local os_info="Linux"
    local distro="Unknown"
    local shell_info="$SHELL"
    
    # Detect distribution
    if [[ -f /etc/fedora-release ]]; then
        distro="Fedora $(cat /etc/fedora-release | grep -oE '[0-9]+' | head -1)"
    elif [[ -f /etc/os-release ]]; then
        distro=$(grep '^PRETTY_NAME=' /etc/os-release | cut -d'"' -f2)
    fi
    
    echo "System: $distro, Shell: $shell_info"
}

# Function to make API call to OpenAI
_ai_command_call_api() {
    local query="$1"
    local system_info=$(_ai_command_get_system_info)
    local system_prompt="You are a helpful assistant that converts natural language requests into terminal commands for Fedora Linux systems using zsh shell.

SYSTEM INFO: $system_info

IMPORTANT GUIDELINES:
- Respond with ONLY the command(s), no explanation or markdown formatting
- Use Fedora-specific commands: dnf (not apt/yum), systemctl, firewall-cmd, rpm, etc.
- Use zsh-compatible syntax and features where beneficial
- For package management: use 'sudo dnf install', 'sudo dnf remove', 'sudo dnf update'
- For services: use 'sudo systemctl start/stop/restart/enable/disable'
- For firewall: use 'sudo firewall-cmd'
- If multiple commands are needed, separate them with newlines
- Be concise and accurate for Fedora Linux environment"
    
    # Create JSON payload using jq for proper escaping
    local json_payload=$(jq -n \
        --arg model "$ZSH_AI_COMMAND_MODEL" \
        --arg system_content "$system_prompt" \
        --arg user_content "$query" \
        --argjson max_tokens "$ZSH_AI_COMMAND_MAX_TOKENS" \
        --argjson temperature "$ZSH_AI_COMMAND_TEMPERATURE" \
        '{
            "model": $model,
            "messages": [
                {
                    "role": "system",
                    "content": $system_content
                },
                {
                    "role": "user",
                    "content": $user_content
                }
            ],
            "max_tokens": $max_tokens,
            "temperature": $temperature
        }')
    
    # Debug mode - show request details if enabled
    if [[ -n "$ZSH_AI_COMMAND_DEBUG" ]]; then
        echo "${fg[blue]}DEBUG: API Request Details:${reset_color}"
        echo "URL: $ZSH_AI_COMMAND_API_BASE_URL/chat/completions"
        echo "Model: $ZSH_AI_COMMAND_MODEL"
        echo "Query: $query"
        echo "${fg[blue]}DEBUG: JSON Payload:${reset_color}"
        echo "$json_payload" | jq . 2>/dev/null || echo "$json_payload"
        echo
    fi
    
    local response=$(curl -s --max-time 30 -H "Content-Type: application/json" \
                          -H "Authorization: Bearer $ZSH_AI_COMMAND_API_KEY" \
                          -d "$json_payload" \
                          "$ZSH_AI_COMMAND_API_BASE_URL/chat/completions")
    
    local curl_exit_code=$?
    if [[ $curl_exit_code -ne 0 ]]; then
        echo "${fg[red]}Error: Failed to connect to API (curl exit code: $curl_exit_code)${reset_color}"
        return 1
    fi
    
    # Check if response is empty
    if [[ -z "$response" ]]; then
        echo "${fg[red]}Error: Empty response from API${reset_color}"
        return 1
    fi
    
    # Check for API errors
    local error_message=$(echo "$response" | jq -r '.error.message // empty' 2>/dev/null)
    if [[ -n "$error_message" ]]; then
        echo "${fg[red]}API Error: $error_message${reset_color}"
        return 1
    fi
    
    # Debug mode - show raw response if enabled
    if [[ -n "$ZSH_AI_COMMAND_DEBUG" ]]; then
        echo "${fg[blue]}DEBUG: Raw API Response:${reset_color}"
        echo "$response" | jq . 2>/dev/null || echo "$response"
        echo "${fg[blue]}DEBUG: End of response${reset_color}"
        echo
    fi
    
    # Extract the command from the response - be more robust with parsing
    local command=""
    if echo "$response" | jq -e '.choices[0].message.content' >/dev/null 2>&1; then
        command=$(echo "$response" | jq -r '.choices[0].message.content' 2>/dev/null)
        
        # Clean up the command - remove code blocks and trim whitespace
        if [[ -n "$command" && "$command" != "null" ]]; then
            # Remove markdown code blocks if present
            command=$(echo "$command" | sed 's/^```[a-z]*\s*//g' | sed 's/```$//g')
            # Remove leading/trailing whitespace but preserve internal structure
            command=$(echo "$command" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        fi
    fi
    
    # Debug the extracted command
    if [[ -n "$ZSH_AI_COMMAND_DEBUG" ]]; then
        echo "${fg[blue]}DEBUG: Extracted command: '$command'${reset_color}"
        echo
    fi
    
    if [[ -z "$command" || "$command" == "null" ]]; then
        echo "${fg[red]}Error: No valid response from API${reset_color}"
        if [[ -z "$ZSH_AI_COMMAND_DEBUG" ]]; then
            echo "${fg[yellow]}Tip: Enable debug mode to see the raw response:${reset_color}"
            echo "${fg[cyan]}export ZSH_AI_COMMAND_DEBUG=1${reset_color}"
        fi
        return 1
    fi
    
    echo "$command"
    return 0
}

# Function to display command suggestions with selection
_ai_command_display_suggestions() {
    local suggestions=("${(@f)1}")  # Split by newlines
    local selected_index=1
    
    if [[ ${#suggestions[@]} -eq 1 ]]; then
        # Single command, ask for confirmation
        echo "${fg[green]}AI suggests:${reset_color}"
        echo "  ${fg[cyan]}${suggestions[1]}${reset_color}"
        echo ""
        echo "Press ${fg[yellow]}Enter${reset_color} to execute, ${fg[yellow]}Ctrl+C${reset_color} to cancel, or ${fg[yellow]}e${reset_color} to edit:"
        
        read -k1 choice
        case $choice in
            $'\n'|$'\r')  # Enter key
                echo ""
                eval "${suggestions[1]}"
                ;;
            'e'|'E')
                echo ""
                print -z "${suggestions[1]}"
                ;;
            *)
                echo ""
                echo "${fg[yellow]}Cancelled${reset_color}"
                ;;
        esac
    else
        # Multiple commands, show selection menu
        echo "${fg[green]}AI suggests multiple options:${reset_color}"
        for i in {1..${#suggestions[@]}}; do
            if [[ $i -eq $selected_index ]]; then
                echo "  ${fg[yellow]}► $i) ${suggestions[$i]}${reset_color}"
            else
                echo "    $i) ${fg[cyan]}${suggestions[$i]}${reset_color}"
            fi
        done
        echo ""
        echo "Use ${fg[yellow]}↑↓${reset_color} to navigate, ${fg[yellow]}Enter${reset_color} to execute, ${fg[yellow]}e${reset_color} to edit, ${fg[yellow]}Ctrl+C${reset_color} to cancel:"
        
        # Simple selection (for now, just ask for number)
        echo "Enter choice (1-${#suggestions[@]}):"
        read choice
        
        if [[ "$choice" =~ ^[0-9]+$ ]] && [[ $choice -ge 1 ]] && [[ $choice -le ${#suggestions[@]} ]]; then
            echo "Executing: ${fg[cyan]}${suggestions[$choice]}${reset_color}"
            eval "${suggestions[$choice]}"
        else
            echo "${fg[yellow]}Invalid choice or cancelled${reset_color}"
        fi
    fi
}

# Main AI command function
ai_command() {
    # Check dependencies
    if ! _ai_command_check_dependencies; then
        return 1
    fi
    
    # Validate configuration
    if ! _ai_command_validate_config; then
        return 1
    fi
    
    local query="$*"
    
    if [[ -z "$query" ]]; then
        echo "${fg[yellow]}Usage: /AI <your natural language request>${reset_color}"
        echo "Example: /AI please give me command to stop the Docker engine"
        return 1
    fi
    
    echo "${fg[blue]}🤖 Thinking...${reset_color}"
    
    local suggestions=$(_ai_command_call_api "$query")
    
    if [[ $? -eq 0 && -n "$suggestions" ]]; then
        _ai_command_display_suggestions "$suggestions"
    else
        echo "${fg[red]}Failed to get AI suggestions${reset_color}"
        return 1
    fi
}

# Create alias for the slash command
# Note: The slash in alias name works in zsh but not bash
if [[ -n "$ZSH_VERSION" ]]; then
    alias '/AI'='ai_command'
else
    # Fallback for bash compatibility
    alias 'AI'='ai_command'
fi

# Auto-completion setup
_ai_command_completion() {
    local state
    _arguments \
        '*: :->query' && return 0
    
    case $state in
        query)
            _message 'natural language query'
            ;;
    esac
}

# Auto-completion only works in zsh
if [[ -n "$ZSH_VERSION" ]] && command -v compdef >/dev/null 2>&1; then
    compdef _ai_command_completion ai_command
    compdef _ai_command_completion '/AI'
fi

# Plugin initialization message
if [[ -n "$ZSH_AI_COMMAND_API_KEY" ]]; then
    echo "${fg[green]}✓ AI Command plugin loaded successfully!${reset_color}"
    echo "  Usage: ${fg[cyan]}/AI <your request>${reset_color}"
else
    echo "${fg[yellow]}⚠ AI Command plugin loaded but API key not set${reset_color}"
    echo "  Set your API key: ${fg[cyan]}export ZSH_AI_COMMAND_API_KEY='your-key'${reset_color}"
fi