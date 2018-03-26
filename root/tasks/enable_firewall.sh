#!/bin/bash

. /root/infrastructure/common.sh

apt install ufw
ufw allow 22
# ufw allow $port
echo "y" | ufw enable

