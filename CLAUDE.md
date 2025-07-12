# Auto-Trading Project Context

## Key Commands
- `./docker-launch.sh [STRATEGY] [PORT_OFFSET]`: Launch trading bot
- `./scripts/setup-proxy.sh`: Start binance rate-limiting proxy
- `./scripts/monitor-bots.sh`: Check all bot status
- `docker logs freqtrade-STRATEGY`: View bot logs
- `docker stop $(docker ps -q --filter name=freqtrade)`: Stop all bots

## Core Files
- `docker-launch.sh`: Main launcher - processes config templates
- `config/*.json`: Strategy templates using `${ENV_VARIABLES}`
- `.env`: API keys and settings (**NEVER commit**)
- `user_data/strategies/`: Trading strategy code

## Project Behavior
- **IMPORTANT**: All bots start in dry-run mode by default
- Each strategy gets isolated data directory: `/DATA_DIR/StrategyName/`
- Port allocation: 8101 + PORT_OFFSET
- Binance proxy required on localhost:8100

## Available Strategies
- **NFI**: Advanced, strategy-managed exits (`stoploss: -0.99`)
- **ReinforcedQuickie**: 5m momentum trading
- **BbandRsi**: Mean reversion with Bollinger Bands + RSI
- **SMAOffset**: Simple trend following

## Security Rules
- **NEVER** suggest withdrawal permissions on API keys
- API keys: reading and spot trading only
- Use placeholder values in examples (`your-domain.com`, `your_api_key`)
- Don't include real credentials or personal domains

## Documentation Flow
- New users start: `docs/getting-started.md`
- Setup issues: `docs/setup/` guides
- Troubleshooting: `docs/reference/troubleshooting.md`
- Link to existing docs rather than recreating content

## Troubleshooting Priority
1. Check logs: `docker logs freqtrade-STRATEGY`
2. Verify proxy: `./scripts/monitor-proxy.sh`
3. Port conflicts: Use different PORT_OFFSET (don't kill processes)
4. No trades: Check dry-run status first