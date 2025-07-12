---
title: Troubleshooting Guide
layout: default
parent: Reference
nav_order: 1
description: "Diagnose and resolve common issues"
---

# Troubleshooting Guide

This guide helps you diagnose and resolve common issues with the auto-trading system.

## Quick Diagnostics

### System Health Check
```bash
# 1. Check Docker status
docker --version
docker ps

# 2. Check bot status
./scripts/monitor-bots.sh

# 3. Check proxy status  
./scripts/monitor-proxy.sh

# 4. Check recent logs
docker logs freqtrade-YourStrategy --tail 50
```

### Common Warning Signs
- **No trades for extended periods** - Strategy may not match market conditions
- **High CPU/memory usage** - Resource constraints or configuration issues
- **Frequent API errors** - Rate limiting or authentication problems
- **Container restart loops** - Configuration or dependency problems

## Installation and Setup Issues

### Docker Problems

#### Docker Not Installed
```
bash: docker: command not found
```
**Solution**: Install Docker following [requirements guide](../setup/requirements.md)

#### Permission Denied
```
ERROR: Got permission denied while trying to connect to Docker daemon
```
**Solutions**:
```bash
# Add user to docker group
sudo usermod -aG docker $USER

# Logout and login again, or run:
newgrp docker

# Test access
docker run hello-world
```

#### Docker Service Not Running
```
Cannot connect to the Docker daemon
```
**Solutions**:
```bash
# Ubuntu/Debian
sudo systemctl start docker
sudo systemctl enable docker

# macOS/Windows
# Start Docker Desktop application
```

### Script Permission Issues

#### Script Not Executable
```
bash: ./docker-launch.sh: Permission denied
```
**Solution**:
```bash
chmod +x docker-launch.sh
chmod +x scripts/*.sh
```

#### Script Not Found
```
bash: ./docker-launch.sh: No such file or directory
```
**Solution**:
```bash
# Ensure you're in the project directory
cd auto-trading
ls -la docker-launch.sh

# If missing, check git clone was successful
git status
```

## Configuration Issues

### Environment Variable Problems

#### Missing .env File
```
ERROR: Environment variable BINANCE_API_KEY not set
```
**Solution**:
```bash
# Create from template
cp .env.sample .env

# Edit with your values
nano .env
```

#### Invalid API Keys
```
ERROR: Unable to authenticate with exchange
```
**Solutions**:
1. **Verify API keys** in Binance account settings
2. **Check permissions**: Ensure "Reading" and "Spot Trading" enabled
3. **Test keys**:
```bash
# Basic API test
curl "https://api.binance.com/api/v3/account" \
  -H "X-MBX-APIKEY: your_api_key"
```

#### Telegram Configuration Issues
```
ERROR: Telegram token invalid
```
**Solutions**:
1. **Verify bot token** from @BotFather
2. **Check chat ID** using @userinfobot
3. **Test token**:
```bash
curl "https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/getMe"
```

### JSON Configuration Errors

#### Invalid JSON Syntax
```
ERROR: Expecting ',' delimiter
```
**Solution**:
```bash
# Validate JSON syntax
cat config/your-config.json | jq .

# Common fixes:
# - Add missing commas between elements
# - Remove trailing commas before closing braces
# - Ensure proper quote matching
```

#### Configuration Validation Errors
```
ERROR: 'max_open_trades' must be integer
```
**Solution**: Check parameter types in [configuration reference](configuration.md)

## Container and Launch Issues

### Port Already in Use

#### Web Interface Port Conflict
```
ERROR: Port 8101 already in use
```
**Solutions**:
```bash
# Find process using port
sudo lsof -i :8101

# Kill process if safe
sudo kill -9 PID

# Or use different port offset
./docker-launch.sh YourStrategy 1  # Uses port 8102
```

#### Multiple Port Conflicts
```bash
# Check all used ports
docker ps --format "table {{.Names}}\t{{.Ports}}"

# Stop all freqtrade containers
docker stop $(docker ps -q --filter name=freqtrade)
```

### Container Startup Problems

#### Container Exits Immediately
```
CONTAINER STATUS: Exited (1)
```
**Diagnosis**:
```bash
# Check container logs
docker logs freqtrade-YourStrategy

# Look for specific error messages
docker logs freqtrade-YourStrategy 2>&1 | grep -i error
```

**Common causes**:
- **Invalid configuration**: Check JSON syntax
- **Missing dependencies**: Rebuild Docker image
- **API authentication failure**: Verify credentials
- **Strategy not found**: Check strategy name spelling

#### Container Won't Start
**Solutions**:
```bash
# Remove existing container
docker rm freqtrade-YourStrategy

# Clean up orphaned containers
docker container prune

# Restart with fresh container
./docker-launch.sh YourStrategy
```

### Strategy Loading Issues

#### Strategy Not Found
```
ERROR: Impossible to load strategy 'YourStrategy'
```
**Solutions**:
```bash
# List available strategies
ls user_data/strategies/

# Update strategies
./scripts/update-strategies.sh

# Check strategy name in logs
docker logs freqtrade-YourStrategy | grep -i strategy
```

#### Strategy Import Errors
```
ERROR: Could not import strategy
```
**Solutions**:
1. **Check Python syntax** in strategy file
2. **Verify dependencies** are installed in Docker image
3. **Update base image**:
```bash
docker pull freqtradeorg/freqtrade:latest
```

## Trading and API Issues

### No Trades Being Executed

#### Bot Running But No Trades
**Diagnosis checklist**:
```bash
# 1. Check if strategy generates signals
docker logs freqtrade-YourStrategy | grep -i "enter\|exit\|signal"

# 2. Verify sufficient balance
# Check web interface balance tab

# 3. Confirm trading pairs are active
# Check exchange for pair availability

# 4. Review market conditions
# Strategy may not match current market state
```

**Common causes**:
- **Dry-run mode enabled**: Normal behavior, no real trades
- **Insufficient balance**: Not enough funds for minimum trade
- **No trading signals**: Market conditions don't match strategy criteria
- **API permissions**: Trading not enabled on API key

#### Orders Not Executing
```
ERROR: Insufficient balance for trade
```
**Solutions**:
1. **Check actual balance** vs configured stake amount
2. **Verify trading pair** minimum order requirements
3. **Adjust stake amount** in configuration
4. **Check for open orders** consuming balance

### API Rate Limiting

#### Rate Limit Exceeded
```
ERROR: Rate limit exceeded, retrying
```
**Solutions**:
```bash
# 1. Ensure proxy is running
./scripts/setup-proxy.sh

# 2. Check proxy status
./scripts/monitor-proxy.sh

# 3. Verify proxy configuration in templates
grep -r "binance-proxy" config/
```

#### API Connection Issues
```
ERROR: Connection timeout
```
**Solutions**:
1. **Check internet connection**
2. **Verify Binance API status**: https://status.binance.com
3. **Test direct API access**:
```bash
curl "https://api.binance.com/api/v3/ping"
```

## Performance Issues

### High Resource Usage

#### High Memory Usage
```bash
# Check memory usage
docker stats --no-stream

# If memory usage > 1GB per container:
# 1. Reduce number of concurrent strategies
# 2. Increase system RAM
# 3. Optimize configuration parameters
```

#### High CPU Usage
**Causes and solutions**:
- **Too frequent processing**: Increase `process_throttle_secs`
- **Complex strategies**: Consider simpler strategies or better hardware
- **Multiple strategies**: Stagger processing intervals

#### Disk Space Issues
```bash
# Check disk usage
df -h
du -sh /your-data-directory/*

# Clean up logs
find /your-data-directory -name "*.log" -mtime +7 -delete

# Compress old databases
./scripts/backup.sh
```

### Slow Performance

#### Web Interface Loading Slowly
**Solutions**:
1. **Restart container**:
```bash
docker restart freqtrade-YourStrategy
```

2. **Check resource usage**:
```bash
docker stats freqtrade-YourStrategy
```

3. **Reduce data retention**:
```json
{
  "internals": {
    "sd_notify": false,
    "heartbeat_interval": 60
  }
}
```

## Database Issues

### Database Corruption
```
ERROR: Database disk image is malformed
```
**Solutions**:
```bash
# 1. Stop the affected bot
docker stop freqtrade-YourStrategy

# 2. Backup current database
cp /data-dir/YourStrategy/user_data/tradesv3-YourStrategy.sqlite \
   /backup/tradesv3-YourStrategy-backup.sqlite

# 3. Attempt repair
sqlite3 /data-dir/YourStrategy/user_data/tradesv3-YourStrategy.sqlite \
  ".recover" | sqlite3 /data-dir/YourStrategy/user_data/tradesv3-YourStrategy-recovered.sqlite

# 4. Replace database and restart
mv /data-dir/YourStrategy/user_data/tradesv3-YourStrategy-recovered.sqlite \
   /data-dir/YourStrategy/user_data/tradesv3-YourStrategy.sqlite
./docker-launch.sh YourStrategy
```

### Database Locking Issues
```
ERROR: Database is locked
```
**Solutions**:
```bash
# 1. Stop all bots accessing the database
docker stop freqtrade-YourStrategy

# 2. Check for orphaned processes
ps aux | grep freqtrade

# 3. Remove lock file if exists
rm -f /data-dir/YourStrategy/user_data/tradesv3-YourStrategy.sqlite-wal
rm -f /data-dir/YourStrategy/user_data/tradesv3-YourStrategy.sqlite-shm

# 4. Restart bot
./docker-launch.sh YourStrategy
```

## Network and Connectivity Issues

### Proxy Issues

#### Binance Proxy Not Responding
```bash
# Check if proxy container is running
docker ps | grep binance-proxy

# If not running, restart
./scripts/setup-proxy.sh

# Test proxy connectivity
curl http://localhost:8100/api/v3/ping
```

#### Proxy Performance Issues
```bash
# Check proxy logs
docker logs binance-proxy

# Monitor proxy metrics
curl http://localhost:8100/metrics

# Restart proxy if needed
docker restart binance-proxy
```

### DNS and Network Issues

#### DNS Resolution Problems
```
ERROR: Name resolution failed
```
**Solutions**:
```bash
# Test DNS resolution
nslookup api.binance.com

# Check Docker DNS
docker run --rm alpine nslookup api.binance.com

# Restart Docker if needed
sudo systemctl restart docker
```

## Monitoring and Alerting Issues

### Telegram Not Working

#### Bot Not Responding
**Diagnosis**:
```bash
# Test bot token
curl "https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/getMe"

# Check bot logs for Telegram errors
docker logs freqtrade-YourStrategy | grep -i telegram
```

#### Missing Notifications
**Common causes**:
- **Notification settings**: Check configuration
- **Chat muted**: Verify Telegram chat settings
- **Bot stopped**: Ensure trading bot is running

### Web Interface Issues

#### Cannot Access Web Interface
```
Connection refused to localhost:8101
```
**Solutions**:
```bash
# 1. Check if container is running
docker ps | grep freqtrade

# 2. Verify port mapping
docker port freqtrade-YourStrategy

# 3. Test local connection
curl http://localhost:8101/api/v1/ping

# 4. Check firewall settings
sudo ufw status
```

#### Login Issues
**Solutions**:
1. **Verify credentials** in .env file
2. **Clear browser cache** and cookies
3. **Try incognito/private browsing**
4. **Check web interface logs** in container

## Emergency Procedures

### Stop All Trading Immediately
```bash
# Stop all freqtrade containers
docker stop $(docker ps -q --filter name=freqtrade)

# Verify all stopped
docker ps --filter name=freqtrade

# Cancel open orders (if needed)
# Access Binance web interface to manually close positions
```

### System Recovery
```bash
# 1. Backup current state
./scripts/backup.sh

# 2. Stop all containers
docker stop $(docker ps -q)

# 3. Clean up Docker system
docker system prune -f

# 4. Restart services
./scripts/setup-proxy.sh
./docker-launch.sh YourStrategy

# 5. Verify recovery
./scripts/monitor-bots.sh
```

## Getting Additional Help

### Log Analysis
```bash
# Comprehensive log review
docker logs freqtrade-YourStrategy > bot.log 2>&1

# Search for specific errors
grep -i "error\|exception\|failed" bot.log

# Check for patterns
grep -E "bought|sold|profit|loss" bot.log | tail -20
```

### Debug Information Collection
When reporting issues, include:
1. **System information**: OS, Docker version
2. **Configuration**: Sanitized config files (remove API keys)
3. **Logs**: Recent container logs
4. **Error messages**: Exact error text
5. **Steps to reproduce**: What led to the issue

### Resources
- **FreqTrade Documentation**: https://www.freqtrade.io/en/stable/
- **FreqTrade Discord**: Community support and discussions
- **Binance API Documentation**: For API-related issues
- **Docker Documentation**: For container and system issues

## Prevention Best Practices

### Regular Maintenance
```bash
# Weekly checks
./scripts/monitor-bots.sh
./scripts/backup.sh
docker system df  # Check disk usage

# Monthly tasks
./scripts/update-strategies.sh
# Review and rotate API keys
# Analyze performance and adjust configurations
```

### Monitoring Setup
```bash
# Set up automated health checks
# Add to crontab:
# */10 * * * * /path/to/scripts/health-check.sh

# Set up log rotation
# Configure logrotate for Docker logs

# Monitor disk space
# Set up alerts for disk usage > 80%
```

### Security Practices
1. **Regular API key rotation** (every 90 days)
2. **Monitor account activity** in Binance
3. **Keep system updated** (Docker, strategies)
4. **Secure backup storage** with encryption
5. **Access control** for configuration files

## Next Steps

After resolving issues:
- [Review monitoring practices](../usage/monitoring.md)
- [Optimize configuration](configuration.md)
- [Understand project structure](project-structure.md) for better troubleshooting