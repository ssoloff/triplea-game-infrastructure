#!/bin/bash
LOBBY_DB=/root/infrastructure/roles/lobby_db/lobby_db.sh
LOBBY=/root/infrastructure/roles/lobby/lobby.sh
BOT=/root/infrastructure/roles/bot/bot.sh
SUPPORT=/root/infrastructure/roles/support/support.sh

set -eux
## note: lobby IP addresses are not secret, but bot IP and database IP addresses are secret


LATEST=$(curl -s 'https://api.github.com/repos/triplea-game/triplea/releases/latest' \
    | python3 -c "import sys, json; print(json.load(sys.stdin)['tag_name'])")

case "$(hostname)" in
  prerelease_staging)
    ${LOBBY_DB} --port=5000 --tag-name=${LATEST}
    ${LOBBY} --lobby-port 7000 --database-port 5000 --tag-name ${LATEST}
    ${BOT} --start_port 8000 --count 2 --lobby-port 7000 --tag-name ${LATEST}
    ;;
  infra-support)
    ${SUPPORT}
    ;;
  *)
    reportError "Unknown host: $(hostname)"
  ;;
esac
