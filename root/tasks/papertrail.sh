#!/bin/bash

. /root/infrastructure/common.sh

## papertrail restarts rsyslogd, to avoid that we'll install papertrail only if needed
if [ ! -f "/etc/rsyslog.d/95-papertrail.conf" ]; then
  PAPERTRAIL_TOKEN=$(readSecret "papertrail_token")
  wget -qO - --header="X-Papertrail-Token: ${PAPERTRAIL_TOKEN}" \
    https://papertrailapp.com/destinations/8364511/setup.sh | sudo bash
fi
