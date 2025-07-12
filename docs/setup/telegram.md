# Telegram Bot Setup

Set up Telegram notifications to receive real-time updates about your trading bot's activity. This is optional but highly recommended for monitoring.

## Why Use Telegram Notifications?

Telegram notifications provide:
- **Trade alerts**: When bot opens/closes positions
- **Performance updates**: Profit/loss summaries  
- **Error notifications**: System issues requiring attention
- **Remote monitoring**: Check bot status from anywhere

## Creating Your Telegram Bot

### 1. Create Bot with BotFather
1. Open Telegram and search for `@BotFather`
2. Start a chat and send `/newbot`
3. Follow the prompts:
   - **Bot name**: Choose a display name (e.g., "My Trading Bot")
   - **Username**: Must end with "bot" (e.g., "my_trading_bot")
4. **Save the bot token** BotFather provides

### 2. Get Your Chat ID
You need your Chat ID so the bot knows where to send messages.

**Method 1 - Using @userinfobot:**
1. Search for `@userinfobot` in Telegram
2. Start a chat and send any message
3. The bot replies with your Chat ID

**Method 2 - Using @RawDataBot:**
1. Search for `@RawDataBot` in Telegram  
2. Start a chat and send any message
3. Look for `"chat":{"id":XXXXXXXXX}` in the response
4. The number after `"id":` is your Chat ID

**Method 3 - Manual extraction:**
1. Send a message to your new bot
2. Visit: `https://api.telegram.org/botYOUR_BOT_TOKEN/getUpdates`
3. Look for your Chat ID in the JSON response

## Configuration

### 1. Add to Environment File
Edit your `.env` file:
```bash
# Telegram Configuration
TELEGRAM_BOT_TOKEN=1234567890:ABCdefGHIjklMNOpqrSTUVwxyz
TELEGRAM_CHAT_ID=123456789
```

### 2. Verify Configuration
Your trading bot will automatically use these settings when configured in the strategy templates.

## Testing Your Setup

### 1. Test Bot Response
Send `/start` to your bot. You should see:
- Welcome message (if bot is running)
- Or no response (if bot isn't running yet - this is normal)

### 2. Launch Bot and Check Notifications
```bash
# Launch in dry-run mode
./docker-launch.sh

# Check logs for Telegram connection
docker logs freqtrade-ReinforcedAverageStrategy | grep -i telegram
```

You should receive a startup message in Telegram showing:
- Bot status and strategy
- Configuration summary
- Market conditions

### 3. Test Commands
Send these commands to your bot:
- `/status` - Current open trades
- `/profit` - Performance summary
- `/help` - Available commands

## Telegram Commands

Once your bot is running, you can control it via Telegram:

### Information Commands
- `/status` - Show open trades and bot status
- `/profit` - Display profit/loss summary
- `/balance` - Show account balance
- `/daily` - Daily profit statistics
- `/weekly` - Weekly performance
- `/monthly` - Monthly performance

### Control Commands
- `/start` - Start receiving notifications
- `/stop` - Stop receiving notifications
- `/help` - Show available commands

### Advanced Commands
- `/trades` - Show recent trade history
- `/performance` - Detailed performance metrics
- `/reload_config` - Reload bot configuration

## Notification Types

### Trade Notifications
- **Entry signals**: When bot opens new positions
- **Exit signals**: When bot closes positions
- **Stop-loss triggers**: When trades are stopped out

### Performance Updates
- **Daily summaries**: End-of-day performance
- **Milestone alerts**: Profit/loss thresholds
- **Drawdown warnings**: When losses exceed limits

### System Notifications
- **Startup/shutdown**: Bot status changes
- **Error alerts**: Technical issues
- **Configuration changes**: Setting updates

## Customizing Notifications

You can adjust notification frequency and types by modifying the strategy configuration templates in the `config/` directory. Look for the `telegram` section:

```json
"telegram": {
    "enabled": true,
    "token": "${TELEGRAM_BOT_TOKEN}",
    "chat_id": "${TELEGRAM_CHAT_ID}",
    "notification_settings": {
        "status": "on",
        "warning": "on", 
        "startup": "on",
        "buy": "on",
        "sell": "on"
    }
}
```

## Privacy and Security

### Bot Security
- **Bot tokens are sensitive** - treat like passwords
- **Restrict bot access** - only you should know the bot username
- **Monitor bot activity** - check for unexpected messages

### Chat Security  
- **Use private chats** - avoid group chats for trading notifications
- **Backup important alerts** - save critical trade information elsewhere
- **Regular token rotation** - create new bots periodically for high-value accounts

## Troubleshooting

### Bot Not Responding
```
No response to /status command
```
**Solutions:**
1. Check bot token in `.env` file
2. Verify trading bot is running: `docker ps`
3. Check logs: `docker logs freqtrade-ReinforcedAverageStrategy`

### Wrong Chat ID
```
Bot sends messages to wrong person/group
```
**Solutions:**
1. Verify Chat ID in `.env` file
2. Use @userinfobot to get correct Chat ID
3. Restart trading bot after fixing

### No Notifications
```
Bot responds to commands but no trade alerts
```
**Solutions:**
1. Check notification settings in strategy config
2. Verify trading activity (maybe no trades triggered)
3. Test in dry-run mode to see simulated trades

### Rate Limiting
```
ERROR - Telegram rate limit exceeded
```
**Solutions:**
1. Reduce notification frequency in config
2. Combine multiple updates into single messages
3. Use webhook instead of polling (advanced)

## Next Steps

With Telegram configured:
- [Launch your first strategy](../usage/launching.md)
- [Learn about monitoring strategies](../usage/monitoring.md)
- [Understand the different strategies](../usage/strategies.md)