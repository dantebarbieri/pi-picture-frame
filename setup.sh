#!/bin/bash
set -e

echo "Checking if feh is installed..."
# Check if feh is installed, install if not
if ! command -v feh &> /dev/null
then
    echo "feh not found. Installing..."
    apt update
    apt install feh -y
    echo "feh installed successfully."
fi

echo "Checking if jq is installed..."
# Check if jq is installed, install if not
if ! command -v jq &> /dev/null
then
    echo "jq not found. Installing..."
    apt update
    apt install jq -y
    echo "jq installed successfully."
fi

echo "Script execution completed."
