# Colloid

Colloid is memory management mechanism for tiered memory architectures (e.g. CXL-attached memory or HBM) that integrates with existing systems. It balances hot data across memory tiers based on their loaded access latencies to minimize overload of individual tiers and maximize application performance.

This repository supplements our (upcoming) SOSP'23 paper and provides open-source implementations of colloid on top of different memory tiering systems, along with scripts and documentation to reproduce/extend the results from our paper.
