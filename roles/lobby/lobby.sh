#!/bin/bash

CURL="curl -L"
RUN_LOBBY="/root/infrastructure/triplea/lobby/files/run_lobby.sh"
RUN_LOBBY="/root/infrastructure/triplea/lobby/files/remove_lobby.sh"

POSITIONAL=()
while [[ $# -gt 0 ]]; do
  key="$1"

  case $key in
    -p|--port)
    PORT="$2"
    shift # past argument
    shift # past value
    ;;
    --database-port)
    DATABASE_PORT="$2"
    shift # past argument
    shift # past value
   --tag-name)
    TAG_NAME="$2"
    shift # past argument
    shift # past value
    ;;

    ;;
    *)    # unknown option
    POSITIONAL+=("$1") # save it in an array for later
    shift # past argument
    ;;
  esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters


echo "Lobby port: ${PORT}"
echo "Lobby database port: ${DATABASE_PORT}"
echo "Lobby version tag: ${TAG_NAME}"

# Retrieve latest triplea version
if [[ "TAG_NAME" == "latest" ]]; then
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
  unzip -o -d $destFolder ${installerFile}
  rm ${installerFile}


## todo: add lobby database port to props
  chmod go-rw ${destFolder}/config/lobby/lobby.properties

  cp ${RUN_LOBBY} ${destFolder}/
  cp ${REMOVE_LOBBY} ${destFolder}/
  chmod +x ${destFolder}/*.sh



  $CURL $SERVICE_FILE_URL > $SERVICE_FILE_PATH
  sed -i "s|LOBBY_DIR|$DESTINATION_FOLDER|" $SERVICE_FILE_PATH

  systemctl enable triplea-lobby
  systemctl daemon-reload

  chown -R triplea:triplea /home/triplea
}


DESTINATION_FOLDER=${DESTINATION_FOLDER}/${TAG_NAME}
if [ ! -d "${DESTINATION_FOLDER}" ]; then
 report "Lobby ${TAG_NAME} install started"
 installLobby ${DESTINATION_FOLDER} ${TAG_NAME}
 report "Lobby ${TAG_NAME} install completed"
fi

