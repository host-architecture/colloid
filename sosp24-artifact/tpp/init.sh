#!/bin/bash

# Script to initialize TPP (+ colloid) for experiments

tierinit_path="${BASH_SOURCE%/*}/../../tpp/tierinit"

# Initialize tiers
insmod $tierinit_path/tierinit.ko

if lsmod | grep -q "$tierinit"; then
    echo "Successful"
else
    echo "Error: Module tierinit is not loaded."
fi