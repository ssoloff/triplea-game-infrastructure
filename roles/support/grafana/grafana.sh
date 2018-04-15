#!/bin/bash

. /root/infrastructure/common.sh

set -e

GRAFANA_SERVICE_FILE="/root/infrastructure/roles/support/grafana/files/grafana.service"
GRAFANA_DIR="/home/grafana/grafana-2.5.0/"

if [ ! -d ${GRAFANA_DIR} ]; then
  ufw allow 3000
  curl -s -L -O https://grafanarel.s3.amazonaws.com/builds/grafana-2.5.0.linux-x64.tar.gz
  tar zxf grafana-2.5.0.linux-x64.tar.gz
  rm *tar.gz
  mkdir -p "/home/grafana/"
  mv grafana-2.5.0/ ${GRAFANA_DIR}
fi

installService grafana ${GRAFANA_SERVICE_FILE} ${GRAFANA_DIR} "bin/grafana-server web"
installUser grafana
chown -R grafana:grafana /home/grafana/
service grafana start
