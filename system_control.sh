#!/bin/bash

set -eux

PATH=$PATH:/usr/sbin/

. /root/infrastructure/common.sh


CONTROL_FILE=$(find /root -maxdepth 1 -name ".control_lock" -type f -cmin -5)
if [ -z "$CONTROL_FILE" ]; then
  touch $CONTROL_FILE

  /root/infrastructure/root/tasks/install_authorized_root_keys.sh
  /root/infrastructure/root/tasks/install_triplea_user.sh
  /root/infrastructure/root/tasks/update_system_packages.sh
  /root/infrastructure/root/tasks/check_localhost.sh
  /root/infrastructure/root/tasks/enable_firewall.sh
  rm $CONTROL_FILE
fi

