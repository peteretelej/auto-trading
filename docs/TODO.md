# Auto-Trading Project TODO List

This document provides a structured checklist of tasks to complete for the auto-trading project. Tasks are organized by phase and complexity, with clear success criteria and dependencies.

## How to Use This Checklist

- Mark tasks as completed by changing `[ ]` to `[x]`
- Complete all tasks in a section before moving to the next section
- Document any issues or learnings as you complete each task

---

## Phase 1: Foundation Setup (Basic Complexity)

### 1.1 Development Environment
- [ ] **Install Docker**
  - Verify with: `docker --version`
  - Reference: [Docker Installation](https://docs.docker.com/get-docker/)

- [ ] **Clone and prepare repository**
  - Run: `git clone https://gitlab.com/peteretelej/auto-trading.git`
  - Run: `cd auto-trading`

- [ ] **Run installation scripts**
  - For Linux/Mac: `chmod +x scripts/install.sh && ./scripts/install.sh`
  - For Windows: Run `scripts/install_windows.bat`

- [ ] **Verify installation**
  - Check all directories created: `config/`, `user_data/`
  - Ensure all scripts are executable

- [ ] **Test web interface accessibility**
  - Run: `chmod +x docker-launch.sh && ./docker-launch.sh` (Linux/Mac)
  - Or run: `scripts/run_windows.bat` (Windows)
  - Verify access to: `http://localhost:8101`

**✓ Success Criteria:** All tools installed and verified working, web interface accessible

### 1.2 Binance Account
- [x] **Create Binance account**
  - Sign up at [Binance.com](https://www.binance.com/en/register)
  - Enable 2FA security
  - Store backup codes securely

- [x] **Complete KYC verification**
  - Submit identity documents
  - Complete facial verification
  - Verify account status shows "Verified"

- [x] **Set up M-Pesa as payment method**
  - Add M-Pesa to P2P payment methods
  - Verify phone number
  - Test P2P interface navigation

- [x] **Generate API keys**
  - Enable "Reading" and "Spot & Margin Trading" permissions
  - **DISABLE** withdrawals permission
  - Set IP restrictions if using fixed IP
  - Store keys securely (not in git repository)

**✓ Success Criteria:** Account verified and API keys generated with correct permissions

### 1.3 Project Configuration
- [x] **Configure environment variables**
  - Copy `.env.sample` to `.env`
  - Add Binance API keys to `.env`
  - Add Telegram bot token and chat ID to `.env`
  - Add Web UI credentials to `.env`
  - Set appropriate data directory path

- [ ] **Customize trading configuration**
  - Copy `config/config.json.example` to `config/config.json`
  - Set risk parameters (max trades, stake amount)
  - Configure trading pairs whitelist
  - Note: All secrets are loaded from .env file

- [x] **Set up Telegram bot**
  - Create bot via BotFather
  - Get bot token and chat ID
  - Add to `.env` file
  - Verify configuration is working

- [ ] **Test configuration**
  - Run in dry-run mode
  - Verify logs show no errors
  - Check Telegram notifications
  - Verify environment variables are properly loaded

**✓ Success Criteria:** All configuration files properly set up and tested

---

## Phase 2: Strategy Development (Medium Complexity)

### 2.1 Strategy Research
- [ ] **Review sample strategies**
  - Examine `user_data/strategies/conservative_strategy.py`
  - Review Freqtrade documentation on strategies
  - Understand strategy structure and components

- [ ] **Learn about technical indicators**
  - Research indicators used in sample strategies
  - Understand how indicators signal entry/exit points
  - Document indicator pros/cons

- [ ] **Define strategy selection criteria**
  - Determine risk tolerance
  - Set target profit expectations
  - Define acceptable drawdown
  - Document criteria for strategy evaluation

- [ ] **Select initial trading pairs**
  - Research top trading pairs by volume
  - Focus on major coins (BTC, ETH, etc.)
  - Consider volatility and liquidity
  - Create initial whitelist

**✓ Success Criteria:** 2-3 strategies selected for testing with clear selection criteria

### 2.2 Testing Environment
- [ ] **Download historical data**
  - For Linux/Mac: `docker run --rm -v "$(pwd)/user_data:/freqtrade/user_data" freqtradeorg/freqtrade:latest download-data --pairs BTC/USDT ETH/USDT --timeframes 1m 5m 15m 1h 4h 1d`
  - For Windows: Use menu option in `scripts/run_windows.bat`
  - Ensure minimum 6 months of data

- [ ] **Verify data quality**
  - Check for gaps in data
  - Ensure all timeframes downloaded
  - Verify data directory structure

- [ ] **Set up automated data updates**
  - Create script or cron job for regular updates
  - Test automated update process
  - Document update procedure

- [ ] **Prepare backtesting scripts**
  - Create backtesting command templates
  - Document parameter options
  - Set up results directory

**✓ Success Criteria:** Complete historical data available and backtesting environment ready

### 2.3 Strategy Validation
- [ ] **Run backtests**
  - Test each selected strategy: `docker run --rm -v "$(pwd)/user_data:/freqtrade/user_data" freqtradeorg/freqtrade:latest backtesting --config user_data/config.json --strategy ConservativeStrategy --timerange 20210101-20210630`
  - Test across multiple timeframes
  - Document command used for each test
  - Save results for comparison

- [ ] **Analyze performance metrics**
  - Compare profit/loss percentages
  - Analyze drawdown periods
  - Calculate win/loss ratios
  - Evaluate number of trades

- [ ] **Compare strategy results**
  - Create comparison table/chart
  - Identify strengths/weaknesses of each
  - Document findings

- [ ] **Select best strategy**
  - Choose based on documented criteria
  - Document reasoning for selection
  - Save strategy parameters

- [ ] **Deploy in dry-run mode**
  - Configure selected strategy
  - Start in paper trading mode
  - Verify trades are being simulated
  - Monitor initial performance

**✓ Success Criteria:** Strategy proven in backtesting and deployed in dry-run mode

---

## Phase 3: Live Deployment (High Complexity)

### 3.1 Risk Management
- [ ] **Strategy-Specific Risk Management**
  - Review strategy documentation for risk management features
  - For NFI: Configure with permissive stoploss (-0.99)
  - Enable position_adjustment_enable for NFI
  - Use strategy-specific configuration templates

- [ ] **Configure Position Adjustments**
  - Enable multiple trade entries for advanced strategies
  - Test position cost averaging in dry-run
  - Understand how strategies handle position adjustments
  - Verify capital allocation across trades

- [ ] **Strategy Protection Parameters**
  - Configure strategy-specific protections
  - Test CooldownPeriod protection
  - Implement StoplossGuard for market crashes
  - Verify MaxDrawdown protection triggers

- [ ] **Define Pair Selection Method**
  - Implement strategy-recommended pairlists
  - Test rangebound filters for volatility control
  - Configure age and volume filters
  - Optimize pair refresh periods

- [ ] **Gradual Capital Deployment**
  - Start with 20-30% of total capital
  - Create capital increase schedule based on performance
  - Document performance metrics for capital increases
  - Set up monitoring for performance tracking

### 3.2 Initial Trading
- [ ] **Transfer initial funds**
  - Use P2P marketplace with M-Pesa
  - Start with small amount ($100-200)
  - Document transaction process
  - Verify funds in spot wallet

- [ ] **Verify exchange connectivity**
  - Check API connection
  - Verify permissions working
  - Test market data access
  - Confirm order capabilities

- [ ] **Execute test trades**
  - Place small manual test order
  - Verify order execution
  - Test order cancellation
  - Document exchange behavior

- [ ] **Enable live trading**
  - Remove dry-run parameter
  - Start with minimal capital
  - Monitor first automated trades
  - Document go-live process

**✓ Success Criteria:** Successfully executing live trades with proper risk management

### 3.3 Monitoring Infrastructure
- [ ] **Configure logging**
  - Set appropriate log levels
  - Ensure log rotation
  - Verify logs contain needed info
  - Test log access during operation

- [ ] **Set up alerts**
  - Configure Telegram notifications
  - Set up critical error alerts
  - Create trade execution notifications
  - Test all notification types

- [ ] **Implement monitoring scripts**
  - Configure `scripts/monitor.sh`
  - Set up regular execution (cron)
  - Test monitoring during operation
  - Document monitoring procedures

- [ ] **Create performance dashboard**
  - Set up simple dashboard (can use Freqtrade UI)
  - Configure key metrics display
  - Ensure mobile accessibility
  - Document dashboard access

**✓ Success Criteria:** Complete monitoring system with alerts and performance tracking

---

## Phase 4: Optimization (Advanced Complexity)

### 4.1 Performance Tracking
- [ ] **Establish metrics system**
  - Define KPIs for strategy performance
  - Create tracking spreadsheet/database
  - Set up regular data collection
  - Document metrics methodology

- [ ] **Create review process**
  - Develop review checklist
  - Set review frequency
  - Create review template
  - Document review procedure

- [ ] **Document optimization workflow**
  - Define when to optimize
  - Create parameter tuning process
  - Establish testing methodology
  - Document workflow steps

- [ ] **Set up update procedures**
  - Define strategy update process
  - Create configuration update checklist
  - Document rollback procedures
  - Test update process

**✓ Success Criteria:** Complete performance tracking and optimization system established

### 4.2 Strategy Enhancement
- [ ] **Analyze trade patterns**
  - Review successful/unsuccessful trades
  - Identify market conditions affecting performance
  - Look for missed opportunities
  - Document pattern findings

- [ ] **Identify improvement areas**
  - Analyze entry/exit timing
  - Review stop-loss effectiveness
  - Evaluate pair selection performance
  - Document potential improvements

- [ ] **Test parameter adjustments**
  - Use hyperopt for parameter optimization
  - Test adjustments in backtesting
  - Validate in dry-run if needed
  - Document parameter changes

- [ ] **Implement and document changes**
  - Update strategy with improvements
  - Document all changes made
  - Track performance before/after
  - Create version history

**✓ Success Criteria:** Strategy improvements identified, tested, and implemented

---

## Phase 5: Expansion (Expert Complexity)

### 5.1 Capital Management
- [ ] **Evaluate performance for capital increase**
  - Review minimum 3 months of performance
  - Calculate risk-adjusted returns
  - Determine optimal capital allocation
  - Document capital management plan

- [ ] **Implement reinvestment strategy**
  - Define profit reinvestment rules
  - Set capital growth targets
  - Document reinvestment decisions
  - Track capital efficiency


### 5.2 Advanced Features
- [ ] **Implement custom analytics**
  - Develop advanced metrics
  - Create custom reporting
  - Set up visualization tools
  - Document analytics methodology

- [ ] **Explore alternative trading systems**
  - Research GoCryptoTrader
  - Compare features with Freqtrade
  - Test integration possibilities
  - Document findings and decisions

**✓ Success Criteria:** Successfully expanded system with advanced features and optimization
