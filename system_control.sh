#!/bin/bash

set -eux

. /root/infrastructure/common.sh

report "Update has started"
/root/infrastructure/root/tasks/install_authorized_root_keys.sh
/root/infrastructure/root/tasks/install_triplea_user.sh
/root/infrastructure/root/tasks/update_system_packages.sh
/root/infrastructure/root/tasks/check_localhost.sh
/root/infrastructure/root/tasks/enable_firewall.sh
/root/infrastructure/host_control.sh
report "Update has completed"
