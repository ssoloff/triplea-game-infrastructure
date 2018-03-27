#!/bin/bash


NEW_HOST_NAME=$1

set -eux

if [ -z "${NEW_HOST_NAME}" ]; then
  echo "Need to supply host name as argument"
  echo "usage: $(basename $0) hostname"
  exit 1
fi

echo "$NEW_HOST_NAME" > /etc/hostname
sed -i "s/^\(127.0.0.1.*localhost\)$/\1 ${NEW_HOST_NAME}/" /etc/hosts
