#!/bin/bash
set -e

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
pushd "${SCRIPT_DIR}"

# Update all scripts, but **run.sh** & **update.sh** are ALWAYS the entrypoints
git reset origin/HEAD --hard
git pull origin main

popd
