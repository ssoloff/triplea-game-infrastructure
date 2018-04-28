#!/bin/bash

## Downloads and unzips installation files to: /home/triplea/bots/${TAG_NAME}

. /root/infrastructure/common.sh

TAG_NAME=$1

set -eu

function main() {
  report "Installing bot version: ${TAG_NAME}"
  local installPath="/home/triplea/bots/${TAG_NAME}"
  mkdir -p ${installPath}

  local installerFile="triplea-${TAG_NAME}.zip"
  rm -f "${installerFile}"
  downloadBinaries "${installerFile}"

  unzip -d "${installPath}" "${installerFile}"

  echo "${TAG_NAME}" > "${installPath}/version"
}

function downloadBinaries() {
  local installerFile=$1
  local url="https://github.com/triplea-game/triplea/releases/download/${TAG_NAME}/triplea-${TAG_NAME}-all_platforms.zip"
  curl -L "${url}" > "${installerFile}"
}

main
