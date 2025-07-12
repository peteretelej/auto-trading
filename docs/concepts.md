---
title: Trading Concepts
layout: default
nav_order: 2
description: "Core concepts behind automated cryptocurrency trading"
permalink: /docs/concepts/
---

# Trading Concepts

This guide explains the core concepts behind automated cryptocurrency trading to help you understand how the system works.

## What is Automated Trading?

Automated trading uses computer programs (bots) to execute trades based on predefined rules and market analysis. Instead of manually watching charts and placing orders, the bot:

1. **Monitors market data** continuously
2. **Analyzes price patterns** using technical indicators  
3. **Makes trading decisions** based on strategy rules
4. **Executes trades** automatically when conditions are met

## How Trading Strategies Work

### Technical Analysis
Trading strategies use **technical indicators** to analyze price movements:
- **Moving Averages**: Smooth out price data to identify trends
- **RSI (Relative Strength Index)**: Measures if assets are overbought/oversold
- **Bollinger Bands**: Show price volatility and potential reversal points
- **MACD**: Identifies trend changes and momentum

### Entry and Exit Signals
Strategies define specific conditions for:
- **Buy signals**: When to enter a trade (e.g., "buy when price crosses above moving average")
- **Sell signals**: When to exit a trade (e.g., "sell when RSI indicates overbought")
- **Stop-loss**: Automatic exit to limit losses if price moves against you

## Available Strategies

This project includes several proven strategies:

### NFI (NostalgiaForInfinity)
- **Type**: Advanced multi-indicator strategy
- **Approach**: Uses sophisticated technical analysis with dynamic risk management
- **Best for**: Experienced traders who understand letting the strategy manage exits
- **Risk management**: Built-in protection mechanisms, uses strategy-specific exits

### ReinforcedQuickie  
- **Type**: Short-term momentum strategy
- **Approach**: Captures quick price movements on 5-minute timeframes
- **Best for**: Active trading with frequent small profits
- **Risk management**: Traditional stop-loss and take-profit levels

### SMAOffset
- **Type**: Trend-following strategy
- **Approach**: Uses simple moving average with offset for entry/exit
- **Best for**: Beginners learning strategy mechanics
- **Risk management**: Clear stop-loss rules

### BbandRsi
- **Type**: Mean reversion strategy  
- **Approach**: Combines Bollinger Bands with RSI for reversal trades
- **Best for**: Range-bound markets
- **Risk management**: Defined exit points based on indicators

## Risk Management Approaches

### Traditional Risk Management
- Fixed stop-loss percentages (e.g., 2-5%)
- Position sizing limits (e.g., 1-2% of capital per trade)
- Maximum number of open trades

### Strategy-Driven Risk Management (Advanced)
- Strategies like NFI manage their own exits using sophisticated logic
- Position adjustments allow averaging into positions
- Dynamic protection based on market conditions
- Requires understanding and trusting the strategy's internal mechanisms

## Key Trading Concepts

### Timeframes
- **1m, 5m**: Very short-term, high-frequency trading
- **15m, 1h**: Short-term momentum trades
- **4h, 1d**: Longer-term trend following

### Market Conditions
- **Trending**: Clear upward or downward price movement
- **Range-bound**: Price moving sideways between support/resistance
- **Volatile**: High price fluctuations and uncertainty

### Performance Metrics
- **Profit/Loss**: Total returns in percentage and absolute terms
- **Win Rate**: Percentage of profitable trades
- **Drawdown**: Maximum loss from peak to trough
- **Sharpe Ratio**: Risk-adjusted returns

## Choosing Your Approach

### For Beginners
1. Start with **SMAOffset** or **BbandRsi**
2. Use traditional risk management
3. Trade small amounts to learn

### For Experienced Traders
1. Consider **NFI** with strategy-driven risk management
2. Understand the strategy's internal logic
3. Monitor performance across market cycles

## Next Steps

Ready to set up your environment? Continue to [Requirements Setup](setup/requirements.md).

Want to understand the project structure? See [Project Reference](reference/project-structure.md).