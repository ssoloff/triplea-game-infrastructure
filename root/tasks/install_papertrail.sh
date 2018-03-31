#!/bin/bash

. /root/infrastructure/common.sh

PAPERTRAIL_TOKEN=$(readSecret "papertrail_token")

wget -qO - --header="X-Papertrail-Token: ${PAPERTRAIL_TOKEN}" \
https://papertrailapp.com/destinations/8364511/setup.sh | sudo bash
