# Automated Crypto Trading Project

## Project Overview
This project explores automated trading in cryptocurrency markets as a potential supplementary income source. The approach focuses on leveraging existing tools and platforms rather than developing trading expertise from scratch, with emphasis on risk management and sustainable trading practices.

## Investment Parameters
- **Initial Investment**: $1,000 USD (hard cap)
- **Reinvestment Strategy**: Profits will be reinvested; no additional capital will be added
- **Time Commitment**: Side project (part-time)

## Project Goals
1. Implement reliable automated trading using Freqtrade (with potential to add GoCryptoTrader later)
2. Establish a trading system with appropriate risk management guardrails
3. Evaluate the viability of automated trading as a supplementary income source
4. Develop a sustainable trading approach requiring minimal daily time investment

## Tool & Platform Decisions

### Trading Platform
- **Primary tool**: Freqtrade
  - Open-source, community-supported Python-based trading bot
  - Extensive documentation and active community
  - Built-in backtesting, simulation, and risk management features
  
### Supported Exchanges
- **Primary**: Binance (accessible in Kenya via P2P with M-Pesa)

## Success Criteria
- System operates with minimal daily intervention (1-2 hours/week)
- Capital preservation (avoid significant drawdowns)
- Consistent, even if modest, returns over time (1-5% monthly is considered successful)
- Clear metrics for evaluating performance and profitability

## Risk Management Parameters
- Leverage advanced strategy-based risk management
- Allow strategy-specific position sizing (position_adjustment enabled)
- Diversification across multiple trading pairs (via strategy pairlists)
- Use strategy's built-in protection and exit logic instead of fixed stoploss
- Start with 20-30% of total capital for initial live trading

## Strategy-Based Risk Management Approach

When using advanced strategies like NostalgiaForInfinity (NFI), we follow community best practices:

1. **Strategy-Driven Exits**: NFI and similar advanced strategies incorporate sophisticated technical analysis and exit conditions that often perform better than simple stoplosses. We configure permissive stoplosses (-0.99) to allow these built-in mechanisms to work as designed.

2. **Custom Protection Logic**: These strategies include protection mechanisms that adapt to market conditions, reducing exposure during downtrends and managing risk dynamically.

3. **Multiple Trade Entries**: Position adjustment is enabled to allow the strategy to average positions at favorable price points, improving overall trade performance.

4. **Parameter Optimization**: Instead of fixed risk percentages, we optimize strategy-specific parameters based on backtesting results and live performance.

5. **Gradual Capital Deployment**: We scale capital allocation based on demonstrated strategy performance rather than fixed percentages.
