#!/bin/bash

set -eu
. /root/infrastructure/common.sh

PROD_LOBBY_IP="45.79.144.53"
PROD_LOBBY_PORT="3304"
PROD_LOBBY_VERSION="1.9.0.0.10663"

PROD_BOT_VERSION="1.9.0.0.10663"
PROD_BOT_MEMORY="168"
PROD_BOT_COUNT="7"

# pre-prod dynamically determines latest version
PRE_PROD_LOBBY_IP="45.79.16.133"
PRE_PROD_LOBBY_PORT="7000"

DB_PORT="5432"


LOBBY_DB="/root/infrastructure/roles/lobby_db/lobby_db.sh --database-port ${DB_PORT}"
LOBBY="/root/infrastructure/roles/lobby/lobby.sh --database-port ${DB_PORT}"
BOT=/root/infrastructure/roles/bot/bot.sh
PROMETHEUS=/root/infrastructure/roles/support/prometheus/prometheus.sh
GRAFANA=/root/infrastructure/roles/support/grafana/grafana.sh


PROD_BOT="${BOT} \
    --bot-port ${PROD_BOT_COUNT} \
    --bot-count ${PROD_BOT_COUNT} \
    --max-memory ${PROD_BOT_MEMORY}  \
    --lobby-port ${PROD_LOBBY_PORT} \
    --lobby-host ${PROD_LOBBY_IP} \
    --tag-name ${PROD_BOT_VERSION}"

TEMP_FILE=$(tempfile)
# delete temp file on any exit event
trap '{ rm -f ${TEMP_FILE}; }' EXIT

## download github API data so we can scrape latest version information
curl  -sq 'https://api.github.com/repos/triplea-game/triplea/tags' | \
    grep "name" > $TEMP_FILE
LATEST_BUILD=$(cat $TEMP_FILE | sed 's/.*\.//' | sed 's/".*//' | sort -nr | head -1)
LATEST_TAG=$(grep ${LATEST_BUILD} $TEMP_FILE | sed 's/.* "//' | sed 's/".*$//')

PRE_PROD_BOT="${BOT} \
      --bot-port 8000 \
      --bot-count 1 \
      --max-memory 128 \
      --lobby-port ${PRE_PROD_LOBBY_PORT} \
      --lobby-host ${PRE_PROD_LOBBY_IP} \
      --tag-name ${LATEST_TAG}"

case "$(hostname)" in
  tripleawarclub)
    ${LOBBY_DB} \
       --tag-name ${PROD_LOBBY_VERSION}
    ${LOBBY} \
       --lobby-port ${PROD_LOBBY_PORT} \
       --tag-name ${PROD_LOBBY_VERSION}
    ;;
  PreRelease)
    ${LOBBY_DB} \
       --database-port 5432 \
       --tag-name ${LATEST_TAG}
    ${LOBBY} \
       --lobby-port ${PRE_PROD_LOBBY_PORT} \
       --tag-name ${LATEST_TAG}
    ${PRE_PROD_BOT} \
      --bot-name prerelease \
      --bot-start-number 9;
    ;;
  bot35_frankfurt_de)
    ${PROD_BOT} \
      --bot-name FRANKFURT_DE \
      --bot-port 8000 \
      --bot-start-number 3 \
      --bot-count 7 \
      --max-memory ${BOT_MEMORY} \
      --lobby-port ${PROD_LOBBY_PORT} \
      --lobby-host ${PROD_LOBBY_IP} \
      --tag-name ${PROD_BOT_VERSION}
    ;;
  bot45_atlanta_ga)
    ${PROD_BOT} \
      --bot-name ATLANTA_GA \
      --bot-start-number 4
    ;;
  bot55_london_uk)
    ${PROD_BOT} \
      --bot-name LONDON_UK \
      --bot-start-number 5
    ;;
  bot65_tokyo_jp)
    ${PROD_BOT} \
      --bot-name TOKYO_JP \
      --bot-start-number 6
    ;;
  infra-support)
    ${PROMETHEUS}
    ${GRAFANA}
    ;;
  *)
    reportError "Unknown host: $(hostname)"
  ;;
esac
