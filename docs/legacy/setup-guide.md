# Setup Guide for Auto-Trading Project

This guide provides detailed instructions for setting up all components of the auto-trading project, including Binance account, Telegram bot, and local development environment.

## Table of Contents
1. [Binance Account Setup](#binance-account-setup)
2. [Telegram Bot Setup](#telegram-bot-setup)
3. [Local Development on Windows](#local-development-on-windows)
4. [Freqtrade Configuration](#freqtrade-configuration)
5. [Server Deployment](#server-deployment)

## Binance Account Setup

### 1. Create a Binance Account
1. Visit [Binance.com](https://www.binance.com/en/register)
2. Sign up with your email and create a strong password
3. Complete email verification
4. Enable Two-Factor Authentication (2FA) for security
   - Use Google Authenticator or Authy for 2FA
   - Store backup codes in a secure location

### 2. Complete Identity Verification (KYC)
1. Navigate to the "Identification" section
2. Select "Kenya" as your country of residence
3. Complete the Basic Verification:
   - Provide personal information
   - Upload ID document (passport, national ID, or driver's license)
   - Complete facial verification
4. Wait for verification approval (typically 1-24 hours)

### 3. Set Up M-Pesa as Payment Method
1. Go to the "Buy Crypto" section
2. Select "P2P Trading"
3. Click on "Payment Methods" and add M-Pesa
4. Verify your M-Pesa number

### 4. Fund Your Account via P2P
1. Go to "P2P Trading"
2. Select "Buy" and choose "USDT"
3. Filter sellers by "M-Pesa" payment method
4. Select a reputable seller with good completion rate and reviews
5. Enter the amount you wish to purchase (start with a small amount to test)
6. Follow the instructions to complete the M-Pesa payment
7. Confirm receipt of USDT in your Binance Spot Wallet

### 5. Generate API Keys
1. Go to "API Management" in your account settings
2. Click "Create API"
3. Set a label for your API (e.g., "FreqtradeBot")
4. **IMPORTANT SECURITY SETTINGS:**
   - Enable "Enable Reading"
   - Enable "Enable Spot & Margin Trading"
   - **DO NOT** enable "Enable Withdrawals"
   - Set IP restriction to your server's IP address
5. Complete security verification
6. Save your API Key and Secret Key securely
   - Store these in your .env file (never commit to git)
   - Keep a backup in a secure password manager

## Telegram Bot Setup

### 1. Create a Telegram Bot
1. Open Telegram and search for "@BotFather"
2. Start a chat with BotFather
3. Send the command `/newbot`
4. Follow the prompts to name your bot
   - Choose a name (e.g., "MyFreqtradeBot")
   - Choose a username ending with "bot" (e.g., "my_freqtrade_bot")
5. BotFather will provide a token - save this securely

### 2. Get Your Chat ID
1. Search for "@userinfobot" on Telegram
2. Start a chat and send any message
3. The bot will reply with your Chat ID
4. Alternatively, search for "@RawDataBot", start a chat, and look for the "chat":{"id":XXXXXXXXX} value

### 3. Configure Telegram in Freqtrade
1. Open your .env file
2. Update the Telegram settings:
   ```
   TELEGRAM_BOT_TOKEN=your_telegram_bot_token
   TELEGRAM_CHAT_ID=your_telegram_chat_id
   ```
3. The config.json file is already set up to use these environment variables

### 4. Test Telegram Integration
1. Start Freqtrade in dry-run mode
2. You should receive a startup message on Telegram
3. Send `/status` to your bot to check if it responds

## Local Development on Windows

### 1. Install Python
1. Download Python 3.9+ from [python.org](https://www.python.org/downloads/)
2. During installation:
   - Check "Add Python to PATH"
   - Check "Install pip"
3. Verify installation by opening Command Prompt and typing:
   ```
   python --version
   pip --version
   ```

### 2. Install Git
1. Download Git from [git-scm.com](https://git-scm.com/download/win)
2. Install with default options
3. Verify installation:
   ```
   git --version
   ```

### 3. Clone the Repository
1. Open Command Prompt
2. Navigate to your desired directory:
   ```
   cd C:\Projects
   ```
3. Clone the repository:
   ```
   git clone https://gitlab.com/peteretelej/auto-trading.git
   cd auto-trading
   ```

### 4. Set Up Virtual Environment
1. Create a virtual environment:
   ```
   python -m venv venv
   ```
2. Activate the virtual environment:
   ```
   venv\Scripts\activate
   ```
3. Your prompt should change to indicate the virtual environment is active

### 5. Install Freqtrade
1. Install dependencies:
   ```
   pip install -U pip setuptools wheel
   ```
2. Install Freqtrade:
   ```
   pip install freqtrade
   ```

### 6. Configure Freqtrade
1. Create a user_data directory:
   ```
   mkdir -p user_data\data user_data\logs user_data\strategies
   ```
2. Copy the example config:
   ```
   copy config\config.json.example user_data\config.json
   ```
3. Edit user_data\config.json with your settings
4. Create a .env file with your API keys (based on .env.sample)

### 7. Run Freqtrade in Dry-Run Mode
1. Ensure your virtual environment is activated
2. Run Freqtrade:
   ```
   freqtrade trade --config user_data\config.json --strategy SampleStrategy --dry-run
   ```

### 8. Access the Web UI
1. Ensure "api_server" is enabled in your config.json
2. Open a browser and navigate to:
   ```
   http://localhost:8101
   ```
3. Log in with the credentials from your config.json

## Freqtrade Configuration

### Basic Configuration
1. Edit config.json to set:
   - max_open_trades: Number of trades to open simultaneously
   - stake_currency: Base currency for trading (e.g., "USDT")
   - stake_amount: Amount to stake per trade or "unlimited"
   - dry_run: Set to true for testing, false for live trading

### Risk Management
1. Configure risk parameters:
   ```json
   "risk": {
     "max_position_size_percentage": 2,
     "max_drawdown_percentage": 10
   }
   ```
2. Set appropriate stoploss in your strategy

### Advanced Strategy Configuration (NFI)
1. For NostalgiaForInfinity (NFI) and other advanced strategies:
   ```json
   "stoploss": -0.99,
   "trailing_stop": false,
   "minimal_roi": {},
   "use_custom_stoploss": true,
   "position_adjustment_enable": true
   ```

2. Use the NFI-specific configuration template:
   ```bash
   cp config/nfi-config-template.json user_data/config-nfi.json
   ```

3. Launch with NFI-specific settings:
   ```bash
   ./docker-launch.sh NFI 1
   ```

4. Strategy-based risk management:
   - Allow strategy to manage its own exits and entries
   - Configure protection parameters in the strategy file
   - Use strategy's built-in pair selection logic when available
   - Gradually increase capital allocation based on performance

### Trading Pairs
1. Configure pair_whitelist with cryptocurrencies you want to trade
2. Use pair_blacklist to exclude specific pairs

### Strategy Selection
1. Choose a strategy:
   - Use sample strategies for testing
   - Develop custom strategies in user_data/strategies/
2. Specify the strategy when running Freqtrade:
   ```
   freqtrade trade --strategy YourStrategy
   ```

## Server Deployment

### 1. Update Caddyfile
Add a new service for Freqtrade to your Caddyfile:

```
trading.ai.etelej.com {
    import cloudflare_tls
    import ip_whitelist
    reverse_proxy localhost:8101
}
```

### 2. Deploy with Docker
1. Use the provided docker-launch.sh script
2. Ensure your .env file is properly configured
3. Run:
   ```
   chmod +x docker-launch.sh
   ./docker-launch.sh
   ```

### 3. Monitor Your Bot
1. Use the provided monitoring script:
   ```
   chmod +x scripts/monitor.sh
   ./scripts/monitor.sh
   ```
2. Set up regular backups:
   ```
   chmod +x scripts/backup.sh
   ./scripts/backup.sh
   ```
3. Consider adding a cron job for regular monitoring and backups
