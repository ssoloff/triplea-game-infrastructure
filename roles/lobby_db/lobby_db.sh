#!/bin/bash

set -ex
. /root/infrastructure/common.sh

while [ "$1" != "" ]; do
    PARAM=`echo $1 | awk -F= '{print $1}'`
    VALUE=`echo $1 | awk -F= '{print $2}'`
    case $PARAM in
        -h | --help)
            usage
            exit
            ;;
        --tag-name)
            TAG=$VALUE
            ;;
        --port)
            DB_PORT=$VALUE
            ;;
        *)
            echo "ERROR: unknown parameter \"$PARAM\""
            usage
            exit 1
            ;;
    esac
    shift
done

if [ -z "${DB_PORT}" ]; then
  reportError "DB port was not set"
  exit 1
fi

if [ -z "${TAG}" ]; then
  reportError "Tag was not set"
  exit 1
fi

/root/infrastructure/roles/lobby_db/tasks/install_postgres.sh ${DB_PORT}
/root/infrastructure/roles/lobby_db/tasks/flyway.sh ${TAG}

