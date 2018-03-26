#!/bin/bash
LOBBY_DB=/root/infrastructure/triplea/lobby_db.sh
LOBBY=/root/infrastructure/triplea/lobby.sh
BOT=/root/infrastructure/triplea/bot.sh

case "$(hostname)" in
  prerelease_staging) # 66.175.213.79
    ${LOBBY_DB} --port=5000
    ${LOBBY} --port=7000 --db=
    ${BOT} --start_port=8000 --count=2
  ;;
  *)
    reportError "Unknown host: $(hostname)"
  ;;
esac
