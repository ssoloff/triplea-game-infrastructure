#!/bin/bash

destFolder=$1

RUN_LOBBY="/root/infrastructure/roles/lobby/files/run_lobby.sh"
REMOVE_LOBBY="/root/infrastructure/roles/lobby/files/remove_lobby.sh"


cp ${RUN_LOBBY} ${destFolder}/
cp ${REMOVE_LOBBY} ${destFolder}/
chmod +x ${destFolder}/*.sh
