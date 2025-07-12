# Revised Freqtrade Strategy Optimization Plan

This document outlines comprehensive changes to optimize your Freqtrade strategies for more aggressive trading and increased trade frequency. Each section is based on community best practices and strategy-specific research.

## Global Configuration Changes

These changes should be applied to `config/config-template.json` as your base configuration.

### 1. Pairlist Configuration

**Current:**
```json
"pairlists": [
  {"method": "StaticPairList"},
  {
    "method": "VolumePairList",
    "number_assets": 20,
    "sort_key": "quoteVolume",
    "min_value": 10000000,
    "refresh_period": 1800
  },
  {"method": "AgeFilter", "min_days_listed": 30},
  {"method": "PrecisionFilter"},
  {"method": "PriceFilter", "low_price_ratio": 0.01},
  {"method": "SpreadFilter", "max_spread_ratio": 0.005},
  {"method": "RangeStabilityFilter", "lookback_days": 3},
  {"method": "VolatilityFilter", "lookback_days": 3, "min_volatility": 0.02, "max_volatility": 0.75}
]
```

**Proposed:**
```json
"pairlists": [
  {"method": "StaticPairList"},
  {
    "method": "VolumePairList",
    "number_assets": 60,
    "sort_key": "quoteVolume",
    "min_value": 1000000,
    "refresh_period": 1800
  },
  {"method": "AgeFilter", "min_days_listed": 14},
  {"method": "PrecisionFilter"},
  {"method": "PriceFilter", "low_price_ratio": 0.01},
  {"method": "SpreadFilter", "max_spread_ratio": 0.01}
]
```

**Changes explained:** 
- Increased `number_assets` from 20 to 60 to allow for more trading pairs (based on NFI strategy recommendations)
- Reduced `min_value` from 10M to 1M to include more trading opportunities
- Reduced `min_days_listed` from 30 to 14 for newer pairs with potentially higher volatility
- Increased `max_spread_ratio` from 0.005 to 0.01 for more trading opportunities
- Removed restrictive `RangeStabilityFilter` and `VolatilityFilter`

### 2. Order Processing Settings

**Current:**
```json
"order_types": {
  "entry": "limit",
  "exit": "limit",
  "emergency_exit": "market",
  "stoploss": "market",
  "stoploss_on_exchange": false,
  "stoploss_on_exchange_interval": 60
},
"unfilledtimeout": {
  "entry": 10,
  "exit": 10,
  "exit_timeout_count": 0,
  "unit": "minutes"
},
"internals": {
  "process_throttle_secs": 5
}
```

**Proposed:**
```json
"order_types": {
  "entry": "limit",
  "exit": "market",
  "emergency_exit": "market",
  "stoploss": "market",
  "stoploss_on_exchange": true,
  "stoploss_on_exchange_interval": 30
},
"unfilledtimeout": {
  "entry": 3,
  "exit": 3,
  "exit_timeout_count": 0,
  "unit": "minutes"
},
"internals": {
  "process_throttle_secs": 3
}
```

**Changes explained:**
- Changed `exit` order type from limit to market for faster execution
- Enabled `stoploss_on_exchange` and reduced check interval to 30 seconds
- Reduced unfilled timeouts from 10 to 3 minutes
- Reduced process throttle from 5 to 3 seconds for faster reactions

## Strategy-Specific Changes

### 1. NFI Strategy (`config/NFI-config-template.json`)

**Current:**
```json
"stoploss": -0.99,
"trailing_stop": false,
"max_open_trades": 3,
"stake_amount": 100,
"minimal_roi": {
  "0": 100
}
```

**Proposed:**
```json
"stoploss": -0.08,
"trailing_stop": true,
"trailing_stop_positive": 0.005,
"trailing_stop_positive_offset": 0.01,
"trailing_only_offset_is_reached": true,
"max_open_trades": 6,
"stake_amount": "5%",
"minimal_roi": {
  "0": 0.03,
  "10": 0.02,
  "30": 0.01,
  "60": 0
},
"pair_whitelist": [
  // Expand this to include 40-60 stable coin pairs
  "BTC/USDT", "ETH/USDT", "ADA/USDT", "SOL/USDT", 
  "BNB/USDT", "XRP/USDT", "MATIC/USDT", "DOT/USDT", 
  "LINK/USDT", "AVAX/USDT", "LUNA/USDT", "NEAR/USDT",
  "DOGE/USDT", "UNI/USDT", "ATOM/USDT", "LTC/USDT",
  "FTM/USDT", "ALGO/USDT", "MANA/USDT", "SAND/USDT",
  "AAVE/USDT", "AXS/USDT", "GALA/USDT", "THETA/USDT",
  "CRO/USDT", "FTT/USDT", "EGLD/USDT", "HBAR/USDT",
  "EOS/USDT", "CAKE/USDT", "KSM/USDT", "ENJ/USDT",
  "WAVES/USDT", "CHZ/USDT", "HOT/USDT", "AR/USDT",
  "BAT/USDT", "ZIL/USDT", "ONE/USDT", "CELO/USDT"
  // Add more pairs as needed
]
```

**Changes explained:**
- Fixed extreme stoploss (-0.99 → -0.08)
- Added trailing stop configuration to lock in profits
- Changed max_open_trades from 3 to 6 (aligning with recommended 4-6 range)
- Changed stake_amount from fixed 100 to 5% of portfolio
- Replaced unrealistic ROI (100 or 10,000%) with tiered profit-taking schedule
- Expanded pair whitelist as the strategy recommends 40-80 stable coin pairs

### 2. ReinforcedQuickie (`config/ReinforcedQuickie-config-template.json`)

**Current:**
```json
"stoploss": -0.05,
"trailing_stop": false,
"max_open_trades": 3,
"stake_amount": 30,
"minimal_roi": {
  "0": 0.01
}
```

**Proposed:**
```json
"stoploss": -0.05,
"trailing_stop": true,
"trailing_stop_positive": 0.005,
"trailing_stop_positive_offset": 0.01,
"trailing_only_offset_is_reached": true,
"max_open_trades": 6,
"stake_amount": "3%",
"minimal_roi": {
  "0": 0.03,
  "10": 0.02,
  "20": 0.01,
  "40": 0
}
```

**Changes explained:**
- Kept the same stoploss as it's already appropriate
- Added trailing stop configuration
- Increased max_open_trades from 3 to 6 (aligning with the "4 to 6 open trades" recommendation)
- Changed stake_amount from fixed 30 to 3% of portfolio
- Added tiered ROI for better profit taking

### 3. ReinforcedSmoothScalp (`config/ReinforcedSmoothScalp-config-template.json`)

**Current:**
```json
"stoploss": -0.03,
"trailing_stop": false,
"max_open_trades": 2,
"stake_amount": 30,
"minimal_roi": {
  "0": 0.005
}
```

**Proposed:**
```json
"stoploss": -0.03,
"trailing_stop": true,
"trailing_stop_positive": 0.003,
"trailing_stop_positive_offset": 0.006,
"trailing_only_offset_is_reached": true,
"max_open_trades": 30,
"stake_amount": "1%",
"minimal_roi": {
  "0": 0.02,
  "5": 0.01,
  "15": 0.005,
  "30": 0
}
```

**Changes explained:**
- Kept the tight stoploss
- Added trailing stop with tighter values (matching the strategy's scalping nature)
- Significantly increased max_open_trades from 2 to 30 (the strategy recommends at least 60 trades, but 30 is more practical for most setups)
- Changed stake_amount from fixed 30 to 1% of portfolio (smaller stakes for more concurrent trades)
- Added tiered ROI designed for quick scalping

### 4. BbandRsi (`config/BbandRsi-config-template.json`)

**Current:**
```json
"stoploss": -0.1,
"trailing_stop": false,
"max_open_trades": 3,
"stake_amount": 100,
"minimal_roi": {
  "0": 0.1
}
```

**Proposed:**
```json
"stoploss": -0.12,
"trailing_stop": true,
"trailing_stop_positive": 0.007,
"trailing_stop_positive_offset": 0.015,
"trailing_only_offset_is_reached": true,
"max_open_trades": 8,
"stake_amount": "4%",
"minimal_roi": {
  "0": 0.03,
  "15": 0.02,
  "30": 0.01,
  "60": 0
},
"timeframe": "1h"  // Original strategy uses 1h timeframe
```

**Changes explained:**
- Adjusted stoploss from -0.1 to -0.12 (slightly more permissive based on strategy design)
- Added trailing stop configuration
- Increased max_open_trades from 3 to 8
- Changed stake_amount from fixed 100 to 4% of portfolio
- Added tiered ROI structure
- Ensured timeframe is set to 1h as per original design

### 5. SMAOffset (`config/SMAOffset-config-template.json`)

**Current:**
```json
"stoploss": -0.1,
"trailing_stop": false,
"max_open_trades": 8,
"stake_amount": 100,
"minimal_roi": {
  "0": 0.1
}
```

**Proposed:**
```json
"stoploss": -0.10,
"trailing_stop": true,
"trailing_stop_positive": 0.01,
"trailing_stop_positive_offset": 0.02,
"trailing_only_offset_is_reached": true,
"max_open_trades": 10,
"stake_amount": "4%",
"minimal_roi": {
  "0": 0.04,
  "20": 0.03,
  "40": 0.015,
  "80": 0
},
"timeframe": "5m"  // Original strategy uses 5m timeframe
```

**Changes explained:**
- Maintained original stoploss of -0.10 which is appropriate for this strategy
- Added trailing stop configuration
- Increased max_open_trades from 8 to 10
- Changed stake_amount from fixed 100 to 4% of portfolio
- Added tiered ROI structure
- Ensured timeframe is 5m per original design
