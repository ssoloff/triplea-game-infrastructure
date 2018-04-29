#!/bin/bash

. /root/infrastructure/common.sh

set -x
sshConf="/etc/ssh/sshd_config"

function turnOffPasswords() {
  checkConfigAndTurnOff "PasswordAuthentication yes" "PasswordAuthentication no"
  checkConfigAndTurnOff "ChallengeResponse yes" "ChallengeResponse no"
  checkConfigAndTurnOff "UsePAM yes" "UsePAM no"
}

function checkConfigAndTurnOff() {
  local token="$1"
  local offToken="$2"
  local sshConf="/etc/ssh/sshd_config"

  grep -q "${token}" ${sshConf} && \
     turnOffPasswordConfig "${token}" "${offToken}"
}

function turnOffPasswordConfig() {
  local token="$1"
  local offToken="$2"
  local sshConf="/etc/ssh/sshd_config"
  sed -i "s/${token}/${offToken}/" ${sshConf}
  systemctl reload ssh
}

turnOffPasswords
