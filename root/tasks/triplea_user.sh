#!/bin/bash

set -eu


. /root/infrastructure/common.sh


installUser triplea

function botPermissions() {
  local botNumber=$1
  egrep -q "^triplea.*triplea-bot@${botNumber}" /etc/sudoers || echo "triplea ALL=(ALL) NOPASSWD: /usr/sbin/service triplea-bot@${botNumber} restart" >> /etc/sudoers
  egrep -q "^triplea.*triplea-bot@${botNumber}" /etc/sudoers || echo "triplea ALL=(ALL) NOPASSWD: /usr/sbin/service triplea-bot@${botNumber} start" >> /etc/sudoers
  egrep -q "^triplea.*triplea-bot@${botNumber}" /etc/sudoers || echo "triplea ALL=(ALL) NOPASSWD: /usr/sbin/service triplea-bot@${botNumber} stop" >> /etc/sudoers
  egrep -q "^triplea.*triplea-bot@${botNumber}" /etc/sudoers || echo "triplea ALL=(ALL) NOPASSWD: /usr/sbin/service triplea-bot@${botNumber} status" >> /etc/sudoers
}

botPermissions 01
botPermissions 02
botPermissions 03
botPermissions 04

## enable sudoer permissions
egrep -q "^triplea.*triplea-lobby" /etc/sudoers || echo "triplea ALL=(ALL) NOPASSWD: /usr/sbin/service triplea-lobby" >> /etc/sudoers
egrep -q "^triplea.*journalctl" /etc/sudoers || echo "triplea ALL=(ALL) NOPASSWD: /usr/sbin/service journalctl" >> /etc/sudoers
egrep -q "^triplea.*htop" /etc/sudoers || echo "triplea ALL=(ALL) NOPASSWD: /usr/bin/htop" >> /etc/sudoers
egrep -q "^triplea.*iftop" /etc/sudoers || echo "triplea ALL=(ALL) NOPASSWD: /usr/bin/iftop" >> /etc/sudoers
