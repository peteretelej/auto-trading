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
