#!/bin/bash
set -e

echo "Downloading images from SmugMug by album id..."
ALBUM_ID=$1
ALBUM_NAME=$2

echo "Getting the directory of the script..."
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
ALBUM_DIR="${SCRIPT_DIR}/images/${ALBUM_NAME}"
mkdir -p "${ALBUM_DIR}"
pushd "${ALBUM_DIR}"

echo "Loading environment variables..."
set -o allexport
source .env
source .config
set +o allexport

echo "Getting API key and secret from environment variables..."
API_KEY=${SMUGMUG_API_KEY}
API_SECRET=${SMUGMUG_API_SECRET}

echo "Constructing URL..."
URL="https://api.smugmug.com/api/v2/album/${ALBUM_ID}!images?APIKey=${API_KEY}"

echo "Making request to SmugMug API..."
response=$(curl -s -H "Accept: application/json" -H "Authorization: Basic $(echo -n "${API_KEY}:${API_SECRET}" | base64 --wrap=0)" -X GET ${URL})

echo "Parsing the response..."
mapfile -t image_data < <(echo $response | jq -r '.Response.AlbumImage[] | "\(.FileName)=\(.ArchivedUri)"')

echo "Downloading new images and removing old images..."
# Create an associative array to keep track of the images present in the album
declare -A present_images

for i in "${image_data[@]}"
do
    local IMAGE_NAME="$(echo "${i%%=*}" | sed 's/[\/:*?"<>|]/-/g')"
    local IMAGE_URI="${i#*=}"
    present_images["${IMAGE_NAME}"]=1

    # Only download images that are not already present in the directory
    if [[ ! -f "${IMAGE_NAME}" ]]; then
        echo "Downloading ${IMAGE_NAME} from ${IMAGE_URI}..."
        curl -o "${IMAGE_NAME}" $IMAGE_URI
    fi
done

# Loop through all the images in the directory and delete any that are not present in the album
for file in *
do
    if [[ -f "$file" ]] && [[ -z ${present_images["$file"]} ]]; then
        echo "Deleting old image: $file"
        rm "$file"
    fi
done

popd

echo "Image download and clean-up completed."
