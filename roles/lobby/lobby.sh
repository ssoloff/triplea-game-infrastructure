#!/bin/bash

. /root/infrastructure/common.sh

while [ "$1" != "" ]; do
  PARAM=$1
  VALUE=$2
  case ${PARAM} in
    --lobby-port)
      PORT=${VALUE}
      ;;
    --database-port)
      DATABASE_PORT=${VALUE}
      ;;
    --tag-name)
      TAG_NAME=${VALUE}
      ;;
     *)
      echo "ERROR: unknown parameter \"${PARAM}\""
      exit 1
      ;;
  esac
  shift
  shift
done

set -e

checkArg PORT ${PORT}
checkArg DATABASE_PORT ${DATABASE_PORT}
checkArg TAG_NAME ${TAG_NAME}


DEST_FOLDER="/home/triplea/lobby/${TAG_NAME}"
INSTALL_SUCCESS_FILE="${DEST_FOLDER}/.install.success"

if [ ! -f "${INSTALL_SUCCESS_FILE}" ]; then
  ufw allow ${PORT}
  ufw reload
  mkdir -p ${DEST_FOLDER}
  /root/infrastructure/roles/lobby/tasks/install_lobby_artifacts.sh ${DEST_FOLDER} ${TAG_NAME}
  report "Lobby updated to ${TAG_NAME}"
  touch ${INSTALL_SUCCESS_FILE}
  service triplea-lobby restart
else
  report "Lobby is at version ${TAG_NAME}"
fi

/root/infrastructure/roles/lobby/tasks/lobby_config.sh ${DEST_FOLDER} ${PORT}
/root/infrastructure/roles/lobby/tasks/install_start_and_stop_scripts.sh ${DEST_FOLDER}
/root/infrastructure/roles/lobby/tasks/install_service_script.sh ${DEST_FOLDER}

service triplea-lobby start

sleep 3
checkServiceIsRunning triplea-lobby

checkPortIsOpen ${PORT}

chwon -R triplea:triplea /home/triplea
