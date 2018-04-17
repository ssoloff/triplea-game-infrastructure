#!/bin/bash

## Sets up service and run files

. /root/infrastructure/common.sh

BOT_START_NUMBER=$1
BOT_COUNT=$2
BOT_NAME=$3
INSTALL_FOLDER=$4
LOBBY_HOST=$5
LOBBY_PORT=$6
MAX_MEMORY=$7

set -eu

checkArg LOBBY_PORT ${LOBBY_PORT}
BOT_FILE_ROOT="/root/infrastructure/roles/bot/files"

checkFolder ${BOT_FILE_ROOT}

function main() {
  installServiceFile ${INSTALL_FOLDER} ${BOT_NAME} ${LOBBY_HOST} ${LOBBY_PORT} ${BOT_START_NUMBER}
  installRunAndUninstallFiles
  createStartStopScripts ${BOT_COUNT}
}


function installServiceFile() {
  local installFolder=$1
  local botName=$2
  local lobbyHost=$3
  local lobbyPort=$4
  local startNumber=$5

  local botActualName="Bot${startNumber}%i_${botName}"
  cat > /lib/systemd/system/triplea-bot@.service <<EOF
[Unit]
Description=TripleA Bot %i
Documentation=https://github.com/triplea-game/lobby/blob/master/README.md

[Service]
Environment=
WorkingDirectory=${installFolder}
User=triplea
ExecStart=${installFolder}/run_bot.sh --max-memory ${MAX_MEMORY} --bot-port 40%i --bot-number %i --bot-name ${botActualName} --lobby-host ${lobbyHost} --lobby-port ${lobbyPort}
Restart=always

[Install]
WantedBy=multi-user.target

EOF

}


function installRunAndUninstallFiles() {
  cp ${BOT_FILE_ROOT}/run_bot.sh ${INSTALL_FOLDER}/
  cp ${BOT_FILE_ROOT}/uninstall_bot.sh ${INSTALL_FOLDER}/
}

function createStartStopScripts() {
  local botCount=$1

  rm -f /home/triplea/start_all /home/triplea/stop_all /home/triplea/restart_all

  for i in $(seq -w 01 ${botCount}); do
    local botNumber=${i}
    local botPort="40${botNumber}"

    ufw allow ${botPort}

    systemctl enable triplea-bot@${botNumber}
    echo "sudo service triplea-bot@${botNumber} restart" > /home/triplea/restart_bot_${botNumber}
    echo "sudo service triplea-bot@${botNumber} restart" >> /home/triplea/restart_all
    echo "sudo service triplea-bot@${botNumber} start" >> /home/triplea/start_all
    echo "sudo service triplea-bot@${botNumber} stop" >> /home/triplea/stop_all
  done
  ufw reload
  chmod +x /home/triplea/stop_bot* /home/triplea/start_bot* /home/triplea/restart_bot*
  chmod +x /home/triplea/start_all /home/triplea/stop_all
}

main
systemctl daemon-reload
