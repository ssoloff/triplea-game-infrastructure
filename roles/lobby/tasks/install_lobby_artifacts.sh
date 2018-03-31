#!/bin/bash

function installLobby() {
  local destFolder=$1
  local tagName=$2

  echo "$tagName" > ${destFolder}/version

  local installerFile="triplea-${tagName}-server.zip"
  wget "https://github.com/triplea-game/triplea/releases/download/${tagName}/${installerFile}"
  unzip -o -d ${destFolder} ${installerFile}
  rm ${installerFile}

  chmod go-rw ${destFolder}/config/lobby/lobby.properties

  cp ${RUN_LOBBY} ${destFolder}/
  cp ${REMOVE_LOBBY} ${destFolder}/
  chmod +x ${destFolder}/*.sh
}

installLobby $1 $2
