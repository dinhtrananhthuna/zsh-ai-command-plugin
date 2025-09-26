#!/bin/zsh

# Load the plugin
source ./ai-command.plugin.zsh

# Test with the actual JSON from the AI
test_json='{
  "commands": [
    {
      "command": "ls -alh",
      "hint": "List all files and directories in the current directory with permissions, sizes and timestamps in human-readable format",
      "category": "FILES",
      "warning_level": "SAFE"
    },
    {
      "command": "tree -a -L 2",
      "hint": "Show a tree view of the current directory up to depth 2, including hidden files",
      "category": "FILES",
      "warning_level": "SAFE"
    }
  ]
}'

echo "Testing JSON parsing..."
echo "Original JSON:"
echo "$test_json"

echo ""
echo "After cleaning:"
cleaned_json=$(_ai_command_clean_json "$test_json")
echo "$cleaned_json"

echo ""
echo "Testing jq parsing:"
if echo "$cleaned_json" | jq -e '.commands' >/dev/null 2>&1; then
    echo "✅ jq parsing successful!"
    
    cmd1=$(echo "$cleaned_json" | jq -r '.commands[0].command')
    hint1=$(echo "$cleaned_json" | jq -r '.commands[0].hint')
    echo "First command: $cmd1"
    echo "First hint: $hint1"
else
    echo "❌ jq parsing failed"
    echo "jq error:"
    echo "$cleaned_json" | jq -e '.commands' 2>&1
fi