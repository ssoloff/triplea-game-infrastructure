#!/bin/bash

set -eux

CLEAN="rm -rf /root/infrastructure/"
## TODO: update repo name from fork to triplea-game
CLONE="git clone https://github.com/DanVanAtta/triplea.git /root/infrastructure/ &> /dev/null"
RUN_CRON="/root/infrastructure/root/root_cron.sh"

sudo apt-get install -y git
crontab -l | { cat; echo "*/1 * * * * ${CLEAN}; ${CLONE}; ${RUN_CRON}"; } | crontab -
