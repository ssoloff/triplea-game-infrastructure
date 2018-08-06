#!/bin/bash

while [ "$1" != "" ]; do
  PARAM=$1
  VALUE=$2
  case ${PARAM} in
    --bot-number)
      BOT_NUMBER=${VALUE}
      ;;
    --bot-name)
      BOT_NAME=${VALUE}
      ;;
    --bot-port)
      BOT_PORT=${VALUE}
      ;;
    --lobby-port)
      LOBBY_PORT=${VALUE}
      ;;
    --lobby-host)
      LOBBY_HOST=${VALUE}
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

BOT_FULL_NAME="${BOT_NAME}" ## must start with "Bot"
COMMENT="automated_host ${BOT_NUMBER}" ## must contain "automated_host"

if [[ -z "${BOT_PORT}" || -z "${BOT_NUMBER}" || -z "{$BOT_NAME}" || -z "${LOBBY_HOST}" \
    || -z "${LOBBY_PORT}" || -z "${MAX_MEMORY}" ]]; then
 echo "Missing parameter in: $@"
 exit 1
fi

cd "$(dirname $0)"
java -server -Xmx${MAX_MEMORY}m -Djava.awt.headless=true -classpath "bin/*" \
    games.strategy.engine.framework.headlessGameServer.HeadlessGameServer \
    -Ptriplea.game= \
    -Ptriplea.server=true \
    -Ptriplea.port=${BOT_PORT} \
    -Ptriplea.lobby.host=${LOBBY_HOST} \
    -Ptriplea.lobby.port=${LOBBY_PORT} \
    -Ptriplea.name=${BOT_FULL_NAME} \
    -Ptriplea.lobby.game.hostedBy=${BOT_FULL_NAME} \
    -Ptriplea.lobby.game.supportEmail=Nobody@hotmail123.com \
    -Ptriplea.lobby.game.comments="${COMMENT}" \
    -Ptriplea.lobby.game.reconnection=172800 \
    -PmapFolder=/home/triplea/maps
