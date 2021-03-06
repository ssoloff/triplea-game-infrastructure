#!/bin/bash

set -eu
. /root/infrastructure/common.sh

## Role installation scripts, each role roughly maps to an application.
LOBBY_DB=/root/infrastructure/roles/lobby_db/lobby_db.sh
LOBBY="/root/infrastructure/roles/lobby/lobby.sh --database-port 5432"
HTTP_SERVER=/root/infrastructure/roles/http_server/http_server.sh
BOT=/root/infrastructure/roles/bot/bot.sh
PROMETHEUS=/root/infrastructure/roles/support/prometheus/prometheus.sh
GRAFANA=/root/infrastructure/roles/support/grafana/grafana.sh


## Production constants/configuration

PROD_LOBBY_IP="45.79.144.53"
PROD_LOBBY_PORT="3304"
PROD_LOBBY_VERSION="1.9.0.0.11996"
PROD_BOT_VERSION="1.9.0.0.12226"

TEMP_FILE=$(tempfile)
# delete temp file on any exit event
trap '{ rm -f ${TEMP_FILE}; }' EXIT

## download repo data from github API data so we can scrape latest version information
curl  -sq 'https://api.github.com/repos/triplea-game/triplea/tags' | \
    grep "name" > "${TEMP_FILE}"
LATEST_BUILD=$(sed 's/.*\.//' "$TEMP_FILE" | sed 's/".*//' | sort -nr | head -1)
LATEST_TAG=$(grep "${LATEST_BUILD}" "$TEMP_FILE" | sed 's/.* "//' | sed 's/".*$//')

PRE_PROD_LOBBY_IP="45.79.16.133"
PRE_PROD_LOBBY_PORT="7000"

PROD_BOT="${BOT} \
    --bot-port 8000 \
    --bot-count 7 \
    --max-memory 168 \
    --lobby-host ${PROD_LOBBY_IP} \
    --lobby-port ${PROD_LOBBY_PORT} \
    --tag-name ${PROD_BOT_VERSION}"

PRE_PROD_BOT="${BOT} \
      --bot-port 8000 \
      --bot-count 1 \
      --max-memory 128 \
      --lobby-host ${PRE_PROD_LOBBY_IP} \
      --lobby-port ${PRE_PROD_LOBBY_PORT} \
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
    ## we'll restart services if installing a new version (preprod only)
    NEW_VERSION=0
    if [ ! -d "/home/triplea/lobby/${LATEST_TAG}" ]; then
      NEW_VERSION=1
    fi
    ${LOBBY_DB} \
       --tag-name ${LATEST_TAG}
    ${LOBBY} \
       --tag-name ${LATEST_TAG} \
       --lobby-port ${PRE_PROD_LOBBY_PORT}
    ${PRE_PROD_BOT} \
      --bot-name prerelease \
      --bot-start-number 9;
    if [ $NEW_VERSION -eq 1 ]; then
      service triplea-lobby restart
      service triplea-bot@01 restart
    fi
    ;;
  bot35_frankfurt_de)
    ${PROD_BOT} \
      --bot-name FRANKFURT_DE \
      --bot-start-number 3
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
    report "Latest system updates applied, no host roles to apply"
  ;;
esac
