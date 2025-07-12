# Automated Crypto Trading Bot

Multi-strategy cryptocurrency trading bot using Freqtrade with Binance integration.

## Quick Start

```bash
# 1. Setup
git clone https://gitlab.com/peteretelej/auto-trading.git
cd auto-trading
cp .env.sample .env     # Add your Binance API keys to .env

# 2. Initialize
./scripts/setup-proxy.sh
./scripts/update-configs.sh

# 3. Launch Bots
./docker-launch.sh                      # Default strategy
./docker-launch.sh NFI 1               # Single strategy
./docker-launch.sh All                 # Launch all strategies
```

Monitor your bots at `http://localhost:PORT` (PORT: 8101-8105)

## Available Commands

```bash
# Launch Options
./docker-launch.sh                     # Default strategy
./docker-launch.sh StrategyName 1      # Specific strategy
./docker-launch.sh NFI 1               # NFI with optimized risk settings
./docker-launch.sh All                 # All strategies (NFI, ReinforcedQuickie, SMAOffset, BbandRsi)

# Maintenance
./scripts/monitor-proxy.sh             # Check proxy health
./scripts/backup.sh                    # Backup trading data
```

## Project Structure

- `config/`: Strategy configurations
- `user_data/`: Trading data & strategies
- `scripts/`: Management scripts
  - `setup-proxy.sh`: Initialize binance-proxy
  - `monitor-proxy.sh`: Health monitoring
  - `update-configs.sh`: Update configurations
  - `backup.sh`: Data backup

## Custom Docker Image

The project uses a custom Docker image built on top of freqtradeorg/freqtrade with additional dependencies:
- ta
- pandas-ta
- technical
- scipy
- finta
- schedule
- ccxt
- scikit-learn
- scikit-optimize
- numpy
- statsmodels

The image is built automatically when launching bots for the first time.

## Prerequisites

- Linux with Docker
- Binance account with API keys (trading enabled)
- 8GB RAM minimum
- jq (for config management)

## Resources

- [Freqtrade Docs](https://www.freqtrade.io/en/stable/)
- [Project Documentation](docs/)

⚠️ **Warning**: Cryptocurrency trading carries significant risk. Only trade with funds you can afford to lose.
