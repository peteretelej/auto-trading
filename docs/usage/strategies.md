# Trading Strategies

This guide explains the available trading strategies, their characteristics, and how to configure them effectively.

## Strategy Overview

Each strategy has different strengths and is optimized for specific market conditions:

| Strategy | Type | Timeframe | Risk Level | Best Markets |
|----------|------|-----------|------------|--------------|
| **NFI** | Advanced Multi-Indicator | 1m | Medium-High | Trending & Volatile |
| **ReinforcedQuickie** | Momentum Scalping | 5m | Medium | Active Trading |
| **BbandRsi** | Mean Reversion | 15m | Medium | Range-Bound |
| **SMAOffset** | Trend Following | 1h | Low-Medium | Clear Trends |

## Strategy Descriptions

### NFI (NostalgiaForInfinity)

**Overview**: Advanced strategy using sophisticated technical analysis with dynamic risk management.

**Key Features**:
- Multiple timeframe analysis
- Advanced entry/exit logic
- Built-in protection mechanisms
- Position adjustment capabilities
- Dynamic risk management

**Best For**:
- Experienced traders who understand complex strategies
- Users comfortable with strategy-managed exits
- Markets with good volatility and liquidity

**Risk Management Approach**:
```json
{
  "stoploss": -0.99,                 // Let strategy manage exits
  "position_adjustment_enable": true, // Allow position averaging
  "use_custom_stoploss": true        // Use strategy's exit logic
}
```

**Configuration**: Uses `NFI-config-template.json`

### ReinforcedQuickie

**Overview**: Short-term momentum strategy designed for quick scalping trades.

**Key Features**:
- Fast 5-minute timeframe
- Quick entry/exit signals
- Momentum-based indicators
- Traditional risk management

**Best For**:
- Active trading approach
- Users who prefer frequent trading
- Markets with good intraday movement

**Risk Management Approach**:
```json
{
  "stoploss": -0.1,              // 10% stop-loss
  "minimal_roi": {               // Take profit levels
    "0": 0.05,                  // 5% immediate
    "30": 0.025,                // 2.5% after 30 min
    "60": 0.01,                 // 1% after 1 hour
    "120": 0                    // Break-even after 2 hours
  }
}
```

**Configuration**: Uses `ReinforcedQuickie-config-template.json`

### BbandRsi

**Overview**: Mean reversion strategy using Bollinger Bands and RSI indicators.

**Key Features**:
- Bollinger Bands for volatility measurement
- RSI for overbought/oversold conditions
- Mean reversion approach
- Clear entry/exit rules

**Best For**:
- Range-bound markets
- Users who prefer lower-frequency trading
- Conservative trading approach

**Risk Management Approach**:
```json
{
  "stoploss": -0.05,             // 5% stop-loss
  "minimal_roi": {               // Conservative profit targets
    "0": 0.02,                  // 2% immediate
    "60": 0.01,                 // 1% after 1 hour
    "120": 0.005,               // 0.5% after 2 hours
    "180": 0                    // Break-even after 3 hours
  }
}
```

**Configuration**: Uses `BbandRsi-config-template.json`

### SMAOffset

**Overview**: Simple trend-following strategy using moving averages with offset.

**Key Features**:
- Simple Moving Average (SMA) based
- Offset mechanism for entry timing
- Easy to understand logic
- Beginner-friendly approach

**Best For**:
- Beginners learning strategy mechanics
- Clear trending markets
- Users who want simple, understandable logic

**Risk Management Approach**:
```json
{
  "stoploss": -0.08,             // 8% stop-loss
  "minimal_roi": {               // Gradual profit taking
    "0": 0.04,                  // 4% immediate
    "60": 0.02,                 // 2% after 1 hour
    "120": 0.01,                // 1% after 2 hours
    "240": 0                    // Break-even after 4 hours
  }
}
```

**Configuration**: Uses `SMAOffset-config-template.json`

## Strategy Configuration

### Configuration Templates

Each strategy has an optimized configuration template in the `config/` directory:

```
config/
├── NFI-config-template.json                    # NFI specific settings
├── ReinforcedQuickie-config-template.json     # Quickie specific settings  
├── BbandRsi-config-template.json              # BbandRsi specific settings
├── SMAOffset-config-template.json             # SMAOffset specific settings
└── config-template.json                       # Default fallback template
```

### Key Configuration Sections

#### Trading Parameters
```json
{
  "max_open_trades": 5,          // Maximum simultaneous trades
  "stake_currency": "USDT",      // Base currency for trading
  "stake_amount": "unlimited",   // Amount per trade
  "tradable_balance_ratio": 0.99 // Percentage of balance to use
}
```

#### Risk Management
```json
{
  "stoploss": -0.1,              // Stop-loss percentage
  "trailing_stop": false,        // Use trailing stops
  "minimal_roi": {...},          // Take profit levels
  "position_adjustment_enable": true // Allow position adjustments
}
```

#### Trading Pairs
```json
{
  "pair_whitelist": [            // Allowed trading pairs
    "BTC/USDT",
    "ETH/USDT", 
    "BNB/USDT"
  ],
  "pair_blacklist": [            // Prohibited pairs
    "BNB/BTC"
  ]
}
```

## Choosing the Right Strategy

### For Beginners
**Recommended**: SMAOffset or BbandRsi
- **Why**: Simple logic, traditional risk management
- **Start with**: Small position sizes, dry-run mode
- **Focus on**: Understanding how strategies work

### For Intermediate Users
**Recommended**: ReinforcedQuickie
- **Why**: More active trading, good learning opportunity
- **Start with**: Moderate position sizes, monitor closely
- **Focus on**: Performance analysis and optimization

### For Advanced Users
**Recommended**: NFI with strategy-driven risk management
- **Why**: Sophisticated approach, potentially higher returns
- **Start with**: Understanding strategy internals
- **Focus on**: Trust the strategy's built-in mechanisms

## Strategy Performance Comparison

### Backtesting Results (Example)
*Note: Past performance doesn't guarantee future results*

| Strategy | 6-Month Return | Max Drawdown | Win Rate | Trades/Day |
|----------|----------------|--------------|----------|------------|
| NFI | 15.2% | -8.1% | 52% | 3.2 |
| ReinforcedQuickie | 12.8% | -12.3% | 48% | 8.7 |
| BbandRsi | 8.4% | -5.2% | 58% | 1.8 |
| SMAOffset | 6.1% | -4.8% | 55% | 1.2 |

### Market Condition Performance

#### Trending Markets (Strong directional movement)
1. **NFI** - Excellent trend following capabilities
2. **SMAOffset** - Good basic trend following
3. **ReinforcedQuickie** - Benefits from momentum
4. **BbandRsi** - May struggle with continuous trends

#### Range-Bound Markets (Sideways movement)
1. **BbandRsi** - Designed for mean reversion
2. **ReinforcedQuickie** - Can capture short-term swings
3. **NFI** - Adaptive to various conditions
4. **SMAOffset** - May generate false signals

#### Volatile Markets (High price swings)
1. **NFI** - Advanced volatility handling
2. **ReinforcedQuickie** - Quick exits limit exposure
3. **BbandRsi** - Good volatility indicators
4. **SMAOffset** - May be whipsawed

## Customizing Strategies

### Adjusting Risk Parameters

#### Conservative Approach
```json
{
  "max_open_trades": 2,          // Fewer simultaneous trades
  "stake_amount": 20,            // Fixed small amount per trade
  "stoploss": -0.05              // Tighter stop-loss
}
```

#### Aggressive Approach  
```json
{
  "max_open_trades": 8,          // More simultaneous trades
  "stake_amount": "unlimited",   // Use available balance
  "stoploss": -0.15              // Wider stop-loss
}
```

### Pair Selection Strategies

#### Conservative Pairs (Major cryptocurrencies)
```json
{
  "pair_whitelist": [
    "BTC/USDT", "ETH/USDT", "BNB/USDT", 
    "ADA/USDT", "DOT/USDT"
  ]
}
```

#### Aggressive Pairs (Including altcoins)
```json
{
  "pair_whitelist": [
    "BTC/USDT", "ETH/USDT", "BNB/USDT",
    "LINK/USDT", "UNI/USDT", "AAVE/USDT",
    "SUSHI/USDT", "COMP/USDT"
  ]
}
```

## Strategy Maintenance

### Regular Reviews

#### Weekly Strategy Assessment
1. **Performance comparison** - Which strategies are outperforming?
2. **Market condition analysis** - Are current conditions suitable?
3. **Risk evaluation** - Are drawdowns within acceptable limits?
4. **Adjustment considerations** - Should parameters be modified?

#### Monthly Strategy Rotation
1. **Pause underperforming strategies** - Stop strategies consistently losing
2. **Increase allocation** to successful strategies
3. **Test new configurations** - Experiment with parameter adjustments
4. **Market cycle considerations** - Adjust for changing market conditions

### Strategy Updates

#### Updating Strategy Code
```bash
# Update all strategies from repositories
./scripts/update-strategies.sh

# Restart bots with updated strategies
docker stop freqtrade-YourStrategy
./docker-launch.sh YourStrategy
```

#### Configuration Updates
1. **Edit template files** in `config/` directory
2. **Test in dry-run mode** before going live
3. **Monitor performance** after changes
4. **Document modifications** for future reference

## Troubleshooting Strategy Issues

### Strategy Not Trading
**Possible Causes**:
- Market conditions don't meet entry criteria
- Insufficient balance for new trades
- API connection issues
- Configuration errors

**Solutions**:
1. Check strategy logs for entry signal details
2. Verify available balance and trading pairs
3. Test API connection and permissions
4. Review configuration file syntax

### Poor Strategy Performance
**Analysis Steps**:
1. Compare current performance with backtesting results
2. Analyze market conditions vs expected conditions
3. Check for configuration changes or errors
4. Review recent market events that might affect performance

### Strategy Conflicts (Multiple Strategies)
**Issues**:
- Competing for same trading pairs
- Insufficient balance distribution
- API rate limiting

**Solutions**:
1. Assign different pairs to different strategies
2. Adjust stake amounts to prevent balance conflicts
3. Use binance-proxy for rate limit management
4. Stagger strategy processing intervals

## Best Practices

### Strategy Selection
1. **Start with one strategy** - Master one before adding others
2. **Match strategy to market** - Use appropriate strategy for conditions
3. **Understand the logic** - Know how your chosen strategy works
4. **Test thoroughly** - Use dry-run mode extensively

### Risk Management
1. **Diversify strategies** - Don't rely on single approach
2. **Position sizing** - Never risk more than you can afford to lose
3. **Regular monitoring** - Check performance and adjust as needed
4. **Emergency planning** - Know how to quickly stop trading

### Performance Optimization
1. **Regular backtesting** - Test strategies against recent data
2. **Parameter tuning** - Carefully adjust settings based on performance
3. **Market adaptation** - Switch strategies based on market conditions
4. **Continuous learning** - Stay updated with strategy developments

## Next Steps

Master strategy management:
- [Learn advanced monitoring techniques](monitoring.md)
- [Understand project structure](../reference/project-structure.md)
- [Troubleshoot common issues](../reference/troubleshooting.md)