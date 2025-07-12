#!/bin/bash
set -e

# Freqtrade Backup Script
# This script creates a backup of Freqtrade configuration and data

# Configuration
BACKUP_DIR="./backups"
DATA_DIR="/ndovu-data/freqtrade"
CONFIG_DIR="./config"
USER_DATA_DIR="./user_data"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="freqtrade_backup_${TIMESTAMP}.tar.gz"

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

echo "Starting Freqtrade backup process..."

# Create temporary directory for the backup
TEMP_DIR=$(mktemp -d)

# Check if Docker is running and if Freqtrade container exists
if docker ps | grep -q freqtrade; then
    echo "Freqtrade container is running. Creating DB backup..."
    # Execute SQL query to create DB file backup
    docker exec freqtrade sqlite3 /freqtrade/user_data/tradesv3.sqlite ".backup '/tmp/tradesv3_backup.sqlite'"
    # Copy the DB backup from the container
    docker cp freqtrade:/tmp/tradesv3_backup.sqlite "$TEMP_DIR/tradesv3.sqlite"
    echo "Database backup created."
else
    echo "Freqtrade container is not running. Skipping database export."
    # Try to copy the SQLite database file directly if it exists
    if [ -f "${DATA_DIR}/user_data/tradesv3.sqlite" ]; then
        cp "${DATA_DIR}/user_data/tradesv3.sqlite" "$TEMP_DIR/tradesv3.sqlite"
        echo "Database file copied directly."
    fi
fi

# Backup configuration files
echo "Backing up configuration files..."
mkdir -p "$TEMP_DIR/config"
if [ -d "$CONFIG_DIR" ]; then
    cp -r "$CONFIG_DIR"/* "$TEMP_DIR/config/"
elif [ -d "$DATA_DIR" ]; then
    cp -r "$DATA_DIR"/*.json "$TEMP_DIR/config/" 2>/dev/null || true
fi

# Backup user_data files
echo "Backing up user_data files..."
mkdir -p "$TEMP_DIR/user_data"
mkdir -p "$TEMP_DIR/user_data/strategies"
mkdir -p "$TEMP_DIR/user_data/hyperopt_results"

# Copy strategies
if [ -d "$USER_DATA_DIR/strategies" ]; then
    cp -r "$USER_DATA_DIR/strategies"/* "$TEMP_DIR/user_data/strategies/" 2>/dev/null || true
elif [ -d "$DATA_DIR/user_data/strategies" ]; then
    cp -r "$DATA_DIR/user_data/strategies"/* "$TEMP_DIR/user_data/strategies/" 2>/dev/null || true
fi

# Copy hyperopt results
if [ -d "$USER_DATA_DIR/hyperopt_results" ]; then
    cp -r "$USER_DATA_DIR/hyperopt_results"/* "$TEMP_DIR/user_data/hyperopt_results/" 2>/dev/null || true
elif [ -d "$DATA_DIR/user_data/hyperopt_results" ]; then
    cp -r "$DATA_DIR/user_data/hyperopt_results"/* "$TEMP_DIR/user_data/hyperopt_results/" 2>/dev/null || true
fi

# Backup .env file
if [ -f ".env" ]; then
    cp ".env" "$TEMP_DIR/.env"
    echo ".env file backed up."
fi

# Create the backup archive
echo "Creating backup archive..."
tar -czf "$BACKUP_DIR/$BACKUP_FILE" -C "$TEMP_DIR" .

# Cleanup
rm -rf "$TEMP_DIR"

echo "Backup completed successfully: $BACKUP_DIR/$BACKUP_FILE"
echo "Backup size: $(du -h "$BACKUP_DIR/$BACKUP_FILE" | cut -f1)"

# List all backups
echo "Available backups:"
ls -lh "$BACKUP_DIR" | grep "freqtrade_backup_"

# Delete backups older than 30 days
find "$BACKUP_DIR" -name "freqtrade_backup_*.tar.gz" -type f -mtime +30 -delete
echo "Backups older than 30 days have been deleted."
