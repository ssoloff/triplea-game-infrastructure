#!/bin/bash
set -ex
. /root/infrastructure/common.sh

TAG_NAME=$1

if [ -z "${TAG_NAME}" ]; then
  echo "tag name cannot be empty"
  exit 1
fi


MIGRATIONS_URL="https://github.com/triplea-game/triplea/releases/download/${TAG_NAME}/migrations.zip"
FLYWAY_INSTALL_URL="https://repo1.maven.org/maven2/org/flywaydb/flyway-commandline/5.0.7/flyway-commandline-5.0.7-linux-x64.tar.gz"

FLYWAY_FOLDER="/home/triplea/flyway-5.0.7/"

if [ ! -d ${FLYWAY_FOLDER} ]; then
  wget ${FLYWAY_INSTALL_URL}
  tar xvf flyway*tar.gz
  rm *tar.gz

  mv flyway* ${FLYWAY_FOLDER}
fi


CONF_FILE="${FLYWAY_FOLDER}/conf/flyway.conf"
cp -v "/root/infrastructure/roles/lobby_db/files/flyway.conf" "${CONF_FILE}"

set +x
sed -i "s/user=.*/user=$(readSecret db_user)/" ${CONF_FILE}
sed -i "s/password=.*/user=$(readSecret db_password)/" ${CONF_FILE}
set -x


MIGRATIONS_FOLDER="/home/triplea/lobby_db/migrations"

rm -f migrations.zip*
wget "${MIGRATIONS_URL}"
rm -rf "${MIGRATIONS_FOLDER}"
unzip -d ${MIGRATIONS_FOLDER} migrations.zip

chown -R triplea:triplea /home/triplea/


# ${FLYWAY_FOLDER}/flyway
