#!/bin/bash

set -eux


. /root/infrastructure/common.sh

function openFirewallForSsh() {
  ufw allow 22
  echo "y" | ufw enable
}

apt install ufw
## if not open, open firewall for ssh and enable firewall.
ufw status | grep ^22 | grep -q ALLOW || openFirewallForSsh

