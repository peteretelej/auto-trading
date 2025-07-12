#!/bin/bash
set -e

# Configuration
PROXY_NAME="binance-proxy"
PROXY_IMAGE="nightshift2k/binance-proxy:latest"
HOST_PORT=8100
INTERNAL_PORT=8090  # binance-proxy default port for SPOT
NETWORK_NAME="freqtrade-network"

# Function to handle errors
handle_error() {
    echo "❌ Error: $1"
    exit 1
}

# Check if Docker is running
if ! docker info >/dev/null 2>&1; then
    handle_error "Docker is not running"
fi

# Create network if it doesn't exist
if ! docker network ls | grep -q "${NETWORK_NAME}"; then
    echo "Creating Docker network ${NETWORK_NAME}..."
    docker network create "${NETWORK_NAME}" || handle_error "Failed to create network"
fi

# Check if container exists and is running
if docker ps -a --format '{{.Names}}' | grep -q "^${PROXY_NAME}$"; then
    echo "Stopping existing ${PROXY_NAME} container..."
    docker stop "${PROXY_NAME}" || handle_error "Failed to stop existing container"
    docker rm "${PROXY_NAME}" || handle_error "Failed to remove existing container"
fi

# Pull the latest binance-proxy image
echo "Pulling latest ${PROXY_IMAGE}..."
docker pull "${PROXY_IMAGE}" || handle_error "Failed to pull image"

# Start binance-proxy container
echo "Starting ${PROXY_NAME} container..."
docker run -d \
    --name "${PROXY_NAME}" \
    --network "${NETWORK_NAME}" \
    --restart unless-stopped \
    --memory=1024m \
    -e CACHE_DURATION=120 \
    -e ORDER_BOOK_CACHE_LIMIT=300 \
    -e KLINES_CACHE_LIMIT=500 \
    -p "${HOST_PORT}:${INTERNAL_PORT}" \
    "${PROXY_IMAGE}" || handle_error "Failed to start container"

# Wait for container to be ready
echo "Waiting for ${PROXY_NAME} to be ready..."
for i in {1..30}; do
    if curl -s "http://localhost:${HOST_PORT}/api/v3/ping" > /dev/null; then
        echo "✅ ${PROXY_NAME} is ready!"
        exit 0
    fi
    sleep 1
done

handle_error "${PROXY_NAME} failed to start properly" 