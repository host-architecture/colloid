# Colloid

Colloid is memory management mechanism for tiered memory architectures (e.g. CXL-attached memory or HBM) that integrates with existing systems. It balances hot data across memory tiers based on their loaded access latencies to minimize overload of individual tiers and maximize application performance.

This repository supplements our (upcoming) SOSP'23 paper and provides open-source implementations of colloid on top of different memory tiering systems, along with scripts and documentation to reproduce/extend the results from our paper.

## Artifact Evaluation
For SOSP'24 artifact evaluation, please directly navigate to [`sosp24-artifact/`](sosp24-artifact) for detailed instructions.

## Overview
Implementation of colloid on top of different existing memory tiering systems are provided in the following sub-repositories/sub-directories. Please see the corresponding READMEs in each of these directories for detailed documentation on how to setup and run the corresponding systems with/without colloid:

* `hemem/` Our fork of [HeMem](https://dl.acm.org/doi/10.1145/3477132.3483550) with colloid integration.
* `tpp/` Our fork of Linux 6.3, which contains up-streamed version of [TPP](https://dl.acm.org/doi/10.1145/3582016.3582063), with colloid integration.

Additionally, [`apps/`](apps) provides source code for benchmark applications, [`scripts/`](scripts) provides helper scripts to run experiments, and [`workloads/`](workloads) provides configuration files for some of the workloads evaluated in the paper. 

## Current limitations, and planned extensions
We have tested colloid using a multi-socket server to emulate tiered memory hardware (since we currently do not have access to real CXL/HBM hardware). Our current implementations of colloid assume the Intel Ice Lake architecture (3rd Generation Intel Xeon Scalable processor) for hardware counters to measure loaded latency. Similar counters are available on other generations of Intel processors (Cascade Lake, Sapphire Rapids) and recent AMD processors for different memory tiers (CXL, HBM). Porting colloid to these architectures should be relatively straightforward (documentation coming soon). Please do reach out if you are interested in testing colloid on other architectures/memory tiers. We would love to explore this.

## Contact
Midhul Vuppalapati ([midhul@cs.cornell.edu](mailto:midhul@cs.cornell.edu))
