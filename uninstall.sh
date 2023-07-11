#!/bin/bash
set -e

echo "Getting the directory of the script..."
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
echo "The script directory is: ${SCRIPT_DIR}"
pushd "${SCRIPT_DIR}"

existing_crontab=$(crontab -l 2>/dev/null || true)

echo "Removing cron job for run.sh..."
# Check if the cron job for run.sh is registered
if echo "${existing_crontab}" | grep -q "${SCRIPT_DIR}/run.sh"; then
  # Remove the cron job for run.sh
  new_crontab=$(echo "${existing_crontab}" | grep -v "${SCRIPT_DIR}/run.sh")
  # Update the crontab with the new entries
  echo "$new_crontab" | crontab -
  existing_crontab=$new_crontab
  echo "Cron job for run.sh removed."
else
  echo "Cron job for run.sh is not registered."
fi

echo "Removing cron job for update.sh..."
# Check if the cron job for update.sh is registered
if echo "${existing_crontab}" | grep -q "${SCRIPT_DIR}/update.sh"; then
  # Remove the cron job for update.sh
  new_crontab=$(echo "${existing_crontab}" | grep -v "${SCRIPT_DIR}/update.sh")
  # Update the crontab with the new entries
  echo "$new_crontab" | crontab -
  existing_crontab=$new_crontab
  echo "Cron job for update.sh removed."
else
  echo "Cron job for update.sh is not registered."
fi

echo "Disabling and stopping slideshow service..."
systemctl disable slideshow
systemctl stop slideshow

echo "Removing symbolic link to slideshow service..."
unlink /etc/systemd/system/slideshow.service

echo "Reloading systemd daemon..."
systemctl daemon-reload

echo "Uninstallation complete."

popd

echo "Script execution completed."
