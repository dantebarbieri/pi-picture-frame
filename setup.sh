#!/bin/bash
set -e

# Check if feh and jq are installed, install if not
if ! command -v feh &> /dev/null
then
    apt update
    apt install feh -y
fi

if ! command -v jq &> /dev/null
then
    apt update
    apt install jq -y
fi
