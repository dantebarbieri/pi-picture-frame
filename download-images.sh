#!/bin/bash
set -e

echo "Starting the image download script..."
echo "Downloading images from SmugMug by album id..."

echo "Getting the directory of the script..."
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

pushd "${SCRIPT_DIR}"

# echo "Getting album id..."
# source get-album-names.sh

echo "Loading environment variables..."
set -o allexport
source .env || true
source .config
set +o allexport

NODE_DIR="${SCRIPT_DIR}/images/${NODE_NAME}"
echo "Creating album directory at: ${NODE_DIR}"
mkdir -p "${NODE_DIR}"
pushd "${NODE_DIR}"

echo "Getting API key and secret from environment variables..."
API_KEY=${SMUGMUG_API_KEY}
API_SECRET=${SMUGMUG_API_SECRET}

echo "Constructing URL..."
NODE_URL="https://api.smugmug.com/api/v2/node/${NODE_NAME}?APIKey=${API_KEY}"

echo -n "Making request to SmugMug API @ ${NODE_URL}..."
node_response=$(curl -s -H "Accept: application/json" -H "Authorization: Basic $(echo -n "${API_KEY}:${API_SECRET}" | base64 --wrap=0)" -X GET ${NODE_URL})
echo "$(echo -n "$node_response" | wc -c) bytes received."

ALBUM_URI=$(echo $node_response | jq -r '.Response.Node.Uris.Album.Uri')

ALBUM_URL="https://api.smugmug.com${ALBUM_URI}!images?APIKey=${API_KEY}"

echo -n "Making request to SmugMug API @ ${ALBUM_URL}..."
response=$(curl -s -H "Accept: application/json" -H "Authorization: Basic $(echo -n "${API_KEY}:${API_SECRET}" | base64 --wrap=0)" -X GET ${ALBUM_URL})
echo "$(echo -n "$response" | wc -c) bytes received."

echo "Parsing the response..."
mapfile -t image_data < <(echo $response | jq -r '.Response.AlbumImage[] | "\(.FileName)=\(.ImageKey)|\(.Format)"')

echo "Downloading new images and removing old images..."
declare -A present_images

for i in "${image_data[@]}"
do
    IMAGE_NAME="$(echo "${i%%=*}" | sed 's/[\\/:*?"<>|]/-/g')"
    tmp="${i#*=}"
    IMAGE_KEY="${tmp%%|*}"
    IMAGE_FORMAT="${tmp#*|}"
    IMAGE_URL="https://photos.smugmug.com/photos/i-${IMAGE_KEY}/0/O/i-${IMAGE_KEY}.${IMAGE_FORMAT,,}"

    present_images["${IMAGE_NAME}"]=1

    if [[ ! -f "${IMAGE_NAME}" ]]; then
        echo "Downloading ${IMAGE_NAME} from ${IMAGE_URL}..."
        curl -o "${IMAGE_NAME}" $IMAGE_URL
    fi

    jhead -ft "${IMAGE_NAME}"
done

for file in *
do
    if [[ -f "$file" ]] && [[ -z ${present_images["$file"]} ]]; then
        echo "Deleting old image: $file"
        rm "$file"
    fi
done

IMAGES_DIR="${SCRIPT_DIR}/images/feh"
mkdir -p "${IMAGES_DIR}"
echo "Removing old symbolic links in: ${IMAGES_DIR}"
rm -f ${IMAGES_DIR}/*

echo "Splitting ALLOWED_KEYWORDS into an array..."
IFS=":" read -ra allowed_keywords <<< "$ALLOWED_KEYWORDS"

echo "Creating symbolic links for images that match allowed keywords..."
for keyword in "${allowed_keywords[@]}"
do
    echo "Creating symbolic links for keyword: $keyword"
    for img in $(exiftool -q -r -if '$Keywords =~ /'"$keyword"'/i' -p '$Directory/$FileName' "$NODE_DIR")
    do
        echo "Creating symbolic link for image: $img"
        ln -s "$img" "$IMAGES_DIR/" 2>/dev/null || true
    done
done

echo "Image download and clean-up completed."

popd
popd
