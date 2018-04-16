#!/bin/bash

set -eu

. /root/infrastructure/common.sh

apt-get update

apt-get install -y \
  curl \
  fail2ban \
  htop \
  iftop \
  openjdk-8-jre \
  openjfx \
  python3 \
  tiptop \
  unattended-upgrades \
  unzip \
  vim
