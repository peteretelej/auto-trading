---
title: Caddy Reverse Proxy Setup
layout: default
parent: Setup Guides
nav_order: 4
description: "Set up Caddy reverse proxy for domain access"
permalink: /docs/setup/caddy-proxy/
---

# Caddy Reverse Proxy Setup

If you want to access your trading bots through a domain name instead of `localhost:8101`, you can set up Caddy as a reverse proxy.

## Basic Setup

### Single Bot Configuration
```caddy
# Caddyfile
your-trading-domain.com {
    reverse_proxy localhost:8101
}
```

### Multiple Bots Configuration
```caddy
# Caddyfile for multiple trading strategies
bot1.your-domain.com {
    reverse_proxy localhost:8101
}

bot2.your-domain.com {
    reverse_proxy localhost:8102  
}

bot3.your-domain.com {
    reverse_proxy localhost:8103
}
```

## Advanced Configuration

### With Authentication and Security
```caddy
trading.your-domain.com {
    # Enable HTTPS automatically
    tls your-email@example.com
    
    # Optional: IP whitelist for additional security
    @allowed {
        remote_ip 192.168.1.0/24 203.0.113.0/24
    }
    handle @allowed {
        reverse_proxy localhost:8101 {
            # Headers for proper WebSocket support
            header_up Host {host}
            header_up X-Real-IP {remote_host}
            header_up X-Forwarded-For {remote_host}
            header_up X-Forwarded-Proto {scheme}
        }
    }
    
    # Deny other IPs
    handle {
        respond "Access denied" 403
    }
}
```

### Subdirectory Setup
If you prefer subdirectories instead of subdomains:

```caddy
your-domain.com {
    # Main site content
    handle / {
        respond "Main site"
    }
    
    # Trading bot at /trading
    handle /trading/* {
        uri strip_prefix /trading
        reverse_proxy localhost:8101
    }
    
    # Additional bots
    handle /bot2/* {
        uri strip_prefix /bot2  
        reverse_proxy localhost:8102
    }
}
```

## Installation and Setup

### Install Caddy
```bash
# Ubuntu/Debian
sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
sudo apt update
sudo apt install caddy

# macOS
brew install caddy
```

### Configure and Start
```bash
# Create Caddyfile in your project directory
nano Caddyfile

# Test configuration
caddy validate

# Run Caddy (foreground)
caddy run

# Or run as service (background)
sudo systemctl enable --now caddy
```

## Security Considerations

### HTTPS/TLS
Caddy automatically handles HTTPS certificates via Let's Encrypt:
```caddy
trading.your-domain.com {
    # HTTPS is automatic - no additional config needed
    reverse_proxy localhost:8101
}
```

### Access Control
```caddy
trading.your-domain.com {
    # Method 1: IP-based restrictions
    @allowed remote_ip 192.168.1.100 203.0.113.50
    handle @allowed {
        reverse_proxy localhost:8101
    }
    respond "Unauthorized" 401
}
```

### Rate Limiting
```caddy
trading.your-domain.com {
    # Limit requests per IP
    rate_limit {
        zone static_ip_10pm {
            key {remote_host}
            events 10
            window 1m
        }
    }
    reverse_proxy localhost:8101
}
```

## Troubleshooting

### Common Issues

#### Domain Not Resolving
- Ensure DNS A record points to your server IP
- Check domain propagation: `dig your-domain.com`

#### HTTPS Certificate Issues
```bash
# Check certificate status
caddy list-certificates

# Force certificate renewal
sudo systemctl stop caddy
sudo caddy run --config Caddyfile
```

#### Bot Not Accessible
- Verify bot is running: `docker ps | grep freqtrade`
- Check port mapping: `docker port freqtrade-YourStrategy`
- Test direct access: `curl localhost:8101/api/v1/ping`

### Port Conflicts
If you change the default web ports in your bot configuration, update the Caddyfile accordingly:

```caddy
# If bot uses port 8150 instead of 8101
trading.your-domain.com {
    reverse_proxy localhost:8150
}
```

## Integration with Trading Setup

### Environment Variables
You can reference the proxy in your environment setup:

```bash
# .env file
WEB_DOMAIN=trading.your-domain.com
WEB_PORT=8101  # Still use localhost port for bot
```

### Docker Launch Integration
Your bots will still bind to localhost ports, but be accessible via your domain:

```bash
# Launch bot normally
./docker-launch.sh NFI

# Access via domain (configured in Caddy)
# https://trading.your-domain.com

# Or direct access (still works)
# http://localhost:8101
```

## Next Steps

- [Return to requirements setup](requirements.md) if setting up Caddy as part of initial configuration
- [Continue to Binance setup](binance.md) once your proxy is configured
- [Launch your first bot](../usage/launching.md) to test the proxy setup