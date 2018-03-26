#!/bin/bash

set -eux

PATH=$PATH:/usr/sbin/

CONTROL_FILE_NAME=".control_lock"
CONTROL_FILE=$(find /root -maxdepth 1 -name "${CONTROL_FILE_NAME}" -type f -cmin -5)

. /root/infrastructure/common.sh

function main() {
  report "Update has started"
  systemInstall
  /root/infrastructure/host_control.sh
  report "Update has completed"
}

## install the universal OS components
function systemInstall() {
  /root/infrastructure/root/tasks/install_authorized_root_keys.sh
  /root/infrastructure/root/tasks/install_triplea_user.sh
  /root/infrastructure/root/tasks/update_system_packages.sh
  /root/infrastructure/root/tasks/check_localhost.sh
  /root/infrastructure/root/tasks/enable_firewall.sh
}

## set up an exit trap to make sure we remove the touch file on exit.
function removeTouchFile() {
  rm -f /root/CONTROL_FILE_NAME
}
trap 'removeTouchFile' EXIT

if [ -z "$CONTROL_FILE" ]; then
  MY_PID=$$
  echo "${MY_PID}" > ${CONTROL_FILE_NAME}
  main
else
  report "Control file touch file found found, update progress is either still running or dead"
fi
