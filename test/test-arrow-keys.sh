#!/bin/bash

# Test script for arrow key functionality in AI command plugin
# This script simulates the menu selection behavior

echo "Testing arrow key functionality for AI command plugin..."
echo ""

# Source the plugin
source ai-command.plugin.zsh

# Test function to simulate multiple suggestions
test_arrow_key_selection() {
    echo "=== Testing Arrow Key Selection ==="
    echo ""
    
    # Simulate multiple command suggestions
    local test_suggestions="sudo systemctl stop docker
sudo service docker stop  
docker system prune -a
docker container stop \$(docker ps -q)"

    echo "Simulating AI response with multiple options:"
    echo "$test_suggestions"
    echo ""
    
    # Call the display function directly
    _ai_command_display_suggestions "$test_suggestions"
}

# Check if we're in an interactive shell
if [[ -t 0 ]]; then
    echo "Interactive terminal detected. Starting test..."
    test_arrow_key_selection
else
    echo "Non-interactive terminal. Cannot test arrow keys."
    echo "Please run this script in an interactive terminal:"
    echo "bash test-arrow-keys.sh"
fi
