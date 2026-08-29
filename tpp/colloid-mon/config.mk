# Default parameters
# Note: do not add whitespace after parameter values

# Latency measurement backend
# Currently supported values
# 	icx-native: Intel Icelake (native)
# 	clx-native: Intel Cascadelake (native)
# 	hsw-native: Intel Haswell (native)
# 	spr-native: Intel Sapphire Rapids (native)
BACKEND ?= spr-native

# Default/alternate tier types
# Currently supported tier types
#	local-dram: DRAM locally attached to default tier socket
#	remote-dram: DRAM attached to remote socket
DEFAULT_TIER ?= local-dram
ALTERNATE_TIER ?= remote-dram

# NUMA node for default tier
DEFAULT_TIER_NUMA ?= 1

# Core on which to run latency measurement
# Should be a dedicated core on the default tier socket
CORE_MON ?= 63