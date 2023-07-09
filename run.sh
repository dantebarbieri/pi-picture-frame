#!/bin/bash
set -e

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
pushd "${SCRIPT_DIR}"

echo "Setting up environment..."
exec sudo setup.sh
echo "Environment setup complete."

echo "Getting album names & downloading images..."
exec get-album-names.sh
echo "Album names & images downloaded."

popd