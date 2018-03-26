#!/bin/bash
LOBBY_DB=/root/infrastructure/roles/lobby_db/lobby_db.sh
LOBBY=/root/infrastructure/roles/lobby/lobby.sh
BOT=/root/infrastructure/roles/bot/bot.sh

## note: lobby IP addresses are not secret, but bot IP and database IP addresses are secret

case "$(hostname)" in
  prerelease_staging)
    ${LOBBY_DB} --port 5000
    ${LOBBY} --port 7000 --database-port 5000 --tag-name "latest"
    ${BOT} --start_port 8000 --count 2 --lobby-port 7000
  ;;
  *)
    reportError "Unknown host: $(hostname)"
  ;;
esac
