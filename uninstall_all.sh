#!/bin/bash

crontab -r
rm -rf /root/infrastructure/
rm -rf /root/logs/
rm /var/mail/root

deluser triplea
rm -rf /home/triplea

apt -y remove \
  git \
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
