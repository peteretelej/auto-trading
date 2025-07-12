# Configuration Reference

This reference provides detailed explanations of all configuration parameters used in the auto-trading system.

## Configuration Overview

The system uses JSON configuration files with environment variable substitution:
- **Templates**: Files in `config/` directory with `.json` extension
- **Environment variables**: Values from `.env` file substituted at runtime
- **Processing**: Templates become actual config files when bots start

## Environment Variables (`.env` file)

### Required Variables

#### Binance API Configuration
```bash
BINANCE_API_KEY=your_api_key_here
BINANCE_API_SECRET=your_secret_key_here
```
- **Purpose**: Authenticate with Binance exchange
- **Security**: Never share or commit these values
- **Permissions**: Enable "Reading" and "Spot Trading" only

#### Web Interface Access
```bash
WEB_USERNAME=admin
WEB_PASSWORD=your_secure_password
WEB_PORT=8101
```
- **WEB_USERNAME**: Login name for bot web interface
- **WEB_PASSWORD**: Strong password (avoid default passwords)
- **WEB_PORT**: Base port for web interface (each bot uses offset)

#### Data Storage
```bash
DATA_DIR=/path/to/your/trading-data
```
- **Purpose**: Directory where bot data is stored
- **Requirements**: Must be absolute path with write permissions
- **Structure**: Each strategy creates subdirectory

### Optional Variables

#### Telegram Notifications
```bash
TELEGRAM_BOT_TOKEN=123456789:ABCdefGHIjklMNOpqrSTUVwxyz
TELEGRAM_CHAT_ID=123456789
```
- **TELEGRAM_BOT_TOKEN**: From @BotFather when creating bot
- **TELEGRAM_CHAT_ID**: Your personal chat ID for receiving messages
- **Usage**: Leave empty to disable Telegram notifications

## Configuration Template Structure

### Basic Template Sections

Every configuration template contains these main sections:

```json
{
  "max_open_trades": 5,
  "stake_currency": "USDT", 
  "stake_amount": "unlimited",
  "tradable_balance_ratio": 0.99,
  "fiat_display_currency": "USD",
  "timeframe": "5m",
  "dry_run": true,
  "cancel_open_orders_on_exit": false,
  
  "bid_strategy": {...},
  "ask_strategy": {...}, 
  "exchange": {...},
  "pairlists": [...],
  "telegram": {...},
  "api_server": {...},
  "internals": {...}
}
```

## Trading Parameters

### Position Management
```json
{
  "max_open_trades": 5,
  "stake_amount": "unlimited",
  "tradable_balance_ratio": 0.99
}
```

#### `max_open_trades`
- **Type**: Integer or -1 for unlimited
- **Purpose**: Maximum number of simultaneous trades
- **Considerations**: 
  - Higher values = more diversification but increased complexity
  - Lower values = easier to manage but less opportunity
  - Balance with available capital

#### `stake_amount` 
- **Type**: Number or "unlimited"
- **Purpose**: Amount invested per trade
- **Options**:
  - Fixed amount: `20` (invest $20 per trade)
  - Percentage: `"5%"` (5% of available balance per trade)
  - Unlimited: `"unlimited"` (divide balance by max_open_trades)

#### `tradable_balance_ratio`
- **Type**: Float between 0 and 1
- **Purpose**: Percentage of total balance available for trading
- **Example**: `0.99` means 99% of balance can be used, 1% kept as reserve

### Currency Settings
```json
{
  "stake_currency": "USDT",
  "fiat_display_currency": "USD"
}
```

#### `stake_currency`
- **Purpose**: Base currency for all trades
- **Common values**: "USDT", "BTC", "ETH"
- **Recommendation**: Use "USDT" for stable value reference

#### `fiat_display_currency`  
- **Purpose**: Currency for profit/loss display in web interface
- **Values**: "USD", "EUR", "GBP", etc.
- **Note**: Only affects display, not actual trading

### Timeframe and Execution
```json
{
  "timeframe": "5m",
  "dry_run": true,
  "cancel_open_orders_on_exit": false
}
```

#### `timeframe`
- **Purpose**: Candle interval for strategy analysis
- **Common values**: "1m", "5m", "15m", "1h", "4h", "1d"
- **Strategy dependency**: Each strategy has optimal timeframe

#### `dry_run`
- **Type**: Boolean
- **Purpose**: Enable simulation mode (no real trading)
- **Safety**: Always start with `true` for testing

## Risk Management

### Stop Loss and Take Profit
```json
{
  "stoploss": -0.1,
  "trailing_stop": false,
  "trailing_stop_positive": 0.01,
  "trailing_stop_positive_offset": 0.02,
  "trailing_only_offset_is_reached": false
}
```

#### `stoploss`
- **Type**: Negative float
- **Purpose**: Maximum loss per trade as percentage
- **Examples**: 
  - `-0.05` = 5% stop loss
  - `-0.99` = 99% stop loss (effectively disabled)
- **Strategy consideration**: NFI uses `-0.99` to rely on internal logic

#### `trailing_stop`
- **Type**: Boolean  
- **Purpose**: Enable dynamic stop loss that follows price
- **Usage**: Locks in profits as price moves favorably

#### `minimal_roi`
- **Type**: Object with time-based profit targets
- **Purpose**: Take profit at specific time intervals
- **Example**:
```json
{
  "minimal_roi": {
    "0": 0.05,    // 5% profit immediately
    "30": 0.025,  // 2.5% profit after 30 minutes
    "60": 0.01,   // 1% profit after 1 hour
    "120": 0      // Break even after 2 hours
  }
}
```

### Position Adjustments
```json
{
  "position_adjustment_enable": true,
  "max_entry_position_adjustment": 3
}
```

#### `position_adjustment_enable`
- **Type**: Boolean
- **Purpose**: Allow multiple entries into same position
- **Use case**: Dollar-cost averaging, adding to winning positions
- **Risk**: Can increase losses if market moves against position

## Exchange Configuration

### Basic Exchange Settings
```json
{
  "exchange": {
    "name": "binance",
    "key": "${BINANCE_API_KEY}",
    "secret": "${BINANCE_API_SECRET}",
    "ccxt_config": {
      "enableRateLimit": false,
      "urls": {
        "api": "http://binance-proxy:8100/binance"
      }
    },
    "pair_whitelist": [...],
    "pair_blacklist": [...]
  }
}
```

#### API Authentication
- **key/secret**: Use environment variables for security
- **enableRateLimit**: Disabled when using binance-proxy
- **urls.api**: Points to rate-limiting proxy

### Trading Pairs
```json
{
  "pair_whitelist": [
    "BTC/USDT",
    "ETH/USDT", 
    "BNB/USDT"
  ],
  "pair_blacklist": [
    "BNB/BTC"
  ]
}
```

#### `pair_whitelist`
- **Purpose**: Allowed trading pairs for strategy
- **Format**: "BASE/QUOTE" (e.g., "BTC/USDT")
- **Strategy**: Different strategies may prefer different pairs

#### `pair_blacklist`
- **Purpose**: Explicitly forbidden pairs
- **Use case**: Exclude problematic or illiquid pairs
- **Priority**: Blacklist overrides whitelist

## Advanced Configuration

### Pair List Filters
```json
{
  "pairlists": [
    {
      "method": "StaticPairList"
    },
    {
      "method": "VolumePairList", 
      "number_assets": 20,
      "sort_key": "quoteVolume"
    },
    {
      "method": "RangeStabilityFilter",
      "lookback_days": 10,
      "min_rate_of_change": 0.02,
      "max_rate_of_change": 0.75
    }
  ]
}
```

#### Available Methods
- **StaticPairList**: Use fixed whitelist
- **VolumePairList**: Select by trading volume
- **RangeStabilityFilter**: Filter by price stability
- **ShuffleFilter**: Randomize pair order
- **SpreadFilter**: Filter by bid-ask spread

### Telegram Configuration
```json
{
  "telegram": {
    "enabled": true,
    "token": "${TELEGRAM_BOT_TOKEN}",
    "chat_id": "${TELEGRAM_CHAT_ID}",
    "notification_settings": {
      "status": "on",
      "warning": "on",
      "startup": "on", 
      "buy": "on",
      "sell": "on",
      "buy_cancel": "on",
      "sell_cancel": "on"
    }
  }
}
```

#### Notification Types
- **status**: Bot status updates
- **warning**: Error and warning messages
- **startup**: Bot start/stop notifications
- **buy/sell**: Trade execution alerts
- **buy_cancel/sell_cancel**: Order cancellation alerts

### Web API Server
```json
{
  "api_server": {
    "enabled": true,
    "listen_ip_address": "0.0.0.0",
    "listen_port": 8101,
    "verbosity": "error",
    "enable_openapi": false,
    "jwt_secret_key": "generated_secret",
    "CORS_origins": [],
    "username": "${WEB_USERNAME}",
    "password": "${WEB_PASSWORD}"
  }
}
```

#### Security Settings
- **listen_ip_address**: "0.0.0.0" allows external access
- **jwt_secret_key**: Automatically generated for security
- **username/password**: From environment variables
- **CORS_origins**: Restrict web interface access

### Internal Settings
```json
{
  "internals": {
    "process_throttle_secs": 5,
    "heartbeat_interval": 60
  }
}
```

#### Performance Tuning
- **process_throttle_secs**: Delay between strategy iterations
- **heartbeat_interval**: Status update frequency
- **Stagger values**: Use different throttle values for multiple strategies

## Strategy-Specific Configurations

### NFI Configuration
```json
{
  "stoploss": -0.99,
  "minimal_roi": {},
  "trailing_stop": false,
  "position_adjustment_enable": true,
  "use_custom_stoploss": true,
  "max_open_trades": 5
}
```
- **Philosophy**: Let strategy manage its own exits
- **Risk management**: Built into strategy logic
- **Position adjustments**: Enabled for averaging

### ReinforcedQuickie Configuration  
```json
{
  "stoploss": -0.1,
  "minimal_roi": {
    "0": 0.05,
    "30": 0.025, 
    "60": 0.01,
    "120": 0
  },
  "timeframe": "5m",
  "max_open_trades": 3
}
```
- **Philosophy**: Quick scalping with traditional risk management
- **Timeframe**: Optimized for 5-minute candles
- **ROI**: Aggressive profit-taking schedule

## Validation and Testing

### Configuration Validation
```bash
# Test configuration syntax
docker run --rm -v "$(pwd)/config:/config" \
  freqtradeorg/freqtrade:latest \
  config validate --config /config/your-config.json

# Test strategy loading
docker run --rm -v "$(pwd):/freqtrade" \
  freqtradeorg/freqtrade:latest \
  list-strategies --config config/your-config.json
```

### Dry-Run Testing
Always test new configurations in dry-run mode:
1. **Set** `"dry_run": true` in template
2. **Launch** bot with new configuration
3. **Monitor** for 24-48 hours minimum
4. **Analyze** simulated performance before going live

### Backtesting Validation
```bash
# Test configuration with backtesting
docker run --rm -v "$(pwd):/freqtrade" \
  freqtradeorg/freqtrade:latest \
  backtesting --config config/your-config.json \
  --strategy YourStrategy \
  --timerange 20230101-20230201
```

## Common Configuration Patterns

### Conservative Setup
- **Small position sizes**: Fixed stake amounts
- **Tight stop losses**: -0.05 to -0.08
- **Few concurrent trades**: 2-3 max_open_trades
- **Major pairs only**: BTC, ETH, BNB
- **Traditional risk management**: Defined ROI and stops

### Aggressive Setup  
- **Larger positions**: Percentage-based or unlimited stakes
- **Wider stops**: -0.10 to -0.15 (or strategy-managed)
- **More concurrent trades**: 5-8 max_open_trades
- **Broader pair selection**: Including altcoins
- **Strategy-driven risk**: Let advanced strategies manage exits

### Multi-Strategy Setup
- **Isolated configurations**: Different templates per strategy
- **Staggered processing**: Different throttle values
- **Pair distribution**: Non-overlapping pair lists
- **Resource allocation**: Balanced stake amounts

## Troubleshooting Configuration

### Common Errors
```json
// Invalid JSON syntax
{
  "max_open_trades": 5,  // Missing comma
  "stake_currency": "USDT"
  "dry_run": true
}

// Correct syntax
{
  "max_open_trades": 5,
  "stake_currency": "USDT",
  "dry_run": true
}
```

### Environment Variable Issues
```bash
# Check if variables are set
echo $BINANCE_API_KEY

# Verify .env file loading
docker run --rm --env-file .env alpine env | grep BINANCE
```

### Validation Tools
```bash
# JSON syntax validation
cat config/your-config.json | jq .

# Freqtrade configuration validation
./docker-launch.sh YourStrategy --dry-run
```

## Security Best Practices

### API Key Protection
- **Never commit** API keys to version control
- **Use environment variables** in all templates
- **Rotate keys regularly** (every 90 days)
- **Monitor API usage** in Binance account

### Configuration Security
- **Secure .env file**: Restrict file permissions (`chmod 600 .env`)
- **Backup securely**: Encrypt backups containing sensitive data
- **Access control**: Limit who can modify configuration files
- **Regular audits**: Review configurations for security issues

## Next Steps

- [Project structure overview](project-structure.md) - Understand file organization
- [Troubleshooting guide](troubleshooting.md) - Solve common configuration issues
- [Strategy documentation](../usage/strategies.md) - Learn about strategy-specific settings