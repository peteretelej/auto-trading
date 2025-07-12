# Requirements Setup

This guide covers the technical prerequisites and initial environment setup for the auto-trading system.

## System Requirements

### Hardware
- **RAM**: 8GB minimum (each strategy uses ~500MB)
- **Storage**: 25GB available space
- **CPU**: 1+ cores (multi-core recommended for multiple strategies)
- **Network**: Stable internet connection

### Operating System
- **Linux** (Ubuntu 20.04+ recommended)
- **macOS** (with Docker Desktop)
- **Windows** (with Docker Desktop or WSL2)

## Software Prerequisites

### Docker Installation

**Ubuntu/Debian:**
```bash
# Update package index
sudo apt update

# Install Docker
sudo apt install docker.io docker-compose

# Add user to docker group (logout/login required)
sudo usermod -aG docker $USER

# Verify installation
docker --version
```

**macOS:**
1. Download [Docker Desktop for Mac](https://docs.docker.com/desktop/mac/install/)
2. Install and start Docker Desktop
3. Verify: `docker --version`

**Windows:**
1. Install [Docker Desktop for Windows](https://docs.docker.com/desktop/windows/install/)
2. Ensure WSL2 backend is enabled
3. Verify: `docker --version`

### Additional Tools

**jq (JSON processor):**
```bash
# Ubuntu/Debian
sudo apt install jq

# macOS
brew install jq

# Verify
jq --version
```

## Project Setup

### Clone Repository
```bash
git clone https://github.com/peteretelej/auto-trading.git
cd auto-trading
```

### Environment Configuration
```bash
# Create environment file from template
cp .env.sample .env

# Edit with your settings (see next sections for values)
nano .env
```

### Test Installation
```bash
# Verify Docker works
docker run hello-world

# Test project scripts
chmod +x docker-launch.sh scripts/*.sh
./scripts/setup-proxy.sh
```

## Directory Structure

After setup, your project will have:
```
auto-trading/
├── config/                 # Strategy configuration templates  
├── docs/                   # Documentation (this folder)
├── scripts/                # Management and monitoring scripts
├── user_data/              # Local strategies and data
├── docker-launch.sh        # Main launch script
├── .env                    # Your API keys and settings
└── .env.sample            # Template for environment variables
```

## Environment Variables

Your `.env` file needs these values (details in next sections):

```bash
# Binance API (required for live trading)
BINANCE_API_KEY=your_api_key_here
BINANCE_API_SECRET=your_secret_here

# Telegram (optional, for notifications)
TELEGRAM_BOT_TOKEN=your_bot_token
TELEGRAM_CHAT_ID=your_chat_id

# Web Interface
WEB_USERNAME=admin
WEB_PASSWORD=your_secure_password
WEB_PORT=8101

# Data directory (adjust path as needed)
DATA_DIR=/home/yourusername/trading-data
```

## Verification

Test your setup works:

```bash
# 1. Test Docker and proxy
./scripts/setup-proxy.sh

# 2. Test bot launch (dry-run mode)
./docker-launch.sh

# 3. Check web interface
curl http://localhost:8101/api/v1/ping

# 4. View logs
docker logs freqtrade-ReinforcedAverageStrategy
```

## Troubleshooting

### Docker Permission Issues
```bash
# Add user to docker group
sudo usermod -aG docker $USER
# Logout and login again
```

### Port Already in Use
```bash
# Find process using port 8101
sudo lsof -i :8101
# Kill process or change WEB_PORT in .env
```

### Script Permission Errors
```bash
# Make scripts executable
chmod +x docker-launch.sh scripts/*.sh
```

## Optional: Domain Access Setup

If you want to access your bots via a custom domain instead of `localhost:8101`:
- [Caddy Reverse Proxy Setup](caddy-proxy.md) - Configure domain access with HTTPS

## Next Steps

With your environment ready, continue to:
- [Binance Setup](binance.md) - Configure your exchange account
- [Telegram Setup](telegram.md) - Set up trade notifications (optional)

Or jump to [Launching Strategies](../usage/launching.md) if you want to test in dry-run mode first.