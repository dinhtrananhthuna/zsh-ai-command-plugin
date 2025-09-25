#!/bin/zsh

# Demo script to show the system prompt that will be sent to the AI
# This helps you understand what information the AI receives about your system

echo "🔍 AI System Prompt Preview"
echo "=========================="
echo
echo "When you use the /AI command, here's the system prompt that gets sent to the AI model:"
echo

# Source the plugin to get the functions
source ./ai-command.plugin.zsh >/dev/null 2>&1

# Get system info
system_info=$(_ai_command_get_system_info)

# Create the same prompt that would be sent to the AI
system_prompt="You are a helpful assistant that converts natural language requests into terminal commands for Fedora Linux systems using zsh shell.

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

echo "📝 SYSTEM PROMPT:"
echo "=================="
echo "$system_prompt"
echo
echo "📊 Key Information Detected:"
echo "============================"
echo "• Operating System: Fedora 42 (Adams)"
echo "• Shell: zsh 5.9"  
echo "• Package Manager: dnf (not apt/yum)"
echo "• Service Manager: systemctl"
echo "• Firewall: firewall-cmd"
echo
echo "✅ This ensures you get Fedora-specific commands like:"
echo "   /AI install docker → sudo dnf install docker"
echo "   /AI start ssh → sudo systemctl start sshd"
echo "   /AI open port 80 → sudo firewall-cmd --permanent --add-port=80/tcp && sudo firewall-cmd --reload"
echo
echo "🚀 Ready to use! Set your API key and start asking for commands."