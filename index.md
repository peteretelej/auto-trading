---
layout: home
title: Auto-Trading Bot
---

# Archived Cryptocurrency Trading Bot

⚠️ **ARCHIVED PROJECT** - This repository is no longer maintained or supported.

This project was an experimental multi-strategy cryptocurrency trading bot built with FreqTrade and Docker. It includes various trading strategies, risk management features, and comprehensive documentation.

## ⚠️ Important Disclaimers

- **No Support**: This project is archived and will not receive updates or support
- **Use at Your Own Risk**: Cryptocurrency trading carries significant financial risk
- **No Guarantees**: Past performance does not guarantee future results
- **Educational Purpose**: This code is shared for educational and reference purposes only

## Features

- Multiple pre-configured trading strategies (NFI, ReinforcedQuickie, SMAOffset, BbandRsi)
- Docker-based deployment for easy setup
- Binance integration with proxy support
- Risk management and configuration templates
- Comprehensive documentation and setup guides

## Quick Links

- [Setup Guide](docs/setup-guide/) - Complete setup instructions
- [Project Reference](docs/project-reference-guide/) - Navigate the codebase
- [About the Project](docs/about-project/) - Goals and parameters
- [GitHub Repository](https://github.com/peteretelej/auto-trading)

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

**Remember**: Only trade with funds you can afford to lose. This software is provided as-is without any warranties.