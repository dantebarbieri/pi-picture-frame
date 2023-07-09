#!/bin/bash
set -e

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
pushd "${SCRIPT_DIR}"

# Load environment variables
set -o allexport
source .env
source .config
set +o allexport

# Get API key and secret from environment variables
API_KEY=${SMUGMUG_API_KEY}
API_SECRET=${SMUGMUG_API_SECRET}

USERNAME=Barbieri

# Create a dictionary to store album names and album ids
declare -A album_ids_to_names

# Construct URL
URL="https://api.smugmug.com/api/v2/user/${USERNAME}!albums?APIKey=${API_KEY}"

# Make request to SmugMug API
response="$(curl -s -H "Accept: application/json" -H "Authorization: Basic $(echo -n "${API_KEY}:${API_SECRET}" | base64 --wrap=0)" -X GET ${URL})"

# Parse the response to get the album names as a string, use "=" as separator
mapfile -t album_data < <(echo $response | jq -r '.Response.Album[] | "\(.AlbumKey)=\(.Name)"')

# Loop through the album data and store the album names and ids in the dictionary
for i in "${album_data[@]}"
do
    album_ids_to_names["${i%%=*}"]="${i#*=}"
done

get_album_names

for id in "${!album_ids_to_names[@]}"
do
    echo "Album ID: ${id}, Album Name: ${album_ids_to_names[$id]}"
    if [[ -z "${ALBUM_NAME}" ]] || [[ "${ALBUM_NAME}" == "${album_ids_to_names[$id]}" ]]; then
        exec download-images.sh "${id}" "${album_ids_to_names[$id]}"
    fi
done

popd