# NFI Risk Management Approach

## Overview
This document outlines the risk management approach for NostalgiaForInfinity (NFI) and other advanced Freqtrade strategies. It represents a fundamental shift from traditional fixed risk parameters to a strategy-driven approach that leverages the sophisticated internal mechanisms of these advanced strategies.

## Traditional vs. Strategy-Driven Risk Management

### Traditional Risk Management
- Fixed percentage stoploss (e.g., 2-5%)  
- Strict position sizing (e.g., 1-2% per trade)
- Fixed trailing stops
- Manual pair selection
- Conservative capital allocation

### Strategy-Driven Risk Management
- Permissive stoploss (-0.99) to allow strategy exit logic
- Position adjustment enabled for dynamic position sizing
- Built-in protection mechanisms
- Strategy-specific pair selection
- Performance-based capital allocation

## Key Configuration Parameters

```json
{
  "stoploss": -0.99,                 // Allow strategy exit logic to work
  "minimal_roi": {},                 // Use strategy's exit signals
  "trailing_stop": false,            // Strategy handles trailing logic
  "position_adjustment_enable": true, // Allow multiple entries
  "use_custom_stoploss": true        // Use strategy's custom stoploss logic
}
```

## Protection Mechanisms
NFI and similar strategies incorporate multiple layers of protection:

1. **Technical Analysis-Based Exits**: Using sophisticated indicator combinations
2. **Custom Stoploss Logic**: Adaptive stoploss based on market conditions
3. **Position Adjustment**: Averaging strategies based on technical signals
4. **Cooldown Periods**: Avoiding re-entry after adverse conditions
5. **Dynamic Protection**: Runtime protections based on market behavior

## Implementation Guide

1. **Migration Steps**:
   - Switch from fixed risk parameters to strategy-driven approach
   - Deploy with NFI-specific configuration template
   - Gradually increase capital allocation based on performance

2. **Monitoring Considerations**:
   - Track strategy-specific metrics (not just traditional drawdown)
   - Set up enhanced monitoring for strategy warning signals
   - Evaluate performance across different market cycles

3. **Capital Allocation**:
   - Begin with 20-30% of total capital
   - Scale based on demonstrated performance
   - Create a documented escalation plan with clear metrics

## Community Alignment
This approach aligns with best practices from the Freqtrade community, particularly for sophisticated strategies like NFI that have undergone extensive development and optimization.

## Risk Considerations
While this approach leverages the strategy's built-in risk management, it's important to:

1. Regularly update the strategy to the latest version
2. Conduct periodic reviews of strategy performance
3. Maintain awareness of broader market conditions
4. Have contingency plans for extreme market events 