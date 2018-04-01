#!/bin/bash
set -ex
. /root/infrastructure/common.sh


URL="https://repo1.maven.org/maven2/org/flywaydb/flyway-commandline/5.0.7/flyway-commandline-5.0.7-linux-x64.tar.gz"

FLYWAY_FOLDER="/home/triplea/flyway-5.0.7"

wget $URL
tar xvf flyway*tar.gz
rm *tar.gz


mv flyway* ${FLYWAY_FOLDER}
chown -R triplea:triplea /home/triplea/

