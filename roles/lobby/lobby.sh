#!/bin/bash



. /root/infrastructure/common.sh

CURL="curl -L"
RUN_LOBBY="/root/infrastructure/roles/lobby/files/run_lobby.sh"
REMOVE_LOBBY="/root/infrastructure/roles/lobby/files/remove_lobby.sh"
LOBBY_SERVICE_FILE="/root/infrastructure/roles/lobby/files/triplea-lobby.service"
POSITIONAL=()

TAG_NAME=
PORT=
DATABASE_PORT

while [[ $# -gt 0 ]]; do
  key="$1"

  case ${key} in
    --lobby-port)
    PORT="$2"
    shift # past argument
    shift # past value
    ;;
    --database-port)
    DATABASE_PORT="$2"
    shift # past argument
    shift # past value
    ;;
   --tag-name)
    TAG_NAME="$2"
    shift # past argument
    shift # past value
    ;;
    *)    # unknown option
    POSITIONAL+=("$1") # save it in an array for later
    shift # past argument
    ;;
  esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters


## TODO: arg check, if any are missing then report an error

echo "Lobby port: ${PORT}"
echo "Lobby database port: ${DATABASE_PORT}"
echo "Lobby version tag: ${TAG_NAME}"

set -eux

# Retrieve latest triplea version
if [[ "${TAG_NAME}" == "latest" ]]; then
  TAG_NAME=$($CURL -s 'https://api.github.com/repos/triplea-game/triplea/releases/latest' \
        | python3 -c "import sys, json; print(json.load(sys.stdin)['tag_name'])")
fi


function installLobby() {
  local destFolder={$1-}
  local tagName={$2-}

  mkdir -p ${destFolder}
  echo "$tagName" > ${destFolder}/version

  local installerFile="triplea-${tagName}.zip"
  $CURL "https://github.com/triplea-game/triplea/releases/download/${tagName}/triplea-${tagName}-server.zip" > ${installerFile}
  unzip -o -d ${destFolder} ${installerFile}
  rm ${installerFile}


  chmod go-rw ${destFolder}/config/lobby/lobby.properties

  cp ${RUN_LOBBY} ${destFolder}/
  cp ${REMOVE_LOBBY} ${destFolder}/
  chmod +x ${destFolder}/*.sh
}

## TODO: update database port + password
 ## todo: add lobby database port to props (do it outside of this method in case we are changing port)
function updateConfig() {
  local destFolder={$1-}

  local serviceFileDeployedPath="/lib/systemd/system/triplea-lobby.service"
  cp ${LOBBY_SERVICE_FILE} > ${serviceFileDeployedPath}
  sed -i "s|LOBBY_DIR|${destFolder}|" ${serviceFileDeployedPath}
  systemctl enable triplea-lobby
  systemctl daemon-reload
}


DESTINATION_FOLDER=/home/triplea/lobby/${TAG_NAME}
if [ ! -d "${DESTINATION_FOLDER}" ]; then
 report "Lobby ${TAG_NAME} update started"
 installLobby ${DESTINATION_FOLDER} ${TAG_NAME}
fi
updateConfig
chown -R triplea:triplea /home/triplea
report "Lobby ${TAG_NAME} update completed"

