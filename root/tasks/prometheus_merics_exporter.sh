#!/bin/bash

EXPORTER_URL="https://github.com/prometheus/node_exporter/releases/download/v0.16.0-rc.0/node_exporter-0.16.0-rc.0.linux-amd64.tar.gz"
FOLDER="node_exporter_0.16.0"

if [ ! -d "${FOLDER}" ]; then
  ufw enable 9100
  ufw reload
  wget ${EXPORTER_URL}
  tar xvfz node_exporter-*.tar.gz
  rm *tar.gz

  mv node_exporter-* ${FOLDER}
fi
