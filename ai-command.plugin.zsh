#!/bin/zsh

# AI Command Plugin for Oh My Zsh
# Allows users to get AI-generated command suggestions using natural language

# Default configuration
export ZSH_AI_COMMAND_API_BASE_URL="${ZSH_AI_COMMAND_API_BASE_URL:-https://api.openai.com/v1}"
export ZSH_AI_COMMAND_MODEL="${ZSH_AI_COMMAND_MODEL:-gpt-3.5-turbo}"
export ZSH_AI_COMMAND_MAX_TOKENS="${ZSH_AI_COMMAND_MAX_TOKENS:-500}"
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

# Function to analyze command risk and provide categorization
_ai_command_analyze_command() {
    local command="$1"
    local risk_level="SAFE"
    local category="OTHER"
    local warning=""
    
    # Risk analysis based on command patterns
    if [[ "$command" =~ (rm -rf|rm -r|rmdir|shred|dd if=.*of=|mkfs|fdisk|parted|wipefs) ]]; then
        risk_level="DANGEROUS"
        warning="WARNING: DESTRUCTIVE - Can permanently delete files/data"
    elif [[ "$command" =~ (sudo|su -|chmod 777|chown|kill -9|pkill|killall|systemctl|firewall-cmd|iptables) ]]; then
        risk_level="CAUTION"
        warning="WARNING: Requires elevated privileges or affects system"
    elif [[ "$command" =~ (find.*-delete|find.*-exec.*rm) ]]; then
        risk_level="CAUTION"
        warning="WARNING: Will modify/delete files"
    fi
    
    # Category detection
    if [[ "$command" =~ (ls|find|grep|cat|less|head|tail|wc|locate) ]]; then
        category="FILE_SEARCH"
    elif [[ "$command" =~ (cp|mv|rm|mkdir|chmod|chown|tar|zip|unzip) ]]; then
        category="FILE_OPS"
    elif [[ "$command" =~ (ps|top|htop|kill|pkill|jobs|nohup) ]]; then
        category="PROCESS"
    elif [[ "$command" =~ (systemctl|service|systemd) ]]; then
        category="SERVICE"
    elif [[ "$command" =~ (dnf|rpm|yum|apt|snap|flatpak) ]]; then
        category="PACKAGE"
    elif [[ "$command" =~ (netstat|ss|lsof|ping|curl|wget|ssh|scp) ]]; then
        category="NETWORK"
    elif [[ "$command" =~ (df|du|mount|umount|lsblk|fdisk) ]]; then
        category="DISK"
    elif [[ "$command" =~ (docker|podman|kubectl) ]]; then
        category="CONTAINER"
    elif [[ "$command" =~ (git|svn|hg) ]]; then
        category="VCS"
    fi
    
    echo "${risk_level}|${category}|${warning}"
}

# Function to get category display
_ai_command_get_category_display() {
    local category="$1"
    case "$category" in
        "FILE_SEARCH") echo "${fg[cyan]}>>SEARCH<<${reset_color}" ;;
        "FILE_OPS") echo "${fg[cyan]}>>FILES<<${reset_color}" ;;
        "PROCESS") echo "${fg[cyan]}>>PROCESS<<${reset_color}" ;;
        "SERVICE") echo "${fg[cyan]}>>SERVICE<<${reset_color}" ;;
        "PACKAGE") echo "${fg[cyan]}>>PACKAGE<<${reset_color}" ;;
        "NETWORK") echo "${fg[cyan]}>>NETWORK<<${reset_color}" ;;
        "DISK") echo "${fg[cyan]}>>DISK<<${reset_color}" ;;
        "CONTAINER") echo "${fg[cyan]}>>CONTAINER<<${reset_color}" ;;
        "VCS") echo "${fg[cyan]}>>VCS<<${reset_color}" ;;
        *) echo "${fg[cyan]}>>SYSTEM<<${reset_color}" ;;
    esac
}

# Function to get risk level color
_ai_command_get_risk_color() {
    local risk_level="$1"
    case "$risk_level" in
        "SAFE") echo "${fg[green]}" ;;
        "CAUTION") echo "${fg[yellow]}" ;;
        "DANGEROUS") echo "${fg[red]}" ;;
        *) echo "${fg[white]}" ;;
    esac
}

# Function to make API call to OpenAI with structured JSON responses
_ai_command_call_api() {
    local query="$1"
    local system_info=$(_ai_command_get_system_info)
    
    local system_prompt="You are a helpful assistant that converts natural language requests into terminal commands for Fedora Linux systems using zsh shell.

SYSTEM INFO: $system_info

IMPORTANT: You MUST respond using the following simple format. Each command on its own line with this exact pattern:

CMD: actual_command_here
HINT: Brief explanation of what this command does and any important usage notes
CATEGORY: FILES|PROCESS|NETWORK|DISK|SERVICE|PACKAGE|SYSTEM|VCS|CONTAINER|SEARCH
RISK: SAFE|CAUTION|DANGEROUS
---

Example:
CMD: sudo dnf update -y
HINT: Updates all installed packages to the latest versions with auto-confirmation
CATEGORY: PACKAGE
RISK: CAUTION
---
CMD: dnf check-update
HINT: Shows available package updates without installing them
CATEGORY: PACKAGE
RISK: SAFE
---

GUIDELINES:
- Provide multiple command options when applicable (different approaches/complexity levels)
- Use Fedora-specific commands: dnf (not apt/yum), systemctl, firewall-cmd, rpm, etc.
- Use zsh-compatible syntax and features where beneficial
- For package management: use 'sudo dnf install', 'sudo dnf remove', 'sudo dnf update'
- For services: use 'sudo systemctl start/stop/restart/enable/disable'
- For firewall: use 'sudo firewall-cmd'
- Be concise and accurate for Fedora Linux environment
- Provide complete, executable commands
- Set RISK: SAFE (read-only operations), CAUTION (system changes/sudo required), DANGEROUS (potential data loss)
- Set appropriate CATEGORY for command type
- Keep hints brief but informative, include important usage warnings
- Always provide at least one command option, up to 5 for complex requests
- End each command block with --- separator"
    
    # Use higher token count for JSON responses with rich information
    local adjusted_max_tokens=$((ZSH_AI_COMMAND_MAX_TOKENS * 2))
    
    # Create JSON payload using jq for proper escaping
    local json_payload=$(jq -n \
        --arg model "$ZSH_AI_COMMAND_MODEL" \
        --arg system_content "$system_prompt" \
        --arg user_content "$query" \
        --argjson max_tokens "$adjusted_max_tokens" \
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
    
    # Debug mode - show request details if enabled (output to stderr to avoid mixing with command output)
    if [[ -n "$ZSH_AI_COMMAND_DEBUG" ]]; then
        echo "${fg[blue]}DEBUG: API Request Details:${reset_color}" >&2
        echo "URL: $ZSH_AI_COMMAND_API_BASE_URL/chat/completions" >&2
        echo "Model: $ZSH_AI_COMMAND_MODEL" >&2
        echo "Query: $query" >&2
        echo "${fg[blue]}DEBUG: JSON Payload:${reset_color}" >&2
        echo "$json_payload" | jq . 2>/dev/null >&2 || echo "$json_payload" >&2
        echo >&2
    fi
    
    local response=$(curl -s --max-time 30 -H "Content-Type: application/json" \
                          -H "Authorization: Bearer $ZSH_AI_COMMAND_API_KEY" \
                          -d "$json_payload" \
                          "$ZSH_AI_COMMAND_API_BASE_URL/chat/completions")
    
    local curl_exit_code=$?
    if [[ $curl_exit_code -ne 0 ]]; then
        echo "${fg[red]}Error: Failed to connect to API (curl exit code: $curl_exit_code)${reset_color}" >&2
        return 1
    fi
    
    # Check if response is empty
    if [[ -z "$response" ]]; then
        echo "${fg[red]}Error: Empty response from API${reset_color}" >&2
        return 1
    fi
    
    # Check for API errors
    local error_message=$(echo "$response" | jq -r '.error.message // empty' 2>/dev/null)
    if [[ -n "$error_message" ]]; then
        echo "${fg[red]}API Error: $error_message${reset_color}" >&2
        return 1
    fi
    
    # Debug mode - show raw response if enabled (output to stderr)
    if [[ -n "$ZSH_AI_COMMAND_DEBUG" ]]; then
        echo "${fg[blue]}DEBUG: Raw API Response:${reset_color}" >&2
        echo "$response" >&2
        echo "${fg[blue]}DEBUG: End of response${reset_color}" >&2
        echo >&2
    fi
    
    # Extract the command from the response - be more robust with parsing
    local command=""
    local raw_content=""
    
    # Debug the JSON structure first
    if [[ -n "$ZSH_AI_COMMAND_DEBUG" ]]; then
        echo "${fg[blue]}DEBUG: Checking JSON structure...${reset_color}" >&2
        echo "${fg[blue]}DEBUG: Response variable length: ${#response}${reset_color}" >&2
        echo "${fg[blue]}DEBUG: Response first 200 chars: ${response:0:200}${reset_color}" >&2
        # Check if response is valid JSON at all
        echo "$response" | jq . >/dev/null 2>&1 && echo "✅ valid JSON" >&2 || echo "❌ invalid JSON" >&2
        echo "$response" | jq -e '.choices' >/dev/null 2>&1 && echo "✅ choices array exists" >&2 || echo "❌ no choices array" >&2
        echo "$response" | jq -e '.choices[0]' >/dev/null 2>&1 && echo "✅ first choice exists" >&2 || echo "❌ no first choice" >&2
        echo "$response" | jq -e '.choices[0].message' >/dev/null 2>&1 && echo "✅ message exists" >&2 || echo "❌ no message" >&2
        echo "$response" | jq -e '.choices[0].message.content' >/dev/null 2>&1 && echo "✅ content exists" >&2 || echo "❌ no content" >&2
    fi
    
    # Extract content using jq for proper JSON parsing
    if echo "$response" | jq -e '.choices[0].message.content' >/dev/null 2>&1; then
        raw_content=$(echo "$response" | jq -r '.choices[0].message.content' 2>/dev/null)
        
        # Remove markdown code blocks if present
        if [[ "$raw_content" == *"```json"* ]]; then
            # Extract JSON from markdown code block
            raw_content=$(echo "$raw_content" | sed 's/^```json$//' | sed 's/^```$//' | sed '/^$/d')
        elif [[ "$raw_content" == *"```"* ]]; then
            # Extract content from generic code block
            raw_content=$(echo "$raw_content" | sed 's/^```$//' | sed '/^$/d')
        fi
        
        command="$raw_content"
    else
        # Fallback to string manipulation if jq fails
        local content_pattern='"content":"'
        if [[ "$response" == *"$content_pattern"* ]]; then
            # Find the start of the content value
            local temp="${response#*$content_pattern}"
            # Find the end of the content value (look for the closing quote before next field)
            local content_end_pattern='","reasoning_content"'
            if [[ "$temp" == *"$content_end_pattern"* ]]; then
                raw_content="${temp%%$content_end_pattern*}"
            else
                # Try alternative end patterns
                content_end_pattern='","refusal"'
                if [[ "$temp" == *"$content_end_pattern"* ]]; then
                    raw_content="${temp%%$content_end_pattern*}"
                else
                    content_end_pattern='","role"'
                    if [[ "$temp" == *"$content_end_pattern"* ]]; then
                        raw_content="${temp%%$content_end_pattern*}"
                    fi
                fi
            fi
            command="$raw_content"
        fi
    fi
    
    if [[ -n "$ZSH_AI_COMMAND_DEBUG" ]]; then
        echo "${fg[blue]}DEBUG: Raw extracted content: '$raw_content'${reset_color}" >&2
    fi
    
    # Clean up the command - remove code blocks and trim whitespace
    if [[ -n "$command" && "$command" != "null" ]]; then
        # Remove markdown code blocks if present (handles both ``` and ```bash)
        command=$(echo "$command" | sed -E 's/^```[a-zA-Z]*[[:space:]]*//g' | sed 's/```[[:space:]]*$//g')
        # Remove leading/trailing whitespace but preserve internal structure
        command=$(echo "$command" | sed -E 's/^[[:space:]]+//;s/[[:space:]]+$//')
        
        # Only do complex cleaning for very long responses (> 5 lines)
        if [[ $(echo "$command" | wc -l) -gt 5 ]]; then
            # For very long responses, try to extract just the command part
            local cleaned_command=""
            while IFS= read -r line; do
                # Skip empty lines and lines that look like explanations
                if [[ -n "$line" && ! "$line" =~ ^[[:space:]]*# && ! "$line" =~ ^[[:space:]]*\* && ! "$line" =~ ^[[:space:]]*- && ! "$line" =~ ^[[:space:]]*[Tt]his && ! "$line" =~ ^[[:space:]]*[Hh]ere ]]; then
                    if [[ -n "$cleaned_command" ]]; then
                        cleaned_command="$cleaned_command\n$line"
                    else
                        cleaned_command="$line"
                    fi
                fi
            done <<< "$command"
            if [[ -n "$cleaned_command" ]]; then
                command="$cleaned_command"
            fi
        fi
    fi
    
    # Debug the extracted command (output to stderr)
    if [[ -n "$ZSH_AI_COMMAND_DEBUG" ]]; then
        echo "${fg[blue]}DEBUG: Extracted command: '$command'${reset_color}" >&2
        echo >&2
    fi
    
    if [[ -z "$command" || "$command" == "null" ]]; then
        echo "${fg[red]}Error: No valid response from API${reset_color}" >&2
        if [[ -z "$ZSH_AI_COMMAND_DEBUG" ]]; then
            echo "${fg[yellow]}Tip: Enable debug mode to see the raw response:${reset_color}" >&2
            echo "${fg[cyan]}export ZSH_AI_COMMAND_DEBUG=1${reset_color}" >&2
        fi
        return 1
    fi
    
    echo "$command"
    return 0
}

# Function to clean JSON by fixing common escape issues
_ai_command_clean_json() {
    local json_input="$1"
    local result
    
    # Handle actual control characters (ASCII 0-31) by removing problematic ones
    result=$(printf '%s' "$json_input" | tr -d '\000-\010\013\014\016-\037')
    
    # Fix invalid JSON escape sequences
    # \; is not valid JSON - need to escape the backslash to make \\;
    result=$(printf '%s' "$result" | sed 's/\\;/\\\\\\\\;/g')
    result=$(printf '%s' "$result" | sed 's/\\|/\\\\\\\\|/g')
    
    printf '%s' "$result"
}

# Function to display command suggestions with enhanced UI and detailed information
_ai_command_display_suggestions() {
    local input_data="$1"
    local suggestions=()
    local descriptions=()
    local risk_levels=()
    local categories=()
    local notes=""
    local has_json_data=false
    
    if [[ -n "$ZSH_AI_COMMAND_DEBUG" ]]; then
        echo "DEBUG: Input data to display function:" >&2
        echo "$input_data" | head -10 >&2
        echo "DEBUG: Input data length: ${#input_data}" >&2
        echo "" >&2
    fi
    
    # Parse the new simple format
    if [[ -n "$ZSH_AI_COMMAND_DEBUG" ]]; then
        echo "DEBUG: Parsing simple format response" >&2
        echo "DEBUG: Input data (first 200 chars): ${input_data:0:200}..." >&2
    fi
    
    # Split input by --- separators and parse each block
    local IFS=$'\n'
    local blocks=(${(f)input_data})
    local current_cmd=""
    local current_hint=""
    local current_category=""
    local current_risk=""
    local in_block=false
    
    for line in "${blocks[@]}"; do
        # Skip empty lines
        [[ -z "$line" ]] && continue
        
        # Check for separator
        if [[ "$line" =~ ^---\s*$ ]]; then
            # End of block, save if we have a command
            if [[ -n "$current_cmd" ]]; then
                suggestions+=("$current_cmd")
                descriptions+=("${current_hint:-Command suggestion}")
                categories+=("${current_category:-SYSTEM}")
                risk_levels+=("${current_risk:-SAFE}")
                has_json_data=true
            fi
            # Reset for next block
            current_cmd=""
            current_hint=""
            current_category=""
            current_risk=""
            in_block=false
            continue
        fi
        
        # Parse command fields
        if [[ "$line" =~ ^CMD:[[:space:]]*(.*) ]]; then
            current_cmd="${match[1]}"
            in_block=true
        elif [[ "$line" =~ ^HINT:[[:space:]]*(.*) ]]; then
            current_hint="${match[1]}"
        elif [[ "$line" =~ ^CATEGORY:[[:space:]]*(.*) ]]; then
            current_category="${match[1]}"
        elif [[ "$line" =~ ^RISK:[[:space:]]*(.*) ]]; then
            current_risk="${match[1]}"
        fi
    done
    
    # Don't forget the last command if there's no final ---
    if [[ -n "$current_cmd" ]]; then
        suggestions+=("$current_cmd")
        descriptions+=("${current_hint:-Command suggestion}")
        categories+=("${current_category:-SYSTEM}")
        risk_levels+=("${current_risk:-SAFE}")
        has_json_data=true
    fi
    
    if [[ -n "$ZSH_AI_COMMAND_DEBUG" ]]; then
        echo "DEBUG: Simple format parsing found ${#suggestions[@]} commands" >&2
        for i in {1..${#suggestions[@]}}; do
            echo "DEBUG: Command $i: '${suggestions[$i]}' | Risk: '${risk_levels[$i]}' | Category: '${categories[$i]}'" >&2
        done
    fi
    
    # Fallback: Legacy ||| format parsing
    if [[ "$has_json_data" != "true" ]] && [[ "$input_data" =~ \|\|\| ]]; then
        if [[ -n "$ZSH_AI_COMMAND_DEBUG" ]]; then
            echo "DEBUG: Falling back to legacy ||| format parsing" >&2
        fi
        
        local IFS=$'\n'
        local lines=(${(f)input_data})
        
        for line in "${lines[@]}"; do
            if [[ "$line" =~ '^(.*)\|\|\|(.*)$' ]]; then
                local raw_command="${match[1]}"
                local description="${match[2]}"
                
                # Clean command: remove backticks
                raw_command=$(echo "$raw_command" | sed -E 's/^[[:space:]]*`//g' | sed -E 's/`[[:space:]]*$//g')
                raw_command=$(echo "$raw_command" | sed -E 's/^[[:space:]]+//;s/[[:space:]]+$//')
                
                # Ignore explanatory text
                if [[ ! "$raw_command" =~ ^[Nn]ote: ]] && \
                   [[ ! "$raw_command" =~ ^[Hh]ere\ (are|is) ]] && \
                   [[ -n "$raw_command" ]]; then
                    suggestions+=("$raw_command")
                    descriptions+=("$description")
                    risk_levels+=("SAFE")  # Default for legacy format
                    categories+=("SYSTEM") # Default for legacy format
                fi
            fi
        done
        
        if [[ ${#suggestions[@]} -gt 0 ]]; then
            has_json_data=true  # Mark as successful parsing
        fi
    fi
    
    # Final fallback: Simple line-by-line parsing
    if [[ "$has_json_data" != "true" ]]; then
        if [[ -n "$ZSH_AI_COMMAND_DEBUG" ]]; then
            echo "DEBUG: Using simple line-by-line parsing (legacy fallback)" >&2
        fi
        
        suggestions=("${(@f)input_data}")  # Split by newlines
        for cmd in "${suggestions[@]}"; do
            descriptions+=("Command suggestion")
            risk_levels+=("SAFE")
            categories+=("SYSTEM")
        done
    fi
    
    local selected_index=1
    
    if [[ ${#suggestions[@]} -eq 1 ]]; then
        # Single command with enhanced display
        local command="${suggestions[1]}"
        local description="${descriptions[1]}"
        
        # Use AI-provided data if available, otherwise analyze locally
        local risk_level="${risk_levels[1]:-SAFE}"
        local category_info="${categories[1]:-SYSTEM}"
        if [[ "$risk_level" == "SAFE" && "$category_info" == "SYSTEM" && "$has_json_data" != "true" ]]; then
            # Only do local analysis if we don't have AI-provided data
            local analysis=$(_ai_command_analyze_command "$command")
            risk_level="${analysis%%|*}"
            category_info="${analysis#*|}"; category_info="${category_info%%|*}"
        fi
        
        local risk_color=$(_ai_command_get_risk_color "$risk_level")
        local category_display=$(_ai_command_get_category_display "$category_info")
        
        # Generate warning based on risk level
        local warning=""
        case "$risk_level" in
            "DANGEROUS") warning="WARNING: DANGEROUS - Can permanently delete files/data" ;;
            "CAUTION") warning="WARNING: Requires elevated privileges or affects system" ;;
        esac
        
        echo "${fg[green]}┌─[AI COMMAND SUGGESTION]─${reset_color}"
        echo "${fg[green]}│${reset_color}"
        echo ""
        echo "${fg[magenta]}├─[COMMAND DETAILS]─${reset_color}"
        echo "${fg[magenta]}│${reset_color}"
        echo "${fg[magenta]}│${reset_color} ${risk_color}>${reset_color} ${fg[bold]}Command:${reset_color} ${fg[cyan]}$command${reset_color}"
        echo "${fg[magenta]}│${reset_color} ${fg[bold]}Purpose:${reset_color} $description"
        echo "${fg[magenta]}│${reset_color} ${fg[bold]}Category:${reset_color} $category_display"
        echo "${fg[magenta]}│${reset_color} ${risk_color}${fg[bold]}Risk Level:${reset_color} $risk_level${reset_color}"
        if [[ -n "$warning" && "$warning" != "" ]]; then
            echo "${fg[magenta]}│${reset_color} ${fg[red]}${warning}${reset_color}"
        fi
        echo "${fg[green]}└─[END]───────────────────────────${reset_color}"
        echo ""
        echo "${fg[yellow]}Actions:${reset_color} ${fg[green]}[Enter]${reset_color} Execute │ ${fg[blue]}[e]${reset_color} Edit │ ${fg[red]}[Ctrl+C]${reset_color} Cancel"
        
        read -k1 choice
        case $choice in
            $'\n'|$'\r')  # Enter key
                echo ""
                echo "${fg[green]}>>> EXECUTING: ${fg[cyan]}$command${reset_color}"
                eval "$command"
                ;;
            'e'|'E')
                echo ""
                echo "${fg[blue]}>>> EDIT MODE ACTIVATED <<<${reset_color}"
                print -z "$command"
                ;;
            *)
                echo ""
                echo "${fg[yellow]}>>> OPERATION CANCELLED <<<${reset_color}"
                ;;
        esac
    else
        # Multiple commands with enhanced display
        local show_details=false
        
        # Check if we're in an interactive terminal
        if [[ -t 0 && -t 1 ]]; then
            # Interactive mode - show menu with navigation
            while true; do
                # Clear screen and show menu
                clear
                echo "${fg[green]}┌─[AI FOUND ${#suggestions[@]} COMMAND OPTIONS]─${reset_color}"
                echo "${fg[green]}│${reset_color}"
                echo ""
                
                # Display commands with enhanced information
                for i in {1..${#suggestions[@]}}; do
                    local command="${suggestions[$i]}"
                    local description="${descriptions[$i]}"
                    
                    # Use AI-provided data if available, otherwise analyze locally
                    local risk_level="${risk_levels[$i]:-SAFE}"
                    local category_info="${categories[$i]:-SYSTEM}"
                    local warning=""
                    
                    if [[ "$risk_level" == "SAFE" && "$category_info" == "SYSTEM" && "$has_json_data" != "true" ]]; then
                        # Only do local analysis if we don't have AI-provided data
                        local analysis=$(_ai_command_analyze_command "$command")
                        risk_level="${analysis%%|*}"
                        category_info="${analysis#*|}"; category_info="${category_info%%|*}"
                        warning="${analysis##*|}"
                    else
                        # Generate warning based on AI-provided risk level
                        case "$risk_level" in
                            "DANGEROUS") warning="WARNING: DANGEROUS - Can permanently delete files/data" ;;
                            "CAUTION") warning="WARNING: Requires elevated privileges or affects system" ;;
                        esac
                    fi
                    
                    local risk_color=$(_ai_command_get_risk_color "$risk_level")
                    local category_display=$(_ai_command_get_category_display "$category_info")
                    
                    if [[ $i -eq $selected_index ]]; then
                        # Highlighted selection with detailed view
                        echo "${fg[yellow]}┌─[OPTION $i - SELECTED]─${reset_color}"
                        echo "${fg[yellow]}│${reset_color} ${risk_color}>${reset_color} ${fg[bold]}${fg[white]}$command${reset_color}"
                        # Always show basic info for selected item
                        echo "${fg[yellow]}│${reset_color} ${fg[bold]}Hint:${reset_color} $description"
                        echo "${fg[yellow]}│${reset_color} ${risk_color}${fg[bold]}Risk:${reset_color} $risk_level${reset_color}"
                        if [[ "$show_details" == "true" ]]; then
                            # Extended details when 'd' is pressed
                            echo "${fg[yellow]}│${reset_color} ${fg[bold]}Category:${reset_color} $category_display"
                            if [[ -n "$warning" && "$warning" != "" ]]; then
                                echo "${fg[yellow]}│${reset_color} ${fg[red]}$warning${reset_color}"
                            fi
                        fi
                        echo "${fg[yellow]}└${reset_color}"
                    else
                        # Regular option display - show command with basic info
                        echo "${fg[cyan]}  $i)${reset_color} ${risk_color}>${reset_color} ${fg[cyan]}$command${reset_color}"
                        # Always show hint as a brief description
                        echo "     ${fg[white]}${description}${reset_color}"
                        if [[ "$show_details" == "true" ]]; then
                            # Extended details when 'd' is pressed
                            echo "     Category: $category_display | Risk: ${risk_color}$risk_level${reset_color}"
                        fi
                    fi
                    echo ""
                done
                
                # Control instructions
                echo "${fg[green]}└─[CONTROLS]─────────────────────────────────${reset_color}"
                echo "${fg[magenta]}Navigation:${reset_color} ${fg[yellow]}↑/↓${reset_color} Select │ ${fg[green]}[Enter]${reset_color} Execute │ ${fg[blue]}[e]${reset_color} Edit │ ${fg[yellow]}[d]${reset_color} More Details"
                echo "${fg[magenta]}Quick Select:${reset_color} ${fg[yellow]}[1-9]${reset_color} Direct number │ ${fg[red]}[Ctrl+C]${reset_color} Cancel"
                
                # Read single character input
                read -k1 -s key
                
                case $key in
                    $'\e')  # Escape sequence (arrow keys start with \e)
                        read -k2 -s key2
                        case $key2 in
                            '[A')  # Up arrow
                                if [[ $selected_index -gt 1 ]]; then
                                    ((selected_index--))
                                fi
                                ;;
                            '[B')  # Down arrow
                                if [[ $selected_index -lt ${#suggestions[@]} ]]; then
                                    ((selected_index++))
                                fi
                                ;;
                        esac
                        ;;
                    $'\n'|$'\r')  # Enter key
                        local selected_command="${suggestions[$selected_index]}"
                        clear
                        echo "${fg[green]}>>> EXECUTING OPTION $selected_index <<<${reset_color}"
                        echo "${fg[cyan]}$selected_command${reset_color}"
                        echo ""
                        eval "$selected_command"
                        break
                        ;;
                    'e'|'E')  # Edit mode
                        clear
                        echo "${fg[blue]}>>> EDIT MODE: OPTION $selected_index <<<${reset_color}"
                        print -z "${suggestions[$selected_index]}"
                        break
                        ;;
                    'd'|'D')  # Toggle details
                        if [[ "$show_details" == "true" ]]; then
                            show_details=false
                        else
                            show_details=true
                        fi
                        ;;
                    [1-9])  # Number key (1-9)
                        if [[ $key -ge 1 ]] && [[ $key -le ${#suggestions[@]} ]] && [[ $key -le 9 ]]; then
                            local selected_command="${suggestions[$key]}"
                            clear
                            echo "${fg[green]}>>> QUICK EXECUTE: OPTION $key <<<${reset_color}"
                            echo "${fg[cyan]}$selected_command${reset_color}"
                            echo ""
                            eval "$selected_command"
                            break
                        fi
                        ;;
                    $'\x03')  # Ctrl+C
                        clear
                        echo "${fg[yellow]}>>> OPERATION CANCELLED - NO COMMAND EXECUTED <<<${reset_color}"
                        break
                        ;;
                esac
            done
        else
            # Non-interactive mode - just display options without navigation
            echo "${fg[green]}┌─[AI FOUND ${#suggestions[@]} COMMAND OPTIONS]─${reset_color}"
            echo "${fg[green]}│${reset_color}"
            echo ""
            
            # Display all commands with enhanced information
            for i in {1..${#suggestions[@]}}; do
                local command="${suggestions[$i]}"
                local description="${descriptions[$i]}"
                
                # Use AI-provided data if available, otherwise analyze locally
                local risk_level="${risk_levels[$i]:-SAFE}"
                local category_info="${categories[$i]:-SYSTEM}"
                local warning=""
                
                if [[ "$risk_level" == "SAFE" && "$category_info" == "SYSTEM" && "$has_json_data" != "true" ]]; then
                    # Only do local analysis if we don't have AI-provided data
                    local analysis=$(_ai_command_analyze_command "$command")
                    risk_level="${analysis%%|*}"
                    category_info="${analysis#*|}"; category_info="${category_info%%|*}"
                    warning="${analysis##*|}"
                else
                    # Generate warning based on AI-provided risk level
                    case "$risk_level" in
                        "DANGEROUS") warning="WARNING: DANGEROUS - Can permanently delete files/data" ;;
                        "CAUTION") warning="WARNING: Requires elevated privileges or affects system" ;;
                    esac
                fi
                
                local risk_color=$(_ai_command_get_risk_color "$risk_level")
                local category_display=$(_ai_command_get_category_display "$category_info")
                
                echo "${fg[cyan]}  $i)${reset_color} ${risk_color}>${reset_color} ${fg[cyan]}$command${reset_color}"
                echo "     Purpose: $description"
                echo "     Category: $category_display"
                echo "     Risk: $risk_level"
                if [[ -n "$warning" && "$warning" != "" ]]; then
                    echo "     ${fg[red]}$warning${reset_color}"
                fi
                echo ""
            done
            
            echo "${fg[green]}└─[NON-INTERACTIVE MODE]──────────────────────${reset_color}"
            echo "${fg[yellow]}To execute a command, use: /AI --execute <option_number>${reset_color}"
            echo "${fg[yellow]}Or run the command directly from the list above.${reset_color}"
        fi
    fi
}

# AI command function with structured JSON responses
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
    
    # Check for help flag
    if [[ "$query" =~ ^(--help|-h) ]]; then
        echo "${fg[green]}┌───────────────────────────────────────────────┐${reset_color}"
        echo "${fg[green]}│ ${fg[bold]} _    ___    _____ ___  __  __ __  __    _   _  _ ____  ${reset_color}${fg[green]} │${reset_color}"
        echo "${fg[green]}│ ${fg[bold]}/_\  |_ _|  / ____/ _ \\|  \/  |  \/  |  /_\ | \| | |  _ \ ${reset_color}${fg[green]} │${reset_color}"
        echo "${fg[green]}│ ${fg[bold]}//_\\\ | |  | |  | | | | |\/| | |\/| | //_\\| .\` | | |_) |${reset_color}${fg[green]} │${reset_color}"
        echo "${fg[green]}│ ${fg[bold]}/_/ \\_\|_|  |_|  |_| |_|_|  |_|_|  |_|/_/ \\_\_|\\_|\_|____/ ${reset_color}${fg[green]} │${reset_color}"
        echo "${fg[green]}│                                                  │${reset_color}"
        echo "${fg[green]}├─[USAGE]─────────────────────────────────────────┤${reset_color}"
        echo "${fg[green]}│${reset_color} /AI <request>     - Get AI command suggestions    ${fg[green]}│${reset_color}"
        echo "${fg[green]}│${reset_color} /AI --help        - Show this help                ${fg[green]}│${reset_color}"
        echo "${fg[green]}├─[EXAMPLES]──────────────────────────────────┤${reset_color}"
        echo "${fg[green]}│${reset_color} /AI stop docker service                          ${fg[green]}│${reset_color}"
        echo "${fg[green]}│${reset_color} /AI find large files                            ${fg[green]}│${reset_color}"
        echo "${fg[green]}│${reset_color} /AI check processes using port 3000             ${fg[green]}│${reset_color}"
        echo "${fg[green]}├─[FEATURES]──────────────────────────────────┤${reset_color}"
        echo "${fg[green]}│${reset_color} > Warning level assessment (SAFE/CAUTION/DANGEROUS) ${fg[green]}│${reset_color}"
        echo "${fg[green]}│${reset_color} > Command categorization with labels             ${fg[green]}│${reset_color}"
        echo "${fg[green]}│${reset_color} > Detailed hints for each command                ${fg[green]}│${reset_color}"
        echo "${fg[green]}│${reset_color} > Smart navigation (arrows + number keys)        ${fg[green]}│${reset_color}"
        echo "${fg[green]}│${reset_color} > Toggle detailed view with 'd' key              ${fg[green]}│${reset_color}"
        echo "${fg[green]}└───────────────────────────────────────────────┘${reset_color}"
        return 0
    fi
    
    if [[ -z "$query" ]]; then
        echo "${fg[red]}┌─[ERROR: NO QUERY PROVIDED]─────────────────────────────────────────────────────┐${reset_color}"
        echo "${fg[red]}│${reset_color} ${fg[yellow]}Usage: /AI <your natural language request>${reset_color}         ${fg[red]}│${reset_color}"
        echo "${fg[red]}│${reset_color} ${fg[cyan]}Tip: Use /AI --help for more options${reset_color}               ${fg[red]}│${reset_color}"
        echo "${fg[red]}├─[QUICK EXAMPLES]───────────────────────────────────────────┤${reset_color}"
        echo "${fg[red]}│${reset_color} > /AI stop docker service                         ${fg[red]}│${reset_color}"
        echo "${fg[red]}│${reset_color} > /AI find files larger than 100MB                ${fg[red]}│${reset_color}"
        echo "${fg[red]}│${reset_color} > /AI check system memory usage                   ${fg[red]}│${reset_color}"
        echo "${fg[red]}└──────────────────────────────────────────────────────┘${reset_color}"
        return 1
    fi
    
    echo "${fg[blue]}>>> AI PROCESSING... <<<${reset_color}"
    
    local suggestions=$(_ai_command_call_api "$query")
    
    if [[ $? -eq 0 && -n "$suggestions" ]]; then
        _ai_command_display_suggestions "$suggestions"
    else
        echo "${fg[red]}Failed to get AI suggestions${reset_color}"
        echo "${fg[yellow]}Tip: Check your API key and network connection${reset_color}"
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

# Plugin initialization - only show messages on errors
# Silent loading when everything is configured correctly
if [[ -z "$ZSH_AI_COMMAND_API_KEY" ]]; then
    echo "${fg[yellow]}⚠ AI Command plugin: API key not set${reset_color}" >&2
    echo "  Set your API key: ${fg[cyan]}export ZSH_AI_COMMAND_API_KEY='your-key'${reset_color}" >&2
fi
