# Binance Setup

This guide walks you through setting up your Binance account for automated trading.

## Account Creation

### 1. Register Account
1. Visit [Binance.com](https://www.binance.com/en/register)
2. Sign up with email and create a strong password
3. Complete email verification
4. **Enable Two-Factor Authentication (2FA)**
   - Use Google Authenticator or Authy
   - Store backup codes securely

### 2. Identity Verification (KYC)
1. Navigate to "Identification" in account settings
2. Select your country of residence
3. Complete Basic Verification:
   - Provide personal information
   - Upload government ID (passport, national ID, driver's license)
   - Complete facial verification
4. Wait for approval (typically 1-24 hours)

## Funding Your Account

### For Kenya Users (M-Pesa)
1. Go to "Buy Crypto" → "P2P Trading"
2. Click "Payment Methods" → Add M-Pesa
3. Verify your M-Pesa number
4. **Make a test purchase:**
   - Select "Buy" → "USDT"
   - Filter by "M-Pesa" payment method
   - Choose reputable seller (high completion rate, good reviews)
   - Start with small amount ($20-50) to test process
   - Follow M-Pesa payment instructions
   - Confirm USDT receipt in Spot Wallet

### For Other Regions
- **Bank Transfer**: Direct deposit to Binance
- **Credit/Debit Card**: Instant purchase with fees
- **P2P Trading**: Local payment methods vary by region

## API Key Setup

⚠️ **Critical Security Settings** - Follow these exactly:

### 1. Create API Key
1. Go to "API Management" in account settings
2. Click "Create API"  
3. Set label: `FreqtradeBot` or similar

### 2. Configure Permissions
**Enable these permissions:**
- ✅ **Enable Reading** (required)
- ✅ **Enable Spot & Margin Trading** (required)

**DISABLE these permissions:**
- ❌ **Enable Withdrawals** (NEVER enable)
- ❌ **Enable Futures** (unless specifically needed)

### 3. IP Restrictions (Recommended)
- Set IP restriction to your server's IP address
- If using dynamic IP, leave unrestricted but monitor closely
- Consider VPS with static IP for production use

### 4. Save Credentials Securely
1. Copy API Key and Secret Key
2. Add to your `.env` file:
   ```bash
   BINANCE_API_KEY=your_api_key_here
   BINANCE_API_SECRET=your_secret_here
   ```
3. **Never commit `.env` to version control**
4. Store backup in secure password manager

## Security Best Practices

### API Key Security
- **Rotate keys every 90 days**
- **Monitor API usage** in Binance account
- **Disable immediately** if suspicious activity
- **Use separate keys** for different bots/purposes

### Account Security
- **Enable withdrawal whitelist** (if available)
- **Set up anti-phishing code**
- **Use strong, unique password**
- **Regular security reviews**

### Monitoring
- **Check account activity** regularly
- **Set up email alerts** for trades and logins
- **Monitor API call limits**

## Testing Your Setup

### 1. Verify API Connection
```bash
# Test API credentials (dry-run mode)
./docker-launch.sh

# Check logs for connection success
docker logs freqtrade-ReinforcedAverageStrategy | grep -i "successfully"
```

### 2. Test Market Data Access
```bash
# Should return market information
curl "https://api.binance.com/api/v3/exchangeInfo" | jq '.symbols[0]'
```

### 3. Verify Permissions
Your bot logs should show:
- ✅ "Exchange connector init"
- ✅ "Validating configuration"
- ❌ No permission errors

## Common Issues

### API Key Problems
```
ERROR - Unable to authenticate
```
**Solution**: Double-check API key and secret in `.env` file

### Permission Errors
```
ERROR - Insufficient permissions
```
**Solution**: Ensure "Enable Reading" and "Enable Spot & Margin Trading" are checked

### IP Restriction Issues
```
ERROR - IP address not allowed
```
**Solution**: Check IP restrictions in Binance API settings

### Rate Limiting
```
ERROR - Rate limit exceeded
```
**Solution**: The binance-proxy (setup automatically) handles this

## Live Trading Preparation

Before switching from dry-run to live trading:

1. **Test thoroughly in dry-run mode** (minimum 1 week)
2. **Start with small capital** ($100-200)
3. **Understand your chosen strategy** thoroughly
4. **Set up monitoring and alerts**
5. **Have emergency stop plan** ready

## Next Steps

With Binance configured:
- [Set up Telegram notifications](telegram.md) (optional)
- [Launch your first strategy](../usage/launching.md)
- [Learn about monitoring](../usage/monitoring.md)

## Emergency Procedures

If something goes wrong:
1. **Disable API key** in Binance immediately
2. **Stop all trading bots**: `docker stop $(docker ps -q --filter name=freqtrade)`
3. **Review account activity** in Binance
4. **Check bot logs** for errors: `docker logs container_name`