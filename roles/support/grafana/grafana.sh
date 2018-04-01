#!/bin/bash

. /root/infrastructure/common.sh

set -ex

GRAFANA_SERVICE_FILE="/root/infrastructure/roles/support/prometheus/files/grafana.service"
GRAFANA_DIR="/home/grafana/grafana-2.5.0/"
mkdir -p ${GRAFANA_DIR}

if [ ! -d ${GRAFANA_DIR} ]; then
  curl -L -O https://grafanarel.s3.amazonaws.com/builds/grafana-2.5.0.linux-x64.tar.gz
  tar zxf grafana-2.5.0.linux-x64.tar.gz
  rm *tar.gz
  mv grafana-2.5.0/ ${GRAFANA_DIR}
fi

installService grafana ${GRAFANA_SERVICE_FILE} ${GRAFANA_DIR} "bin/grafana-server web"
installUser grafana
chown -R grafana:grafana /home/grafana/

