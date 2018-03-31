#!/bin/bash

set -ex

PROM_FOLDER="prometheus-2.2.1"

if [ ! -d "${PROM_FOLDER}" ]; then

  ufw enable 9090
  PROM_DL="https://github.com/prometheus/prometheus/releases/download/v2.2.1/prometheus-2.2.1.linux-amd64.tar.gz"
  wget ${PROM_DL}
  tar xvfz prometheus-*.tar.gz
  rm *.tar.gz
  mv prom*2.2.1* ${PROM_FOLDER}
  echo "installed prometheus to $(pwd)/${PROM_FOLDER}"
fi

