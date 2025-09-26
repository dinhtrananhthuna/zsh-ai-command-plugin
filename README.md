# AI Command Plugin for Oh My Zsh - Enhanced Edition

🤖 **Transform your terminal experience!** Convert natural language requests into executable terminal commands with advanced AI assistance, detailed command explanations, and intelligent safety features.

## ✨ Enhanced Features (NEW!)

- 🧠 **Smart Mode Detection**: Automatically detects complex queries and provides enhanced assistance
- 🛡️ **Risk Assessment**: Visual safety indicators for every command (Safe/Caution/Dangerous)
- 📝 **Detailed Explanations**: Each command comes with clear descriptions of what it does
- 🏷️ **Smart Categorization**: Commands organized by type (Files, Network, Process, etc.) with icons
- 🎯 **Enhanced Navigation**: Arrow keys, number shortcuts, and toggle detailed view
- 💡 **Multiple Approaches**: Get different ways to accomplish the same task
- 🔍 **Edit Before Execute**: Always option to modify commands before running
- 🎨 **Beautiful Interface**: Professional terminal UI with color-coded information

## Core Features

- 🎯 **Natural Language to Commands**: Type `/AI please stop Docker engine` and get the exact command
- 🔄 **Multiple Suggestions**: Get several command options when available with descriptions
- ⚡ **Quick Execution**: Press Enter to execute immediately or 'e' to edit first
- 🔧 **Configurable**: Support for custom OpenAI endpoints, models, and parameters
- ✅ **Smart Validation**: Dependency checking and error handling

## Prerequisites

- Oh My Zsh installed
- `curl` (usually pre-installed)
- `jq` for JSON parsing

### Install jq (if not already installed)

**Fedora/RHEL/CentOS:**
```bash
sudo dnf install jq
```

**Ubuntu/Debian:**
```bash
sudo apt install jq
```

**macOS:**
```bash
brew install jq
```

## Installation

### Method 1: Clone to Oh My Zsh plugins directory

1. Clone the plugin to your Oh My Zsh plugins directory:
```bash
git clone https://github.com/yourusername/zsh-ai-command-plugin.git ~/.oh-my-zsh/plugins/ai-command
```

2. Add the plugin to your `.zshrc`:
```bash
plugins=(... ai-command)
```

### Method 2: Manual Installation

1. Clone this repository:
```bash
git clone https://github.com/yourusername/zsh-ai-command-plugin.git
cd zsh-ai-command-plugin
```

2. Copy the plugin file to Oh My Zsh plugins directory:
```bash
mkdir -p ~/.oh-my-zsh/plugins/ai-command
cp ai-command.plugin.zsh ~/.oh-my-zsh/plugins/ai-command/
```

3. Add to your plugins list in `~/.zshrc`:
```bash
plugins=(... ai-command)
```

### Method 3: Local Development

1. Source the plugin directly in your `.zshrc`:
```bash
# Add to ~/.zshrc
source /path/to/zsh-ai-command-plugin/ai-command.plugin.zsh
```

## Configuration

### Required Configuration

Set your OpenAI API key:
```bash
export ZSH_AI_COMMAND_API_KEY="your-openai-api-key-here"
```

Add this to your `~/.zshrc` to make it permanent:
```bash
echo 'export ZSH_AI_COMMAND_API_KEY="your-api-key"' >> ~/.zshrc
```

### Optional Configuration

You can customize the AI behavior with these environment variables:

```bash
# API endpoint (default: https://api.openai.com/v1)
export ZSH_AI_COMMAND_API_BASE_URL="https://your-custom-endpoint.com/v1"

# Model name (default: gpt-3.5-turbo)
export ZSH_AI_COMMAND_MODEL="gpt-4"

# Maximum tokens for response (default: 150)
export ZSH_AI_COMMAND_MAX_TOKENS="200"

# Temperature for AI responses (default: 0.3)
export ZSH_AI_COMMAND_TEMPERATURE="0.5"
```

## For Fedora Linux Users

This plugin is optimized for Fedora Linux! It automatically detects your Fedora system and provides Fedora-specific commands using `dnf`, `systemctl`, `firewall-cmd`, etc.

See `FEDORA_EXAMPLES.md` for comprehensive examples of Fedora-specific commands you can request.

## For Digital Ocean or Custom Endpoints

If you're using a custom OpenAI-compatible API (like on Digital Ocean):

```bash
export ZSH_AI_COMMAND_API_BASE_URL="https://your-do-endpoint.com/v1"
export ZSH_AI_COMMAND_MODEL="your-model-name"
export ZSH_AI_COMMAND_API_KEY="your-api-key"
```

## Usage

### Basic Usage

Simply type `/AI` followed by your natural language request:

```bash
/AI please stop the Docker engine
# Shows: Safe/Caution/Dangerous indicator + clear explanation
```

```bash
/AI how to find files larger than 100MB
# Auto-detects and provides multiple search approaches with descriptions
```

```bash
/AI --enhanced find different ways to clean up disk space
# Explicit enhanced mode with detailed options and safety warnings
```

### Enhanced Mode Options

- **Regular mode**: `/AI <query>` - Basic command suggestions
- **Enhanced mode**: `/AI --enhanced <query>` - Multiple detailed options with descriptions
- **Auto-enhanced**: Complex queries automatically trigger enhanced features
- **Help**: `/AI --help` - Show all available features and controls

### Enhanced Interactive Interface

Experience the new beautiful and informative command interface:

1. **Single Command with Details:**
   ```
   🤖 AI Suggestion:
   
   ┌─ Command Details
   │
   │ 🟡 Command: sudo systemctl stop docker
   │ 📝 Purpose: Stop Docker service immediately
   │ 🏷️  Category: 🔧 Service
   │ 🛡️  Risk Level: CAUTION
   │ ⚠ Requires elevated privileges or affects system
   └
   
   Actions: [Enter] Execute │ [e] Edit │ [Ctrl+C] Cancel
   ```

2. **Multiple Enhanced Options:**
   ```
   🤖 AI found 3 command options:
   
   ┌─► Option 1 [SELECTED]
   │ 🟡 sudo systemctl stop docker
   │ 📝 Purpose: Stop Docker service immediately (recommended for quick stop)
   │ 🏷️  Category: 🔧 Service
   │ 🛡️  Risk: CAUTION
   │ ⚠ Requires elevated privileges or affects system
   └
   
     2) 🟡 sudo systemctl disable docker && sudo systemctl stop docker
        📝 Stop Docker service and prevent auto-start on boot
   
     3) 🟢 docker stop $(docker ps -q) && sudo systemctl stop docker  
        📝 Stop all running containers first, then stop Docker service (safest)
   
   Navigation: ↑↓ Select │ [Enter] Execute │ [e] Edit │ [d] Toggle Details
   Quick Select: [1-9] Direct number │ [Ctrl+C] Cancel
   ```

#### Enhanced Navigation Controls
- **↑↓ Arrow Keys**: Navigate between options with live preview
- **Enter**: Execute selected command with confirmation
- **e**: Edit selected command in terminal before execution
- **d**: Toggle between compact and detailed view
- **1-9**: Quick select by number with immediate feedback
- **Ctrl+C**: Cancel safely without executing anything

#### Visual Safety Indicators
- 🟢 **GREEN**: Safe read-only operations
- 🟡 **YELLOW**: Caution - system changes or requires sudo
- 🔴 **RED**: Dangerous - can delete files or cause data loss

### Options

- **Enter**: Execute the command immediately
- **e**: Edit the command in your terminal before execution
- **Ctrl+C**: Cancel without executing
- **↑↓ Arrow Keys**: Navigate between multiple options (when available)
- **Number (1-N)**: Select from multiple options by typing the number

## Examples

Here are example queries showcasing both basic and enhanced features:

### Basic Commands (Single Suggestion)
| Query | Expected Command | Risk Level |
|-------|------------------|------------|
| `/AI check disk space` | `df -h` | 🟢 Safe |
| `/AI show running containers` | `docker ps` | 🟢 Safe |
| `/AI list large files` | `find . -type f -size +100M` | 🟢 Safe |

### Enhanced Commands (Multiple Options with Descriptions)
| Query | Generated Options | Features Shown |
|-------|-------------------|----------------|
| `/AI stop docker engine` | Multiple systemctl approaches | 🟡 Risk indicators, 🔧 Service category |
| `/AI find different ways to clean disk` | Multiple cleanup strategies | 🔴 Danger warnings, 📁 File operations |
| `/AI check what's using port 3000 and kill it` | Various process management options | ⚙️ Process category, safety tips |
| `/AI backup this directory with timestamp` | Different backup methods (tar, rsync, etc.) | 💾 Storage category, best practices |

### Auto-Enhanced Queries (Complex queries trigger enhanced mode automatically)
- `/AI find files larger than 100MB and delete them safely`
- `/AI check system memory usage and kill high memory processes`  
- `/AI update all packages and clean up cache afterwards`
- `/AI show me different ways to restart network services`

### Enhanced Mode Examples
```bash
# Explicit enhanced mode for detailed options
/AI --enhanced install docker
# Shows: Multiple installation methods, post-install steps, security notes

/AI --enhanced find and remove temporary files  
# Shows: Various temp file locations, safety warnings, different cleaning levels

/AI --enhanced check network connectivity issues
# Shows: Multiple diagnostic approaches, from basic ping to advanced troubleshooting
```

## Troubleshooting

### Common Issues

1. **"jq: command not found"**
   - Install jq: `sudo dnf install jq` (Fedora) or `sudo apt install jq` (Ubuntu)

2. **"API key not set" error**
   - Make sure you've exported your API key: `export ZSH_AI_COMMAND_API_KEY="your-key"`

3. **"Failed to connect to API" error**
   - Check your internet connection
   - Verify your API endpoint URL
   - Ensure your API key is valid

4. **Plugin not loading**
   - Make sure the plugin is listed in your `~/.zshrc` plugins array
   - Restart your terminal or run `source ~/.zshrc`

### Debug Mode

To see detailed API responses for debugging:

```bash
# Add debug output
export ZSH_AI_COMMAND_DEBUG=1
```

## Security Considerations

- **API Key**: Store your API key securely and never commit it to version control
- **Command Execution**: Always review commands before executing, especially with `sudo`
- **Network**: The plugin sends your queries to the configured API endpoint

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

MIT License - see LICENSE file for details

## Changelog

### v1.0.0
- Initial release
- Basic AI command suggestion functionality
- OpenAI API integration
- Interactive command selection
- Configuration support for custom endpoints

## Support

If you encounter any issues or have suggestions, please:
1. Check the troubleshooting section
2. Search existing issues
3. Create a new issue with details about your environment and the problem

---

**Happy commanding! 🚀**