#!/bin/zsh

test_line='`find / -type f -size +100M`|||Find files larger than 100MB in the entire file system'

echo "Test line: $test_line"
echo ""

if [[ "$test_line" =~ '^(.*)\|\|\|(.*)$' ]]; then
    echo "Regex matched!"
    echo "match[1]: '${match[1]}'"
    echo "match[2]: '${match[2]}'"
    echo "Full match array: ${match[@]}"
else
    echo "Regex did not match"
fi

echo ""

# Let's try a simpler approach by finding the position
if [[ "$test_line" =~ '\|\|\|' ]]; then
    echo "Contains |||"
    # Split by ||| using parameter expansion
    local before_sep="${test_line%|||*}"
    local after_sep="${test_line#*|||}"
    echo "Before |||: '$before_sep'"
    echo "After |||: '$after_sep'"
else
    echo "Does not contain |||"
fi
