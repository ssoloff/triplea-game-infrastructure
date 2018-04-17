#!/bin/bash

set -eu


. /root/infrastructure/common.sh


installUser triplea

## enable sudoer permissions
egrep -q "^triplea.*triplea-bot@01" /etc/sudoers || echo "triplea ALL=(ALL) NOPASSWD: /usr/sbin/service triplea-bot@01 restart" >> /etc/sudoers
egrep -q "^triplea.*triplea-bot@02" /etc/sudoers || echo "triplea ALL=(ALL) NOPASSWD: /usr/sbin/service triplea-bot@02 restart" >> /etc/sudoers
egrep -q "^triplea.*triplea-bot@03" /etc/sudoers || echo "triplea ALL=(ALL) NOPASSWD: /usr/sbin/service triplea-bot@03 restart" >> /etc/sudoers
egrep -q "^triplea.*triplea-bot@04" /etc/sudoers || echo "triplea ALL=(ALL) NOPASSWD: /usr/sbin/service triplea-bot@04 restart" >> /etc/sudoers
egrep -q "^triplea.*triplea-lobby" /etc/sudoers || echo "triplea ALL=(ALL) NOPASSWD: /usr/sbin/service triplea-lobby" >> /etc/sudoers
egrep -q "^triplea.*journalctl" /etc/sudoers || echo "triplea ALL=(ALL) NOPASSWD: /usr/sbin/service journalctl" >> /etc/sudoers
egrep -q "^triplea.*htop" /etc/sudoers || echo "triplea ALL=(ALL) NOPASSWD: /usr/bin/htop" >> /etc/sudoers
egrep -q "^triplea.*iftop" /etc/sudoers || echo "triplea ALL=(ALL) NOPASSWD: /usr/bin/iftop" >> /etc/sudoers
