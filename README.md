# Colloid

Colloid is memory management mechanism for tiered memory architectures (e.g. CXL-attached memory or HBM) that integrates with existing systems. It balances hot data across memory tiers based on their loaded access latencies to minimize overload of individual tiers and maximize application performance.

This repository supplements our (upcoming) SOSP'23 paper and provides open-source implementations of colloid on top of different memory tiering systems, along with scripts and documentation to reproduce/extend the results from our paper.

## Overview
Implementation of colloid on top of different existing memory tiering systems are provided in the following sub-repositories/sub-directories. Please see the corresponding READMEs in each of these directories for detailed documentation on how to setup and run the corresponding systems with/without colloid:

* [`hemem/`](https://github.com/webglider/hemem/tree/939dc0072126d3a2639917d3eef00634dbac2e26) Our fork of [HeMem](https://dl.acm.org/doi/10.1145/3477132.3483550) with colloid integration.
* [`tpp/`](tpp) Our fork of Linux 6.3, which contains up-streamed version of [TPP](https://dl.acm.org/doi/10.1145/3582016.3582063), with colloid integration.

Additionally, ['apps/'](apps) provides source code for benchmark applications, [`scripts/`] provides helper scripts to run experiments, and [`workloads/`] provides configuration files for some of the workloads evaluated in the paper. 
