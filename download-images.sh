#!/bin/bash
set -e

echo "Starting the image download script..."
echo "Downloading images from SmugMug by album id..."

echo "Getting the directory of the script..."
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

pushd "${SCRIPT_DIR}"

echo "Getting album id..."
source get-album-names.sh

echo "Loading environment variables..."
set -o allexport
source .env || true
source .config
set +o allexport

ALBUM_DIR="${SCRIPT_DIR}/images/${ALBUM_NAME}"
echo "Creating album directory at: ${ALBUM_DIR}"
mkdir -p "${ALBUM_DIR}"
pushd "${ALBUM_DIR}"

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
declare -A present_images

for i in "${image_data[@]}"
do
    local IMAGE_NAME="$(echo "${i%%=*}" | sed 's/[\\/:*?"<>|]/-/g')"
    local IMAGE_URI="${i#*=}"
    present_images["${IMAGE_NAME}"]=1

    if [[ ! -f "${IMAGE_NAME}" ]]; then
        echo "Downloading ${IMAGE_NAME} from ${IMAGE_URI}..."
        curl -o "${IMAGE_NAME}" $IMAGE_URI
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
echo "Removing old symbolic links in: ${IMAGES_DIR}"
rm -f "${IMAGES_DIR}/*"

echo "Splitting ALLOWED_KEYWORDS into an array..."
allowed_keywords=($(IFS=":"; echo $ALLOWED_KEYWORDS))

echo "Creating symbolic links for images that match allowed keywords..."
for keyword in "${allowed_keywords[@]}"
do
    for img in $(exiftool -q -r -if '$Keywords =~ /'"$keyword"'/i' -p '$Directory/$FileName' "$ALBUM_DIR")
    do
        ln -s "$img" "$IMAGES_DIR"
    done
done

popd
popd

echo "Image download and clean-up completed."
