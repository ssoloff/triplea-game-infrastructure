#!/bin/bash

EXPORTER_URL="https://github.com/prometheus/node_exporter/releases/download/v0.16.0-rc.0/node_exporter-0.16.0-rc.0.linux-amd64.tar.gz"


METRICS_SERVICE_FILE="/root/infrastructrure/root/files/metrics_export.service"
METRICS_FOLDER="/home/metrics/node_exporter"

if [ ! -d "${METRICS_FOLDER}" ]; then
  installuser metrics
  installService metrics ${METRICS_SERVICE_FILE} ${METRICS_FOLDER} node_exporter
  ufw allow 9100
  ufw reload
  wget ${EXPORTER_URL}
  tar xvfz node_exporter-*.tar.gz
  rm *tar.gz

  mv node_exporter-* ${METRICS_FOLDER}
fi
