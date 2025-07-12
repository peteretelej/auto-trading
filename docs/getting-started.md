---
title: Getting Started
layout: default
nav_order: 1
description: "Complete setup guide for the cryptocurrency trading bot"
---

# Getting Started

This guide helps you understand and set up the auto-trading system. Follow these steps in order for the best experience.

## What You'll Learn

By the end of this guide, you'll understand:
- How automated cryptocurrency trading works
- What tools and accounts you need
- How to run your first trading bot safely

## Prerequisites

Before starting, ensure you have:
- **Linux system with Docker** (8GB RAM minimum)
- **Binance account** (for cryptocurrency trading)
- **Basic command line familiarity**
- **$100-200 initial capital** (optional, for live trading)

## Step-by-Step Setup

### 1. Understand the Concepts
Start by reading [Trading Concepts](concepts.md) to understand:
- How automated trading strategies work
- Risk management principles
- The different strategies available

### 2. Set Up Your Environment
Follow the [Requirements Setup](setup/requirements.md) to:
- Install Docker and clone the project
- Prepare your local environment

### 3. Configure External Services
Set up your trading infrastructure:
- [Binance Account Setup](setup/binance.md) - Exchange account and API keys
- [Telegram Bot Setup](setup/telegram.md) - Trade notifications (optional)

### 4. Launch Your First Bot
Once everything is configured:
- Read [Launching Strategies](usage/launching.md)
- Start with dry-run mode (no real money)
- Monitor performance with [Monitoring Guide](usage/monitoring.md)

## Safety First

⚠️ **Always start in dry-run mode** - This simulates trades without risking real money

⚠️ **Start small** - Use only money you can afford to lose when going live

⚠️ **Understand the risks** - Cryptocurrency trading can result in significant losses

## Getting Help

- **Project Structure**: See [Project Reference](reference/project-structure.md)
- **Common Issues**: Check [Troubleshooting](reference/troubleshooting.md)
- **Configuration Details**: Review [Configuration Reference](reference/configuration.md)

## Quick Start (Experienced Users)

```bash
# Clone and setup
git clone https://github.com/peteretelej/auto-trading.git
cd auto-trading
cp .env.sample .env
# Add your API keys to .env

# Launch default strategy in dry-run
./scripts/setup-proxy.sh
./docker-launch.sh

# Access web interface
open http://localhost:8101
```

For detailed instructions, continue with the [concepts guide](concepts.md).