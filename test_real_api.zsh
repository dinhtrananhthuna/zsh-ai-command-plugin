#!/bin/zsh

# Load the plugin
source ./ai-command.plugin.zsh

# Capture API response to a file
echo "Querying API..."
export ZSH_AI_COMMAND_DEBUG=1
_ai_command_call_api "list files" > api_response.txt 2>&1

# Extract the JSON content from the API response
echo "Extracting JSON content..."
grep -A 200 '"content":"{' api_response.txt | head -100 > json_content.txt

# Try to parse the JSON with jq
echo "Testing JSON parsing..."
json_content=$(cat json_content.txt)
cleaned_json=$(_ai_command_clean_json "$json_content")
echo "$cleaned_json" > cleaned_json.txt

echo "Testing with jq..."
cat cleaned_json.txt | jq . > parsed_json.txt 2>&1

echo "Check the following files for debugging:"
echo "- api_response.txt: Full API response"
echo "- json_content.txt: Extracted JSON content"
echo "- cleaned_json.txt: Cleaned JSON content"
echo "- parsed_json.txt: jq parsing results or errors"