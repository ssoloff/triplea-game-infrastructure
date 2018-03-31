#!/bin/bash

. /root/infrastructure/common.sh

set -ex

PROM_FOLDER="/home/prometheus/prometheus-2.2.1/"
PROM_SERVICE_FILE="/root/infrastructure/roles/support/prometheus/files/prometheus.service"
PROM_DL="https://github.com/prometheus/prometheus/releases/download/v2.2.1/prometheus-2.2.1.linux-amd64.tar.gz"
PROM_CONFIG="/home/prometheus/prometheus.yml"


installUser prometheus

if [ ! -d "${PROM_FOLDER}" ]; then
  ufw allow 9090
  wget ${PROM_DL}
  tar xvfz prometheus-*.tar.gz
  rm *.tar.gz

  mv prom*2.2.1* ${PROM_FOLDER}
  echo "installed prometheus to ${PROM_FOLDER}"
fi

mkdir -p ${PROM_FOLDER}

cp "/root/infrastructure/roles/support/prometheus/files/prometheus.yml" ${PROM_FOLDER}
installService prometheus ${PROM_SERVICE_FILE} ${PROM_FOLDER} "prometheus"


service prometheus start
