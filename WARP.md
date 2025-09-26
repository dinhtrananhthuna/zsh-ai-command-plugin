# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Project Overview

This is a zsh plugin for Oh My Zsh that converts natural language requests into executable terminal commands using OpenAI's API. The plugin features enhanced UI with risk assessment, command categorization, and interactive navigation.

## Architecture

### Core Components

- **Main Plugin File**: `ai-command.plugin.zsh` - Contains all functionality in a single monolithic file
- **API Layer**: `_ai_command_call_api()` - Handles OpenAI API communication with JSON mode support
- **Display Engine**: `_ai_command_display_suggestions()` - Renders interactive UI with enhanced navigation
- **Risk Analysis**: `_ai_command_analyze_command()` - Local command risk assessment and categorization
- **Installation**: `install.sh` - Automated installer with dependency checking

### Key Functions

- `ai_command()` - Main entry point with smart mode detection
- `_ai_command_call_api()` - API communication with enhanced prompting for structured JSON responses
- `_ai_command_display_suggestions()` - Interactive display with arrow key navigation and risk indicators
- `_ai_command_analyze_command()` - Local analysis for risk levels (SAFE/CAUTION/DANGEROUS) and categories

### Data Flow

1. User input via `/AI` command
2. System info gathering (Fedora Linux detection, shell type)
3. API call with structured JSON prompts (always enforced)
4. JSON response parsing with command, hint, category, warning_level
5. Interactive display with rich information
6. Command execution or editing

## Development Commands

### Testing and Development

```bash
# Run basic test suite
./test/test.sh

# Test enhanced UI functionality
./test/test-enhanced-ui.sh

# Test complex command parsing
./test/test-complex-commands.sh

# Debug API interactions
./test/debug-api.sh

# Test arrow key navigation
./test/test-arrow-keys.sh

# Debug JSON parsing issues
./debug_parsing.zsh
```

### Installation and Setup

```bash
# Automated installation
./install.sh

# Manual installation to Oh My Zsh
mkdir -p ~/.oh-my-zsh/plugins/ai-command
cp ai-command.plugin.zsh ~/.oh-my-zsh/plugins/ai-command/

# For development - source directly
source ./ai-command.plugin.zsh
```

### Configuration

```bash
# Required - OpenAI API key
export ZSH_AI_COMMAND_API_KEY="your-api-key"

# Optional - Custom endpoint (e.g., Digital Ocean)
export ZSH_AI_COMMAND_API_BASE_URL="https://your-endpoint.com/v1"
export ZSH_AI_COMMAND_MODEL="gpt-4"

# Optional - Adjust token limits for complex responses
export ZSH_AI_COMMAND_MAX_TOKENS="500"  # Base tokens (doubled for JSON responses)
export ZSH_AI_COMMAND_TEMPERATURE="0.3"

# Debug mode for development
export ZSH_AI_COMMAND_DEBUG=1
```

## Code Style and Patterns

### Zsh Conventions
- Uses zsh-specific features: `${(f)variable}` for line splitting, `${match[1]}` for regex captures
- Color output with `autoload -U colors && colors` and `${fg[color]}` variables
- Auto-completion with `compdef` for zsh

### Error Handling
- Comprehensive dependency checking (`curl`, `jq`)
- API response validation with fallback parsing methods
- Debug mode with detailed logging to stderr

### UI/UX Patterns
- Consistent box-drawing characters for visual hierarchy
- Color-coded risk levels: 🟢 SAFE, 🟡 CAUTION, 🔴 DANGEROUS  
- Interactive navigation with clear control instructions
- Non-interactive mode fallback for scripting

### API Integration
- Always enforces structured JSON responses with rich metadata
- Single parsing strategy (JSON only - no fallbacks)
- Fedora Linux-specific command preferences built into prompts
- Higher token allocation for detailed responses with hints

## Testing Strategy

### Current Test Coverage
- Plugin loading and dependency checking
- Alias creation and configuration validation
- Mock parsing with sample API responses
- Interactive UI components (separate test files)

### Manual Testing Approach
- Tests require manual execution due to interactive nature
- Sample commands provided for different complexity levels
- Debug mode available for API interaction troubleshooting

## Dependencies

### Runtime Dependencies
- **Oh My Zsh**: Plugin framework
- **zsh**: Shell (uses zsh-specific features)
- **curl**: API communication  
- **jq**: JSON parsing and manipulation

### Development Dependencies
- Test scripts are self-contained in `test/` directory
- No external test frameworks - uses basic shell scripting

## Key Implementation Details

### JSON Response Structure
All responses follow this strict structure:
```json
{
  "commands": [
    {
      "command": "actual_command_here",
      "hint": "Brief explanation with usage notes",
      "category": "FILES|PROCESS|NETWORK|DISK|SERVICE|PACKAGE|SYSTEM|VCS|CONTAINER|SEARCH",
      "warning_level": "SAFE|CAUTION|DANGEROUS"
    }
  ]
}
```

### Warning Level Categories
- **SAFE**: Read-only operations with no risk
- **CAUTION**: System changes or requires sudo privileges
- **DANGEROUS**: Potential data loss or destructive operations
- AI-provided warning levels are always used (no local analysis fallback)

### Response Processing
- JSON responses are strictly enforced - no fallback parsing
- Failed JSON parsing results in error (encourages proper AI responses)
- Rich metadata (hint, category, warning_level) always included
