# Use the official freqtrade image as base
FROM freqtradeorg/freqtrade:stable

# Switch to root for installations
USER root

# Install additional dependencies
RUN apt-get update && \
    apt-get install -y \
    build-essential \
    python3-dev \
    && rm -rf /var/lib/apt/lists/*

# Install additional Python packages
RUN pip install --no-cache-dir \
    ta==0.10.2 \
    pandas-ta==0.3.14b \
    finta==1.3 \
    schedule==1.2.1

# Switch back to freqtrade user
USER ftuser

# Set up freqtrade directories
WORKDIR /freqtrade

# Copy strategy files
COPY --chown=ftuser:ftuser user_data/strategies /freqtrade/user_data/strategies/

# Copy config files
COPY --chown=ftuser:ftuser config/*.json /freqtrade/user_data/config/

# Set default config path
ENV CONFIG_PATH=/freqtrade/user_data/config

# Default command (will be overridden by docker-launch.sh)
CMD ["freqtrade", "trade", "--config", "user_data/config/config-template.json"]
