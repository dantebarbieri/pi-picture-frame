# pi-picture-frame

## Installation

### Prerequisites

Ensure that `git` is installed and that `bash` is at least version 4.

Then, set environment variables for the SMUGMUG_API_KEY and the SMUGMUG_API_SECRET. This can be done by adding them to your `bashrc` (~/.bashrc):
```sh
export SMUGMUG_API_KEY=
export SMUGMUG_API_SECRET=
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

Undoes the work of install and setup. Does not uninstall prerequisite packages, but unregisters all cron jobs for this app. See [Architecture](#architecture) for more information.

## Usage

Execute
```sh
./run.sh
```
from the repo root.

## Configuration

You can alter some basic config in the [`.config`](./.config) file. The config is set via environment variables.
- `NODE_ID` - The node id to use for the slide show. This is usually at the end of Uri's from SmugMug.
- `ALLOWED_KEYWORDS` - A colon-separated list of keywords that are allowed on the images. At least one keyword must match for the image to be displayed.
- `SLIDE_DELAY` - The number of seconds to display each image.

## Architecture
The images are displayed via the [`display-images`](./display-images.sh) script which is executed automatically by [`run`](./run.sh) which is a startup service that automatically runs on [download-images](./download-images.sh) and then the aforementioned display-images.

The images are updated via a cron job which executes [download-images](./download-images.sh) via [run](./run.sh). The images are downloaded by their node id. This requires the correct API information to be defined in the environment. It can be overridden by putting it into [.config](./.config), but **this is strongly discouraged as it will make both API key & secret public!**.

All of the files are updated every day via a separate cron job which executes [update](./update.sh). This uses `git` to reset the local files to whatever is in remote. Therefore, local changes aren't persisted. But the directory isn't cleaned so untracked files may not be destroyed during the update.
