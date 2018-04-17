#!/bin/bash

set -eu


. /root/infrastructure/common.sh


installUser triplea

## enable sudoer permissions
egrep -q "^triplea.*triplea-bot" /etc/sudoers || echo "triplea ALL=(ALL) NOPASSWD: /usr/sbin/service triplea-bot" >> /etc/sudoers
egrep -q "^triplea.*triplea-lobby" /etc/sudoers || echo "triplea ALL=(ALL) NOPASSWD: /usr/sbin/service triplea-lobby" >> /etc/sudoers
egrep -q "^triplea.*journalctl" /etc/sudoers || echo "triplea ALL=(ALL) NOPASSWD: /usr/sbin/service journalctl" >> /etc/sudoers
egrep -q "^triplea.*htop" /etc/sudoers || echo "triplea ALL=(ALL) NOPASSWD: /usr/bin/htop" >> /etc/sudoers
egrep -q "^triplea.*iftop" /etc/sudoers || echo "triplea ALL=(ALL) NOPASSWD: /usr/bin/iftop" >> /etc/sudoers
