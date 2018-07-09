#!/bin/bash

. /root/infrastructure/common.sh

while [ "$1" != "" ]; do
  PARAM=$1
  VALUE=$2
  case ${PARAM} in
    --bot-name)
      BOT_NAME=${VALUE}
      ;;
    --bot-port)
      BOT_PORT=${VALUE}
      ;;
    --bot-start-number)
      BOT_START_NUMBER=${VALUE}
      ;;
    --bot-count)
      BOT_COUNT=${VALUE}
      ;;
    --lobby-port)
      LOBBY_PORT=${VALUE}
      ;;
    --lobby-host)
      LOBBY_HOST=${VALUE}
      ;;
    --tag-name)
      TAG_NAME=${VALUE}
      ;;
    --max-memory)
      MAX_MEMORY=${VALUE}
      ;;
     *)
      echo "ERROR: unknown parameter \"${PARAM}\""
      exit 1
      ;;
  esac
  shift
  shift
done

set -eu

checkArg BOT_NAME ${BOT_NAME}
checkArg BOT_PORT ${BOT_PORT}
checkArg BOT_START_NUMBER ${BOT_START_NUMBER}
checkArg BOT_COUNT ${BOT_COUNT}
checkArg TAG_NAME ${TAG_NAME}
checkArg LOBBY_PORT ${LOBBY_PORT}
checkArg LOBBY_HOST ${LOBBY_HOST}
checkArg MAX_MEMORY ${MAX_MEMORY}


function installService() {
  /root/infrastructure/roles/bot/tasks/install_service_files.sh \
    ${BOT_START_NUMBER} \
    ${BOT_COUNT} \
    ${BOT_NAME} \
    ${INSTALL_FOLDER} \
    ${LOBBY_HOST} \
    ${LOBBY_PORT} \
    ${MAX_MEMORY}
}

function installBinaries() {
  /root/infrastructure/roles/bot/tasks/install_binaries.sh ${TAG_NAME}
}

function disableOldBots() {
  /root/infrastructure/roles/bot/tasks/disable_old_bots.sh ${BOT_COUNT}
}

mkdir -p /home/triplea/bots/
INSTALL_FOLDER=/home/triplea/bots/${TAG_NAME}

## if the install folder is not present then we will install
if [ ! -d "${INSTALL_FOLDER}" ]; then
  installBinaries
  installService
  ## we are running as root, so let's make sure we keep perms to the triplea user
  chown -R triplea:triplea /home/triplea

  ## after having done an install, call restart to launch bots to the new version
  for i in $(seq -w 01 ${BOT_COUNT}); do
    service triplea-bot@${i} restart
  done
else
  ## always update the service configuration scripts, even if we have already installed binaries.
  installService
fi

disableOldBots
  
## Download all maps for the bot.
/root/infrastructure/roles/bot/tasks/update_maps.sh
chown -R triplea:triplea /home/triplea

## Start up all of the bots
for i in $(seq -w 01 ${BOT_COUNT}); do
  service triplea-bot@${i} start
done


BOT_RUN_COUNT=$(systemctl list-units triplea-bot@*.service --all --no-legend | grep active | grep -c "running")

report "Running ${BOT_RUN_COUNT} bots at version ${TAG_NAME}"
