#!/bin/bash
set -e

echo "Getting the directory of the script..."
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
echo "The script directory is: ${SCRIPT_DIR}"
pushd "${SCRIPT_DIR}"

echo "Getting album names & downloading images..."
./download-images.sh
echo "Album names & images downloaded."

popd

echo "Script execution completed."

exec ./display-images.sh
