#!/bin/bash
set -e
. /root/infrastructure/common.sh

PORT=$1

apt install -y postgresql postgresql-contrib

## TODO: automate setting of password
## Warning: server needs enough available memory for postgres to start
## sudo -u postgres psql postgres
## \password postgres

function createDb() {
  echo "create database ta_users;" | sudo -u postgres psql postgres
}

echo "\l" | sudo -u postgres psql postgres | grep ta_users || createDb


CONF_FILE="/etc/postgresql/9.5/main/postgresql.conf"

function updatePort() {
  local portNumber=$1
  sed -i "s/port =.*/port = ${portNumber}/" ${CONF_FILE}
  service postgresql restart
}

grep "port = ${PORT}" ${CONF_FILE} || updatePort ${PORT}


