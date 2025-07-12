# Monitoring and Analysis

This guide covers how to monitor your trading bots, analyze performance, and maintain the system effectively.

## Monitoring Overview

Effective monitoring involves:
- **Real-time tracking** of bot status and trades
- **Performance analysis** to understand profitability
- **System health** monitoring for technical issues
- **Risk assessment** to manage exposure

## Web Interface Monitoring

### Accessing the Interface
- **Single strategy**: http://localhost:8101
- **Multiple strategies**: http://localhost:810X (X = 1,2,3...)
- **Login**: Use credentials from `.env` file

### Key Dashboard Sections

#### Overview Dashboard
- **Current Performance**: Profit/loss, open trades
- **Bot Status**: Running, stopped, errors
- **Market Summary**: Active trading pairs
- **Recent Activity**: Latest trades and signals

#### Trades Tab
- **Open Positions**: Current active trades
- **Trade History**: Completed trades with P&L
- **Trade Details**: Entry/exit prices, duration
- **Filtering**: By date, profit/loss, trading pair

#### Performance Tab
- **Profit Charts**: Visual performance over time
- **Statistics**: Win rate, average profit, drawdown
- **Daily/Weekly/Monthly**: Performance breakdowns
- **Comparison**: Strategy performance comparisons

#### Logs Tab
- **Real-time logs**: Live bot activity
- **Error messages**: Issues requiring attention
- **Debug information**: Detailed operation data
- **Log filtering**: By severity and category

## Command Line Monitoring

### Quick Status Check
```bash
# Check all running bots
docker ps --filter name=freqtrade

# Monitor specific strategy
docker logs -f freqtrade-NFI

# System status overview
./scripts/monitor-bots.sh
```

### Detailed Bot Monitoring
```bash
# Strategy-specific logs
docker logs freqtrade-NFI | tail -100

# Error checking
docker logs freqtrade-NFI 2>&1 | grep -i error

# Trade activity
docker logs freqtrade-NFI | grep -E "(bought|sold|profit)"

# Real-time log following
docker logs -f freqtrade-NFI
```

### Proxy and System Health
```bash
# Check binance-proxy status
./scripts/monitor-proxy.sh

# System resource usage
docker stats

# Disk space monitoring
df -h
du -sh /your-data-directory/*
```

## Telegram Monitoring

### Available Commands
Send these to your Telegram bot:

#### Status Commands
- `/status` - Current open trades and performance
- `/profit` - Profit/loss summary
- `/daily` - Today's performance
- `/weekly` - Week's performance  
- `/monthly` - Month's performance

#### Information Commands
- `/balance` - Account balance information
- `/trades` - Recent trade history
- `/performance` - Detailed performance metrics
- `/help` - Available commands list

### Automated Notifications
Your bot automatically sends:
- **Trade alerts**: New positions opened/closed
- **Daily summaries**: End-of-day performance
- **Error notifications**: System issues
- **Milestone alerts**: Significant profit/loss events

## Performance Analysis

### Key Metrics to Track

#### Profitability Metrics
- **Total Profit/Loss**: Absolute returns in USDT
- **ROI Percentage**: Return on investment
- **Daily/Weekly Returns**: Performance trends
- **Profit Factor**: Gross profit ÷ gross loss

#### Risk Metrics
- **Maximum Drawdown**: Largest loss from peak
- **Current Drawdown**: Present decline from peak
- **Volatility**: Standard deviation of returns
- **Risk-Adjusted Returns**: Sharpe ratio

#### Trade Metrics
- **Win Rate**: Percentage of profitable trades
- **Average Win/Loss**: Mean profit vs mean loss
- **Trade Frequency**: Number of trades per day
- **Holding Time**: Average trade duration

### Performance Review Process

#### Daily Review (5 minutes)
1. **Check bot status** - All strategies running?
2. **Review overnight activity** - Any significant trades?
3. **Check error logs** - Any issues to address?
4. **Verify system health** - Proxy working, no resource issues?

#### Weekly Review (30 minutes)  
1. **Performance analysis** - Which strategies performed best?
2. **Market condition assessment** - How did market changes affect bots?
3. **Risk evaluation** - Drawdowns within acceptable limits?
4. **Strategy comparison** - Relative performance analysis

#### Monthly Review (2 hours)
1. **Comprehensive P&L analysis** - Detailed profit/loss breakdown
2. **Strategy effectiveness** - Which strategies to continue/stop?
3. **Risk management review** - Adjust position sizes or risk parameters?
4. **Market cycle analysis** - How strategies performed in different conditions

## System Maintenance

### Regular Maintenance Tasks

#### Daily
```bash
# Check system health
./scripts/monitor-bots.sh

# Verify proxy status
./scripts/monitor-proxy.sh

# Review error logs
docker logs freqtrade-YourStrategy 2>&1 | grep -i error
```

#### Weekly
```bash
# Update market data
docker exec freqtrade-YourStrategy freqtrade download-data

# Backup databases
./scripts/backup.sh

# Check disk space
df -h
```

#### Monthly
```bash
# Update strategies
./scripts/update-strategies.sh

# Rotate API keys (security best practice)
# Update .env file and restart bots

# Review and clean old logs
find /your-data-directory -name "*.log" -mtime +30 -delete
```

### Health Monitoring Scripts

#### Monitor All Bots
```bash
#!/bin/bash
# scripts/monitor-bots.sh

echo "=== Trading Bot Status ==="
date

for container in $(docker ps --filter name=freqtrade --format "{{.Names}}"); do
    strategy=$(echo $container | sed 's/freqtrade-//')
    status=$(docker inspect -f '{{.State.Status}}' $container)
    uptime=$(docker inspect -f '{{.State.StartedAt}}' $container)
    
    echo "Strategy: $strategy"
    echo "Status: $status" 
    echo "Started: $uptime"
    echo "---"
done

# Check proxy
if docker ps | grep -q binance-proxy; then
    echo "Binance Proxy: RUNNING ✅"
else
    echo "Binance Proxy: STOPPED ❌"
fi
```

#### Resource Monitoring
```bash
# Check resource usage
docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}"

# Monitor disk space
df -h | grep -E '(Filesystem|/dev/)'

# Check for memory issues
free -h
```

## Alert Setup

### System Alerts
Set up monitoring for critical issues:

#### Disk Space Alert
```bash
# Add to crontab for daily check
# 0 9 * * * /path/to/disk-check.sh

#!/bin/bash
THRESHOLD=90
USAGE=$(df -h | grep '/dev/' | awk '{print $5}' | sed 's/%//')
if [ $USAGE -gt $THRESHOLD ]; then
    echo "Disk usage is ${USAGE}% - Clean up required"
    # Send alert via Telegram or email
fi
```

#### Bot Health Alert
```bash
# Check if all bots are running
# */10 * * * * /path/to/health-check.sh

#!/bin/bash
for strategy in NFI ReinforcedQuickie BbandRsi; do
    if ! docker ps | grep -q "freqtrade-$strategy"; then
        echo "ALERT: $strategy bot is not running!"
        # Restart or send notification
    fi
done
```

## Troubleshooting Performance Issues

### Bot Not Trading
**Symptoms**: No new trades for extended period
**Checks**:
1. Market conditions - Is strategy suitable for current market?
2. Configuration - Are trading pairs still active?
3. Balance - Sufficient funds for new trades?
4. API limits - Any rate limiting issues?

### Poor Performance
**Symptoms**: Consistent losses or underperformance
**Analysis**:
1. Compare with dry-run results
2. Check market conditions vs backtesting period
3. Review strategy parameters
4. Consider market regime changes

### High Drawdown
**Symptoms**: Losses exceeding comfortable levels
**Actions**:
1. Reduce position sizes
2. Implement stricter stop-losses
3. Pause strategy during unfavorable conditions
4. Review risk management settings

### System Overload
**Symptoms**: Slow response, high CPU/memory usage
**Solutions**:
1. Reduce number of concurrent strategies
2. Increase monitoring intervals
3. Clean up old data and logs
4. Upgrade hardware if needed

## Best Practices

### Monitoring Discipline
1. **Set regular schedules** - Daily quick checks, weekly reviews
2. **Document findings** - Keep notes on performance and issues
3. **Stay objective** - Don't let emotions drive decisions
4. **Plan responses** - Know what to do for different scenarios

### Performance Optimization
1. **Focus on risk-adjusted returns** - Not just absolute profits
2. **Consider market conditions** - Strategies perform differently in various markets
3. **Regular strategy evaluation** - Pause underperforming strategies
4. **Continuous learning** - Understand why strategies succeed or fail

### Risk Management
1. **Set clear limits** - Maximum drawdown, position sizes
2. **Regular reviews** - Weekly risk assessment
3. **Emergency procedures** - Know how to quickly stop trading
4. **Diversification** - Don't rely on single strategy or market

## Next Steps

Master monitoring with:
- [Strategy configuration details](strategies.md) 
- [Troubleshooting common issues](../reference/troubleshooting.md)
- [Understanding project structure](../reference/project-structure.md)