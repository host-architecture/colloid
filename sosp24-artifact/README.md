# Colloid Artifact

This directory contains scripts and instructions for running the experiments from our SOSP'24 paper.

## Server Access: A Note for Artifact Evaluators

For artifact evaluation, we will provide evaluators (secure and anonymous) access to a server with specifications matching the evaluation setup used in the paper. To reduce evaluator burden, all the necessary systems and tools will be pre-compiled and configured on the server so that evaluators can directly start running experiments.

**We request the evaluators to reserve time-slots through this [todo], and we will make sure the server is available and accessible during each time-slot. We request evaluators to mark themselves as Reviewer A/B/C, etc., to preserve anonymity. Estimated times for both Testing Functionality and Reproducing Results are provided below. Also please avoid selecting timeslots that have already been reserved (marked in green on the calendar).**

Access to the server will be facilitated through a secure VPN. We will share VPN details and ssh credentials through HotCRP once the evaluation period starts.

## Directory structure 
* [`docs`](docs) Documentation for general environment setup used by all experiments.
* [`func`](func) Testing functionality of artifacts. 
* [`hemem`](hemem) HeMem (+ colloid) experiments.
* [`tppthp`](tppthp) TPP w/ THP (+ colloid) experiments.
* [`tpp`](tpp) TPP (+ colloid) experiments.

## Testing functionality

We provide a quick start guide to run a simple experiment on HeMem+colloid and TPP+colloid to test that they are functional. Detailed instructions are provided [here](func). (Similar flow will be used later for reproducing the paper results. We recommend that reviewers try this out to gain familiarity with the setup).

## Reproducing results
