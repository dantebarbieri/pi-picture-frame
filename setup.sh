#!/bin/bash
set -e

echo "Getting the directory of the script..."
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
pushd "${SCRIPT_DIR}"

echo "Checking if feh is installed..."
# Check if feh is installed, install if not
if ! command -v feh &> /dev/null
then
    echo "feh not found. Installing..."
    apt update
    apt install feh -y
    echo "feh installed successfully."
fi

echo "Checking if jq is installed..."
# Check if jq is installed, install if not
if ! command -v jq &> /dev/null
then
    echo "jq not found. Installing..."
    apt update
    apt install jq -y
    echo "jq installed successfully."
fi

#!/bin/bash

echo "Checking if jhead is installed..."
# Check if jhead is installed, install if not
if ! command -v jhead &> /dev/null
then
    echo "jhead not found. Installing..."
    apt update
    apt install jhead -y
    echo "jhead installed successfully."
fi

echo "Checking if exiftool is installed..."
# Check if exiftool is installed, install if not
if ! command -v exiftool &> /dev/null
then
    echo "exiftool not found. Installing..."
    apt update
    apt install libimage-exiftool-perl -y
    echo "exiftool installed successfully."
fi

echo "Customizing slideshow service..."
sed -i "s|/path/to/your/slideshow_script.sh|$SCRIPT_DIR/display-images.sh|g" slideshow.service

echo "Creating symbolic link to slideshow service..."
ln -sf "${SCRIPT_DIR}/slideshow.service" /etc/systemd/system/slideshow.service

echo "Reloading systemd daemon..."
systemctl start slideshow
systemctl enable slideshow

popd

echo "Script execution completed."
