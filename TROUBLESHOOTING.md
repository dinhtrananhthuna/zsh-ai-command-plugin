# Troubleshooting "No valid response from API"

## Quick Fix

The most common cause is a missing or incorrect API key. Here's how to fix it:

### Step 1: Set Your API Key

**For OpenAI:**
```bash
export ZSH_AI_COMMAND_API_KEY="your-openai-api-key-here"
```

**For Digital Ocean:**
```bash
export ZSH_AI_COMMAND_API_KEY="your-do-api-key"
export ZSH_AI_COMMAND_API_BASE_URL="https://your-endpoint.digitalocean.com/v1"
export ZSH_AI_COMMAND_MODEL="your-model-name"
```

### Step 2: Test the Connection
```bash
# Run the debug script
./debug-api.sh

# Or test manually with debug mode
export ZSH_AI_COMMAND_DEBUG=1
/AI test connection
```

## Common Issues and Solutions

### 1. "No valid response from API"
**Causes:**
- Missing API key
- Invalid API key
- Wrong API endpoint URL
- Model not found
- Network connectivity issues

**Solutions:**
```bash
# Check your configuration
echo "API Key: ${ZSH_AI_COMMAND_API_KEY:+Set}${ZSH_AI_COMMAND_API_KEY:-Not set}"
echo "Base URL: $ZSH_AI_COMMAND_API_BASE_URL"
echo "Model: $ZSH_AI_COMMAND_MODEL"

# Enable debug mode to see what's happening
export ZSH_AI_COMMAND_DEBUG=1
/AI your test command
```

### 2. OpenAI Configuration
If you're using OpenAI, make sure:
```bash
export ZSH_AI_COMMAND_API_KEY="sk-your-openai-key"
export ZSH_AI_COMMAND_API_BASE_URL="https://api.openai.com/v1"  # default
export ZSH_AI_COMMAND_MODEL="gpt-3.5-turbo"  # or gpt-4
```

### 3. Digital Ocean Configuration
If you're using Digital Ocean AI:
```bash
export ZSH_AI_COMMAND_API_KEY="your-do-api-key"
export ZSH_AI_COMMAND_API_BASE_URL="https://your-endpoint.digitalocean.com/v1"
export ZSH_AI_COMMAND_MODEL="your-deployed-model-name"
```

### 4. Custom API Configuration
For other OpenAI-compatible APIs:
```bash
export ZSH_AI_COMMAND_API_KEY="your-api-key"
export ZSH_AI_COMMAND_API_BASE_URL="https://your-api-endpoint.com/v1"
export ZSH_AI_COMMAND_MODEL="your-model-name"
```

## Debug Mode

Enable debug mode to see exactly what's happening:

```bash
export ZSH_AI_COMMAND_DEBUG=1
/AI your command here
```

This will show:
- The exact API request being sent
- The raw API response
- How the response is being parsed

## Testing Steps

### 1. Basic connectivity test:
```bash
# Test if you can reach the API endpoint
curl -I https://api.openai.com/v1/

# For Digital Ocean, replace with your endpoint
curl -I https://your-endpoint.digitalocean.com/v1/
```

### 2. API key test:
```bash
# Test with a simple API call (OpenAI example)
curl -H "Authorization: Bearer $ZSH_AI_COMMAND_API_KEY" \
     -H "Content-Type: application/json" \
     "https://api.openai.com/v1/models"
```

### 3. Full API test:
```bash
# Run our comprehensive debug script
./debug-api.sh
```

## Error Messages and Meanings

| Error | Meaning | Solution |
|-------|---------|----------|
| "ZSH_AI_COMMAND_API_KEY is not set" | API key missing | Set the environment variable |
| "Failed to connect to API" | Network/connectivity issue | Check internet and endpoint URL |
| "Authentication failed" | Invalid API key | Verify your API key is correct |
| "No valid response from API" | Response parsing failed | Enable debug mode to see raw response |
| "Model not found" | Invalid model name | Check model name for your provider |

## Getting Help

1. **Enable debug mode** first: `export ZSH_AI_COMMAND_DEBUG=1`
2. **Run the debug script**: `./debug-api.sh`
3. **Check the output** for specific error messages
4. **Share the debug output** (without your API key) for help

## Make Configuration Permanent

Once it's working, add to your `~/.zshrc`:

```bash
# AI Command Plugin Configuration
export ZSH_AI_COMMAND_API_KEY="your-api-key"
export ZSH_AI_COMMAND_API_BASE_URL="your-endpoint-if-not-openai"
export ZSH_AI_COMMAND_MODEL="your-model-name"

# Optional: Enable debug mode permanently
# export ZSH_AI_COMMAND_DEBUG=1
```

Then restart your terminal or run `source ~/.zshrc`.