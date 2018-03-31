#!/bin/bash

set -ex

destFolder=$1
serviceFileDeployedPath="/lib/systemd/system/triplea-lobby.service"
LOBBY_SERVICE_FILE="/root/infrastructure/roles/lobby/files/triplea-lobby.service"


cp -v ${LOBBY_SERVICE_FILE} ${serviceFileDeployedPath}
sed -i "s|LOBBY_DIR|${destFolder}|" ${serviceFileDeployedPath}
systemctl enable triplea-lobby
systemctl daemon-reload

