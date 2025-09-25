#!/bin/bash

# AI Command Plugin Installer for Oh My Zsh
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Plugin details
PLUGIN_NAME="ai-command"
PLUGIN_DIR="$HOME/.oh-my-zsh/plugins/$PLUGIN_NAME"
ZSHRC="$HOME/.zshrc"

echo -e "${BLUE}🤖 AI Command Plugin Installer${NC}"
echo "================================="

# Check if Oh My Zsh is installed
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    echo -e "${RED}❌ Oh My Zsh is not installed. Please install it first:${NC}"
    echo "sh -c \"\$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)\""
    exit 1
fi

echo -e "${GREEN}✅ Oh My Zsh found${NC}"

# Check for required dependencies
echo "Checking dependencies..."

if ! command -v curl >/dev/null 2>&1; then
    echo -e "${RED}❌ curl is not installed. Please install curl first.${NC}"
    exit 1
fi
echo -e "${GREEN}✅ curl found${NC}"

if ! command -v jq >/dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  jq is not installed. Installing jq...${NC}"
    
    # Detect OS and install jq
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if command -v dnf >/dev/null 2>&1; then
            sudo dnf install -y jq
        elif command -v apt >/dev/null 2>&1; then
            sudo apt update && sudo apt install -y jq
        elif command -v yum >/dev/null 2>&1; then
            sudo yum install -y jq
        elif command -v pacman >/dev/null 2>&1; then
            sudo pacman -S jq
        else
            echo -e "${RED}❌ Cannot install jq automatically. Please install it manually.${NC}"
            exit 1
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        if command -v brew >/dev/null 2>&1; then
            brew install jq
        else
            echo -e "${RED}❌ Homebrew not found. Please install jq manually: brew install jq${NC}"
            exit 1
        fi
    else
        echo -e "${RED}❌ Cannot install jq automatically on this OS. Please install it manually.${NC}"
        exit 1
    fi
fi
echo -e "${GREEN}✅ jq found${NC}"

# Create plugin directory
echo "Setting up plugin..."
mkdir -p "$PLUGIN_DIR"

# Copy plugin file
if [[ -f "ai-command.plugin.zsh" ]]; then
    cp "ai-command.plugin.zsh" "$PLUGIN_DIR/"
    echo -e "${GREEN}✅ Plugin file copied${NC}"
else
    echo -e "${RED}❌ Plugin file not found. Make sure you're running this from the plugin directory.${NC}"
    exit 1
fi

# Check if plugin is already in .zshrc
if grep -q "ai-command" "$ZSHRC"; then
    echo -e "${YELLOW}⚠️  Plugin already configured in .zshrc${NC}"
else
    # Add plugin to .zshrc
    echo "Adding plugin to .zshrc..."
    
    # Find the plugins line and add our plugin
    if grep -q "plugins=(" "$ZSHRC"; then
        # Use sed to add the plugin to the existing plugins line
        if [[ "$OSTYPE" == "darwin"* ]]; then
            # macOS sed
            sed -i '' 's/plugins=(/plugins=(ai-command /' "$ZSHRC"
        else
            # GNU sed (Linux)
            sed -i 's/plugins=(/plugins=(ai-command /' "$ZSHRC"
        fi
        echo -e "${GREEN}✅ Plugin added to .zshrc${NC}"
    else
        # No plugins line found, add one
        echo "" >> "$ZSHRC"
        echo "plugins=(ai-command)" >> "$ZSHRC"
        echo -e "${GREEN}✅ Plugin configuration added to .zshrc${NC}"
    fi
fi

# Configuration setup
echo ""
echo -e "${BLUE}📋 Configuration Setup${NC}"
echo "======================="

# Check if API key is already set
if [[ -n "$ZSH_AI_COMMAND_API_KEY" ]]; then
    echo -e "${GREEN}✅ API key already configured${NC}"
else
    echo -e "${YELLOW}⚠️  API key not set${NC}"
    echo ""
    echo "To use this plugin, you need to set your OpenAI API key:"
    echo -e "${BLUE}export ZSH_AI_COMMAND_API_KEY=\"your-api-key-here\"${NC}"
    echo ""
    echo "Add this line to your .zshrc to make it permanent:"
    echo -e "${BLUE}echo 'export ZSH_AI_COMMAND_API_KEY=\"your-api-key\"' >> ~/.zshrc${NC}"
    echo ""
    
    read -p "Would you like to set your API key now? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        read -p "Enter your OpenAI API key: " -s api_key
        echo
        if [[ -n "$api_key" ]]; then
            echo "export ZSH_AI_COMMAND_API_KEY=\"$api_key\"" >> "$ZSHRC"
            echo -e "${GREEN}✅ API key added to .zshrc${NC}"
        else
            echo -e "${YELLOW}⚠️  No API key entered, skipping...${NC}"
        fi
    fi
fi

# Optional configuration
echo ""
echo "Optional configuration (you can skip these):"
echo ""
echo "For custom OpenAI endpoints (like Digital Ocean):"
echo -e "${BLUE}export ZSH_AI_COMMAND_API_BASE_URL=\"https://your-endpoint.com/v1\"${NC}"
echo -e "${BLUE}export ZSH_AI_COMMAND_MODEL=\"your-model-name\"${NC}"
echo ""

read -p "Would you like to configure a custom endpoint? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    read -p "Enter your API base URL: " base_url
    read -p "Enter your model name: " model_name
    
    if [[ -n "$base_url" ]]; then
        echo "export ZSH_AI_COMMAND_API_BASE_URL=\"$base_url\"" >> "$ZSHRC"
        echo -e "${GREEN}✅ API base URL added${NC}"
    fi
    
    if [[ -n "$model_name" ]]; then
        echo "export ZSH_AI_COMMAND_MODEL=\"$model_name\"" >> "$ZSHRC"
        echo -e "${GREEN}✅ Model name added${NC}"
    fi
fi

# Installation complete
echo ""
echo -e "${GREEN}🎉 Installation Complete!${NC}"
echo "========================"
echo ""
echo "To start using the AI Command plugin:"
echo -e "1. ${YELLOW}Restart your terminal or run: ${BLUE}source ~/.zshrc${NC}"
echo -e "2. ${YELLOW}Try it out: ${BLUE}/AI please show me disk usage${NC}"
echo ""
echo "Examples:"
echo -e "  ${BLUE}/AI stop docker engine${NC}"
echo -e "  ${BLUE}/AI find files larger than 100MB${NC}"
echo -e "  ${BLUE}/AI create a backup of this folder${NC}"
echo ""
echo -e "${YELLOW}Need help? Check the README.md file for detailed usage instructions.${NC}"
echo ""
echo -e "${GREEN}Happy commanding! 🚀${NC}"