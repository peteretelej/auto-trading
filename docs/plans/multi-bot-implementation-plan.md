# Implementation Plan: Multi-Strategy Trading Bot System

## Phase 1: Foundation Setup

### 1. Strategy-Specific Configuration Templates

- [x] Create `NFI-config-template.json` in the config directory with NFI-specific settings:
  ```json
  {
    "max_open_trades": 5, // NFI works best with 3-5 trades
    "stake_currency": "USDT",
    "tradable_balance_ratio": 0.99,
    "minimal_roi": { "0": 100 }, // NFI manages its own exit signals
    "stoploss": -0.99 // NFI uses internal stoploss logic
    // Strategy-specific pair lists and indicators
  }
  ```
- [x] Create `ReinforcedQuickie-config-template.json` with optimized settings:
  ```json
  {
    "max_open_trades": 3,
    "stake_currency": "USDT",
    "minimal_roi": {
      "0": 0.05,
      "30": 0.025,
      "60": 0.01,
      "120": 0
    },
    "stoploss": -0.1,
    "timeframe": "5m" // ReinforcedQuickie works best with 5m
    // Specific indicators and settings
  }
  ```
- [x] Create `ReinforcedSmoothScalp-config-template.json` with dedicated settings:
  ```json
  {
    "max_open_trades": 2,
    "stake_currency": "USDT",
    "minimal_roi": {
      "0": 0.02,
      "60": 0.01,
      "120": 0.005,
      "180": 0
    },
    "stoploss": -0.05,
    "timeframe": "15m" // Optimal for this strategy
    // Specific indicators and settings
  }
  ```
- [x] Ensure all templates include Freqcache proxy configuration:
  ```json
  "exchange": {
    "ccxt_config": {
      "urls": {
        "api": "http://freqcache:8100/binance"
      }
    },
    "ccxt_async_config": {
      "enableRateLimit": false  // Disabled as Freqcache handles this
    }
  }
  ```
- [x] Implement staggered processing intervals across templates:
  ```json
  // For individual strategies:
  "internals": {
    "process_throttle_secs": 5  // Original strategy
    // 7 for second strategy
    // 9 for third strategy, etc.
  }
  ```

### 2. Update Dockerfile

- [x] Modify Dockerfile to include all required dependencies for NFI and other strategies:

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

# Add system packages that might be needed
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Switch back to the freqtrade user
USER ftuser

# Add healthcheck
HEALTHCHECK --interval=60s --timeout=10s --start-period=30s --retries=3 \
  CMD curl -s --fail http://localhost:8080/api/v1/ping || exit 1
```

## Phase 2: Rate Limit Management Implementation (Moved up from Phase 4)

### 1. Create Binance Proxy Setup Script

- [x] Create `scripts/setup-proxy.sh` for managing the binance-proxy container:

  ```bash
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

  # Check if proxy is responding
  if curl -s --max-time 5 http://localhost:${HOST_PORT}/api/v3/ping &>/dev/null; then
    echo "${PROXY_NAME} is running and responding"
  else
    echo "Warning: ${PROXY_NAME} health check failed. Please check logs."
  fi
  ```

### 2. Configuration Optimizations

- [x] Implement pair distribution across bots (in each template):

  ```json
  // Bot 1: Major pairs
  "pair_whitelist": ["BTC/USDT", "ETH/USDT", "BNB/USDT"],

  // Bot 2: DeFi tokens
  "pair_whitelist": ["CAKE/USDT", "UNI/USDT", "AAVE/USDT"],

  // Bot 3: L1 alternatives
  "pair_whitelist": ["SOL/USDT", "ADA/USDT", "AVAX/USDT"]
  ```

- [x] Set up timeframe diversification:

  ```json
  // Timeframe per strategy to reduce API overlap:
  // NFI: "timeframe": "1m",
  // ReinforcedQuickie: "timeframe": "5m",
  // Custom strategy: "timeframe": "15m",
  // ReinforcedSmoothScalp: "timeframe": "1h",
  // ReinforcedAverageStrategy: "timeframe": "4h"
  ```

- [x] Create monitoring configuration for rate limits:
  ```bash
  # Added to scripts/monitor-proxy.sh
  echo "===== BINANCE PROXY STATUS ====="
  if docker ps | grep -q binance-proxy; then
    echo "Proxy Status: RUNNING"
    
    # Basic health check
    if curl -s --max-time 3 http://localhost:8100/api/v3/ping &>/dev/null; then
      echo "API Status: ✅ Responding"
    else
      echo "API Status: ❌ Not responding"
    fi
  fi
  ```

### 3. Testing and Validation

Prerequisites:

- [x] Ensure Docker is running
- [x] Ensure port 8100 is available for binance-proxy

Binance Proxy Container Testing:

- [x] Verify container creation and startup:
  ```bash
  docker ps | grep binance-proxy
  docker logs binance-proxy
  ```
- [x] Test API endpoints:
  ```bash
  # Test ping endpoint
  curl http://localhost:8100/api/v3/ping
  # Test exchangeInfo
  curl http://localhost:8100/api/v3/exchangeInfo
  ```
- [x] Monitor performance:
  ```bash
  docker stats binance-proxy
  ```

Integration Testing:

- [x] Single bot test:
  ```bash
  # Start one bot and monitor proxy
  ./docker-launch.sh ReinforcedAverageStrategy
  ./scripts/monitor-proxy.sh
  ```
- [x] Multi-bot test:
  ```bash
  # Start multiple bots and verify proxy handles the load
  ./docker-launch.sh ReinforcedQuickie 1
  ./docker-launch.sh NostalgiaForInfinityX 2
  ./scripts/monitor-proxy.sh
  ```

## Phase 3: Update Strategy Management

### 1. Enhance update-strategies.sh

- [x] Modify to include NFI repository download
- [x] Add error handling and improved logging
- [x] Test to ensure both standard and NFI strategies are updated correctly

### 2. Testing Strategy Updates

- [x] Create test script for strategy validation:

  ```bash
  #!/bin/bash
  # scripts/test-strategies.sh

  # Test standard Freqtrade strategy loading
  docker run --rm -v "${PWD}/user_data:/freqtrade/user_data" \
    freqtradeorg/freqtrade:latest list-strategies

  # Test NFI strategy loading
  docker run --rm -v "${PWD}/user_data:/freqtrade/user_data" \
    freqtradeorg/freqtrade:latest list-strategies --strategy NostalgiaForInfinityX
  ```

- [x] Set up structured strategy verification:
  - [x] Script to verify strategies load properly
  - [x] Basic backtesting validation of each strategy
  - [x] Strategy parameters validation

## Phase 4: Multi-Bot Support Implementation

### 1. Enhance docker-launch.sh

- [x] Add command-line argument processing and validation:

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
  ```

- [x] Implement strategy-specific directory structure with proper data isolation:

  ```bash
  # Create strategy-specific data directories for proper isolation
  mkdir -p "${STRATEGY_DATA_DIR}"
  mkdir -p "${STRATEGY_DATA_DIR}/user_data"
  mkdir -p "${STRATEGY_DATA_DIR}/user_data/data"
  mkdir -p "${STRATEGY_DATA_DIR}/user_data/logs"
  mkdir -p "${STRATEGY_DATA_DIR}/user_data/strategies"

  # Each bot needs its own database file to prevent conflicts
  DB_FILE="sqlite:////freqtrade/user_data/tradesv3-${BOT_INSTANCE}.sqlite"
  LOG_FILE="/freqtrade/user_data/logs/freqtrade-${BOT_INSTANCE}.log"
  ```

- [x] Add Binance Proxy integration for rate limit management:

  ```bash
  # Ensure binance-proxy is running
  echo "Ensuring binance-proxy is running..."
  ./scripts/setup-proxy.sh

  # Run the container with strategy-specific settings
  docker run -d --name "${CONTAINER_NAME}" --restart unless-stopped \
    -p "${PORT}:${PORT}" \
    -v "${STRATEGY_DATA_DIR}/user_data:/freqtrade/user_data" \
    -v "${PROCESSED_CONFIG}:/freqtrade/config.json:ro" \
    "${CUSTOM_IMAGE_TAG}" trade \
    --user-data-dir "/freqtrade/user_data" \
    --logfile "${LOG_FILE}" \
    --db-url "${DB_FILE}" \
    --config "/freqtrade/config.json" \
    --strategy "${STRATEGY}" \
    --dry-run \
    -v
  ```

### 2. Test Individual Strategy Launches

- [x] Create test script to verify proper bot initialization:

  ```bash
  #!/bin/bash
  # scripts/test-bot-launch.sh

  # Test default strategy
  echo "Testing default strategy launch..."
  ./docker-launch.sh
  sleep 10
  docker logs freqtrade-ReinforcedAverageStrategy | grep "Starting freqtrade" || echo "Default bot failed to start properly"
  docker stop freqtrade-ReinforcedAverageStrategy

  # Test NFI strategy
  echo "Testing NFI strategy launch..."
  ./docker-launch.sh NostalgiaForInfinityX 1
  sleep 10
  docker logs freqtrade-NostalgiaForInfinityX | grep "Using strategy 'NostalgiaForInfinityX'" || echo "NFI bot failed to start properly"
  docker stop freqtrade-NostalgiaForInfinityX
  ```

- [x] Verify multiple bots can run simultaneously:
  
  ```bash
  # Launch multiple bots
  echo "Testing multiple simultaneous bot instances..."
  ./docker-launch.sh ReinforcedAverageStrategy 0
  ./docker-launch.sh NostalgiaForInfinityX 1
  ./docker-launch.sh ReinforcedQuickie 2
  
  # Check all instances are running
  docker ps | grep freqtrade
  ```

## Phase 5: Error Recovery and Maintenance

### 1. Error Recovery Setup

- [x] Create automatic container health monitoring:

  ```bash
  #!/bin/bash
  # scripts/health-check.sh

  # Find all freqtrade containers
  CONTAINERS=$(docker ps -a --filter "name=freqtrade-" --format "{{.Names}}")

  for CONTAINER in $CONTAINERS; do
    STATUS=$(docker inspect -f '{{.State.Status}}' $CONTAINER)

    if [ "$STATUS" != "running" ]; then
      echo "Container $CONTAINER is not running (status: $STATUS). Attempting restart..."
      docker start $CONTAINER
    else
      # Check if container is responsive
      STRATEGY=$(echo $CONTAINER | sed 's/freqtrade-//')
      PORT_OFFSET=$(docker port $CONTAINER | grep -o '810[0-9]:' | head -1 | cut -d: -f1 | sed 's/810//')
      PORT=$((8101 + $PORT_OFFSET))

      if ! curl -s --max-time 5 http://localhost:$PORT/api/v1/ping &>/dev/null; then
        echo "Container $CONTAINER is running but not responsive. Restarting..."
        docker restart $CONTAINER
      fi
    fi
  done
  ```

- [ ] Set up cron job for regular health checks:
  ```bash
  # Add to crontab
  # */10 * * * * /path/to/scripts/health-check.sh >> /path/to/health-check.log 2>&1
  ```

### 2. Backup Strategy

- [ ] Enhance `backup.sh` to support multiple bot instances with incremental backups:

  ```bash
  #!/bin/bash
  # scripts/backup.sh

  BACKUP_DIR="/backup/freqtrade/$(date +%Y-%m-%d)"
  RETENTION_DAYS=14
  DATA_DIR="/ndovu-data/freqtrade"

  # Create backup directory
  mkdir -p "$BACKUP_DIR"

  # Find all strategy directories
  STRATEGIES=$(find "$DATA_DIR" -mindepth 1 -maxdepth 1 -type d)

  for STRATEGY_DIR in $STRATEGIES; do
    STRATEGY_NAME=$(basename "$STRATEGY_DIR")
    STRATEGY_BACKUP_DIR="$BACKUP_DIR/$STRATEGY_NAME"
    mkdir -p "$STRATEGY_BACKUP_DIR"

    # Copy config file
    if [ -f "$STRATEGY_DIR/config.json" ]; then
      cp "$STRATEGY_DIR/config.json" "$STRATEGY_BACKUP_DIR/"
    fi

    # Backup databases
    DB_FILES=$(find "$STRATEGY_DIR/user_data" -name "*.sqlite")
    for DB in $DB_FILES; do
      # Use sqlite3 to create a consistent backup while DB is in use
      docker exec -i freqtrade-$STRATEGY_NAME sqlite3 /freqtrade/user_data/$(basename "$DB") ".backup '/tmp/backup.sqlite'"
      docker cp freqtrade-$STRATEGY_NAME:/tmp/backup.sqlite "$STRATEGY_BACKUP_DIR/$(basename "$DB")"
      docker exec -i freqtrade-$STRATEGY_NAME rm /tmp/backup.sqlite
    done

    # Backup logs (last 1000 lines only to save space)
    LOG_FILES=$(find "$STRATEGY_DIR/user_data/logs" -name "*.log")
    for LOG in $LOG_FILES; do
      tail -n 1000 "$LOG" > "$STRATEGY_BACKUP_DIR/$(basename "$LOG")"
    done
  done

  # Compress backup
  cd "$(dirname "$BACKUP_DIR")"
  tar -czf "$(basename "$BACKUP_DIR").tar.gz" "$(basename "$BACKUP_DIR")"
  rm -rf "$BACKUP_DIR"

  # Clean up old backups
  find "$(dirname "$BACKUP_DIR")" -name "*.tar.gz" -mtime +$RETENTION_DAYS -delete
  ```

### 3. Security Hardening

- [ ] Create security checklist and procedures:

  ```markdown
  # Security Checklist

  ## API Keys

  - [ ] Use API key-only access (no withdrawals enabled)
  - [ ] Rotate API keys every 90 days
  - [ ] Use IP restrictions on API keys

  ## Network Security

  - [ ] Use isolated Docker network for bot communication
  - [ ] Restrict Freqcache port to localhost only
  - [ ] Use explicit web UI authentication

  ## Access Control

  - [ ] Implement IP-based access restrictions for web UI
  - [ ] Use strong passwords for web UI
  - [ ] Enable two-factor authentication if available
  ```

- [ ] Set up automatic API key rotation script:
  ```bash
  # scripts/rotate-api-keys.sh
  # (Placeholder - implementation would depend on your API key management system)
  ```

## Phase 6: Documentation and Finalization

### 1. Update Documentation

- [ ] Update `README.md` with new multi-strategy functionality:

  ````markdown
  ## Multi-Strategy Support

  The bot now supports running multiple trading strategies simultaneously:

  ### Launch Commands

  ```bash
  # Launch default strategy on port 8101
  ./docker-launch.sh

  # Launch NFI strategy on port 8101
  ./docker-launch.sh NostalgiaForInfinityX

  # Launch multiple strategies on different ports
  ./docker-launch.sh ReinforcedQuickie 1  # Port 8102
  ./docker-launch.sh ReinforcedSmoothScalp 2  # Port 8103
  ./docker-launch.sh NostalgiaForInfinityX 3  # Port 8104
  ```
  ````

  ### Web Access

  Each bot instance is available on its respective port:

  - Main bot: https://trading.ai.etelej.com
  - Additional bots: https://trading-8102.ai.etelej.com, etc.

  ```

  ```

### 2. Create Launch Helper Scripts

- [ ] Develop `launch-all.sh` for quickly launching multiple strategies:

  ```bash
  #!/bin/bash
  # scripts/launch-all.sh

  # Launch primary strategies
  ./docker-launch.sh ReinforcedAverageStrategy 0
  ./docker-launch.sh NostalgiaForInfinityX 1
  ./docker-launch.sh ReinforcedQuickie 2

  # Wait between launches to prevent rate limit issues
  sleep 10

  # Launch secondary strategies
  ./docker-launch.sh ReinforcedSmoothScalp 3

  echo "All strategy bots launched"
  ```

- [ ] Create `monitor-all.sh` for monitoring all running bot instances:

  ```bash
  #!/bin/bash
  # scripts/monitor-all.sh

  # Find all freqtrade containers
  CONTAINERS=$(docker ps -a --filter "name=freqtrade-" --format "{{.Names}}")

  echo "===== TRADING BOT STATUS ====="
  echo "Time: $(date)"
  echo

  for CONTAINER in $CONTAINERS; do
    STRATEGY=$(echo $CONTAINER | sed 's/freqtrade-//')
    STATUS=$(docker inspect -f '{{.State.Status}}' $CONTAINER)
    UPTIME=$(docker inspect -f '{{.State.StartedAt}}' $CONTAINER | xargs -I{} date -d {} +%s)
    NOW=$(date +%s)
    UPTIME_SEC=$((NOW - UPTIME))
    UPTIME_HUMAN=$(printf '%dd %dh %dm %ds' $((UPTIME_SEC/86400)) $((UPTIME_SEC%86400/3600)) $((UPTIME_SEC%3600/60)) $((UPTIME_SEC%60)))

    echo "Strategy: $STRATEGY"
    echo "Status: $STATUS"
    echo "Uptime: $UPTIME_HUMAN"

    # Get open trades count
    if [ "$STATUS" = "running" ]; then
      PORT_OFFSET=$(docker port $CONTAINER | grep -o '810[0-9]:' | head -1 | cut -d: -f1 | sed 's/810//')
      PORT=$((8101 + $PORT_OFFSET))

      if curl -s --max-time 5 http://localhost:$PORT/api/v1/status &>/dev/null; then
        OPEN_TRADES=$(curl -s http://localhost:$PORT/api/v1/status | grep -o '"trade_count":[0-9]*' | cut -d: -f2)
        echo "Open trades: $OPEN_TRADES"
      else
        echo "API not responding"
      fi
    fi

    echo "----------------------------"
  done

  # Check Freqcache status
  if docker ps | grep -q freqcache; then
    echo "===== FREQCACHE STATUS ====="
    curl -s http://localhost:8100/metrics | grep -E 'cache_hit_ratio|requests_total'
    echo "============================"
  fi
  ```

- [ ] Implement `stop-all.sh` for gracefully stopping all instances:

  ```bash
  #!/bin/bash
  # scripts/stop-all.sh

  # Find all freqtrade containers
  CONTAINERS=$(docker ps -a --filter "name=freqtrade-" --format "{{.Names}}")

  for CONTAINER in $CONTAINERS; do
    echo "Stopping $CONTAINER..."
    docker stop $CONTAINER
  done

  echo "All trading bots stopped"
  ```

### 3. Performance Metrics

- [ ] Define and implement monitoring thresholds:

  ```bash
  # Add to scripts/monitor-all.sh

  # Define thresholds
  MIN_CACHE_HIT_RATIO=70  # Percent
  MAX_RESPONSE_TIME=2     # Seconds
  MAX_ERROR_RATE=1        # Percent

  # Check cache hit ratio
  CACHE_HIT_RATIO=$(curl -s http://localhost:8100/metrics | grep 'cache_hit_ratio' | grep -o '[0-9.]*')
  if (( $(echo "$CACHE_HIT_RATIO < $MIN_CACHE_HIT_RATIO" | bc -l) )); then
    echo "WARNING: Cache hit ratio below threshold: ${CACHE_HIT_RATIO}% < ${MIN_CACHE_HIT_RATIO}%"
  fi

  # Check error rates
  ERROR_COUNT=$(curl -s http://localhost:8100/metrics | grep 'errors_total' | grep -o '[0-9]*')
  REQUEST_COUNT=$(curl -s http://localhost:8100/metrics | grep 'requests_total' | grep -o '[0-9]*')
  ERROR_RATE=$(echo "scale=2; $ERROR_COUNT * 100 / $REQUEST_COUNT" | bc)

  if (( $(echo "$ERROR_RATE > $MAX_ERROR_RATE" | bc -l) )); then
    echo "WARNING: Error rate above threshold: ${ERROR_RATE}% > ${MAX_ERROR_RATE}%"
  fi
  ```

## Deployment Checklist

- [ ] Backup existing system

  - [ ] Database snapshots
  - [ ] Configuration files
  - [ ] Custom strategies

- [ ] Deploy updated Dockerfile

  - [ ] Build with all required dependencies
  - [ ] Test with single strategy

- [ ] Set up Freqcache infrastructure

  - [ ] Create isolated Docker network
  - [ ] Deploy Redis container
  - [ ] Deploy Freqcache container
  - [ ] Verify proxy functionality

- [ ] Create new config templates

  - [ ] Strategy-specific configurations
  - [ ] Freqcache integration
  - [ ] Staggered processing intervals

- [ ] Update strategy repositories

  - [ ] Standard Freqtrade strategies
  - [ ] NFI strategy

- [ ] Test deployments

  - [ ] Single strategy deployment
  - [ ] Multi-strategy deployment
  - [ ] Rate limit monitoring

- [ ] Setup monitoring and maintenance

  - [ ] Implement health checks
  - [ ] Configure backup script
  - [ ] Set up performance monitoring
  - [ ] Enable security measures

- [ ] Document final implementation
  - [ ] Update main README
  - [ ] Create usage examples
  - [ ] Document maintenance procedures
