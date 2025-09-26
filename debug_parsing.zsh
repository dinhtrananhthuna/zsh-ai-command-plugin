#!/bin/zsh

# Test the parsing logic with sample data
test_data="Here are some commands to find large files on a Fedora Linux system:

\`find / -type f -size +100M\`|||Find files larger than 100MB in the entire file system (may take a long time to run)
\`sudo find / -type f -size +100M -print0 | xargs -0 du -h\`|||Find files larger than 100MB and print their size in human-readable format
\`find ~ -type f -size +10M -exec du -h {} \\;\`|||Find files larger than 10MB in the current user's home directory and print their size
\`sudo find / -type f -size +500M -exec ls -lh {} \\;\`|||Find files larger than 500MB and print their details, including size and permissions
\`du -h --threshold=100M /\`|||Find files and directories larger than 100MB in the root directory and print their size

Note: Be careful when running these commands, as they may take a long time to complete and may require root privileges to access certain directories."

echo "Raw test data:"
echo "=============="
echo "$test_data"
echo ""
echo "Parsing results:"
echo "================"

# Parse similar to the plugin logic
local suggestions=()
local descriptions=()

if [[ "$test_data" =~ \|\|\| ]]; then
    echo "Found ||| separator - using enhanced parsing"
    local IFS=$'\n'
    local lines=(${(f)test_data})
    local line_count=0
    
    for line in "${lines[@]}"; do
        ((line_count++))
        echo "Line $line_count: '$line'"
        
        # Look specifically for the |||DESCRIPTION pattern in a line
        if [[ "$line" =~ ^(.*)\|\|\|(.*)$ ]]; then
            local raw_command="${match[1]}"
            local description="${match[2]}"
            
            echo "  -> Found command line!"
            echo "  -> Raw command before cleaning: '$raw_command'"
            echo "  -> Description: '$description'"
            
            # Clean command: remove backticks common in markdown code blocks
            raw_command=$(echo "$raw_command" | sed -E 's/^[[:space:]]*`//g' | sed -E 's/`[[:space:]]*$//g')
            raw_command=$(echo "$raw_command" | sed -E 's/^[[:space:]]+//;s/[[:space:]]+$//')
            
            echo "  -> Cleaned command: '$raw_command'"
            
            # Ignore lines that start with "Note:" or don't look like commands
            if [[ ! "$raw_command" =~ ^[Nn]ote: ]] && \
               [[ ! "$raw_command" =~ ^[Hh]ere\ (are|is) ]] && \
               [[ -n "$raw_command" ]]; then
                suggestions+=("$raw_command")
                descriptions+=("$description")
                echo "  -> Added to suggestions array"
            else
                echo "  -> Skipped (Note or explanatory text)"
            fi
        else
            echo "  -> Skipped (no ||| separator)"
        fi
        echo ""
    done
else
    echo "No ||| separator found - using simple parsing"
fi

echo "Final results:"
echo "============="
echo "Number of suggestions: ${#suggestions[@]}"
for i in {1..${#suggestions[@]}}; do
    echo "[$i] Command: '${suggestions[$i]}'"
    echo "    Description: '${descriptions[$i]}'"
    echo ""
done