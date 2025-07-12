---
layout: home
title: Auto-Trading Bot
---

# Archived Cryptocurrency Trading Bot

⚠️ **ARCHIVED PROJECT** - This repository is no longer maintained or supported.

This project was an experimental multi-strategy cryptocurrency trading setup built with FreqTrade and Docker. It provides infrastructure and guidance for running multiple trading strategies simultaneously, including Docker deployment configuration, rate-limiting proxy setup, monitoring scripts, strategy-specific configuration templates, and complete setup documentation. The infrastructure work for multi-strategy automated trading is already done.

## ⚠️ Important Disclaimers

- **No Support**: This project is archived and will not receive updates or support
- **Use at Your Own Risk**: Cryptocurrency trading carries significant financial risk
- **No Guarantees**: Past performance does not guarantee future results
- **Educational Purpose**: This code is shared for educational and reference purposes only

## Features

- Infrastructure for running multiple FreqTrade strategies simultaneously
- Docker-based deployment with isolated strategy instances
- Binance rate-limiting proxy for multiple concurrent bots
- Strategy-specific configuration templates and risk management
- Comprehensive setup documentation and monitoring tools

## Quick Start Path

New to automated trading? Follow this educational sequence:

1. **[Getting Started](docs/getting-started/)** - Overview and prerequisites  
2. **[Trading Concepts](docs/concepts/)** - Understand how strategies work
3. **[Setup Guides](docs/setup/)** - Configure your environment and accounts
4. **[Launch Your First Bot](docs/usage/launching/)** - Start trading safely
5. **[Monitor Performance](docs/usage/monitoring/)** - Track and analyze results

## Documentation Sections

### Setup and Configuration
- **[Requirements](docs/setup/requirements/)** - Technical prerequisites and installation
- **[Binance Account](docs/setup/binance/)** - Exchange setup and API configuration  
- **[Telegram Bot](docs/setup/telegram/)** - Optional trade notifications

### Using the System  
- **[Launching Strategies](docs/usage/launching/)** - Running and managing trading bots
- **[Strategy Guide](docs/usage/strategies/)** - Available strategies and configurations
- **[Monitoring](docs/usage/monitoring/)** - Performance tracking and analysis

### Technical Reference
- **[Project Structure](docs/reference/project-structure/)** - File organization and architecture
- **[Configuration](docs/reference/configuration/)** - Detailed parameter explanations
- **[Troubleshooting](docs/reference/troubleshooting/)** - Common issues and solutions

## Quick Links

- **[GitHub Repository](https://github.com/peteretelej/auto-trading)** - Source code and releases
- **[FreqTrade Documentation](https://www.freqtrade.io/en/stable/)** - Official trading framework docs
- **[Original Project Goals](docs/about-project/)** - Context and objectives

## Getting Started

```bash
# Clone the repository
git clone https://github.com/peteretelej/auto-trading.git
cd auto-trading

# Setup environment
cp .env.sample .env     # Add your API keys

# Initialize and launch
./scripts/setup-proxy.sh
./docker-launch.sh
```

Monitor your bots at `http://localhost:8101-8105`

## Documentation

All documentation is available in the `docs/` folder and on this site:

- Complete setup instructions for Binance, Telegram, and local development
- Project structure and navigation guide
- Strategy configuration and risk management
- Deployment and monitoring guides

---

**Documentation**: This comprehensive documentation was created with [Claude Code assistance](https://github.com/peteretelej/auto-trading/commit/1d439e9fb4e7914e815337dce262b17a1305e948) to transform internal development notes into educational resources suitable for open source sharing.

**Remember**: Only trade with funds you can afford to lose. This software is provided as-is without any warranties.