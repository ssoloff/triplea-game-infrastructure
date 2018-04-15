#!/bin/bash

set -e
. /root/infrastructure/common.sh

while [ "$1" != "" ]; do
  PARAM=$1
  VALUE=$2
  case ${PARAM} in
    --database-port)
      DB_PORT=${VALUE}
      ;;
    --tag-name)
      TAG_NAME="${VALUE}"
      ;;
     *)
      echo "ERROR: unknown parameter \"${PARAM}\""
      exit 1
      ;;
  esac
  shift
  shift
done

checkArg TAG_NAME ${TAG_NAME}
checkArg DB_PORT ${DB_PORT}

/root/infrastructure/roles/lobby_db/tasks/install_postgres.sh ${DB_PORT}
/root/infrastructure/roles/lobby_db/tasks/flyway.sh ${TAG_NAME}

checkServiceIsRunning postgresql
