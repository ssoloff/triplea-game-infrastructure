#!/bin/bash

. /root/infrastructure/common.sh



while [ "$1" != "" ]; do
  PARAM=$1
  VALUE=$2
 
  case ${PARAM} in
    --port)
      PORT=${VALUE}
      ;;
    --tag-name)
      TAG_NAME=${VALUE}
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

checkArg PORT ${PORT}
checkArg TAG_NAME ${TAG_NAME}

DEST_FOLDER="/home/triplea/http_server/${TAG_NAME}"
/root/infrastructure/roles/http_server/tasks/install.sh ${DEST_FOLDER} ${TAG_NAME} ${PORT}
/root/infrastructure/roles/http_server/tasks/install_service_scripts.sh ${DEST_FOLDER}

chown -R triplea:triplea /home/triplea
service http-server start

sleep 3
checkServiceIsRunning http-server

checkPortIsOpen ${PORT}
