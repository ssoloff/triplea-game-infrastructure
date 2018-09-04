#!/bin/bash

set -e

. /root/infrastructure/common.sh

DEST_FOLDER=$1
TAG_NAME=$2
PORT=$3

checkArg PORT $PORT

INSTALL_SUCCESS_FILE="${DEST_FOLDER}/.install.success"

if [ ! -f "${INSTALL_SUCCESS_FILE}" ]; then
  ufw allow ${PORT}
  ufw reload
  mkdir -p ${DEST_FOLDER}

  INSTALLER_FILE="http-server-${TAG_NAME}.zip"
  rm -f ${INSTALLER_FILE}

  wget "https://github.com/triplea-game/triplea/releases/download/${TAG_NAME}/${INSTALLER_FILE}"
  unzip -o -d ${DEST_FOLDER} ${INSTALLER_FILE}
  rm -f ${INSTALLER_FILE}

  touch ${INSTALL_SUCCESS_FILE}
  report "http-server ${TAG_NAME} installed"
fi
