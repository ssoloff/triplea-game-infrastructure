#!/bin/bash
set -ex
. /root/infrastructure/common.sh


URL="https://repo1.maven.org/maven2/org/flywaydb/flyway-commandline/5.0.7/flyway-commandline-5.0.7-linux-x64.tar.gz"

FLYWAY_FOLDER="/home/triplea/flyway-5.0.7/"

if [ ! -d ${FLYWAY_FOLDER} ]; then
  wget $URL
  tar xvf flyway*tar.gz
  rm *tar.gz

  mv flyway* ${FLYWAY_FOLDER}
fi


CONF_FILE="${FLYWAY_FOLDER}/conf/flyway.conf"
cp -v "/root/infrastructure/roles/lobby_db/files/flyway.conf" "${CONF_FILE}"
sed -i "s/user=.*/user=$(readSecret db_user)/" ${CONF_FILE}
sed -i "s/password=.*/user=$(readSecret db_password)/" ${CONF_FILE}
chown -R triplea:triplea /home/triplea/


# ${FLYWAY_FOLDER}/flyway
