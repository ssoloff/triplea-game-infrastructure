#!/bin/bash
HTTP_SERVER=/root/infrastructure/roles/http_server/http_server.sh
LOBBY_DB=/root/infrastructure/roles/lobby_db/lobby_db.sh
LOBBY=/root/infrastructure/roles/lobby/lobby.sh
BOT=/root/infrastructure/roles/bot/bot.sh
PROMETHEUS=/root/infrastructure/roles/support/prometheus/prometheus.sh
GRAFANA=/root/infrastructure/roles/support/grafana/grafana.sh

set -eu
. /root/infrastructure/common.sh

#LATEST_RELEASE=$(curl -s 'https://api.github.com/repos/triplea-game/triplea/releases/latest' \
#    | python3 -c "import sys, json; print(json.load(sys.stdin)['tag_name'])")

TEMP_FILE=$(tempfile)
curl  -sq 'https://api.github.com/repos/triplea-game/triplea/tags' | \
    grep "name" > $TEMP_FILE
LATEST_BUILD=$(cat $TEMP_FILE | sed 's/.*\.//' | sed 's/".*//' | sort -nr | head -1)
LATEST_TAG=$(grep ${LATEST_BUILD} $TEMP_FILE | sed 's/.* "//' | sed 's/".*$//')

PRERELEASE_LOBBY="66.175.213.79"
PRERELEASE_LOBBY_PORT="7000"
PRERELEASE_BOT_MEMORY=128

BOT_COUNT=3
BOT_MEMORY=168
PROD_BOT_VERSION="1.9.0.0.10663"
PROD_LOBBY_IP="45.79.144.53"
PROD_LOBBY_PORT="3304"
PROD_LOBBY_VERSION="1.9.0.0.10663"

case "$(hostname)" in
  tripleawarclub)
    ${LOBBY_DB} \
       --database-port 5432 \
       --tag-name ${PROD_LOBBY_VERSION}
    ${LOBBY} \
       --lobby-port 3304 \
       --database-port 5432 \
       --tag-name ${PROD_LOBBY_VERSION}
    ;;
  PreRelease)
    ${LOBBY_DB} \
       --database-port 5432 \
       --tag-name ${LATEST_TAG}
    ${LOBBY} \
       --lobby-port 7000 \
       --database-port 5432 \
       --tag-name ${LATEST_TAG}
    ${BOT} \
      --bot-name prerelease \
      --bot-port 8000 \
      --bot-start-number 9 \
      --bot-count 1 \
      --max-memory 128 \
      --lobby-port 7000 \
      --lobby-host 45.79.16.133 \
      --tag-name ${LATEST_TAG}
    ;;
  bot35_frankfurt_de)
    ${BOT} \
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
    ${BOT} \
      --bot-name ATLANTA_GA \
      --bot-port 8000 \
      --bot-start-number 4 \
      --bot-count 7 \
      --max-memory ${BOT_MEMORY} \
      --lobby-port ${PROD_LOBBY_PORT} \
      --lobby-host ${PROD_LOBBY_IP} \
      --tag-name ${PROD_BOT_VERSION}
    ;;
  bot55_london_uk)
    ${BOT} \
      --bot-name LONDON_UK \
      --bot-port 8000 \
      --bot-start-number 5 \
      --bot-count 7 \
      --max-memory ${BOT_MEMORY} \
      --lobby-port ${PROD_LOBBY_PORT} \
      --lobby-host ${PROD_LOBBY_IP} \
      --tag-name ${PROD_BOT_VERSION}
    ;;
  bot65_tokyo_jp)
    ${BOT} \
      --bot-name TOKYO_JP \
      --bot-port 8000 \
      --bot-start-number 6 \
      --bot-count 7 \
      --max-memory ${BOT_MEMORY} \
      --lobby-port ${PROD_LOBBY_PORT} \
      --lobby-host ${PROD_LOBBY_IP} \
      --tag-name ${PROD_BOT_VERSION}
    ;;
  infra-support)
    ${PROMETHEUS}
    ${GRAFANA}
    ;;
  *)
    reportError "Unknown host: $(hostname)"
  ;;
esac
