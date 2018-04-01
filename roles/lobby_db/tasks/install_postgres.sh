#!/bin/bash
set -ex
. /root/infrastructure/common.sh

apt -y postgresql postgresql-contrib

## TODO: automate setting of password
## sudo -u postgres psql postgres
## \password postgres

function createDb() {
  echo "create database ta_users;" | sudo -u postgres psql postgres
}

echo "\l" | sudo -u postgres psql postgres | grep ta_users || createDb
