#!/bin/zsh

# Test the JSON cleaning function
_ai_command_clean_json() {
    local json_data="$1"
    
    # Replace common control characters that cause jq to fail
    # Handle newlines, tabs, carriage returns, and other control chars
    json_data=$(echo "$json_data" | sed 's/\\n/\\\\n/g')  # Escape newlines
    json_data=$(echo "$json_data" | sed 's/\\t/\\\\t/g')  # Escape tabs
    json_data=$(echo "$json_data" | sed 's/\\r/\\\\r/g')  # Escape carriage returns
    
    # Handle actual control characters (ASCII 0-31) by removing or escaping them
    # Remove null bytes and other problematic control characters
    json_data=$(echo "$json_data" | tr -d '\000-\010\013\014\016-\037')
    
    echo "$json_data"
}

# Test with problematic JSON
echo "Testing JSON cleaning function..."

# Simulate problematic JSON with control characters that cause jq error
# This simulates the actual jq error you encountered
problematic_json='{
"commands": [
  {
    "command": "ls -la",
    "hint": "List files with details",
    "category": "FILES",
    "warning_level": "SAFE"
  }
]
}'

echo "Original JSON:"
echo "$problematic_json"

echo ""
echo "Cleaned JSON:"
cleaned_json=$(_ai_command_clean_json "$problematic_json")
echo "$cleaned_json"

echo ""
echo "Testing jq parsing on cleaned JSON:"
if echo "$cleaned_json" | jq -e '.commands[0].command' >/dev/null 2>&1; then
    cmd=$(echo "$cleaned_json" | jq -r '.commands[0].command')
    hint=$(echo "$cleaned_json" | jq -r '.commands[0].hint')
    category=$(echo "$cleaned_json" | jq -r '.commands[0].category')
    warning=$(echo "$cleaned_json" | jq -r '.commands[0].warning_level')
    
    echo "✅ JSON parsing successful!"
    echo "Command: $cmd"
    echo "Hint: $hint"
    echo "Category: $category"
    echo "Warning Level: $warning"
else
    echo "❌ JSON parsing failed"
fi