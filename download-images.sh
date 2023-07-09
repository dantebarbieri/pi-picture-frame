#!/bin/bash
set -e

# Download images from SmugMug by album id
ALBUM_ID=$1
ALBUM_NAME=$2

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
mkdir -p "${SCRIPT_DIR}/images/${ALBUM_NAME}"
pushd "${SCRIPT_DIR}/images/${ALBUM_NAME}"

# Load environment variables
set -o allexport
source .env
source .config
set +o allexport

# Get API key and secret from environment variables
API_KEY=${SMUGMUG_API_KEY}
API_SECRET=${SMUGMUG_API_SECRET}

# Create a dictionary to store album names and album ids
declare -A album_ids_to_names

URL="https://api.smugmug.com/api/v2/album/${ALBUM_ID}!images?APIKey=${API_KEY}"

response=$(curl -s -H "Accept: application/json" -H "Authorization: Basic $(echo -n "${API_KEY}:${API_SECRET}" | base64 --wrap=0)" -X GET ${URL})

mapfile -t image_data < <(echo $response | jq -r '.Response.AlbumImage[] | "\(.FileName)=\(.ArchivedUri)"')

echo "Downloading ${#image_data[@]} images from album ${album_ids_to_names[$ALBUM_ID]}"

for i in "${image_data[@]}"
do
    local IMAGE_NAME="$(echo "${i%%=*}" | sed 's/[\/:*?"<>|]/-/g')"
    local IMAGE_URI="${i#*=}"
    echo "Downloading ${IMAGE_NAME} from ${IMAGE_URI}"
    curl -o "${IMAGE_NAME}" $IMAGE_URI
done

popd