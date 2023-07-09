#!/bin/bash
set -e

# Load environment variables
set -o allexport
source .env
set +o allexport

# Check if feh and jq are installed, install if not
if ! command -v feh &> /dev/null
then
    sudo apt update
    sudo apt install feh -y
fi

if ! command -v jq &> /dev/null
then
    sudo apt update
    sudo apt install jq -y
fi

# Get API key and secret from environment variables
API_KEY=${SMUGMUG_API_KEY}
API_SECRET=${SMUGMUG_API_SECRET}

USERNAME=Barbieri

# Create a dictionary to store album names and album ids
declare -A album_ids_to_names

# Define functions
get_album_names() {
    # Construct URL
    local URL="https://api.smugmug.com/api/v2/user/${USERNAME}!albums?APIKey=${API_KEY}"

    # Make request to SmugMug API
    local response="$(curl -s -H "Accept: application/json" -H "Authorization: Basic $(echo -n "${API_KEY}:${API_SECRET}" | base64 --wrap=0)" -X GET ${URL})"

    # Parse the response to get the album names as a string, use "|" as separator
    mapfile -t album_data < <(echo $response | jq -r '.Response.Album[] | "\(.AlbumKey)=\(.Name)"')

    # Loop through the album data and store the album names and ids in the dictionary
    for i in "${album_data[@]}"
    do
        album_ids_to_names["${i%%=*}"]="${i#*=}"
    done
}

# Download images from SmugMug by album id
download_images() {
    local BASE_URL="https://api.smugmug.com"
    local ALBUM_ID=$1

    local URL="https://api.smugmug.com/api/v2/album/${ALBUM_ID}!images?APIKey=${API_KEY}"

    local response=$(curl -s -H "Accept: application/json" -H "Authorization: Basic $(echo -n "${API_KEY}:${API_SECRET}" | base64 --wrap=0)" -X GET ${URL})

    mapfile -t image_data < <(echo $response | jq -r '.Response.AlbumImage[] | "\(.FileName)=\(.ArchivedUri)"')

    echo "Downloading ${#image_data[@]} images from album ${album_ids_to_names[$ALBUM_ID]}"

    for i in "${image_data[@]}"
    do
        local IMAGE_NAME="$(echo "${i%%=*}" | sed 's/[\/:*?"<>|]/-/g')"
        local IMAGE_URI="${i#*=}"
        echo "Downloading ${IMAGE_NAME} from ${IMAGE_URI}"
        curl -o "${IMAGE_NAME}" $IMAGE_URI
    done
}

get_album_names

for id in "${!album_ids_to_names[@]}"
do
    echo "Album ID: ${id}, Album Name: ${album_ids_to_names[$id]}"
    mkdir -p "${album_ids_to_names[$id]}"
    pushd "${album_ids_to_names[$id]}"
    download_images $id
    popd
done
