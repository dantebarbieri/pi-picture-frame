# pi-picture-frame

## Installation

### Prerequisites

Ensure that `git` is installed and that `bash` is at least version 4.

Then, set environment variables for the SMUGMUG_API_KEY and the SMUGMUG_API_SECRET. This can be done by adding them to your `bashrc` (~/.bashrc):
```sh
SMUGMUG_API_KEY=
SMUGMUG_API_SECRET=
```

### Install Script

[install](./install.sh)
```sh
git clone https://github.com/dantebarbieri/pi-picture-frame \
&& cd pi-picture-frame \
&& ./install.sh
```

### Uninstall Script

[uninstall](./uninstall.sh)
```sh
./uninstall.sh
```

Undoes the work of install and setup. Does not uninstall prerequisite packages, but unregisters all cron jobs for this app and removes the systemd service. See [Architecture](#architecture) for more information.

## Usage

Program should run automatically via systemd. The install script installs all dependencies and creates the systemd service as well as registers cron jobs for image fetch and update.

## Configuration

You can alter some basic config in the [`.config`](./.config) file. The config is set via environment variables.
- `ALBUM_NAME` *(optional)* - The album name to use for the slide show. Required if ALBUM_ID is not manually set.
- `ALBUM_ID` *(optional)* - The album id (if known) to use for the slide show. This is overwritten if an ALBUM_NAME is specified and matches a valid name on SmugMug.
- `ALLOWED_KEYWORDS` - A colon-separated list of keywords which are allowed on the images. At least one keyword must match for the image to be displayed.
- `SLIDE_DELAY` - The number of seconds to display each image.

## Architecture
The images are displayed via the [`display-images`](./display-images.sh) script which is executed automatically by [`slideshow.service`](./slideshow.service) which is a systemd service that automatically runs on startup and restarts if it ever crashes.

The images are updated via a cron job which executes [download-images](./download-images.sh) via [run](./run.sh). This also uses [get-album-names](./get-album-names.sh) to get the album names and ids. The images are downloaded by their album id. This requires the correct API information to be defined in the environment. It can be overridden by putting it into [.config](./.config), but **this is strongly discouraged as it will make both API key & secret public!**.

All of the files are updated every day via a separate cron job which executes [update](./update.sh). This uses `git` to reset the local files to whatever is in remote. Therefore, local changes aren't persisted. But the directory isn't cleaned so untracked files may not be destroyed during the update.
