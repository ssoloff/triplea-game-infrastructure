#!/bin/bash

set -e

. /root/infrastructure/common.sh

destFolder=$1

cp -v "/root/infrastructure/roles/lobby/files/run_lobby.sh" ${destFolder}/
cp -v "/root/infrastructure/roles/lobby/files/remove_lobby.sh" ${destFolder}/

chmod +x ${destFolder}/*.sh
