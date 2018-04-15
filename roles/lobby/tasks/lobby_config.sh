#!/bin/bash

set -e

. /root/infrastructure/common.sh

function updateConfig() {
  local destFolder=$1
  local port=$2
  local propsFile="${destFolder}/config/lobby/lobby.properties"

  grep "port =" ${propsFile} || echo "port = ${port}" >> ${propsFile}
  sed -i "s/postgres_user.*/postgres_user = $(readSecret db_user)/" ${propsFile}
  sed -i "s/postgres_password.*/postgres_password = $(readSecret db_password)/" ${propsFile}

  chmod go-rw ${propsFile}
}

updateConfig $1 $2
