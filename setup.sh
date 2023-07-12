#!/bin/bash
set -e

echo "Getting the directory of the script..."
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
pushd "${SCRIPT_DIR}"

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

echo "Checking if jhead is installed..."
# Check if jhead is installed, install if not
if ! command -v jhead &> /dev/null
then
    echo "jhead not found. Installing..."
    apt update
    apt install jhead -y
    echo "jhead installed successfully."
fi

echo "Checking if exiftool is installed..."
# Check if exiftool is installed, install if not
if ! command -v exiftool &> /dev/null
then
    echo "exiftool not found. Installing..."
    apt update
    apt install libimage-exiftool-perl -y
    echo "exiftool installed successfully."
fi

popd

echo "Script execution completed."
