#!/bin/bash

## This script is set up as a cron job on each server executed as root.
## Responsibility here is to execute system control and redirect output to a logging folder.


PATH=$PATH:/usr/sbin/
CONTROL_FILE_NAME=".control_lock"
CONTROL_FILE=$(find /root -maxdepth 1 -name "${CONTROL_FILE_NAME}" -type f -cmin -5)


## set up an exit trap to make sure we remove the touch file on exit.
function removeTouchFile() {
  rm -f /root/${CONTROL_FILE_NAME}
}

if [ -z "$CONTROL_FILE" ]; then
  MY_PID=$$
  echo "${MY_PID}" > ${CONTROL_FILE_NAME}
  trap 'removeTouchFile' EXIT

  LOG_FOLDER="/root/logs/$(date +%Y)/$(date +%m)/$(date +%d)/$(date +%H)"
  mkdir -p ${LOG_FOLDER}

  LOG_FILE="$LOG_FOLDER/root_cron_log.$(date +%Y).$(date +%m).$(date +%d)_$(date +%H).$(date +%M).log"
  echo "Cron executing ${date} ${hostname}" > $LOG_FILE
  /root/infrastructure/system_control.sh 2>&1 >> ${LOG_FILE}
else
  report "Control file touch file found found, update progress is either still running or dead"
fi


