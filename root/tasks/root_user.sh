#!/bin/bash

set -eu


. /root/infrastructure/common.sh

mkdir -p /root/.ssh
cp -v /root/infrastructure/root/files/root_user_authorized_keys /root/.ssh/authorized_keys
chmod 644 /root/.ssh/authorized_keys
