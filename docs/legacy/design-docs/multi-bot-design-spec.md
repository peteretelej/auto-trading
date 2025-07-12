# Design Specification: Multi-Strategy Trading Bot System

## 1. Overview

This document outlines the design and implementation plan for enhancing the auto-trading system to support multiple concurrent strategies, including NostalgiaForInfinityX (NFI), while maintaining a simplified user experience through a single command interface.

### 1.1 System Requirements

1. Support multiple simultaneous trading bots with different strategies
2. Update and maintain NFI alongside the standard Freqtrade strategies
3. Create a unified management interface through the docker-launch.sh script
4. Maintain strategy-specific configurations while leveraging environment variables
5. Operate bots on different ports to avoid conflicts (8101, 8102, etc.)
6. Keep the user experience straightforward with minimal command complexity

## 2. System Architecture

### 2.1 Component Overview

```
┌─────────────────┐     ┌───────────────────────┐     ┌─────────────────┐
│ docker-launch.sh│────▶│ Strategy-Specific     │────▶│ Docker          │
│ (Entry Point)   │     │ Configuration Handler │     │ Container System│
└─────────────────┘     └───────────────────────┘     └─────────────────┘
         │                         ▲                            │
         │                         │                            │
         ▼                         │                            ▼
┌─────────────────┐                │                  ┌─────────────────┐
│ update-strategies│                │                  │ Freqtrade Bots  │
│ (Enhanced)      │────────────────┘                  │ (Multiple       │
└─────────────────┘                                   │  Instances)     │
                                                      └─────────────────┘
```

### 2.2 Directory Structure Updates

```
auto-trading/
├── config/
│   ├── config-template.json           # Default config template
│   ├── NFI-config-template.json       # NFI-specific template
│   ├── ReinforcedQuickie-config-template.json
│   ├── ReinforcedSmoothScalp-config-template.json
│   └── ...
├── user_data/
│   └── strategies/
│       ├── NostalgiaForInfinityX.py   # NFI strategy file
│       └── ...
├── docker-launch.sh                   # Enhanced with multi-bot support
├── Dockerfile                         # Updated with all dependencies
└── scripts/
    └── update-strategies.sh           # Enhanced to include NFI
```

## 3. Component Design Specifications

### 3.1 Enhanced update-strategies.sh

The script will be modified to support both standard Freqtrade strategies and custom repositories like NFI.

#### Key Features:
- Unified strategy update process
- Support for multiple strategy repositories
- Custom handling for specialized strategies like NFI
- Repository-specific checkout options
- Error handling and reporting

#### Implementation Details:
```bash
#!/bin/bash
set -e

USER_DATA_DIR="../user_data"
TEMP_DIR="temp_strategies_update"
FT_STRATEGIES_REPO="https://github.com/freqtrade/freqtrade-strategies.git"
NFI_REPO="https://github.com/iterativv/NostalgiaForInfinity.git"
NFI_BRANCH="main"

update_ft_strategies() {
    echo "Updating standard Freqtrade strategies..."
    
    # Clear existing temp directory
    rm -rf "${TEMP_DIR}"
    
    # Clone standard strategies
    git clone --depth 1 --filter=blob:none --sparse "${FT_STRATEGIES_REPO}" "${TEMP_DIR}"
    
    # Sparse checkout and processing
    (cd "${TEMP_DIR}" && git sparse-checkout set user_data/strategies)
    
    # Copy and process standard strategies
    mkdir -p "${USER_DATA_DIR}/strategies"
    cp -rT "${TEMP_DIR}/user_data/strategies" "${USER_DATA_DIR}/strategies/"
    
    # Process subdirectories
    for SUBDIR in $(find "${USER_DATA_DIR}/strategies" -mindepth 1 -maxdepth 1 -type d); do
        SUBDIR_NAME=$(basename "$SUBDIR")
        
        for STRATEGY_FILE in $(find "$SUBDIR" -maxdepth 1 -name "*.py"); do
            STRATEGY_FILENAME=$(basename "$STRATEGY_FILE")
            
            # Skip special files
            if [[ "$STRATEGY_FILENAME" == "__"* ]]; then
                continue
            fi
            
            # Create prefixed copy
            cp "$STRATEGY_FILE" "${USER_DATA_DIR}/strategies/${SUBDIR_NAME}_${STRATEGY_FILENAME}"
        done
    done
}

update_nfi_strategy() {
    echo "Updating NostalgiaForInfinityX strategy..."
    
    # Use a separate temp directory for NFI
    NFI_TEMP_DIR="temp_nfi_update"
    rm -rf "${NFI_TEMP_DIR}"
    
    # Clone NFI repository
    git clone --depth 1 --branch ${NFI_BRANCH} ${NFI_REPO} "${NFI_TEMP_DIR}"
    
    # Copy NFI strategy files
    mkdir -p "${USER_DATA_DIR}/strategies"
    cp "${NFI_TEMP_DIR}"/*.py "${USER_DATA_DIR}/strategies/"
    
    # Clean up
    rm -rf "${NFI_TEMP_DIR}"
}

# Execute both update functions
update_ft_strategies
update_nfi_strategy

# Clean up
rm -rf "${TEMP_DIR}"

echo "Strategy update completed successfully."
```

### 3.2 Updated Dockerfile

The Dockerfile will be enhanced to include all dependencies required by both standard strategies and NFI.

```dockerfile
# Use the official Freqtrade image as the base
FROM freqtradeorg/freqtrade:latest

# Install dependencies for all strategies
USER root
RUN pip install --no-cache-dir \
    ta \
    pandas-ta \
    technical \
    scipy \
    finta \
    schedule \
    ccxt \
    scikit-learn \
    scikit-optimize \
    numpy \
    statsmodels

# Switch back to the freqtrade user
USER ftuser

# The rest of the image setup is inherited from the base image
```

### 3.3 Strategy-Specific Configuration Templates

Each strategy will have its own configuration template in the config directory with optimized settings.

#### Default config-template.json (ReinforcedAverageStrategy)
The existing template remains unchanged for backward compatibility.

#### NFI-config-template.json
```json
{
    "max_open_trades": 5,
    "stake_currency": "USDT",
    "stake_amount": 20,
    "tradable_balance_ratio": 0.99,
    "fiat_display_currency": "USD",
    "dry_run": true,
    "dry_run_wallet": 1000,
    "stoploss": -0.99,
    "trailing_stop": false,
    "trailing_stop_positive": 0.01,
    "trailing_stop_positive_offset": 0.02,
    "trailing_only_offset_is_reached": false,
    "minimal_roi": {
        "0": 100
    },
    "exchange": {
        "name": "binance",
        "key": "${BINANCE_API_KEY}",
        "secret": "${BINANCE_API_SECRET}",
        "ccxt_config": {
            "urls": {
                "api": "http://freqcache:8100/binance"
            }
        },
        "ccxt_async_config": {
            "enableRateLimit": false  // Disable as freqcache handles this
        },
        "pair_whitelist": [
            "BTC/USDT", "ETH/USDT", "ADA/USDT", "SOL/USDT",
            "BNB/USDT", "XRP/USDT", "MATIC/USDT", "DOT/USDT",
            "LINK/USDT", "AVAX/USDT", "LUNA/USDT", "NEAR/USDT"
        ],
        "pair_blacklist": [
            "BNB/BTC", "BNB/ETH", ".*UP/USDT", ".*DOWN/USDT",
            ".*BEAR/USDT", ".*BULL/USDT"
        ]
    },
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
        {"method": "VolatilityFilter", "lookback_days": 3}
    ],
    "order_types": {
        "entry": "limit",
        "exit": "limit",
        "emergency_exit": "market",
        "stoploss": "market",
        "stoploss_on_exchange": true,
        "stoploss_on_exchange_interval": 60
    },
    "telegram": {
        "enabled": true,
        "token": "${TELEGRAM_BOT_TOKEN}",
        "chat_id": "${TELEGRAM_CHAT_ID}",
        "notification_settings": {
            "status": "on",
            "warning": "on",
            "startup": "on",
            "entry": "on",
            "exit": "on",
            "entry_fill": "on",
            "exit_fill": "on",
            "entry_cancel": "on",
            "exit_cancel": "on"
        }
    },
    "api_server": {
        "enabled": true,
        "listen_ip_address": "0.0.0.0",
        "listen_port": "${WEB_PORT}",
        "verbosity": "error",
        "enable_openapi": true,
        "jwt_secret_key": "${JWT_SECRET_KEY}",
        "CORS_origins": [
            "http://localhost:${WEB_PORT}",
            "https://trading.ai.etelej.com",
            "https://trading-${WEB_PORT}.ai.etelej.com"
        ],
        "username": "${WEB_USERNAME}",
        "password": "${WEB_PASSWORD}"
    },
    "bot_name": "NFI-freqtrade",
    "initial_state": "running",
    "force_entry_enable": false,
    "internals": {
        "process_throttle_secs": 5
    }
}
```

Similar templates would be created for other strategies (ReinforcedQuickie, ReinforcedSmoothScalp, etc.)

### 3.4 Enhanced docker-launch.sh

The docker-launch.sh script will be updated to support launching different strategy instances with a single command.

```bash
#!/bin/bash
set -ex

# Configuration variables
APP=freqtrade
DATA_DIR="/ndovu-data/freqtrade" # Base host directory for persistent data
BASE_IMAGE="freqtradeorg/freqtrade:latest"
CUSTOM_IMAGE_TAG="freqtrade-local:latest"

# Process arguments
STRATEGY=${1:-ReinforcedAverageStrategy}  # Default strategy if none specified
BOT_INSTANCE="${STRATEGY}"
PORT_OFFSET=$(( ${2:-0} + 0 ))  # Default port offset 0 if none specified
PORT=$((8101 + ${PORT_OFFSET}))

echo "Launching ${STRATEGY} on port ${PORT} (instance: ${BOT_INSTANCE})"

# Strategy-specific directories
STRATEGY_DATA_DIR="${DATA_DIR}/${BOT_INSTANCE}"
CONFIG_TEMPLATE="./config/${STRATEGY}-config-template.json"
# Fall back to default template if strategy-specific doesn't exist
if [ ! -f "${CONFIG_TEMPLATE}" ]; then
    echo "No strategy-specific config template found, using default"
    CONFIG_TEMPLATE="./config/config-template.json"
fi
PROCESSED_CONFIG="${STRATEGY_DATA_DIR}/config.json"

# Load environment variables from .env file and export them for envsubst
if [ -f ".env" ]; then
    export $(grep -v '^#' .env | xargs)
else
    echo "Error: .env file not found. Please create one based on .env.sample"
    exit 1
fi

# Validate required environment variables
if [ -z "$BINANCE_API_KEY" ] || [ -z "$BINANCE_API_SECRET" ]; then
    echo "Error: BINANCE_API_KEY or BINANCE_API_SECRET is not set in .env file"
    exit 1
fi

# Create strategy-specific data directories
mkdir -p "${STRATEGY_DATA_DIR}"
mkdir -p "${STRATEGY_DATA_DIR}/user_data"
mkdir -p "${STRATEGY_DATA_DIR}/user_data/data"
mkdir -p "${STRATEGY_DATA_DIR}/user_data/logs"
mkdir -p "${STRATEGY_DATA_DIR}/user_data/strategies"

# Update strategies from repositories
echo "Updating trading strategies..."
cd ./scripts
./update-strategies.sh
cd ..

# Replace port in config template before processing
export WEB_PORT=${PORT}

# Process config template with environment variables
mkdir -p "$(dirname "${PROCESSED_CONFIG}")"
# First pass: substitute environment variables
envsubst < "${CONFIG_TEMPLATE}" > "${PROCESSED_CONFIG}.tmp"

# Second pass: convert port from string to integer
# Use sed to convert "listen_port": "8101" to "listen_port": 8101
sed -E 's/"listen_port": "([0-9]+)"/"listen_port": \1/g' "${PROCESSED_CONFIG}.tmp" > "${PROCESSED_CONFIG}"
rm "${PROCESSED_CONFIG}.tmp"

echo "Generated ${PROCESSED_CONFIG} from template with port conversion."

# Copy user_data contents to the strategy-specific data directory
if [ -d "./user_data" ]; then
    echo "Copying contents from ./user_data to ${STRATEGY_DATA_DIR}/user_data/ ..."
    cp -rT "./user_data" "${STRATEGY_DATA_DIR}/user_data/"
fi

# Build the custom Docker image
echo "Building custom Docker image ${CUSTOM_IMAGE_TAG}..."
docker build -t "${CUSTOM_IMAGE_TAG}" .

# Stop and remove existing container if it exists
CONTAINER_NAME="${APP}-${BOT_INSTANCE}"
docker stop "${CONTAINER_NAME}" || true
docker rm "${CONTAINER_NAME}" || true

# Run the container with strategy-specific settings
docker run -d --name "${CONTAINER_NAME}" --restart unless-stopped \
    -p "${PORT}:${PORT}" \
    -v "${STRATEGY_DATA_DIR}/user_data:/freqtrade/user_data" \
    -v "${PROCESSED_CONFIG}:/freqtrade/config.json:ro" \
    "${CUSTOM_IMAGE_TAG}" trade \
    --user-data-dir "/freqtrade/user_data" \
    --logfile "/freqtrade/user_data/logs/freqtrade.log" \
    --db-url "sqlite:////freqtrade/user_data/tradesv3.sqlite" \
    --config "/freqtrade/config.json" \
    --strategy "${STRATEGY}" \
    --dry-run \
    -v

echo "${CONTAINER_NAME} launched in dry-run mode on port ${PORT}"

echo "Waiting 2 seconds before showing logs..."
sleep 2

# Show initial logs
echo "Showing container logs:"
docker logs -f "${CONTAINER_NAME}"
```

### 3.5 Updated Caddyfile Configuration

The Caddyfile should be updated with explicit configurations for each bot instance rather than using dynamic port extraction, which could pose security risks.

```
# Freqtrade Multi-Bot Configuration
# Add this to your existing Caddyfile

# Wildcard for ai.etelej.com subdomains
*.ai.etelej.com {
    import cloudflare_tls

    # Main trading bot instance
    @trading host trading.ai.etelej.com
    handle @trading {
        import ip_whitelist
        reverse_proxy localhost:8101 {
            transport http {
                read_timeout 2m
                write_timeout 2m
                dial_timeout 10s
            }
        }
    }
    
    # Explicitly define each additional bot instance
    @trading-8102 host trading-8102.ai.etelej.com
    handle @trading-8102 {
        import ip_whitelist
        reverse_proxy localhost:8102 {
            transport http {
                read_timeout 2m
                write_timeout 2m
                dial_timeout 10s
            }
        }
    }
    
    @trading-8103 host trading-8103.ai.etelej.com
    handle @trading-8103 {
        import ip_whitelist
        reverse_proxy localhost:8103 {
            transport http {
                read_timeout 2m
                write_timeout 2m
                dial_timeout 10s
            }
        }
    }
    
    @trading-8104 host trading-8104.ai.etelej.com
    handle @trading-8104 {
        import ip_whitelist
        reverse_proxy localhost:8104 {
            transport http {
                read_timeout 2m
                write_timeout 2m
                dial_timeout 10s
            }
        }
    }
    
    @trading-8105 host trading-8105.ai.etelej.com
    handle @trading-8105 {
        import ip_whitelist
        reverse_proxy localhost:8105 {
            transport http {
                read_timeout 2m
                write_timeout 2m
                dial_timeout 10s
            }
        }
    }
    
    # Fallback for unhandled ai subdomains
    handle {
        respond 404 {
            body "Domain not configured"
        }
    }
}
```

This configuration:
1. Maintains the main bot instance at trading.ai.etelej.com pointing to port 8101
2. Explicitly defines each additional bot instance with its own host matcher and reverse proxy
3. Applies the same security settings (ip_whitelist, TLS) to all instances
4. Limits access to only the explicitly configured ports (8101-8105)

This approach is more secure than dynamic port extraction as it allows access only to the specific ports you've intentionally configured.

## 4. Usage Examples

### 4.1 Launch Default Strategy (ReinforcedAverageStrategy)
```bash
./docker-launch.sh
```
Access at: https://trading.ai.etelej.com

### 4.2 Launch NFI Strategy
```bash
./docker-launch.sh NostalgiaForInfinityX
```
Access at: https://trading.ai.etelej.com (replaces default instance)

### 4.3 Launch Multiple Strategy Instances with Different Port Offsets
```bash
# Launch default ReinforcedAverageStrategy on port 8101
./docker-launch.sh

# Launch ReinforcedQuickie on port 8102
./docker-launch.sh ReinforcedQuickie 1
# Access at: https://trading-8102.ai.etelej.com

# Launch ReinforcedSmoothScalp on port 8103
./docker-launch.sh ReinforcedSmoothScalp 2
# Access at: https://trading-8103.ai.etelej.com

# Launch NFI on port 8104
./docker-launch.sh NostalgiaForInfinityX 3
# Access at: https://trading-8104.ai.etelej.com
```

### 4.4 Monitor Multiple Instances
Each instance will have its own Telegram notifications with the bot name specified in the config template.

For web access, all instances can be accessed through their respective URLs, but the main trading.ai.etelej.com interface can also be used to view and manage all bots by changing the API URL in the settings.

## 5. Implementation Plan

### 5.1 Phase 1: Foundation Setup

1. **Create Strategy-Specific Configuration Templates**
   - Create NFI-config-template.json with NFI-specific settings
   - Create ReinforcedQuickie-config-template.json
   - Create ReinforcedSmoothScalp-config-template.json

2. **Update Dockerfile**
   - Add all required dependencies for NFI and other strategies
   - Test Docker build to ensure dependencies install correctly

3. **Enhance update-strategies.sh**
   - Modify to include NFI repository download
   - Add error handling and improved logging
   - Test to ensure both standard and NFI strategies are updated correctly

### 5.2 Phase 2: Multi-Bot Support Implementation

1. **Enhance docker-launch.sh**
   - Add command-line argument processing
   - Implement strategy-specific directory structure
   - Add port management functionality
   - Update container naming convention

2. **Test Individual Strategy Launches**
   - Test launching default ReinforcedAverageStrategy
   - Test launching NostalgiaForInfinityX
   - Verify configurations are correctly applied

3. **Test Multiple Simultaneous Strategy Instances**
   - Launch multiple strategy bots simultaneously
   - Verify they operate independently
   - Confirm port assignments work correctly
   - Test Telegram notifications from multiple bots

### 5.3 Phase 3: Documentation and Optimization

1. **Document System Usage**
   - Update README.md with new functionality
   - Create usage examples and common commands
   - Document strategy-specific considerations

2. **System Optimization**
   - Review resource usage with multiple bots
   - Optimize Docker configurations for efficiency
   - Implement safeguards against excessive resource usage

3. **Final Testing and Deployment**
   - Comprehensive testing of all components
   - Verify update process works smoothly
   - Confirm data separation between bot instances
   - Deploy to production environment

## 6. Monitoring and Maintenance

### 6.1 Monitoring Considerations

1. **Resource Usage Monitoring**
   - Implement monitoring for CPU, memory, and disk usage
   - Set up alerts for excessive resource consumption

2. **Strategy Update Monitoring**
   - Track NFI repository for updates
   - Automated testing of updated strategies before deployment

3. **Performance Tracking**
   - Compare performance metrics across different strategies
   - Track overall system stability with multiple bots

### 6.2 Maintenance Procedures

1. **Regular Updates**
   - Weekly strategy updates via docker-launch.sh
   - Monthly review of strategy performance

2. **Backup Procedures**
   - Enhance backup.sh to support multiple bot instances
   - Implement cross-instance backup verification

## 7. Conclusion

This design provides a comprehensive approach to supporting multiple trading strategies, including NFI, while maintaining a simple user interface through the docker-launch.sh script. The implementation allows for independent operation of multiple strategy instances, each with optimized configurations and separate data storage.

The system is designed to be maintainable, with clear update paths for both standard Freqtrade strategies and specialized strategies like NFI. The unified command interface ensures ease of use despite the underlying complexity.

## 8. Binance API Rate Limit Management

Running multiple bot instances simultaneously with the same Binance API key presents significant challenges with rate limits. This section outlines the potential issues and recommended solutions.

### 8.1 Binance API Limits Overview

Binance enforces several types of rate limits:
- **Request Weight**: ~1,200 weight per minute (each endpoint has different weights)
- **Order Rate**: ~50 orders per 10 seconds
- **Raw Requests**: ~20-100 requests per second depending on endpoint

With 5 bots operating independently, these limits could be quickly exceeded as each bot:
- Fetches the same market data independently
- Checks order status and account balances
- Places trades, potentially at similar times

### 8.2 Common Rate Limit Solutions

#### 8.2.1 Primary Recommendation: Shared Cache Implementation

The most effective solution is implementing a shared cache/proxy:

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│ Freqtrade   │     │ Freqtrade   │     │ Freqtrade   │
│ Bot 1       │     │ Bot 2       │     │ Bot 3       │
└──────┬──────┘     └──────┬──────┘     └──────┬──────┘
       │                   │                   │
       ▼                   ▼                   ▼
┌─────────────────────────────────────────────────────┐
│              Data Cache/Proxy Service                │
└───────────────────────────┬─────────────────────────┘
                            │
                            ▼
                    ┌───────────────┐
                    │   Binance API │
                    └───────────────┘
```

**Implementation Options:**

1. **Redis-based cache with proxy service:**
   - Create a simple Redis instance for caching API responses
   - Develop a lightweight proxy service that interfaces with Binance
   - Configure all bots to connect to the proxy instead of directly to Binance
   - Cache common data (OHLCV, ticker, orderbook) with appropriate TTLs

2. **Using an existing solution:**
   - CCXT-Cache: https://github.com/crypto-chassis/ccxt-cache
   - Freqcache: https://github.com/freqtrade/freqcache

#### 8.2.2 Alternative Approach: Configuration Optimizations

If implementing a proxy is not immediately feasible, adjust configurations:

1. **Staggered Processing:**
   ```json
   // Bot 1
   "internals": {
       "process_throttle_secs": 5
   }
   
   // Bot 2
   "internals": {
       "process_throttle_secs": 7
   }
   
   // Bot 3
   "internals": {
       "process_throttle_secs": 9
   }
   
   // Bot 4
   "internals": {
       "process_throttle_secs": 11
   }
   
   // Bot 5
   "internals": {
       "process_throttle_secs": 13
   }
   ```

2. **Enhanced CCXT Rate Limiting:**
   ```json
   "ccxt_async_config": {
       "enableRateLimit": true,
       "rateLimit": 500,  // Milliseconds between requests
       "verbose": false
   }
   ```

3. **Pair Optimization:**
   Allocate different trading pairs to different bots instead of having each bot monitor all pairs:
   
   ```json
   // Bot 1: Major pairs
   "pair_whitelist": ["BTC/USDT", "ETH/USDT", "BNB/USDT"]
   
   // Bot 2: DeFi tokens
   "pair_whitelist": ["CAKE/USDT", "UNI/USDT", "AAVE/USDT"]
   
   // Bot 3: L1 alternatives
   "pair_whitelist": ["SOL/USDT", "ADA/USDT", "AVAX/USDT"]
   
   // Bot 4: L2 solutions
   "pair_whitelist": ["MATIC/USDT", "OP/USDT", "ARB/USDT"]
   
   // Bot 5: Emerging assets
   "pair_whitelist": ["DOT/USDT", "ATOM/USDT", "LINK/USDT"]
   ```

4. **Timeframe Diversification:**
   Configure each bot to operate on different timeframes to further reduce API call overlap:
   
   ```
   Bot 1: timeframe = "1m"  (NFI)
   Bot 2: timeframe = "5m"  (ReinforcedQuickie)
   Bot 3: timeframe = "15m" (Custom strategy)
   Bot 4: timeframe = "1h"  (ReinforcedSmoothScalp variant)
   Bot 5: timeframe = "4h"  (ReinforcedAverageStrategy)
   ```

### 8.3 Monitoring and Mitigation

Add monitoring to detect and respond to rate limit issues:

1. **Enhanced Logging:**
   ```json
   "api_server": {
       "verbosity": "info",
       // other settings...
   }
   ```

2. **Telegram Alerts for Rate Limit Errors:**
   Configure more detailed notifications to catch rate limit errors early.

3. **Circuit Breaker Pattern:**
   Add a script that monitors logs for rate limit errors and temporarily pauses lower-priority bots when limits are being approached.

### 8.4 Implementation Plan for Rate Limit Management

1. **Phase 1: Configuration Optimization**
   - Implement staggered processing
   - Configure enhanced CCXT rate limiting
   - Distribute pairs across bots
   - Diversify timeframes

2. **Phase 2: Basic Monitoring**
   - Enhance logging for rate limit errors
   - Add Telegram alerts for detected issues
   - Implement manual circuit breaker process

3. **Phase 3: Shared Cache Implementation**
   - Develop or deploy a proxy service
   - Configure Redis caching
   - Update bot configurations to use proxy
   - Test and validate performance

By implementing these measures, the multi-bot system can operate within Binance's rate limits while maintaining trading efficiency.

### 8.5 Binance Proxy Implementation with Docker

After reviewing available options, **Binance Proxy** (https://github.com/nightshift2k/binance-proxy) is the ideal solution for this setup. It's a simplified, purpose-built proxy for Binance, with efficient websocket implementation and caching of key endpoints.

#### 8.5.1 Implementation with Standard Docker

Since this project uses standalone Docker commands rather than docker-compose, here's how to implement Binance Proxy with the existing workflow:

1. **Create a setup script for the proxy:**
   ```bash
   # Create scripts/setup-proxy.sh
   #!/bin/bash
   set -e

   # Configuration
   PROXY_NAME="binance-proxy"
   PROXY_IMAGE="nightshift2k/binance-proxy:latest"
   HOST_PORT=8100
   INTERNAL_PORT=8090  # binance-proxy default port for SPOT

   # Check if container exists
   if ! docker ps -a --format '{{.Names}}' | grep -q "^${PROXY_NAME}$"; then
     echo "Creating ${PROXY_NAME} container..."
     docker run -d --name ${PROXY_NAME} \
       --restart unless-stopped \
       --memory=256m \
       -p ${HOST_PORT}:${INTERNAL_PORT} \
       ${PROXY_IMAGE}
   elif [ "$(docker inspect -f '{{.State.Status}}' ${PROXY_NAME})" != "running" ]; then
     echo "Starting ${PROXY_NAME} container..."
     docker start ${PROXY_NAME}
   else
     echo "${PROXY_NAME} container is already running"
   fi

   # Wait for proxy to start
   echo "Waiting for ${PROXY_NAME} to initialize..."
   sleep 5

   # Check if proxy is responding
   if curl -s --max-time 5 http://localhost:${HOST_PORT}/api/v3/ping &>/dev/null; then
     echo "${PROXY_NAME} is running and responding"
   else
     echo "Warning: ${PROXY_NAME} health check failed. Please check logs."
     echo "Run: docker logs ${PROXY_NAME}"
   fi
   ```

2. **Update docker-launch.sh to include proxy setup:**
   ```bash
   # At the beginning of docker-launch.sh, after setting variables:
   
   # Ensure binance-proxy is running
   ./scripts/setup-proxy.sh
   
   # Continue with the rest of the script...
   ```

3. **Update strategy config templates to use Binance Proxy:**
   For all configuration templates, modify the exchange section:

   ```json
   "exchange": {
       "name": "binance",
       "key": "${BINANCE_API_KEY}",
       "secret": "${BINANCE_API_SECRET}",
       "ccxt_config": {
           "urls": {
               "api": {
                   "public": "http://localhost:8100/api/v3"
               }
           }
       },
       "ccxt_async_config": {
           "enableRateLimit": false
       },
       "pair_whitelist": [
           // Your pairs...
       ],
       "pair_blacklist": [
           // Your blacklist...
       ]
   }
   ```

4. **Create a migration script if needed:**
   ```bash
   # Create scripts/remove-freqcache.sh
   #!/bin/bash
   set -e

   echo "Removing Freqcache components..."

   # Stop and remove Redis container
   if docker ps -a --format '{{.Names}}' | grep -q "^redis$"; then
       echo "Stopping and removing Redis container..."
       docker stop redis || echo "Redis container already stopped"
       docker rm redis || echo "Redis container already removed"
       echo "Redis container removed"
   fi

   # Stop and remove Freqcache container
   if docker ps -a --format '{{.Names}}' | grep -q "^freqcache$"; then
       echo "Stopping and removing Freqcache container..."
       docker stop freqcache || echo "Freqcache container already stopped"
       docker rm freqcache || echo "Freqcache container already removed"
       echo "Freqcache container removed"
   fi

   # Set up binance-proxy instead
   echo "Setting up Binance Proxy..."
   ./scripts/setup-proxy.sh
   ```

#### 8.5.2 Testing and Validation

1. **Test Binance Proxy setup:**
   ```bash
   # Create scripts/test-proxy.sh
   #!/bin/bash
   set -e

   # Basic health check
   echo "Testing basic endpoints..."
   echo "Testing ping endpoint..."
   if curl -s --max-time 5 http://localhost:8100/api/v3/ping >/dev/null; then
       echo "✅ Ping endpoint is working"
   else
       echo "❌ Ping endpoint failed"
       exit 1
   fi

   # Test the key cached endpoints
   endpoints=(
       "exchangeInfo:http://localhost:8100/api/v3/exchangeInfo"
       "ticker:http://localhost:8100/api/v3/ticker/24hr?symbol=BTCUSDT"
       "depth:http://localhost:8100/api/v3/depth?symbol=BTCUSDT&limit=5"
       "klines:http://localhost:8100/api/v3/klines?symbol=BTCUSDT&interval=1m&limit=5"
   )

   for endpoint in "${endpoints[@]}"; do
       name="${endpoint%%:*}"
       url="${endpoint#*:}"
       
       echo "Testing $name endpoint..."
       if curl -s --max-time 5 "$url" | grep -q "{"; then
           echo "✅ $name endpoint is working"
       else
           echo "❌ $name endpoint failed"
           exit 1
       fi
   done
   ```

2. **Test with one bot instance:**
   ```bash
   ./docker-launch.sh ReinforcedQuickie 1
   ```

3. **Check bot logs for connection to Binance Proxy:**
   ```bash
   docker logs freqtrade-ReinforcedQuickie
   # Look for successful data fetching without Binance rate limit errors
   ```

#### 8.5.3 Proxy Monitoring

To ensure Binance Proxy is functioning correctly:

1. **Create a monitoring script:**
   ```bash
   # Create scripts/monitor-proxy.sh
   #!/bin/bash
   set -e

   echo "===== BINANCE PROXY STATUS ====="
   if docker ps | grep -q binance-proxy; then
       echo "Proxy Status: RUNNING"
       
       # Basic health check
       if curl -s --max-time 3 http://localhost:8100/api/v3/ping &>/dev/null; then
           echo "API Status: ✅ Responding"
       else
           echo "API Status: ❌ Not responding"
       fi
       
       # Get container stats
       PROXY_MEMORY=$(docker stats binance-proxy --no-stream --format "{{.MemUsage}}")
       PROXY_CPU=$(docker stats binance-proxy --no-stream --format "{{.CPUPerc}}")
       
       echo "Resource Usage:"
       echo "Memory: $PROXY_MEMORY"
       echo "CPU: $PROXY_CPU"
       
       # Show recent logs
       echo "Recent Logs:"
       docker logs --tail=10 binance-proxy | grep -E "REST|WS|PROXY|ERROR" || echo "No relevant logs found"
   else
       echo "Proxy Status: STOPPED"
       echo "⚠️ Warning: Binance Proxy container is not running"
   fi
   echo "================================="
   ```

2. **Add to existing monitoring tools:**
   Update `scripts/monitor.sh` to include proxy monitoring.

By implementing Binance Proxy, all bot instances will share the same cached data, significantly reducing the API calls to Binance while maintaining the individual strategy logic of each bot.