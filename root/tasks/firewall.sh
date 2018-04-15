#!/bin/bash

set -eu


. /root/infrastructure/common.sh

function openFirewallForSsh() {
  ufw allow 22
  echo "y" | ufw enable
}

apt install -y ufw
## if not open, open firewall for ssh and enable firewall.
ufw status | grep ^22 | grep -q ALLOW || openFirewallForSsh

