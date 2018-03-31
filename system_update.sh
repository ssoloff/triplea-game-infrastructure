#!/bin/bash

set -eux

. /root/infrastructure/common.sh

echo "Update Started"
/root/infrastructure/root/system_control.sh
/root/infrastructure/roles/host_control.sh
