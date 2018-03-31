#!/bin/bash

set -eux

. /root/infrastructure/common.sh


echo "Update Started"
export PATH=${PATH}:/usr/local/sbin/:/usr/sbin/:/sbin/
/root/infrastructure/root/system_control.sh
/root/infrastructure/roles/host_control.sh
