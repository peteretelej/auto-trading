#!/bin/bash

# ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Function to check if container is running
is_container_running() {
    local status=$(docker inspect -f '{{.State.Status}}' "$1" 2>/dev/null)
    [[ "$status" == "running" ]]
}

# Function to get container uptime
get_container_uptime() {
    local started_at=$(docker inspect -f '{{.State.StartedAt}}' "$1" 2>/dev/null)
    if [ -n "$started_at" ]; then
        echo "Started: $(date -d "$started_at" '+%Y-%m-%d %H:%M:%S')"
    else
        echo "Not available"
    fi
}

# Function to get container port mapping
get_container_port() {
    local container=$1
    # Get the first port mapping that matches our port range (8101-8105)
    local port=$(docker inspect -f '{{range $p, $conf := .NetworkSettings.Ports}}{{if and (gt (index $conf 0).HostPort "8100") (lt (index $conf 0).HostPort "8106")}}{{(index $conf 0).HostPort}}{{end}}{{end}}' "$1" 2>/dev/null)
    if [ -n "$port" ]; then
        echo "$port"
    else
        echo "Unknown"
    fi
}

# Function to read config from container
get_config_value() {
    local container=$1
    local key=$2
    
    # Check if container is running before trying to exec
    if ! is_container_running "$container"; then
        echo "N/A"
        return
    fi
    
    # Use jq to extract the value from config.json
    local value=$(docker exec "$container" cat /freqtrade/user_data/config.json 2>/dev/null | \
                 jq -r "${key}" 2>/dev/null)
    
    if [ -n "$value" ] && [ "$value" != "null" ]; then
        echo "$value"
    else
        echo "Not set"
    fi
}

# Function to get bot status from API
get_bot_status() {
    local container=$1
    local port=$(get_container_port "$container")
    
    if ! is_container_running "$container"; then
        return 1
    fi
    
    # Try to get status from the API
    local status=$(docker exec "$container" curl -s http://localhost:8080/api/v1/status 2>/dev/null)
    if [ -n "$status" ]; then
        echo "$status"
        return 0
    fi
    return 1
}

# Get all freqtrade containers
containers=$(docker ps -a --filter "name=freqtrade-" --format "{{.Names}}")

if [ -z "$containers" ]; then
    echo -e "${RED}No freqtrade containers found!${NC}"
    exit 1
fi

echo -e "${BOLD}=== Freqtrade Containers Health Check ===${NC}\n"

# Loop through each container
for container in $containers; do
    # Extract strategy and instance from container name (format: freqtrade-STRATEGY-INSTANCE)
    strategy=$(echo "$container" | cut -d'-' -f2)
    instance=$(echo "$container" | cut -d'-' -f3)
    
    echo -e "\n${BLUE}${BOLD}=== $container ===${NC}"
    
    # Get port information
    port=$(get_container_port "$container")
    echo -e "${CYAN}Web UI: ${BOLD}http://localhost:$port${NC}"
    
    # Additional config information if container is running
    if is_container_running "$container"; then
        echo -e "${GREEN}Status: Running${NC}"
        echo -e "${GREEN}$(get_container_uptime "$container")${NC}"
        
        # Get key configuration details
        dry_run=$(get_config_value "$container" ".dry_run")
        stake_currency=$(get_config_value "$container" ".stake_currency")
        stake_amount=$(get_config_value "$container" ".stake_amount")
        max_open_trades=$(get_config_value "$container" ".max_open_trades")
        telegram_enabled=$(get_config_value "$container" ".telegram.enabled")
        
        echo -e "\n${BOLD}Configuration:${NC}"
        echo -e "----------------------------------------"
        # Determine if it's a main bot (has Telegram enabled)
        if [[ "$telegram_enabled" == "true" ]]; then
            echo -e "${MAGENTA}Bot Type: ${BOLD}Main Bot (Telegram enabled)${NC}"
        else
            echo -e "${MAGENTA}Bot Type: Secondary Bot${NC}"
        fi
        
        # Show trading mode
        if [[ "$dry_run" == "true" ]]; then
            echo -e "${YELLOW}Trading Mode: ${BOLD}Dry Run${NC}"
        else
            echo -e "${RED}Trading Mode: ${BOLD}Live Trading${NC}"
        fi
        
        # Show key settings
        echo -e "${CYAN}Strategy: ${BOLD}$strategy${NC}"
        echo -e "${CYAN}Stake Currency: ${BOLD}$stake_currency${NC}"
        echo -e "${CYAN}Stake Amount: ${BOLD}$stake_amount${NC}"
        echo -e "${CYAN}Max Open Trades: ${BOLD}$max_open_trades${NC}"
        echo -e "----------------------------------------"
        
        # Get current trading status
        bot_status=$(get_bot_status "$container")
        if [ $? -eq 0 ]; then
            echo -e "\n${BOLD}Current Trading Status:${NC}"
            echo -e "----------------------------------------"
            running_trades=$(echo "$bot_status" | jq -r '.running_trades | length')
            echo -e "${YELLOW}Open Trades: ${BOLD}$running_trades${NC}"
            
            # Show current trades if any
            if [ "$running_trades" -gt 0 ]; then
                echo -e "\n${BOLD}Active Trades:${NC}"
                echo "$bot_status" | jq -r '.running_trades[] | "  \(.pair): \(.profit_pct)% (\(.profit_abs) \(.stake_currency))"' | \
                while read line; do
                    if [[ "$line" == *"-"* ]]; then
                        echo -e "${RED}$line${NC}"
                    else
                        echo -e "${GREEN}$line${NC}"
                    fi
                done
            fi
            echo -e "----------------------------------------"
        fi
        
        echo -e "\n${YELLOW}Recent Logs (INFO/WARNING/ERROR):${NC}"
        echo -e "----------------------------------------"
        docker logs "$container" --tail 100 2>&1 | grep -v "DEBUG" | grep -E "INFO|WARNING|ERROR|CRITICAL" | tail -n 10
        echo -e "----------------------------------------"
    else
        echo -e "${RED}Status: Not Running${NC}"
        echo -e "${RED}Last known logs:${NC}"
        echo -e "----------------------------------------"
        docker logs "$container" --tail 20 2>&1
        echo -e "----------------------------------------"
    fi
done

# Performance summary
echo -e "\n${BOLD}=== Overall Performance Summary ===${NC}"
for container in $containers; do
    if is_container_running "$container"; then
        # Try to get performance data from the API
        perf=$(docker exec "$container" curl -s http://localhost:8080/api/v1/performance 2>/dev/null)
        
        if [ -n "$perf" ] && [ "$perf" != "null" ]; then
            echo -e "\n${BLUE}${container}:${NC}"
            echo -e "----------------------------------------"
            echo "$perf" | jq -r 'map("\(.pair): \(.profit_pct)% (\(.profit_abs) \(.stake_currency))") | .[]' 2>/dev/null | \
            while read line; do
                if [[ "$line" == *"-"* ]]; then
                    echo -e "  ${RED}$line${NC}"
                else
                    echo -e "  ${GREEN}$line${NC}"
                fi
            done
            echo -e "----------------------------------------"
        fi
    fi
done

# Error summary
echo -e "\n${BOLD}=== Error Summary ===${NC}"
for container in $containers; do
    errors=$(docker logs "$container" --tail 100 2>&1 | grep -i "error" | wc -l)
    if [ "$errors" -gt 0 ]; then
        echo -e "${RED}${container}: Found ${errors} errors in recent logs${NC}"
        # Show the actual errors
        echo -e "Recent errors:"
        docker logs "$container" --tail 100 2>&1 | grep -i "error" | tail -n 3
    else
        echo -e "${GREEN}${container}: No recent errors${NC}"
    fi
done 