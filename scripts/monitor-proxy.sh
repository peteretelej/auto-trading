#!/bin/bash
set -e

# Configuration
PROXY_NAME="binance-proxy"
PROXY_IMAGE="nightshift2k/binance-proxy:latest"
HOST_PORT=8100
INTERNAL_PORT=8090
PROXY_URL="http://localhost:${HOST_PORT}"
CHECK_INTERVAL=60  # seconds
LOG_FILE="/tmp/binance-proxy-monitor.log"

# Function to handle errors
handle_error() {
    echo "❌ Error: $1"
    exit 1
}

# Check if Docker is running
if ! docker info >/dev/null 2>&1; then
    handle_error "Docker is not running"
fi

# Check if container exists and is running
if ! docker ps --format '{{.Names}}' | grep -q "^${PROXY_NAME}$"; then
    handle_error "${PROXY_NAME} container is not running. Use ./scripts/setup-proxy.sh to start it."
fi

# Get container info
CONTAINER_ID=$(docker ps --filter "name=${PROXY_NAME}" --format "{{.ID}}")
CREATED=$(docker inspect --format='{{.Created}}' "${CONTAINER_ID}")
STATUS=$(docker inspect --format='{{.State.Status}}' "${CONTAINER_ID}")
STARTED_AT=$(docker inspect --format='{{.State.StartedAt}}' "${CONTAINER_ID}")
UPTIME=$(docker inspect --format='{{.State.StartedAt}}' "${CONTAINER_ID}" | xargs -I{} date -d {} +%s)
NOW=$(date +%s)
UPTIME_SEC=$((NOW - UPTIME))
UPTIME_HUMAN=$(printf '%dd %dh %dm %ds' $((UPTIME_SEC/86400)) $((UPTIME_SEC%86400/3600)) $((UPTIME_SEC%3600/60)) $((UPTIME_SEC%60)))

# Print container info
echo "===== BINANCE PROXY STATUS ====="
echo "Container ID: ${CONTAINER_ID}"
echo "Image: ${PROXY_IMAGE}"
echo "Status: ${STATUS}"
echo "Created: ${CREATED}"
echo "Started: ${STARTED_AT}"
echo "Uptime: ${UPTIME_HUMAN}"

# Check if proxy is responding
if curl -s --max-time 5 "${PROXY_URL}/api/v3/ping" &>/dev/null; then
    echo "API Status: ✅ Responding"
    
    # Get exchange info to verify functionality
    echo "Testing exchange info endpoint..."
    if curl -s --max-time 5 "${PROXY_URL}/api/v3/exchangeInfo" > /dev/null; then
        echo "Exchange Info: ✅ Working"
    else
        echo "Exchange Info: ❌ Not working"
    fi
else
    echo "API Status: ❌ Not responding"
fi

# Show recent logs
echo -e "\n===== RECENT LOGS ====="
docker logs --tail 20 "${PROXY_NAME}" | grep -E "REST|PROXY|ERROR|WARNING" || echo "No relevant logs found"

# Check resource usage
MEMORY_USAGE=$(docker stats "${PROXY_NAME}" --no-stream --format "{{.MemUsage}}")
CPU_USAGE=$(docker stats "${PROXY_NAME}" --no-stream --format "{{.CPUPerc}}")
MEMORY_LIMIT="256MB"

echo -e "\n===== RESOURCE USAGE ====="
echo "Memory: ${MEMORY_USAGE} (Limit: ${MEMORY_LIMIT})"
echo "CPU: ${CPU_USAGE}"

echo -e "\n===== ENDPOINTS CACHED ====="
echo "The following endpoints are cached by binance-proxy:"
echo "- /api/v3/klines (candlestick data)"
echo "- /api/v3/depth (orderbook)"
echo "- /api/v3/ticker/24hr (24h price statistics)"
echo "- /api/v3/exchangeInfo (trading rules & symbol info)"
echo "All other endpoints are proxied directly to Binance API"

# Function to check endpoint health
check_endpoint() {
    local endpoint=$1
    local description=$2
    local start_time=$(date +%s%N)
    local response=$(curl -s -w "\n%{http_code}" "${PROXY_URL}${endpoint}")
    local end_time=$(date +%s%N)
    local latency=$(( (end_time - start_time) / 1000000 ))  # Convert to milliseconds
    
    local http_code=$(echo "$response" | tail -n1)
    local body=$(echo "$response" | sed '$d')
    
    if [ "$http_code" == "200" ]; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] ✅ ${description}: OK (${latency}ms)"
    else
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] ❌ ${description}: Failed - HTTP ${http_code}"
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] Error details for ${endpoint}: ${body}" >> "$LOG_FILE"
    fi
}

# Function to check container resources
check_resources() {
    local stats=$(docker stats "${PROXY_NAME}" --no-stream --format "{{.CPUPerc}}\t{{.MemUsage}}")
    local cpu_usage=$(echo "$stats" | cut -f1)
    local mem_usage=$(echo "$stats" | cut -f2)
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] 📊 Resources - CPU: ${cpu_usage}, Memory: ${mem_usage}"
}

# Main monitoring loop
echo "Starting ${PROXY_NAME} monitoring..."
echo "Logging detailed errors to: $LOG_FILE"

while true; do
    # Check basic endpoints
    check_endpoint "/api/v3/ping" "Ping"
    check_endpoint "/api/v3/time" "Server Time"
    check_endpoint "/api/v3/exchangeInfo" "Exchange Info"
    
    # Check container resources
    check_resources

    # Add rate limit monitoring
    echo -e "\n===== RATE LIMIT STATUS ====="
    docker exec "${PROXY_NAME}" cat /tmp/rate_limits.log 2>/dev/null || echo "No rate limit log found"

    # Check cache status
    echo -e "\n===== CACHE STATUS ====="
    docker exec "${PROXY_NAME}" sh -c 'ls -l /tmp/cache/ 2>/dev/null | wc -l' | { read count; echo "Total cached items: $count"; }
    
    # Wait for next check
    sleep "$CHECK_INTERVAL"
done 