# AI Command Plugin for Oh My Zsh

🤖 Bring AI assistance to your terminal! Convert natural language requests into executable terminal commands using OpenAI's GPT models.

## Features

- 🎯 **Natural Language to Commands**: Type `/AI please stop Docker engine` and get the exact command
- 🔄 **Multiple Suggestions**: Get several command options when available
- ⚡ **Quick Execution**: Press Enter to execute immediately or 'e' to edit first
- 🎨 **Beautiful Interface**: Colored output with intuitive selection
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
```

```bash
/AI how to find files larger than 100MB
```

```bash
/AI compress this directory into a tar.gz file
```

### Interactive Interface

When you run a command, you'll see:

1. **Single command suggestion:**
   ```
   AI suggests:
     sudo systemctl stop docker

   Press Enter to execute, Ctrl+C to cancel, or e to edit:
   ```

2. **Multiple command suggestions:**
   ```
   AI suggests multiple options:
     ► 1) sudo systemctl stop docker
       2) sudo service docker stop
       3) docker system prune -a

   Use ↑↓ to navigate, Enter to execute, e to edit, Ctrl+C to cancel:
   ```
   
   **Navigation:**
   - Use **↑↓ arrow keys** to move between options
   - Press **Enter** to execute the highlighted option
   - Press **e** to edit the highlighted option
   - Press **1-9** to directly select by number
   - Press **Ctrl+C** to cancel

### Options

- **Enter**: Execute the command immediately
- **e**: Edit the command in your terminal before execution
- **Ctrl+C**: Cancel without executing
- **↑↓ Arrow Keys**: Navigate between multiple options (when available)
- **Number (1-N)**: Select from multiple options by typing the number

## Examples

Here are some example queries and the types of commands they might generate:

| Query | Expected Command |
|-------|------------------|
| `/AI stop docker engine` | `sudo systemctl stop docker` |
| `/AI find large files` | `find . -type f -size +100M` |
| `/AI check disk space` | `df -h` |
| `/AI kill process on port 3000` | `lsof -ti:3000 \| xargs kill -9` |
| `/AI create a backup of this folder` | `tar -czf backup_$(date +%Y%m%d).tar.gz .` |
| `/AI show running containers` | `docker ps` |
| `/AI update system packages` | `sudo dnf update` |
| `/AI install docker` | `sudo dnf install docker` |
| `/AI enable docker service` | `sudo systemctl enable --now docker` |
| `/AI open firewall for ssh` | `sudo firewall-cmd --permanent --add-service=ssh && sudo firewall-cmd --reload` |

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