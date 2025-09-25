# Digital Ocean AI Setup Guide

This guide shows you how to configure the AI Command plugin to work with your Digital Ocean AI models.

## Prerequisites

1. Digital Ocean account with AI/ML services enabled
2. API key from Digital Ocean
3. Model endpoint URL
4. Model name you want to use

## Configuration

### Step 1: Set your Digital Ocean API credentials

```bash
# Your Digital Ocean API key
export ZSH_AI_COMMAND_API_KEY="your-digital-ocean-api-key"

# Your Digital Ocean AI endpoint (replace with your actual endpoint)
export ZSH_AI_COMMAND_API_BASE_URL="https://your-do-endpoint.com/v1"

# Your model name (replace with your actual model)
export ZSH_AI_COMMAND_MODEL="your-model-name"
```

### Step 2: Optional configuration

You can also customize these parameters:

```bash
# Maximum tokens for response (default: 150)
export ZSH_AI_COMMAND_MAX_TOKENS="200"

# Temperature for AI responses (default: 0.3, range: 0.0-1.0)
export ZSH_AI_COMMAND_TEMPERATURE="0.2"
```

### Step 3: Make configuration permanent

Add these to your `~/.zshrc` file:

```bash
# Digital Ocean AI Command Plugin Configuration
export ZSH_AI_COMMAND_API_KEY="your-digital-ocean-api-key"
export ZSH_AI_COMMAND_API_BASE_URL="https://your-do-endpoint.com/v1"
export ZSH_AI_COMMAND_MODEL="your-model-name"
export ZSH_AI_COMMAND_MAX_TOKENS="200"
export ZSH_AI_COMMAND_TEMPERATURE="0.2"
```

## Testing

After configuration, test the plugin:

```bash
# Reload your shell configuration
source ~/.zshrc

# Test the plugin
/AI show me disk usage
```

## Example Digital Ocean Configurations

### GPT-like Model
```bash
export ZSH_AI_COMMAND_API_KEY="do_api_key_here"
export ZSH_AI_COMMAND_API_BASE_URL="https://api.digitalocean.com/v1/ai"
export ZSH_AI_COMMAND_MODEL="gpt-3.5-turbo"
```

### Custom Model
```bash
export ZSH_AI_COMMAND_API_KEY="do_api_key_here"
export ZSH_AI_COMMAND_API_BASE_URL="https://your-custom-endpoint.digitalocean.com/v1"
export ZSH_AI_COMMAND_MODEL="your-fine-tuned-model"
```

## Troubleshooting

### Common Issues

1. **"Failed to connect to API"**
   - Verify your API base URL is correct
   - Check if your API key has the necessary permissions
   - Ensure your Digital Ocean AI service is active

2. **"API Error: Authentication failed"**
   - Double-check your API key
   - Verify the key has access to AI services

3. **"Model not found"**
   - Confirm your model name is correct
   - Check if the model is available in your Digital Ocean account

### Debug Mode

Enable debug mode to see detailed API responses:

```bash
export ZSH_AI_COMMAND_DEBUG=1
/AI your command here
```

This will show you the full API request and response for troubleshooting.

## Performance Tips

- Use lower temperature (0.1-0.3) for more consistent command suggestions
- Adjust max_tokens based on your needs (100-300 is usually sufficient)
- For faster responses, consider using smaller models if available

## Security Notes

- Never commit your API keys to version control
- Store API keys in environment variables, not in scripts
- Consider using Digital Ocean's secret management for production environments
- Regularly rotate your API keys

---

For more information, check the main README.md file.