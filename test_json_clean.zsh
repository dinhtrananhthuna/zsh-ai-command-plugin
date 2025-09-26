#!/bin/zsh

# Simulate the raw JSON content from API
raw_json='{\n\"commands\": [\n{\n\"command\": \"find / -type f -size +100M\",\n\"description\": \"Find files larger than 100MB\",\n\"risk_level\": \"SAFE\",\n\"category\": \"FILES\"\n}\n],\n\"notes\": \"Test notes\"\n}'

echo "Raw JSON:"
echo "$raw_json"
echo ""

# Apply the cleaning transformations
echo "Cleaning step 1 - unescape quotes:"
step1=$(echo "$raw_json" | sed 's/\\\"/"/g')
echo "$step1"
echo ""

echo "Cleaning step 2 - unescape newlines:"
step2=$(echo "$step1" | sed 's/\\n/\n/g')
echo "$step2"
echo ""

echo "Testing jq parsing:"
if echo "$step2" | jq -e '.commands' >/dev/null 2>&1; then
    echo "✅ jq parsing successful"
    echo "$step2" | jq -r '.commands[0].command'
else
    echo "❌ jq parsing failed"
    echo "$step2" | jq . 2>&1 || echo "JSON validation failed"
fi