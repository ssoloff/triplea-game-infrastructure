#!/bin/bash

. /root/infrastructure/common.sh

set -ex

EXPORTER_URL="https://github.com/prometheus/node_exporter/releases/download/v0.16.0-rc.0/node_exporter-0.16.0-rc.0.linux-amd64.tar.gz"
METRICS_SERVICE_FILE="/root/infrastructure/root/files/metrics-export.service"
METRICS_FOLDER="/home/metrics/node_exporter/"

installUser metrics

if [ ! -d "${METRICS_FOLDER}" ]; then
  ufw allow 9100
  ufw reload
  wget ${EXPORTER_URL}
  tar xvfz node_exporter-*.tar.gz
  rm *tar.gz

  installService metrics ${METRICS_SERVICE_FILE} ${METRICS_FOLDER} node_exporter
  mv node_exporter-* ${METRICS_FOLDER}
fi

chown -R metrics:metrics /home/metrics/
service metrics start
