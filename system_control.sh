#!/bin/bash

set -eux

PATH=$PATH:/usr/sbin/

LOBBY_DB=/root/infrastructure/triplea/lobby_db.sh
LOBBY=/root/infrastructure/triplea/lobby.sh

CONTROL_FILE_NAME=".control_lock"
CONTROL_FILE=$(find /root -maxdepth 1 -name "${CONTROL_FILE_NAME}" -type f -cmin -5)


. /root/infrastructure/common.sh

function main() {
  report "Update has started"
  systemInstall
  applicationInstall
  report "Update has completed"
}


function applicationInstall() {
  case "$(hostname)" in
    prerelease_staging)
    ;;
    *)
      reportError "Unknown host: $(hostname)"
    ;;
    esac
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
  touch ${CONTROL_FILE_NAME}
  main
else
  report "Control file touch file found found, update progress is either still running or dead"
fi
