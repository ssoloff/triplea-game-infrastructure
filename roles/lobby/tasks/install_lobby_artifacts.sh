#!/bin/bash

set -e

. /root/infrastructure/common.sh

function installLobby() {
  local destFolder=$1
  local tagName=$2

  echo "$tagName" > ${destFolder}/version

  local installerFile="triplea-lobby-${tagName}.zip"
  wget "https://github.com/triplea-game/triplea/releases/download/${tagName}/${installerFile}"
  unzip -o -d ${destFolder} ${installerFile}
  rm ${installerFile}

}

installLobby $1 $2
