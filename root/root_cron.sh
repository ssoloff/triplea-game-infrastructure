#!/bin/bash

## This script is set up as a cron job on each server executed as root.
## Responsibility here is to execute system control and redirect output to a logging folder.

LOG_FOLDER="/root/logs/$(date +%Y)/$(date +%m)/$(date +%d)/$(date +%H)"
mkdir -p ${LOG_FOLDER}

LOG_FILE="$LOG_FOLDER/root_cron_log.$(date +%Y).$(date +%m).$(date +%d)_$(date +%H).$(date +%M).log"
echo "Cron executing ${date} ${hostname}" > $LOG_FILE
rm -rf /root/infrastructure/
git clone https://github.com/DanVanAtta/infrastructure.git 2>&1 >> ${LOG_FILE}
/root/infrastructure/system_control.sh 2>&1 >> ${LOG_FILE}
