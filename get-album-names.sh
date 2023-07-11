#!/bin/bash
set -e

echo "Getting the directory of the script..."
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
echo "The script directory is: ${SCRIPT_DIR}"
pushd "${SCRIPT_DIR}"

echo "Loading environment variables..."
# Load environment variables
set -o allexport
source .env || true
source .config
set +o allexport

echo "Getting API key and secret from environment variables..."
# Get API key and secret from environment variables
API_KEY=${SMUGMUG_API_KEY}
API_SECRET=${SMUGMUG_API_SECRET}

USERNAME=Barbieri

# Create a dictionary to store album names and album ids
declare -A album_ids_to_names

echo "Constructing URL..."
# Construct URL
URL="https://api.smugmug.com/api/v2/user/${USERNAME}!albums?APIKey=${API_KEY}"

echo "Making request to SmugMug API..."
# Make request to SmugMug API
response="$(curl -s -H "Accept: application/json" -H "Authorization: Basic $(echo -n "${API_KEY}:${API_SECRET}" | base64 --wrap=0)" -X GET ${URL})"

echo "Parsing the response..."
# Parse the response to get the album names as a string, use "=" as separator
mapfile -t album_data < <(echo $response | jq -r '.Response.Album[] | "\(.AlbumKey)=\(.Name)"')

echo "Storing album names and ids in the dictionary..."
# Loop through the album data and store the album names and ids in the dictionary
for i in "${album_data[@]}"
do
    album_ids_to_names["${i%%=*}"]="${i#*=}"
done

echo "Getting album names..."
get_album_names

echo "Processing each album..."
for id in "${!album_ids_to_names[@]}"
do
    echo "Album ID: ${id}, Album Name: ${album_ids_to_names[$id]}"
    if [[ "${ALBUM_NAME}" == "${album_ids_to_names[$id]}" ]]; then
        $ALBUM_ID="${id}"
    fi
done

popd

echo "Script execution completed."
