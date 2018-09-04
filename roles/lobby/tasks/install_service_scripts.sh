#!/bin/bash

set -e

. /root/infrastructure/common.sh

destFolder=$1
serviceFileDeployedPath="/lib/systemd/system/triplea-lobby.service"
LOBBY_SERVICE_FILE="/root/infrastructure/roles/lobby/files/triplea-lobby.service"

installService triplea-lobby ${LOBBY_SERVICE_FILE} "${destFolder}/" run_lobby.sh

cp -v "/root/infrastructure/roles/lobby/files/run_lobby.sh" ${destFolder}/
cp -v "/root/infrastructure/roles/lobby/files/remove_lobby.sh" ${destFolder}/

chmod +x ${destFolder}/*.sh
