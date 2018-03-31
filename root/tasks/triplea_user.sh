#!/bin/bash

set -eux


. /root/infrastructure/common.sh

grep -q triplea /etc/passwd || adduser --disabled-password --gecos "" triplea
grep -q "^triplea" /etc/sudoers || echo "triplea ALL=(ALL) /usr/sbin/service triplea-lobby" >> /etc/sudoers
grep -q "^triplea.*htop" /etc/sudoers || echo "triplea ALL=(ALL) /usr/bin/htop*" >> /etc/sudoers
grep -q "^triplea.*iftop" /etc/sudoers || echo "triplea ALL=(ALL) /usr/bin/iftop" >> /etc/sudoers

mkdir -p /home/triplea/.ssh
cat /root/infrastructure/root/files/triplea_user_authorized_keys \
    /root/infrastructure/root/files/root_user_authorized_keys > /home/triplea/.ssh/authorized_keys
chmod 644 /home/triplea/.ssh/authorized_keys
