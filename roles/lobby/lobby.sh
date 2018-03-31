#!/bin/bash

. /root/infrastructure/common.sh

POSITIONAL=()
while [[ $# -gt 0 ]]; do
  key="$1"

  case ${key} in
    --lobby-port)
    PORT="$2"
    shift # past argument
    shift # past value
    ;;
    --database-port)
    DATABASE_PORT="$2"
    shift # past argument
    shift # past value
    ;;
   --tag-name)
    TAG_NAME="$2"
    shift # past argument
    shift # past value
    ;;
    *)    # unknown option
    POSITIONAL+=("$1") # save it in an array for later
    shift # past argument
    ;;
  esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters


function checkArg() {
  local label=$1
  local arg=$2
  if [ -z "$arg" ]; then
    echo "${label} was not set"
    exit 1
  fi
}

set -ex

checkArg DATABASE_PORT ${DATABASE_PORT}
checkArg PORT ${PORT}
checkArg TAG_NAME ${TAG_NAME}

echo "Lobby port: ${PORT}"
echo "Lobby database port: ${DATABASE_PORT}"
echo "Lobby version tag: ${TAG_NAME}"


DEST_FOLDER="/home/triplea/lobby/${TAG_NAME}"
INSTALL_SUCCESS_FILE="${DEST_FOLDER}/.install.success"

if [ ! -f "${INSTALL_SUCCESS_FILE}" ]; then
mkdir -p ${DEST_FOLDER}

  /root/infrastructure/roles/lobby/tasks/install_lobby_artifact.sh ${DEST_FOLDER} ${TAG_NAME}
  /root/infrastructure/roles/lobby/tasks/install_start_and_stop_scripts.sh ${DEST_FOLDER}

  report "Completed update to ${TAG_NAME}"
  touch ${INSTALL_SUCCESS_FILE}
else
  report "Host is already at version ${TAG_NAME}"
fi

/root/infrastructure/roles/lobby/tasks/install_service_script.sh ${DEST_FOLDER}







