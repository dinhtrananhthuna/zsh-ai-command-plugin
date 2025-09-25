# AI Command Plugin - Quick Start

🚀 Get your AI assistant in the terminal in under 5 minutes!

## What is this?

This Oh My Zsh plugin allows you to type natural language commands in your terminal and get AI-generated command suggestions. Just type `/AI` followed by what you want to do!

**🎯 Optimized for Fedora Linux + zsh** - The AI automatically detects your Fedora system and provides Fedora-specific commands using `dnf`, `systemctl`, `firewall-cmd`, etc.

## Examples

```bash
/AI please stop the Docker engine
# → sudo systemctl stop docker

/AI install nodejs
# → sudo dnf install nodejs npm

/AI update system packages  
# → sudo dnf update

/AI find files larger than 100MB
# → find . -type f -size +100M

/AI create a backup of this folder
# → tar -czf backup_$(date +%Y%m%d).tar.gz .
```

## Super Quick Install

1. **Run the installer:**
   ```bash
   ./install.sh
   ```

2. **Set your API key:**
   ```bash
   export ZSH_AI_COMMAND_API_KEY="your-openai-api-key"
   ```

3. **Restart your terminal or:**
   ```bash
   source ~/.zshrc
   ```

4. **Try it out:**
   ```bash
   /AI show me disk usage
   /AI install git
   /AI restart network service
   ```

That's it! 🎉

## Manual Install (Alternative)

If you prefer to install manually:

```bash
# Copy to Oh My Zsh plugins directory
mkdir -p ~/.oh-my-zsh/plugins/ai-command
cp ai-command.plugin.zsh ~/.oh-my-zsh/plugins/ai-command/

# Add to your .zshrc plugins list
# Edit ~/.zshrc and add 'ai-command' to your plugins array:
# plugins=(git ai-command other-plugins...)

# Set your API key
echo 'export ZSH_AI_COMMAND_API_KEY="your-api-key"' >> ~/.zshrc

# Reload
source ~/.zshrc
```

## For Digital Ocean Users

See `DIGITAL_OCEAN_SETUP.md` for specific configuration instructions.

## Configuration

### Required
- `ZSH_AI_COMMAND_API_KEY` - Your OpenAI (or compatible) API key

### Optional
- `ZSH_AI_COMMAND_API_BASE_URL` - Custom API endpoint (default: OpenAI)
- `ZSH_AI_COMMAND_MODEL` - Model name (default: gpt-3.5-turbo)
- `ZSH_AI_COMMAND_MAX_TOKENS` - Response length (default: 150)
- `ZSH_AI_COMMAND_TEMPERATURE` - AI creativity (default: 0.3)

## How It Works

1. **You type:** `/AI compress this directory`
2. **AI suggests:** `tar -czf archive.tar.gz .`
3. **You choose:** Press Enter to execute, 'e' to edit, or Ctrl+C to cancel

## File Structure

```
zsh-ai-command-plugin/
├── ai-command.plugin.zsh    # Main plugin file
├── install.sh               # Automatic installer
├── test.sh                  # Test suite
├── README.md               # Detailed documentation
├── QUICKSTART.md           # This file
├── DIGITAL_OCEAN_SETUP.md  # Digital Ocean specific guide
└── LICENSE                 # MIT License
```

## Need Help?

1. **Check dependencies:** Make sure `curl` and `jq` are installed
2. **Verify API key:** Ensure your API key is correctly set
3. **Test plugin:** Run `./test.sh` to check everything works
4. **Read docs:** Check `README.md` for troubleshooting

## Next Steps

- ⭐ Star this repo if you find it useful
- 🐛 Report bugs in the Issues section  
- 🔧 Contribute improvements
- 📚 Read the full README.md for advanced features

---

**Happy commanding! 🤖**