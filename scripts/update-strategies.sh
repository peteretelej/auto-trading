#!/bin/bash
set -e

STRATEGIES_DIR="./user_data/strategies"
mkdir -p "${STRATEGIES_DIR}"

echo "Updating trading strategies..."

# Download NFI strategy from GitHub
echo "Downloading NostalgiaForInfinityX.py from GitHub..."
if wget -q -O "${STRATEGIES_DIR}/NostalgiaForInfinityX.py" https://raw.githubusercontent.com/iterativv/NostalgiaForInfinity/main/NostalgiaForInfinityX.py; then
    echo "✅ Successfully downloaded NostalgiaForInfinityX.py"
else
    echo "❌ Failed to download NostalgiaForInfinityX.py"
    exit 1
fi

# Create proper NFI class as a subclass - using lowercase class name
echo "Creating NFI.py class..."
cat > "${STRATEGIES_DIR}/NFI.py" << EOF
# NFI strategy class
# This file creates a subclass of NostalgiaForInfinityX

from NostalgiaForInfinityX import NostalgiaForInfinityX

class NFI(NostalgiaForInfinityX):
    """
    NFI strategy - this is a subclass of NostalgiaForInfinityX
    """
    # You can override parameters here if needed
    # For example:
    # minimal_roi = {"0": 0.1}

# Also create lowercase alias for Freqtrade compatibility
class nfi(NostalgiaForInfinityX):
    """
    nfi strategy - this is a subclass of NostalgiaForInfinityX (lowercase version)
    """
    pass
EOF
echo "✅ Successfully created NFI.py class"

# Download SMAOffset.py
echo "Downloading SMAOffset.py from GitHub..."
if wget -q -O "${STRATEGIES_DIR}/SMAOffset.py" https://raw.githubusercontent.com/thierryjmartin/freqtrade-stuff/main/SMAOffset.py; then
    echo "✅ Successfully downloaded SMAOffset.py"
else
    echo "❌ Failed to download SMAOffset.py"
    exit 1
fi

# Download BbandRsi.py
echo "Downloading BbandRsi.py from GitHub..."
if wget -q -O "${STRATEGIES_DIR}/BbandRsi.py" https://raw.githubusercontent.com/PeetCrypto/freqtrade-stuff/main/BbandRsi.py; then
    echo "✅ Successfully downloaded BbandRsi.py"
else
    echo "❌ Failed to download BbandRsi.py"
    exit 1
fi

# Download ElliotV5_SMA
echo "Downloading ElliotV5_SMA.py from GitHub..."
if wget -q -O "${STRATEGIES_DIR}/ElliotV5_SMA.py" https://raw.githubusercontent.com/5drei1/freqtrade_pub_strats/main/ElliotV5.py; then
    echo "✅ Successfully downloaded ElliotV5_SMA.py"
else
    echo "❌ Failed to download ElliotV5_SMA.py"
    exit 1
fi

# Download MultiMA_TSL
echo "Downloading MultiMA_TSL.py from GitHub..."
if wget -q -O "${STRATEGIES_DIR}/MultiMA_TSL.py" https://raw.githubusercontent.com/stash86/MultiMA_TSL/main/user_data/strategies/MultiMA_TSL.py; then
    echo "✅ Successfully downloaded MultiMA_TSL.py"
else
    echo "❌ Failed to download MultiMA_TSL.py"
    exit 1
fi

# Download BB_RPB_TSL_RNG
echo "Downloading BB_RPB_TSL_RNG.py from GitHub..."
if wget -q -O "${STRATEGIES_DIR}/BB_RPB_TSL_RNG.py" https://raw.githubusercontent.com/jilv220/freqtrade-stuff/main/BB_RPB_TSL_RNG.py; then
    echo "✅ Successfully downloaded BB_RPB_TSL_RNG.py"
else
    echo "❌ Failed to download BB_RPB_TSL_RNG.py"
    exit 1
fi

# Download BinHV45
echo "Downloading BinHV45.py from GitHub..."
if wget -q -O "${STRATEGIES_DIR}/BinHV45.py" https://raw.githubusercontent.com/freqtrade/freqtrade-strategies/main/user_data/strategies/berlinguyinca/BinHV45.py; then
    echo "✅ Successfully downloaded BinHV45.py"
else
    echo "❌ Failed to download BinHV45.py"
    exit 1
fi

echo "Strategy update completed." 