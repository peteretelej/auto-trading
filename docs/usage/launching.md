---
title: Launching Strategies
layout: default
parent: Usage Guides
nav_order: 1
description: "How to start and manage trading strategies"
permalink: /docs/usage/launching/
---

# Launching Strategies

This guide covers how to start and manage trading strategies with the auto-trading system.

## Before You Start

### Prerequisites Checklist
- ✅ [Environment setup](../setup/requirements.md) complete
- ✅ [Binance account](../setup/binance.md) configured (API keys in `.env`)
- ✅ [Telegram bot](../setup/telegram.md) setup (optional)
- ✅ Understanding of [trading concepts](../concepts.md)

### Safety First
⚠️ **Always start in dry-run mode** - This simulates trading without real money
⚠️ **Test thoroughly** before risking real capital
⚠️ **Start small** when you do go live

## Basic Launch Commands

### Default Strategy
```bash
# Launch with default settings (ReinforcedAverageStrategy)
./docker-launch.sh
```
- **Port**: 8101
- **Web Interface**: http://localhost:8101
- **Mode**: Dry-run (safe, no real money)

### Specific Strategy
```bash
# Launch a specific strategy
./docker-launch.sh NFI
./docker-launch.sh ReinforcedQuickie  
./docker-launch.sh BbandRsi
./docker-launch.sh SMAOffset
```

### Multiple Strategies
```bash
# Launch multiple strategies on different ports
./docker-launch.sh NFI 0              # Port 8101
./docker-launch.sh ReinforcedQuickie 1 # Port 8102  
./docker-launch.sh BbandRsi 2         # Port 8103
```

## Strategy Options

### Available Strategies

| Strategy | Best For | Timeframe | Risk Level |
|----------|----------|-----------|------------|
| **NFI** | Experienced traders | 1m | Medium-High |
| **ReinforcedQuickie** | Active trading | 5m | Medium |
| **BbandRsi** | Range-bound markets | 15m | Medium |
| **SMAOffset** | Beginners | 1h | Low-Medium |

### Strategy-Specific Configurations
Each strategy has optimized settings in `config/` directory:
- `NFI-config-template.json` - Advanced risk management
- `ReinforcedQuickie-config-template.json` - Short-term momentum
- `BbandRsi-config-template.json` - Mean reversion approach
- `SMAOffset-config-template.json` - Simple trend following

## Understanding the Launch Process

### What Happens When You Launch
1. **Proxy Setup**: Binance rate-limiting proxy starts automatically
2. **Configuration**: Strategy-specific config is generated from template
3. **Container Creation**: Docker container with your strategy launches
4. **Data Directories**: Isolated data directories created for each strategy
5. **API Connection**: Bot connects to Binance and starts monitoring

### Directory Structure Created
```
/your-data-directory/
├── ReinforcedAverageStrategy/     # Default strategy
│   └── user_data/
│       ├── data/                  # Market data
│       ├── logs/                  # Bot logs
│       └── tradesv3.sqlite       # Trade database
├── NFI/                          # NFI strategy instance
├── ReinforcedQuickie/            # Quickie strategy instance
└── ...
```

## Monitoring Your Bots

### Web Interface Access
- **Single bot**: http://localhost:8101
- **Multiple bots**: http://localhost:810X (where X = 1,2,3...)
- **Login**: Use WEB_USERNAME and WEB_PASSWORD from `.env`

### Command Line Monitoring
```bash
# Check running containers
docker ps

# View logs for specific strategy
docker logs freqtrade-NFI

# Monitor all strategies
./scripts/monitor-bots.sh

# Check proxy status
./scripts/monitor-proxy.sh
```

### Key Metrics to Watch
- **Open Trades**: Number of active positions
- **Profit/Loss**: Current performance
- **Win Rate**: Percentage of profitable trades
- **Drawdown**: Maximum loss from peak

## Dry-Run vs Live Trading

### Dry-Run Mode (Default)
- **Safe testing** with simulated money
- **Real market data** and realistic conditions
- **No financial risk** 
- **Perfect for learning** strategy behavior

**Dry-run indicators:**
- Web interface shows "DRY RUN" prominently
- Telegram messages include "DRY RUN" prefix
- Logs show "Dry run enabled"

### Switching to Live Trading

⚠️ **Only do this after thorough testing**

1. **Edit the strategy config** (e.g., `config/NFI-config-template.json`):
   ```json
   "dry_run": false
   ```

2. **Remove dry-run flag** from `docker-launch.sh`:
   ```bash
   # Find this line and remove --dry-run
   --dry-run
   ```

3. **Start with small capital**:
   ```json
   "stake_amount": 10  // Start with $10 per trade
   ```

4. **Restart the bot**:
   ```bash
   docker stop freqtrade-YourStrategy
   ./docker-launch.sh YourStrategy
   ```

## Managing Multiple Strategies

### Resource Considerations
- **RAM**: ~500MB per strategy
- **API Limits**: Binance proxy handles rate limiting
- **Port Usage**: Each strategy needs unique port

### Launching All Strategies
```bash
# Launch primary strategies
./docker-launch.sh NFI 0
./docker-launch.sh ReinforcedQuickie 1
./docker-launch.sh BbandRsi 2

# Wait between launches to stagger startup
sleep 30

# Launch additional strategies
./docker-launch.sh SMAOffset 3
```

### Stopping Strategies
```bash
# Stop specific strategy
docker stop freqtrade-NFI

# Stop all trading bots
docker stop $(docker ps -q --filter name=freqtrade)

# Stop everything including proxy
docker stop $(docker ps -q)
```

## Troubleshooting Launch Issues

### Container Won't Start
```bash
# Check container status
docker ps -a

# View startup logs
docker logs freqtrade-YourStrategy

# Common fixes
./scripts/setup-proxy.sh  # Ensure proxy is running
chmod +x docker-launch.sh # Fix script permissions
```

### API Connection Problems
```
ERROR - Unable to connect to exchange
```
**Solutions:**
1. Check API keys in `.env` file
2. Verify Binance API permissions
3. Ensure proxy is running: `./scripts/setup-proxy.sh`

### Port Already in Use
```
ERROR - Port 8101 already in use
```
**Solutions:**
1. Use different port offset: `./docker-launch.sh Strategy 1`
2. Stop existing container: `docker stop freqtrade-Strategy`
3. Find process using port: `sudo lsof -i :8101`

### Strategy Not Found
```
ERROR - No strategy 'YourStrategy' found
```
**Solutions:**
1. Check available strategies: `ls user_data/strategies/`
2. Verify strategy name spelling
3. Update strategies: `./scripts/update-strategies.sh`

## Best Practices

### Starting Out
1. **Learn one strategy first** - Master one before trying multiple
2. **Monitor closely** - Watch dry-run performance for at least a week
3. **Understand the market** - Learn when your strategy works best
4. **Keep records** - Document what you learn

### Production Running
1. **Regular monitoring** - Check bots daily
2. **Performance reviews** - Weekly analysis of results
3. **Strategy rotation** - Pause strategies during unfavorable conditions
4. **Emergency stops** - Know how to quickly stop all trading

### Risk Management
1. **Start small** - Use minimum stake amounts initially
2. **Diversify** - Don't use all capital on one strategy
3. **Set limits** - Define maximum loss thresholds
4. **Regular reviews** - Weekly performance and risk assessment

## Next Steps

With strategies running:
- [Learn about monitoring and analysis](monitoring.md)
- [Understand strategy configurations](strategies.md)
- [Check the troubleshooting guide](../reference/troubleshooting.md) for common issues