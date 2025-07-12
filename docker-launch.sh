#!/bin/bash
set -e

# Enable command tracing for debugging
set -x

# Default strategies to launch when using "All"
STRATEGIES=("NFI" "ReinforcedQuickie" "SMAOffset" "BbandRsi" "BB_RPB_TSL_RNG")
# Specify which strategy should be the main bot (with Telegram). Leave empty for no main bot.
MAIN_BOT="NFI"
# all available strategies
#STRATEGIES=("NFI" "ReinforcedQuickie" "SMAOffset" "BbandRsi" "ElliotV5" "MultiMA_TSL3" "BB_RPB_TSL_RNG" "BinHV45")

# Function to handle errors with better messages
handle_error() {
    echo "❌ Error: $1"
    echo "Command that failed: $BASH_COMMAND"
    echo "Error occurred on line $BASH_LINENO"
    exit 1
}

# Setup error trap to provide better diagnostics
trap 'handle_error "Command failed with exit code $?"' ERR

# Load environment variables first
if [ -f ".env" ]; then
    echo "Loading environment variables from .env file..."
    set -a  # automatically export all variables
    source .env
    set +a
else
    echo "❌ Error: No .env file found. Please create one from .env.example"
    exit 1
fi

# Validate required environment variables
required_vars=(
    "BINANCE_API_KEY"
    "BINANCE_API_SECRET"
    "TELEGRAM_BOT_TOKEN"
    "TELEGRAM_CHAT_ID"
    "JWT_SECRET_KEY"
    "WEB_USERNAME"
    "WEB_PASSWORD"
    "WEB_BASE_URL"
)

for var in "${required_vars[@]}"; do
    if [ -z "${!var}" ]; then
        echo "❌ Error: Required environment variable $var is not set in .env file"
        exit 1
    fi
done

# Configuration
PROXY_NAME="binance-proxy"
PROXY_IMAGE="nightshift2k/binance-proxy:latest"
HOST_PORT=8100
INTERNAL_PORT=8090
NETWORK_NAME="freqtrade-network"
MAX_BOTS=8
BASE_PORT=8101
CONFIG_DIR="config"  # For templates only
DATA_DIR="/ndovu-data/freqtrade"  # Host directory for persistent data
FREQTRADE_IMAGE="auto-trading:latest"

# Function to check if port is available
is_port_available() {
    local port=$1
    ! netstat -tln | grep -q ":${port} "
}

# Function to get next available port
get_next_port() {
    local port=$BASE_PORT
    while [ $port -lt $(($BASE_PORT + $MAX_BOTS)) ]; do
        if is_port_available $port; then
            echo $port
            return 0
        fi
        ((port++))
    done
    handle_error "No available ports in range $BASE_PORT-$(($BASE_PORT + $MAX_BOTS - 1))"
}

# Function to prepare strategy config
prepare_config() {
    local strategy=$1
    local instance=$2
    local port=$3
    local is_main_bot=$4  # New parameter to indicate if this is the main bot
    
    # Redirect all debug output to stderr
    {
        echo "DEBUG: Entering prepare_config with strategy=$strategy, instance=$instance, port=$port, is_main_bot=$is_main_bot"
        
        # Create instance-specific config directory in DATA_DIR and ensure it exists
        local processed_config_dir="${DATA_DIR}/configs"
        mkdir -p "$processed_config_dir"
        if [ ! -d "$processed_config_dir" ]; then
            echo "ERROR: Failed to create config directory: $processed_config_dir"
            return 1
        fi
        echo "DEBUG: Created processed_config_dir: $processed_config_dir"
        
        # Select template based on strategy
        local template="${CONFIG_DIR}/${strategy}-config-template.json"
        local config="${processed_config_dir}/${strategy}-${instance}.json"
        echo "DEBUG: template=$template, config=$config"
        
        if [ ! -f "$template" ]; then
            template="${CONFIG_DIR}/config-template.json"
            echo "DEBUG: Strategy template not found, using default: $template"
        fi
        
        if [ ! -f "$template" ]; then
            echo "ERROR: No config template found for strategy $strategy"
            return 1
        fi

        # Export additional variables needed for the config
        export INSTANCE_NAME="${strategy}-${instance}"
        export PROXY_URL="http://${PROXY_NAME}:${INTERNAL_PORT}/api/v3"
        export API_SERVER_PORT="${port}"
        export WEB_PORT="${port}"  # For CORS origins
        echo "DEBUG: Exported env vars: INSTANCE_NAME=$INSTANCE_NAME, PROXY_URL=$PROXY_URL, API_SERVER_PORT=$API_SERVER_PORT, WEB_PORT=$WEB_PORT"
        
        # First apply strategy-specific configurations using jq
        if [ "$strategy" = "NFI" ]; then
            # Ensure AgeFilter is correctly positioned after StaticPairList for NFI
            echo "DEBUG: Applying NFI-specific configuration"
            jq '.pairlists = [
                {"method": "StaticPairList"},
                {"method": "AgeFilter", "min_days_listed": 30},
                {"method": "VolumePairList", "number_assets": 20, "sort_key": "quoteVolume", "min_value": 0, "refresh_period": 1800},
                {"method": "PrecisionFilter"},
                {"method": "PriceFilter", "low_price_ratio": 0.01},
                {"method": "SpreadFilter", "max_spread_ratio": 0.005},
                {"method": "RangeStabilityFilter", "lookback_days": 3, "min_rate_of_change": 0.05, "refresh_period": 1440},
                {"method": "VolatilityFilter", "lookback_days": 3, "min_volatility": 0.02, "max_volatility": 0.75, "refresh_period": 1440}
            ]' "$template" > "$config"
            echo "DEBUG: jq exit code: $?"
        else
            echo "DEBUG: Using template as-is for non-NFI strategy"
            cp "$template" "$config"
        fi
        
        # Verify config file was created
        if [ ! -f "$config" ]; then
            echo "ERROR: Failed to create config file from template"
            return 1
        fi
        
        # Then substitute environment variables
        echo "DEBUG: Substituting environment variables"
        envsubst < "$config" > "${config}.tmp" && mv "${config}.tmp" "$config"
        
        # Explicitly set Telegram enabled state based on main bot status
        if [ "$is_main_bot" = "true" ]; then
            echo "DEBUG: Enabling Telegram for main bot"
            jq '.telegram.enabled = true' "$config" > "${config}.tmp" && mv "${config}.tmp" "$config"
        else
            echo "DEBUG: Disabling Telegram for non-main bot"
            jq '.telegram.enabled = false' "$config" > "${config}.tmp" && mv "${config}.tmp" "$config"
        fi
        
        # Make sure all numeric fields are properly converted to numbers
        echo "DEBUG: Converting numeric fields"
        jq '.api_server.listen_port |= (if type == "string" then tonumber else . end) | 
            .max_open_trades |= (if type == "string" then tonumber else . end) | 
            .stake_amount |= (if type == "string" then tonumber else . end) |
            .dry_run_wallet |= (if type == "string" then tonumber else . end)' "$config" > "${config}.tmp" && mv "${config}.tmp" "$config"
        
        echo "DEBUG: Final config: $config"
        grep -i "listen_port" "$config" || echo "DEBUG: listen_port not found in config"
        
        # Final verification that file exists and is readable
        if [ ! -f "$config" ]; then
            echo "ERROR: Config file doesn't exist at the end of prepare_config: $config"
            return 1
        fi
        
        # All debug output goes to stderr
    } >&2
    
    # Only this is captured as the function output
    echo "${processed_config_dir}/${strategy}-${instance}.json"
}

# Function to launch a single bot with proper error handling
launch_bot() {
    local strategy=$1
    local instance=$2
    local is_main_bot=false  # Default to false
    
    # Simple check if this is the main bot
    if [ "$strategy" = "$MAIN_BOT" ]; then
        is_main_bot=true
    fi
    
    echo "DEBUG: Entering launch_bot function with strategy=$strategy, instance=$instance, is_main_bot=$is_main_bot"
    
    # Check if we've reached max bots
    RUNNING_BOTS=$(docker ps --format '{{.Names}}' | grep -c "freqtrade")
    echo "DEBUG: RUNNING_BOTS=$RUNNING_BOTS, MAX_BOTS=$MAX_BOTS"
    if [ $RUNNING_BOTS -ge $MAX_BOTS ]; then
        handle_error "Maximum number of bots ($MAX_BOTS) already running"
    fi

    # Get next available port
    PORT=$(get_next_port)
    echo "DEBUG: PORT=$PORT"

    # Create data directories if they don't exist
    mkdir -p "${DATA_DIR}/user_data"
    mkdir -p "${DATA_DIR}/user_data/data"
    mkdir -p "${DATA_DIR}/user_data/logs"
    mkdir -p "${DATA_DIR}/user_data/strategies"
    echo "DEBUG: Created data directories"

    # Copy user_data contents if needed
    if [ -d "user_data" ]; then
        echo "Copying contents from user_data to ${DATA_DIR}/user_data/ ..."
        cp -rT "user_data" "${DATA_DIR}/user_data/" || echo "Warning: Could not copy all contents from user_data. Check permissions."
    fi

    # Prepare config and make sure it exists before proceeding
    echo "DEBUG: Calling prepare_config"
    CONFIG_FILE=$(prepare_config "$strategy" "$instance" "$PORT" "$is_main_bot")
    echo "DEBUG: CONFIG_FILE=$CONFIG_FILE"
    
    if [ ! -f "$CONFIG_FILE" ]; then
        echo "ERROR: Config file $CONFIG_FILE does not exist. prepare_config failed."
        return 1
    fi

    # Use realpath to get absolute path without potential character issues
    RESOLVED_CONFIG_FILE=$(realpath "${CONFIG_FILE}")
    echo "DEBUG: RESOLVED_CONFIG_FILE=$RESOLVED_CONFIG_FILE"
    
    if [ -z "$RESOLVED_CONFIG_FILE" ] || [ ! -f "$RESOLVED_CONFIG_FILE" ]; then
        echo "ERROR: Failed to resolve config file path or file doesn't exist: $CONFIG_FILE"
        return 1
    fi

    # Launch the bot
    CONTAINER_NAME="freqtrade-${strategy}-${instance}"
    echo "DEBUG: CONTAINER_NAME=$CONTAINER_NAME"

    if [ "$is_main_bot" = "true" ]; then
        echo "📱 Launching main bot with Telegram: $CONTAINER_NAME"
    else
        echo "🤖 Launching secondary bot: $CONTAINER_NAME"
    fi
    
    echo "🚀 Launching on port $PORT..."
    
    # Launch function with error handling
    launch_docker_container() {
        local container_name=$1
        local is_main=$2
        
        echo "DEBUG: Running docker command for ${is_main:+main}${is_main:+secondary} bot"
        echo "DEBUG: CONFIG_FILE before Docker run: $RESOLVED_CONFIG_FILE"
        set +e  # Temporarily disable exit on error just for the docker run
        
        # Map the port to the same port inside and outside the container
        docker run -d \
            --name "$container_name" \
            --network "${NETWORK_NAME}" \
            --restart unless-stopped \
            -v "${DATA_DIR}/user_data:/freqtrade/user_data" \
            -v "$RESOLVED_CONFIG_FILE:/freqtrade/user_data/config.json:ro" \
            -p "${PORT}:${PORT}" \
            ${FREQTRADE_IMAGE} trade \
            --config /freqtrade/user_data/config.json \
            --strategy "$strategy"
        local result=$?
        set -e  # Re-enable exit on error
        return $result
    }
    
    # Call the launch function and handle errors
    if ! launch_docker_container "$CONTAINER_NAME" "$is_main_bot"; then
        echo "⚠️ Failed to launch $CONTAINER_NAME. Docker command failed."
        echo "ℹ️ Check the previous messages for specific Docker errors."
        return 1
    fi

    echo "✅ Bot launched successfully! Monitor at http://localhost:$PORT"
    echo "DEBUG: Exiting launch_bot function"
    return 0
}

# Function to stop running bots
stop_bots() {
    local pattern=$1
    local running_bots
    
    echo "🛑 Stopping running bots matching pattern: freqtrade-${pattern}"
    running_bots=$(docker ps -a -q --filter "name=freqtrade-${pattern}")
    
    if [ -n "$running_bots" ]; then
        echo "Found running/stopped bots, stopping and removing them..."
        docker stop $running_bots 2>/dev/null || true
        docker rm $running_bots 2>/dev/null || true
        echo "✅ All matching bots stopped and removed successfully"
    else
        echo "No matching bots found"
    fi
}

# Function to validate build
validate_build() {
    echo "🔍 Validating build..."
    if ! docker build -t ${FREQTRADE_IMAGE} .; then
        handle_error "Failed to build custom image"
    fi
    echo "✅ Build validation successful"
}

# Check if Docker network exists
if ! docker network ls | grep -q "${NETWORK_NAME}"; then
    echo "Creating ${NETWORK_NAME}..."
    docker network create "${NETWORK_NAME}" || handle_error "Failed to create network"
fi

# Update trading strategies
echo "📥 Downloading required trading strategies..."
bash ./scripts/update-strategies.sh

# Check if binance-proxy is running
if ! curl -s "http://localhost:${HOST_PORT}/api/v3/ping" > /dev/null; then
    echo "Starting ${PROXY_NAME}..."
    ./scripts/setup-proxy.sh
fi

# Build custom Freqtrade image if not exists
if ! docker images ${FREQTRADE_IMAGE} | grep -q "${FREQTRADE_IMAGE}"; then
    echo "🔨 Building custom Freqtrade image..."
    docker build -t ${FREQTRADE_IMAGE} . || handle_error "Failed to build custom image"
fi

# Parse command line arguments
STRATEGY=${1:-"default"}

if [ "$STRATEGY" = "All" ]; then
    # First validate the build
    validate_build
    
    # Stop ALL existing bots (both running and stopped containers)
    echo "🧹 Cleaning up all existing bots before launching new ones..."
    stop_bots ".*"
    
    # Small pause to ensure cleanup is complete
    sleep 2
    
    echo "🚀 Launching all supported strategies..."
    LAUNCH_SUCCESS=0
    LAUNCH_FAILED=0
    
    # We need to disable exit on error just for the strategy loop
    set +e
    for ((i=0; i<${#STRATEGIES[@]}; i++)); do
        echo "Launching strategy ${i+1}/${#STRATEGIES[@]}: ${STRATEGIES[$i]}"
        if launch_bot "${STRATEGIES[$i]}" "$((i+1))"; then
            LAUNCH_SUCCESS=$((LAUNCH_SUCCESS + 1))
        else
            LAUNCH_FAILED=$((LAUNCH_FAILED + 1))
            echo "⚠️ Strategy ${STRATEGIES[$i]} failed to launch, but continuing with others"
        fi

        # delay between bot launches
        echo "🔄 Sleeping for 10 seconds before launching next bot..."
        sleep 10
    done
    # Re-enable exit on error after loop
    set -e
    
    if [ $LAUNCH_SUCCESS -gt 0 ]; then
        echo "✅ Launch summary: $LAUNCH_SUCCESS bots started successfully, $LAUNCH_FAILED failed"
    else
        echo "❌ All bot launches failed. Check logs for details."
        exit 1
    fi
else
    # For single strategy, only stop that specific one
    stop_bots "${STRATEGY}"
    INSTANCE=${2:-"1"}
    launch_bot "$STRATEGY" "$INSTANCE"
fi
