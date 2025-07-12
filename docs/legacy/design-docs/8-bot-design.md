# Freqtrade Bot Expansion: Design Document & Implementation Plan

## 1. Executive Summary

This document outlines the design and implementation plan for expanding our Freqtrade bot setup from 4 to 8 bots running in dry-run mode. The plan includes adding high-performing strategies identified through community testing and performance analysis.

Current bots:
- NFI
- ReinforcedQuickie
- SMAOffset
- BbandRsi

Additional bots to implement:
- ElliotV5_SMA
- MultiMA_TSL
- BB_RPB_TSL_RNG
- BinHV45_987

## 2. Current System Architecture

### 2.1 Directory Structure
```
/
├── config/                     # Configuration templates
│   ├── config-template.json    # Base configuration template
│   ├── NFI-config-template.json
│   ├── ReinforcedQuickie-config-template.json
│   ├── SMAOffset-config-template.json
│   ├── BbandRsi-config-template.json
│   └── ...
├── user_data/
│   └── strategies/             # Strategy implementation files
│       ├── NFI.py
│       ├── berlinguyinca_ReinforcedQuickie.py
│       ├── berlinguyinca_ReinforcedAverageStrategy.py
│       ├── berlinguyinca_ReinforcedSmoothScalp.py
│       └── ...
├── scripts/
│   ├── backup.sh               # Backup utilities
│   ├── monitor-bots.sh         # Bot monitoring
│   ├── monitor-proxy.sh        # Proxy monitoring
│   ├── setup-proxy.sh          # Proxy setup
│   └── update-strategies.sh    # Strategy downloader
└── docker-launch.sh            # Main bot launcher
```

### 2.2 Current Launch Configuration

The `docker-launch.sh` script contains the following key components:

- **Network setup**: Creates Docker network if it doesn't exist
- **Strategy update**: Runs `update-strategies.sh` to download strategy files
- **Proxy check**: Verifies binance-proxy is running
- **Image build**: Builds custom Freqtrade image if needed
- **Bot launch**: Launches containers based on specified strategies
- **Default strategies array**:
  ```bash
  STRATEGIES=("NFI" "ReinforcedQuickie" "SMAOffset" "BbandRsi")
  ```

## 3. Implementation Requirements

### 3.1 New Strategy Files

The following strategy files need to be obtained:

| Strategy | Source | Description |
|----------|--------|-------------|
| ElliotV5_SMA | GitHub | Elliot wave-based strategy with SMA |
| MultiMA_TSL | GitHub | Multiple moving average strategy with trailing stop loss |
| BB_RPB_TSL_RNG | GitHub | Bollinger Bands with Real Pull Back and trailing stop loss |
| BinHV45_987 | GitHub | High-frequency Bollinger Band strategy |

### 3.2 New Configuration Templates

Create config templates for each new strategy with appropriate parameters:

| Strategy | Base ROI | Stoploss | Timeframe | Special Parameters |
|----------|----------|----------|-----------|-------------------|
| ElliotV5_SMA | {"0": 0.10} | -0.189 | 5m | trailing_stop: true |
| MultiMA_TSL | {"0": 0.10} | -0.15 | 5m | trailing_stop: true |
| BB_RPB_TSL_RNG | {"0": 0.10} | -0.99 | 5m | use_custom_stoploss: true |
| BinHV45_987 | {"0": 0.0125} | -0.05 | 1m | N/A |

## 4. Implementation Plan

### 4.1 Strategy File Acquisition

1. Update the `scripts/update-strategies.sh` script to download the new strategy files:

```bash
# Add to update-strategies.sh

# Download ElliotV5_SMA
echo "Downloading ElliotV5_SMA.py from GitHub..."
if wget -q -O "${STRATEGIES_DIR}/ElliotV5_SMA.py" https://raw.githubusercontent.com/5drei1/freqtrade_pub_strats/main/ElliotV5.py; then
    echo "✅ Successfully downloaded ElliotV5_SMA.py"
else
    echo "❌ Failed to download ElliotV5_SMA.py"
    exit 1
fi

# Download MultiMA_TSL
echo "Downloading MultiMA_TSL.py from GitHub..."
if wget -q -O "${STRATEGIES_DIR}/MultiMA_TSL.py" https://raw.githubusercontent.com/stash86/MultiMA_TSL/main/user_data/strategies/MultiMA_TSL.py; then
    echo "✅ Successfully downloaded MultiMA_TSL.py"
else
    echo "❌ Failed to download MultiMA_TSL.py"
    exit 1
fi

# Download BB_RPB_TSL_RNG
echo "Downloading BB_RPB_TSL_RNG.py from GitHub..."
if wget -q -O "${STRATEGIES_DIR}/BB_RPB_TSL_RNG.py" https://raw.githubusercontent.com/jilv220/freqtrade-stuff/main/BB_RPB_TSL_RNG.py; then
    echo "✅ Successfully downloaded BB_RPB_TSL_RNG.py"
else
    echo "❌ Failed to download BB_RPB_TSL_RNG.py"
    exit 1
fi

# Download BinHV45_987
echo "Downloading BinHV45.py from GitHub..."
if wget -q -O "${STRATEGIES_DIR}/BinHV45.py" https://raw.githubusercontent.com/freqtrade/freqtrade-strategies/main/user_data/strategies/berlinguyinca/BinHV45.py; then
    echo "✅ Successfully downloaded BinHV45.py"
else
    echo "❌ Failed to download BinHV45.py"
    exit 1
fi
```

### 4.2 Configuration Template Creation

Create configuration templates for each new strategy:

1. **ElliotV5_SMA-config-template.json**:
```json
{
    "max_open_trades": 6,
    "stake_currency": "USDT",
    "stake_amount": 20,
    "tradable_balance_ratio": 0.99,
    "fiat_display_currency": "USD",
    "dry_run": true,
    "dry_run_wallet": 1000,
    "stoploss": -0.189,
    "trailing_stop": true,
    "trailing_stop_positive": 0.005,
    "trailing_stop_positive_offset": 0.03,
    "trailing_only_offset_is_reached": true,
    "minimal_roi": {
        "0": 0.10
    },
    "exchange": {
        "name": "binance",
        "key": "${BINANCE_API_KEY}",
        "secret": "${BINANCE_API_SECRET}",
        "ccxt_config": {},
        "ccxt_async_config": {},
        "pair_whitelist": [
            "BTC/USDT",
            "ETH/USDT",
            "ADA/USDT",
            "SOL/USDT",
            "BNB/USDT",
            "XRP/USDT",
            "MATIC/USDT",
            "DOT/USDT",
            "LINK/USDT",
            "AVAX/USDT"
        ],
        "pair_blacklist": [
            "BNB/BTC",
            "BNB/ETH",
            ".*UP/USDT",
            ".*DOWN/USDT",
            ".*BEAR/USDT",
            ".*BULL/USDT"
        ]
    },
    "pairlists": [
        {
            "method": "StaticPairList"
        },
        {
            "method": "VolumePairList",
            "number_assets": 20,
            "sort_key": "quoteVolume",
            "min_value": 10000000,
            "refresh_period": 1800
        },
        {
            "method": "AgeFilter",
            "min_days_listed": 30
        },
        {
            "method": "PrecisionFilter"
        },
        {
            "method": "PriceFilter",
            "low_price_ratio": 0.01
        },
        {
            "method": "SpreadFilter",
            "max_spread_ratio": 0.005
        },
        {
            "method": "RangeStabilityFilter",
            "lookback_days": 3,
            "min_rate_of_change": 0.05,
            "refresh_period": 1440
        },
        {
            "method": "VolatilityFilter",
            "lookback_days": 3,
            "min_volatility": 0.02,
            "max_volatility": 0.75,
            "refresh_period": 1440
        }
    ],
    "telegram": {
        "enabled": false,
        "token": "${TELEGRAM_BOT_TOKEN}",
        "chat_id": "${TELEGRAM_CHAT_ID}",
        "notification_settings": {
            "status": "on",
            "warning": "on",
            "startup": "on",
            "entry": "on",
            "exit": "on",
            "entry_fill": "on",
            "exit_fill": "on",
            "entry_cancel": "on",
            "exit_cancel": "on"
        }
    },
    "api_server": {
        "enabled": true,
        "listen_ip_address": "0.0.0.0",
        "listen_port": "${WEB_PORT}",
        "verbosity": "error",
        "enable_openapi": true,
        "jwt_secret_key": "${JWT_SECRET_KEY}",
        "CORS_origins": [
            "http://localhost:${WEB_PORT}",
            "https://trading.ai.etelej.com"
        ],
        "username": "${WEB_USERNAME}",
        "password": "${WEB_PASSWORD}"
    },
    "bot_name": "ElliotBot",
    "initial_state": "running",
    "force_entry_enable": false,
    "internals": {
        "process_throttle_secs": 5
    },
    "order_types": {
        "entry": "limit",
        "exit": "limit",
        "emergency_exit": "market",
        "stoploss": "market",
        "stoploss_on_exchange": true,
        "stoploss_on_exchange_interval": 60
    }
}
```

2. **MultiMA_TSL-config-template.json**:
```json
{
    "max_open_trades": 6,
    "stake_currency": "USDT",
    "stake_amount": 15,
    "tradable_balance_ratio": 0.99,
    "fiat_display_currency": "USD",
    "dry_run": true,
    "dry_run_wallet": 1000,
    "stoploss": -0.15,
    "trailing_stop": true,
    "trailing_stop_positive": 0.01,
    "trailing_stop_positive_offset": 0.02,
    "trailing_only_offset_is_reached": true,
    "minimal_roi": {
        "0": 0.10
    },
    "exchange": {
        "name": "binance",
        "key": "${BINANCE_API_KEY}",
        "secret": "${BINANCE_API_SECRET}",
        "ccxt_config": {},
        "ccxt_async_config": {},
        "pair_whitelist": [
            "BTC/USDT",
            "ETH/USDT",
            "ADA/USDT",
            "SOL/USDT",
            "BNB/USDT",
            "XRP/USDT",
            "MATIC/USDT",
            "DOT/USDT",
            "LINK/USDT",
            "AVAX/USDT"
        ],
        "pair_blacklist": [
            "BNB/BTC",
            "BNB/ETH",
            ".*UP/USDT",
            ".*DOWN/USDT",
            ".*BEAR/USDT",
            ".*BULL/USDT"
        ]
    },
    "pairlists": [
        {
            "method": "StaticPairList"
        },
        {
            "method": "VolumePairList",
            "number_assets": 20,
            "sort_key": "quoteVolume",
            "min_value": 10000000,
            "refresh_period": 1800
        },
        {
            "method": "AgeFilter",
            "min_days_listed": 30
        },
        {
            "method": "PrecisionFilter"
        },
        {
            "method": "PriceFilter",
            "low_price_ratio": 0.01
        },
        {
            "method": "SpreadFilter",
            "max_spread_ratio": 0.005
        },
        {
            "method": "RangeStabilityFilter",
            "lookback_days": 3,
            "min_rate_of_change": 0.05,
            "refresh_period": 1440
        },
        {
            "method": "VolatilityFilter",
            "lookback_days": 3,
            "min_volatility": 0.02,
            "max_volatility": 0.75,
            "refresh_period": 1440
        }
    ],
    "telegram": {
        "enabled": false,
        "token": "${TELEGRAM_BOT_TOKEN}",
        "chat_id": "${TELEGRAM_CHAT_ID}",
        "notification_settings": {
            "status": "on",
            "warning": "on",
            "startup": "on",
            "entry": "on",
            "exit": "on",
            "entry_fill": "on",
            "exit_fill": "on",
            "entry_cancel": "on",
            "exit_cancel": "on"
        }
    },
    "api_server": {
        "enabled": true,
        "listen_ip_address": "0.0.0.0",
        "listen_port": "${WEB_PORT}",
        "verbosity": "error",
        "enable_openapi": true,
        "jwt_secret_key": "${JWT_SECRET_KEY}",
        "CORS_origins": [
            "http://localhost:${WEB_PORT}",
            "https://trading.ai.etelej.com"
        ],
        "username": "${WEB_USERNAME}",
        "password": "${WEB_PASSWORD}"
    },
    "bot_name": "MultiMABot",
    "initial_state": "running",
    "force_entry_enable": false,
    "internals": {
        "process_throttle_secs": 5
    },
    "order_types": {
        "entry": "limit",
        "exit": "limit",
        "emergency_exit": "market",
        "stoploss": "market",
        "stoploss_on_exchange": true,
        "stoploss_on_exchange_interval": 60
    }
}
```

3. **BB_RPB_TSL_RNG-config-template.json**:
```json
{
    "max_open_trades": 6,
    "stake_currency": "USDT",
    "stake_amount": 15,
    "tradable_balance_ratio": 0.99,
    "fiat_display_currency": "USD",
    "dry_run": true,
    "dry_run_wallet": 1000,
    "stoploss": -0.99,
    "use_custom_stoploss": true,
    "minimal_roi": {
        "0": 0.10
    },
    "exchange": {
        "name": "binance",
        "key": "${BINANCE_API_KEY}",
        "secret": "${BINANCE_API_SECRET}",
        "ccxt_config": {},
        "ccxt_async_config": {},
        "pair_whitelist": [
            "BTC/USDT",
            "ETH/USDT",
            "ADA/USDT",
            "SOL/USDT",
            "BNB/USDT",
            "XRP/USDT",
            "MATIC/USDT",
            "DOT/USDT",
            "LINK/USDT",
            "AVAX/USDT"
        ],
        "pair_blacklist": [
            "BNB/BTC",
            "BNB/ETH",
            ".*UP/USDT",
            ".*DOWN/USDT",
            ".*BEAR/USDT",
            ".*BULL/USDT"
        ]
    },
    "pairlists": [
        {
            "method": "StaticPairList"
        },
        {
            "method": "VolumePairList",
            "number_assets": 20,
            "sort_key": "quoteVolume",
            "min_value": 10000000,
            "refresh_period": 1800
        },
        {
            "method": "AgeFilter",
            "min_days_listed": 30
        },
        {
            "method": "PrecisionFilter"
        },
        {
            "method": "PriceFilter",
            "low_price_ratio": 0.01
        },
        {
            "method": "SpreadFilter",
            "max_spread_ratio": 0.005
        },
        {
            "method": "RangeStabilityFilter",
            "lookback_days": 3,
            "min_rate_of_change": 0.05,
            "refresh_period": 1440
        },
        {
            "method": "VolatilityFilter",
            "lookback_days": 3,
            "min_volatility": 0.02,
            "max_volatility": 0.75,
            "refresh_period": 1440
        }
    ],
    "telegram": {
        "enabled": false,
        "token": "${TELEGRAM_BOT_TOKEN}",
        "chat_id": "${TELEGRAM_CHAT_ID}",
        "notification_settings": {
            "status": "on",
            "warning": "on",
            "startup": "on",
            "entry": "on",
            "exit": "on",
            "entry_fill": "on",
            "exit_fill": "on",
            "entry_cancel": "on",
            "exit_cancel": "on"
        }
    },
    "api_server": {
        "enabled": true,
        "listen_ip_address": "0.0.0.0",
        "listen_port": "${WEB_PORT}",
        "verbosity": "error",
        "enable_openapi": true,
        "jwt_secret_key": "${JWT_SECRET_KEY}",
        "CORS_origins": [
            "http://localhost:${WEB_PORT}",
            "https://trading.ai.etelej.com"
        ],
        "username": "${WEB_USERNAME}",
        "password": "${WEB_PASSWORD}"
    },
    "bot_name": "BB_RPB_Bot",
    "initial_state": "running",
    "force_entry_enable": false,
    "internals": {
        "process_throttle_secs": 5
    },
    "order_types": {
        "entry": "limit",
        "exit": "limit",
        "emergency_exit": "market",
        "stoploss": "market",
        "stoploss_on_exchange": true,
        "stoploss_on_exchange_interval": 60
    }
}
```

4. **BinHV45-config-template.json**:
```json
{
    "max_open_trades": 6,
    "stake_currency": "USDT",
    "stake_amount": 15,
    "tradable_balance_ratio": 0.99,
    "fiat_display_currency": "USD",
    "dry_run": true,
    "dry_run_wallet": 1000,
    "stoploss": -0.05,
    "minimal_roi": {
        "0": 0.0125
    },
    "timeframe": "1m",
    "exchange": {
        "name": "binance",
        "key": "${BINANCE_API_KEY}",
        "secret": "${BINANCE_API_SECRET}",
        "ccxt_config": {},
        "ccxt_async_config": {},
        "pair_whitelist": [
            "BTC/USDT",
            "ETH/USDT",
            "ADA/USDT",
            "SOL/USDT",
            "BNB/USDT",
            "XRP/USDT",
            "MATIC/USDT",
            "DOT/USDT",
            "LINK/USDT",
            "AVAX/USDT"
        ],
        "pair_blacklist": [
            "BNB/BTC",
            "BNB/ETH",
            ".*UP/USDT",
            ".*DOWN/USDT",
            ".*BEAR/USDT",
            ".*BULL/USDT"
        ]
    },
    "pairlists": [
        {
            "method": "StaticPairList"
        },
        {
            "method": "VolumePairList",
            "number_assets": 20,
            "sort_key": "quoteVolume",
            "min_value": 10000000,
            "refresh_period": 1800
        },
        {
            "method": "AgeFilter",
            "min_days_listed": 30
        },
        {
            "method": "PrecisionFilter"
        },
        {
            "method": "PriceFilter",
            "low_price_ratio": 0.01
        },
        {
            "method": "SpreadFilter",
            "max_spread_ratio": 0.005
        },
        {
            "method": "RangeStabilityFilter",
            "lookback_days": 3,
            "min_rate_of_change": 0.05,
            "refresh_period": 1440
        },
        {
            "method": "VolatilityFilter",
            "lookback_days": 3,
            "min_volatility": 0.02,
            "max_volatility": 0.75,
            "refresh_period": 1440
        }
    ],
    "telegram": {
        "enabled": false,
        "token": "${TELEGRAM_BOT_TOKEN}",
        "chat_id": "${TELEGRAM_CHAT_ID}",
        "notification_settings": {
            "status": "on",
            "warning": "on",
            "startup": "on",
            "entry": "on",
            "exit": "on",
            "entry_fill": "on",
            "exit_fill": "on",
            "entry_cancel": "on",
            "exit_cancel": "on"
        }
    },
    "api_server": {
        "enabled": true,
        "listen_ip_address": "0.0.0.0",
        "listen_port": "${WEB_PORT}",
        "verbosity": "error",
        "enable_openapi": true,
        "jwt_secret_key": "${JWT_SECRET_KEY}",
        "CORS_origins": [
            "http://localhost:${WEB_PORT}",
            "https://trading.ai.etelej.com"
        ],
        "username": "${WEB_USERNAME}",
        "password": "${WEB_PASSWORD}"
    },
    "bot_name": "BinHV45Bot",
    "initial_state": "running",
    "force_entry_enable": false,
    "internals": {
        "process_throttle_secs": 5
    },
    "order_types": {
        "entry": "limit",
        "exit": "limit",
        "emergency_exit": "market",
        "stoploss": "market",
        "stoploss_on_exchange": true,
        "stoploss_on_exchange_interval": 60
    }
}
```

### 4.3 Docker Launch Script Update

Update the `docker-launch.sh` script to include the new strategies in the `STRATEGIES` array:

```bash
# Default strategies to launch when using "All"
STRATEGIES=("NFI" "ReinforcedQuickie" "SMAOffset" "BbandRsi" "ElliotV5_SMA" "MultiMA_TSL" "BB_RPB_TSL_RNG" "BinHV45")
```

### 4.4 System Check and Capacity Testing

Ensure our system has sufficient resources:

1. **RAM requirements**: With 8 bots, estimate 300-500MB per bot = 2.4-4GB total
2. **CPU requirements**: Estimate 0.2-0.5 CPU cores per bot = 1.6-4 cores total
3. **Storage requirements**: Minimal impact, mainly for logs and DB files

Create a simple resource monitoring script (`scripts/check-resources.sh`):

```bash
#!/bin/bash
set -e

echo "=== SYSTEM RESOURCE CHECK ==="
echo ""

# Check CPU usage
echo "CPU Usage by Bot Containers:"
echo "---------------------------------"
docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}" | grep freqtrade

# Check Memory
echo ""
echo "System Memory Status:"
echo "---------------------------------"
free -h

# Check Disk Space
echo ""
echo "Disk Space Status:"
echo "---------------------------------"
df -h | grep -E '/$|/home'

# Check Docker Space
echo ""
echo "Docker Disk Usage:"
echo "---------------------------------"
docker system df

echo ""
echo "=== END RESOURCE CHECK ==="
```

## 5. Implementation Steps

### 5.1 Preparation Phase

1. **Backup current configuration**:
   ```bash
   ./scripts/backup.sh
   ```

2. **Create new strategy files**:
   - Create a new branch or backup before modifying the update-strategies.sh script
   - Update and run `scripts/update-strategies.sh` to download new strategy files
   - Verify the strategy files are correctly downloaded to `user_data/strategies/`

3. **Create configuration templates**:
   - Create the 4 new configuration template files in the `config/` directory

4. **Update docker-launch.sh**:
   - Update the STRATEGIES array to include all 8 strategies
   - Test the changes with a single strategy first

### 5.2 Testing Phase

1. **Individual Strategy Testing**:
   - Test each new strategy individually before running all 8 simultaneously
   ```bash
   ./docker-launch.sh ElliotV5_SMA 1
   ./docker-launch.sh MultiMA_TSL 1
   ./docker-launch.sh BB_RPB_TSL_RNG 1
   ./docker-launch.sh BinHV45 1
   ```

2. **Resource Monitoring**:
   - Run the resource monitoring script during testing to ensure system capacity
   ```bash
   ./scripts/check-resources.sh
   ```

3. **Proxy Monitoring**:
   - Monitor the Binance proxy for any rate limit issues
   ```bash
   ./scripts/monitor-proxy.sh
   ```

### 5.3 Full Deployment

1. **Stop All Current Bots**:
   ```bash
   ./docker-launch.sh All stop
   ```

2. **Launch All 8 Bots**:
   ```bash
   ./docker-launch.sh All
   ```

3. **Verify Operation**:
   ```bash
   ./scripts/monitor-bots.sh
   ```

4. **Monitor Performance**:
   - Check the Web UI for each bot (ports 8101-8108)
   - Run periodic monitoring for the first 24-48 hours
   - Verify trade logs and performance metrics

## 6. Troubleshooting Guide

### 6.1 Common Issues

1. **Strategy Loading Errors**:
   - Check if the strategy file exists in `user_data/strategies/`
   - Verify dependencies in requirements.txt
   - Look for Python syntax errors in the strategy files

2. **Configuration Issues**:
   - Check for JSON syntax errors in config templates
   - Ensure environment variables are correctly substituted
   - Verify port assignments are unique

3. **Resource Constraints**:
   - If memory usage is too high, adjust `process_throttle_secs` to higher values
   - Consider reducing pair_whitelist size for memory-intensive strategies

### 6.2 Rollback Procedure

If issues occur, follow this rollback procedure:

1. Stop all bots:
   ```bash
   ./docker-launch.sh All stop
   ```

2. Restore from backup:
   ```bash
   # Restore config files
   cp backups/[latest-backup]/config/* config/
   
   # Restore strategy files
   cp backups/[latest-backup]/user_data/strategies/* user_data/strategies/
   ```

3. Revert docker-launch.sh changes:
   ```bash
   # Edit docker-launch.sh and restore original STRATEGIES array
   STRATEGIES=("NFI" "ReinforcedQuickie" "SMAOffset" "BbandRsi")
   ```

4. Restart original bots:
   ```bash
   ./docker-launch.sh All
   ```

## 7. Maintenance Plan

### 7.1 Regular Monitoring Tasks

1. **Daily Checks**:
   - Run `./scripts/monitor-bots.sh` to check bot status
   - Run `./scripts/monitor-proxy.sh` to check proxy status
   - Review performance metrics in Web UI

2. **Weekly Maintenance**:
   - Run `./scripts/backup.sh` to create backups
   - Check for strategy updates
   - Review performance and consider strategy adjustments

### 7.2 Performance Optimization

After 2-4 weeks of operation, evaluate performance:

1. **Strategy Comparison**:
   - Compare win rates, profit per trade, total profit
   - Identify best and worst performing strategies

2. **Configuration Tuning**:
   - Adjust ROI and stoploss parameters based on performance
   - Consider hyperopt for top-performing strategies

3. **Possible Replacements**:
   - Consider replacing worst-performing strategies with new alternatives
   - Keep researching community strategies for better options

## 8. Future Considerations

### 8.1 Live Trading Migration Path

When ready for live trading:

1. Update config files to set `"dry_run": false`
2. Adjust position sizing (`stake_amount`) for real-money risk management
3. Enable Telegram notifications for at least one "main" bot
4. Start with small capital allocation (10-20% of intended amount)
5. Gradually increase allocation based on performance

### 8.2 Advanced Features to Explore

1. **Strategy Diversification**:
   - Consider timeframe diversity (mixing 5m, 15m, 1h strategies)
   - Implement different strategy types (trend-following, mean-reversion, etc.)

2. **Custom Indicators**:
   - Explore custom indicator development for strategy enhancements
   - Consider machine learning features through FreqAI

3. **Risk Management Improvements**:
   - Implement dynamic position sizing
   - Develop custom trailing stoploss rules
   - Explore portfolio-wide risk controls
