#!/bin/bash

set -eu

. /root/infrastructure/common.sh

USER_NAME=admin

installUser ${USER_NAME}

cp /root/infrastructure/root/files/admin_user_authorized_keys /home/${USER_NAME}/.ssh/authorized_keys
chmod 644 /home/${USER_NAME}/.ssh/authorized_keys
chown -R ${USER_NAME}:${USER_NAME} /home/${USER_NAME}/

## enable sudoer permissions

function botPermissions() {
  local botNumber=$1
  grep -E -q "^${USER_NAME}.*triplea-bot@${botNumber} restart" /etc/sudoers || echo "${USER_NAME} ALL=(ALL) NOPASSWD: /usr/sbin/service triplea-bot@${botNumber} restart" >> /etc/sudoers
  grep -E -q "^${USER_NAME}.*triplea-bot@${botNumber} start" /etc/sudoers || echo "${USER_NAME} ALL=(ALL) NOPASSWD: /usr/sbin/service triplea-bot@${botNumber} start" >> /etc/sudoers
  grep -E -q "^${USER_NAME}.*triplea-bot@${botNumber} stop" /etc/sudoers || echo "${USER_NAME} ALL=(ALL) NOPASSWD: /usr/sbin/service triplea-bot@${botNumber} stop" >> /etc/sudoers
  grep -E -q "^${USER_NAME}.*triplea-bot@${botNumber} status" /etc/sudoers || echo "${USER_NAME} ALL=(ALL) NOPASSWD: /usr/sbin/service triplea-bot@${botNumber} status" >> /etc/sudoers
}

## TODO: we have a hardcoded assumption here that we'll have 4 bots... It is a different config for how many bots there are per server.
botPermissions 01
botPermissions 02
botPermissions 03
botPermissions 04
botPermissions 05
botPermissions 06
botPermissions 07
botPermissions 08
botPermissions 09
botPermissions 10

grep -E -q "^${USER_NAME}.*triplea-lobby" /etc/sudoers || echo "${USER_NAME} ALL=(ALL) NOPASSWD: /usr/sbin/service triplea-lobby" >> /etc/sudoers
grep -E -q "^${USER_NAME}.*journalctl" /etc/sudoers || echo "${USER_NAME} ALL=(ALL) NOPASSWD: /usr/sbin/service journalctl" >> /etc/sudoers
grep -E -q "^${USER_NAME}.*htop" /etc/sudoers || echo "${USER_NAME} ALL=(ALL) NOPASSWD: /usr/bin/htop" >> /etc/sudoers
grep -E -q "^${USER_NAME}.*iftop" /etc/sudoers || echo "${USER_NAME} ALL=(ALL) NOPASSWD: /usr/bin/iftop" >> /etc/sudoers

