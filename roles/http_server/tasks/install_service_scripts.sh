#!/bin/bash

destFolder=$1
tagName=$2

set -eu

. /root/infrastructure/common.sh

SERVICE_FILE="/root/infrastructure/roles/http_server/files/http-server.service"

cp -v "/root/infrastructure/roles/lobby/files/run_http_server.sh" ${destFolder}/
sed -i "s/TAG_NAME/${tagName}/" ${destFolder}/run_http_server.sh

chmod +x ${destFolder}/*.sh

installService http-server ${SERVICE_FILE} "${destFolder}/" run_http_server.sh
systemctl enable http-server
