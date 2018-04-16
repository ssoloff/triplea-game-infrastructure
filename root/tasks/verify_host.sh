#!/bin/bash

set -eu

. /root/infrastructure/common.sh


if [ "$(hostname)" == "localhost" ]; then
  reportError "Hostname is set to localhost; run '/root/infrastructure/setup/set_host_name.sh' and restart the server"
fi

service metrics status | grep "Active: active"  || reportError "Metrics not running, run: 'service metrics status'"

checkFile ${SECRET_FILE}
