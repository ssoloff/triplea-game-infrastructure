#!/bin/bash
set -e
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

sed -i "s/flyway.user=.*/flyway.user=$(readSecret db_user)/" ${CONF_FILE}
sed -i "s/flyway.password=.*/flyway.password=$(readSecret db_password)/" ${CONF_FILE}


MIGRATIONS_FOLDER="${FLYWAY_FOLDER}/sql/"

rm -f migrations.zip*
wget "${MIGRATIONS_URL}"
rm -rf "${MIGRATIONS_FOLDER}"

rm -f ${MIGRATIONS_FOLDER}/*
unzip -d ${MIGRATIONS_FOLDER} migrations.zip
rm -f migrations.zip*
chown -R triplea:triplea /home/triplea/


${FLYWAY_FOLDER}/flyway migrate

SCHEMA=$(${FLYWAY_FOLDER}/flyway info | grep "Schema version")
report "DB ${SCHEMA}; tag: ${TAG_NAME}"
