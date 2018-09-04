#!/bin/bash

## This script is set up as a cron job on each server executed as root.
## Responsibility here is to execute system control and redirect output to a logging folder.


PATH=$PATH:/usr/sbin/

## the control file is a lock file to prevent concurrent running fo the script
CONTROL_FILE_NAME=".control_lock"
## we'll consider lock files older than 5 minutes to have died
CONTROL_FILE=$(find /root -maxdepth 1 -name "${CONTROL_FILE_NAME}" -type f -cmin -5)


## set up an exit trap to make sure we remove the touch file on exit.
function removeTouchFile() {
  rm -f "/root/${CONTROL_FILE_NAME}"
}

if [ -z "$CONTROL_FILE" ]; then
  MY_PID=$$
  echo "${MY_PID}" > "${CONTROL_FILE_NAME}"
  trap 'removeTouchFile' EXIT

  LOG_FOLDER="/home/admin/logs/$(date +%Y)/$(date +%m)/$(date +%d)/$(date +%H)"
  LOG_FILE="$LOG_FOLDER/root_cron_log.$(date +%Y).$(date +%m).$(date +%d)_$(date +%H).$(date +%M).log"
  mkdir -p "$(dirname ${LOG_FILE})"

  echo "Cron executing ${date} ${hostname}" > "${LOG_FILE}"
  chown -R admin:admin "${LOG_FOLDER}"
  /root/infrastructure/system_update.sh 1>> "${LOG_FILE}" | /usr/bin/logger
else
  report "Control file touch file found found, update progress is either still running or dead"
fi


