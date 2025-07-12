# Project Structure

This reference explains the organization of files and directories in the auto-trading project.

## Root Directory

```
auto-trading/
├── config/                    # Strategy configuration templates
├── docs/                      # Project documentation
├── scripts/                   # Management and utility scripts
├── user_data/                 # Trading strategies and local data
├── docker-launch.sh           # Main bot launcher script
├── Dockerfile                 # Custom Docker image definition
├── requirements.txt           # Python dependencies
├── .env                       # Your environment variables (private)
├── .env.sample               # Environment variable template
├── .gitignore                # Git ignore rules
└── README.md                 # Project overview
```

## Configuration Directory (`config/`)

Contains strategy-specific configuration templates that are processed during bot startup.

```
config/
├── NFI-config-template.json                    # NostalgiaForInfinity settings
├── ReinforcedQuickie-config-template.json     # ReinforcedQuickie settings
├── BbandRsi-config-template.json              # BbandRsi settings  
├── SMAOffset-config-template.json             # SMAOffset settings
└── config-template.json                       # Default fallback template
```

### Template Processing
- Templates use environment variables: `${BINANCE_API_KEY}`
- Processed into actual config files during launch
- Each strategy gets isolated configuration

### Key Template Sections
- **Exchange settings**: API keys, rate limits, proxy configuration
- **Trading parameters**: Stake amounts, max trades, trading pairs
- **Risk management**: Stop-loss, take-profit, position sizing
- **Strategy specifics**: Indicators, timeframes, custom parameters

## Documentation Directory (`docs/`)

Organized educational documentation structure:

```
docs/
├── getting-started.md         # Main entry point for new users
├── concepts.md               # Trading concepts and background
├── setup/                    # Setup guides
│   ├── requirements.md       # Environment and technical setup
│   ├── binance.md           # Exchange account configuration
│   └── telegram.md          # Notification bot setup
├── usage/                    # Operational guides
│   ├── launching.md         # Starting and managing strategies  
│   ├── monitoring.md        # Performance tracking and analysis
│   └── strategies.md        # Strategy details and configuration
└── reference/               # Technical reference
    ├── project-structure.md # This file - project organization
    ├── configuration.md     # Detailed configuration options
    └── troubleshooting.md   # Common issues and solutions
```

## Scripts Directory (`scripts/`)

Management and utility scripts for system operation:

```
scripts/
├── setup-proxy.sh           # Initialize Binance rate-limiting proxy
├── monitor-proxy.sh         # Check proxy health and performance
├── monitor-bots.sh          # Monitor all running trading bots
├── backup.sh               # Backup trading databases and configs
├── update-strategies.sh     # Update strategy code from repositories
└── check-resources.sh       # System resource monitoring
```

### Script Functions

#### `setup-proxy.sh`
- Creates and starts binance-proxy container
- Handles rate limiting for multiple strategies
- Provides health checks and restart logic

#### `monitor-bots.sh`
- Shows status of all trading bot containers
- Displays uptime, resource usage, and trade counts
- Provides quick health overview

#### `backup.sh`
- Creates backups of trade databases
- Includes configuration files and logs
- Implements retention policies for storage management

#### `update-strategies.sh`  
- Downloads latest strategy code from repositories
- Updates both standard Freqtrade and NFI strategies
- Handles dependencies and validation

## User Data Directory (`user_data/`)

Contains strategy code and serves as template for bot data directories:

```
user_data/
├── strategies/              # Trading strategy Python files
│   ├── NFI.py              # NostalgiaForInfinity strategy
│   ├── ReinforcedQuickie.py # Quick momentum strategy
│   ├── BbandRsi.py         # Bollinger Bands + RSI strategy
│   ├── SMAOffset.py        # Simple moving average strategy
│   ├── berlinguyinca/      # Additional strategy collection
│   ├── futures/            # Futures trading strategies
│   └── lookahead_bias/     # Research/experimental strategies
├── data/                   # Market data (when downloaded)
├── logs/                   # Bot operation logs
└── notebooks/              # Jupyter notebooks for analysis
```

### Strategy Organization
- **Main strategies**: Core strategies optimized for spot trading
- **Collections**: Grouped strategies from specific developers
- **Futures strategies**: Specialized for futures trading
- **Experimental**: Research and testing strategies

## Runtime Data Structure

When bots are running, each strategy creates isolated data directories:

```
/your-data-directory/           # Defined by DATA_DIR in .env
├── NFI/                        # NFI strategy instance
│   ├── config.json            # Processed configuration
│   └── user_data/
│       ├── data/              # Downloaded market data
│       ├── logs/              # Strategy-specific logs
│       │   └── freqtrade-NFI.log
│       └── tradesv3-NFI.sqlite # Trade database
├── ReinforcedQuickie/          # Quickie strategy instance
│   ├── config.json
│   └── user_data/
│       ├── data/
│       ├── logs/
│       │   └── freqtrade-ReinforcedQuickie.log
│       └── tradesv3-ReinforcedQuickie.sqlite
└── ...
```

### Data Isolation Benefits
- **Independent databases**: Each strategy has separate trade history
- **Isolated logs**: Strategy-specific log files for easier debugging
- **Configuration separation**: Different settings per strategy
- **Independent market data**: Strategies can use different timeframes

## Key Files

### `docker-launch.sh`
Main script for launching trading strategies:
- **Argument processing**: Strategy name and port offset
- **Environment setup**: Configuration generation from templates
- **Container management**: Creates and starts Docker containers
- **Data directory creation**: Sets up isolated strategy directories
- **Proxy integration**: Ensures rate-limiting proxy is running

### `Dockerfile`
Custom Docker image definition:
- **Base image**: Built on official FreqTrade image
- **Additional dependencies**: TA libraries, analysis tools
- **System packages**: Required for strategy execution
- **Health checks**: Container monitoring capabilities

### `.env` File Structure
```bash
# Binance API Configuration
BINANCE_API_KEY=your_api_key_here
BINANCE_API_SECRET=your_secret_here

# Telegram Notifications (Optional)
TELEGRAM_BOT_TOKEN=your_bot_token
TELEGRAM_CHAT_ID=your_chat_id

# Web Interface Access
WEB_USERNAME=admin
WEB_PASSWORD=your_secure_password
WEB_PORT=8101

# Data Storage Location
DATA_DIR=/path/to/your/trading-data
```

## File Permissions and Security

### Executable Scripts
```bash
# Ensure scripts are executable
chmod +x docker-launch.sh
chmod +x scripts/*.sh
```

### Sensitive Files
- **`.env`**: Contains API keys - never commit to version control
- **Trade databases**: Contain financial data - backup regularly
- **Log files**: May contain sensitive information - protect access

### Docker Security
- **User isolation**: Containers run as non-root user
- **API restrictions**: Use read-only API keys when possible
- **Network isolation**: Containers use isolated networks

## Development and Customization

### Adding New Strategies
1. **Place strategy file** in `user_data/strategies/`
2. **Create configuration template** in `config/` (optional)
3. **Test in dry-run mode** before live trading
4. **Update documentation** if sharing with others

### Modifying Configurations
1. **Edit template files** in `config/` directory
2. **Use environment variables** for sensitive data
3. **Test changes** in dry-run mode first
4. **Document modifications** for future reference

### Custom Scripts
1. **Add scripts** to `scripts/` directory
2. **Make executable**: `chmod +x scripts/your-script.sh`
3. **Follow naming conventions**: Use descriptive names
4. **Include error handling** and logging

## Backup and Recovery

### Critical Data
- **Trade databases**: `tradesv3-*.sqlite` files
- **Configuration files**: Templates and processed configs
- **Environment variables**: `.env` file (store securely)
- **Custom strategies**: Any modified strategy files

### Backup Strategy
```bash
# Use provided backup script
./scripts/backup.sh

# Manual backup example
tar -czf backup-$(date +%Y%m%d).tar.gz \
  config/ .env user_data/strategies/ \
  /your-data-directory/*/user_data/tradesv3*.sqlite
```

### Recovery Process
1. **Restore configuration files** and environment variables
2. **Restore trade databases** to appropriate directories
3. **Verify API credentials** and permissions
4. **Test in dry-run mode** before resuming live trading

## Performance Considerations

### Resource Usage
- **Memory**: ~500MB per strategy container
- **CPU**: Minimal when not actively trading
- **Disk**: Grows with trade history and market data
- **Network**: API calls for market data and trade execution

### Optimization Tips
- **Limit concurrent strategies** based on available resources
- **Regular log cleanup** to manage disk space
- **Monitor API usage** to stay within rate limits
- **Use SSD storage** for better database performance

## Next Steps

Explore specific aspects:
- [Configuration details](configuration.md) - Detailed parameter explanations
- [Troubleshooting guide](troubleshooting.md) - Common issues and solutions
- [Getting started](../getting-started.md) - If you haven't started yet