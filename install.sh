#!/bin/bash
set -e

echo "Getting the directory of the script..."
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
echo "The script directory is: ${SCRIPT_DIR}"
pushd "${SCRIPT_DIR}"

echo "Setting up environment..."
sudo ./setup.sh
echo "Environment setup complete."

existing_crontab=$(crontab -l 2>/dev/null || true)

echo "Adding cron job for run.sh..."
# Check if the cron job for run.sh is already registered
if ! echo "${existing_crontab}" | grep -q "${SCRIPT_DIR}/run.sh"; then
  if [[ -n "${existing_crontab}" ]]; then
    # Combine the existing entries with the new cron job for run.sh
    new_crontab="${existing_crontab}
0 0 * * * /bin/bash ${SCRIPT_DIR}/run.sh"
  else
    # Only add the new cron job for run.sh
    new_crontab="0 0 * * * /bin/bash ${SCRIPT_DIR}/run.sh"
  fi
  # Update the crontab with the combined entries
  echo "$new_crontab" | crontab -
  existing_crontab=$new_crontab
  echo "Cron job for run.sh registered."
else
  echo "Cron job for run.sh is already registered."
fi

echo "Adding cron job for update.sh..."
# Check if the cron job for update.sh is already registered
if ! echo "${existing_crontab}" | grep -q "${SCRIPT_DIR}/update.sh"; then
  if [[ -n "${existing_crontab}" ]]; then
    # Combine the existing entries with the new cron job for update.sh
    new_crontab="${existing_crontab}
0 12 * * * /bin/bash ${SCRIPT_DIR}/update.sh"
  else
    # Only add the new cron job for update.sh
    new_crontab="0 12 * * * /bin/bash ${SCRIPT_DIR}/update.sh"
  fi
  # Update the crontab with the combined entries
  echo "$new_crontab" | crontab -
  existing_crontab=$new_crontab
  echo "Cron job for update.sh registered."
else
  echo "Cron job for update.sh is already registered."
fi

popd

echo "Script execution completed."
