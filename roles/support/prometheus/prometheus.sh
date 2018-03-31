#!/bin/bash

. /root/infrastructure/common.sh

set -ex

PROM_FOLDER="/home/prometheus/prometheus-2.2.1"
PROM_SERVICE_FILE="/root/infrastructure/roles/support/prometheus/files/prometheus.service"
PROM_START=""


if [ ! -d "${PROM_FOLDER}" ]; then
  installUser prometheus
  installService prometheus ${PROM_SERVICE_FILE} ${PROM_FOLDER}
  ufw allow 9090
  PROM_DL="https://github.com/prometheus/prometheus/releases/download/v2.2.1/prometheus-2.2.1.linux-amd64.tar.gz"
  wget ${PROM_DL}
  tar xvfz prometheus-*.tar.gz
  rm *.tar.gz
  mv prom*2.2.1* ${PROM_FOLDER}

  echo "installed prometheus to ${PROM_FOLDER}"
fi
