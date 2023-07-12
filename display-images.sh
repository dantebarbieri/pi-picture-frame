#!/bin/bash
set -e

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
recoverable=true
while [ $recoverable ]
do
    feh -r -n -S mtime -D $SLIDE_DELAY --auto-rotate -Z -F -Y --on-last-slide quit "$IMAGES_DIR"
done

popd
popd
