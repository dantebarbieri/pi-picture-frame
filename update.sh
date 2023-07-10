#!/bin/bash
set -e

echo "Getting the directory of the script..."
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
echo "The script directory is: ${SCRIPT_DIR}"
pushd "${SCRIPT_DIR}"

echo "Updating scripts..."
# Update all scripts, but **run.sh** & **update.sh** are ALWAYS the entrypoints
echo "Discarding local changes..."
git checkout -- .
echo "Resetting branch to origin/main..."
git fetch origin main
git reset --hard origin/main
echo "Scripts updated successfully."

popd

echo "Script execution completed."
