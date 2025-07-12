# Automated Crypto Trading Bot

⚠️ **ARCHIVED PROJECT** - No longer maintained or supported.

Multi-strategy cryptocurrency trading bot using Freqtrade with Binance integration.

This project provides infrastructure and guidance for running multiple FreqTrade strategies simultaneously. It includes Docker deployment configuration, rate-limiting proxy setup, monitoring scripts, strategy-specific configuration templates, and complete setup documentation. The infrastructure work for multi-strategy automated trading is already done.

**Note**: This project was [open sourced with Claude Code assistance](https://github.com/peteretelej/auto-trading/commit/1d439e9fb4e7914e815337dce262b17a1305e948) for educational sharing purposes.

**Important**: This project is shared for educational purposes only. Cryptocurrency trading carries significant risk. Use at your own risk.

## Quick Start

```bash
# 1. Setup
git clone https://github.com/peteretelej/auto-trading.git
cd auto-trading
cp .env.sample .env     # Add your Binance API keys to .env

# 2. Initialize
./scripts/setup-proxy.sh

# 3. Launch Bots
./docker-launch.sh                      # Default strategy  
./docker-launch.sh NFI 1               # Specific strategy
./docker-launch.sh ReinforcedQuickie 2 # Multiple strategies
```

Monitor your bots at `http://localhost:8101` (additional bots use 8102, 8103, etc.)

## Available Strategies

| Strategy | Best For | Risk Level |
|----------|----------|------------|
| **NFI** | Experienced traders | Medium-High |
| **ReinforcedQuickie** | Active trading | Medium |
| **BbandRsi** | Range-bound markets | Medium |
| **SMAOffset** | Beginners | Low-Medium |

## Launch Commands

```bash
# Single strategy
./docker-launch.sh NFI                 # Advanced strategy
./docker-launch.sh ReinforcedQuickie   # Quick momentum trades
./docker-launch.sh BbandRsi            # Mean reversion
./docker-launch.sh SMAOffset           # Simple trend following

# Multiple strategies (different ports)
./docker-launch.sh NFI 0               # Port 8101
./docker-launch.sh ReinforcedQuickie 1 # Port 8102
./docker-launch.sh BbandRsi 2          # Port 8103

# Management
./scripts/monitor-bots.sh              # Check all bot status
./scripts/backup.sh                    # Backup trading data
```

## Documentation

**Complete setup and usage guides:** [docs.peteretelej.github.io/auto-trading](https://peteretelej.github.io/auto-trading)

### Quick Links
- **[Getting Started](docs/getting-started.md)** - New user guide and setup overview
- **[Trading Concepts](docs/concepts.md)** - Understand how automated trading works
- **[Setup Guides](docs/setup/)** - Environment, Binance, and Telegram configuration
- **[Usage Guides](docs/usage/)** - Launching, monitoring, and strategy management
- **[Reference](docs/reference/)** - Technical documentation and troubleshooting

### Key Documentation
- [Requirements Setup](docs/setup/requirements.md) - Technical prerequisites
- [Binance Setup](docs/setup/binance.md) - Exchange account configuration
- [Launching Strategies](docs/usage/launching.md) - Running your first bot
- [Monitoring Guide](docs/usage/monitoring.md) - Performance tracking
- [Troubleshooting](docs/reference/troubleshooting.md) - Common issues and solutions

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

- **[Project Documentation](https://peteretelej.github.io/auto-trading)** - Complete guides and references
- [Freqtrade Documentation](https://www.freqtrade.io/en/stable/) - Official FreqTrade docs
- [Binance API Documentation](https://binance-docs.github.io/apidocs/) - Exchange API reference

## Important Disclaimers

⚠️ **ARCHIVED**: This project is no longer maintained or supported  
⚠️ **RISK**: Cryptocurrency trading carries significant financial risk  
⚠️ **NO GUARANTEES**: Past performance does not guarantee future results  
⚠️ **EDUCATIONAL**: This code is shared for educational and reference purposes only

**Only trade with funds you can afford to lose.**
