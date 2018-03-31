#!/bin/bash

set -eux

. /root/infrastructure/common.sh

apt-get update

apt-get -y install \
  curl \
  fail2ban \
  htop \
  iftop \
  openjdk-8-jre \
  openjfx \
  postgresql \
  postgresql-contrib \
  python3 \
  tiptop \
  unattended-upgrades \
  unzip \
  vim
