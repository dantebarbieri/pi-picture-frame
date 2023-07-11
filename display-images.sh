#!/bin/bash

echo "Getting the directory of the script..."
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

pushd "${SCRIPT_DIR}"

echo "Loading environment variables..."
set -o allexport
source .env || true
source .config
set +o allexport

IMAGES_DIR="${SCRIPT_DIR}/images/feh"
mkdir -p "${IMAGES_DIR}"
pushd "${IMAGES_DIR}"

echo "Starting the slideshow..."
while true
do
    feh -r -S mtime -D $SLIDE_DELAY -F -Z -z -Y --cycle-once "$IMAGES_DIR"
done

popd
popd
