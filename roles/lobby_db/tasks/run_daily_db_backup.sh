#!/bin/bash

set -eu

. /root/infrastructure/common.sh

 ## this is a remote server where we will copy a log of the dump file.
 ## In this case if we lose database server we will not also lose the backup dump files.
BACKUP_SERVER="172.104.27.19"
DB_NAME="ta_users"
BACKUP_FOLDER=/home/admin/db_backups/
mkdir -p "$BACKUP_FOLDER"

SECRET_FILE=/home/triplea/secrets

YEAR=$(date +%Y)
MONTH=$(date +%m)
DAY=$(date +%d)

BACKUP_FILE_NAME="${DB_NAME}_backup-${YEAR}-${MONTH}-${DAY}.pg_dump"
BACKUP_FILE="${BACKUP_FOLDER}/${BACKUP_FILE_NAME}"

## if the backup file exists, our job has already run
if [ -e "$BACKUP_FILE" ]; then
  echo "Daily DB backup file ${BACKUP_FILE} exists, skipping DB backup"
  ## TODO: would be excellent to put a size check here, and give a loud warning and exit 1
  ## if the dump file size is 0.
  exit 0
fi

## here we read the db_user and db_password values from secrets file
DB_USER=$(grep "db_user" "$SECRET_FILE" | sed "s/^db_user=//")
DB_PASS=$(grep "db_password" "$SECRET_FILE" | sed "s/^db_password=//")
echo "Saving DB backup to: ${BACKUP_FILE}"
 ## runs a pg_dump which saves a copy of the database to the backup file
PGPASSWORD="${DB_PASS}" pg_dump -U postgres -h localhost "$DB_NAME" > "$BACKUP_FILE"
 ## ensure admin owns the db dump file so admin user could restore it.
chown -R admin:admin "$BACKUP_FOLDER"

 ## Copy the backup file to a remote server
ssh -o StrictHostKeyChecking=no ${BACKUP_SERVER} "mkdir -p ${BACKUP_FOLDER}"
REMOTE_FILE="${BACKUP_FOLDER}/$(hostname)_$BACKUP_FILE_NAME}"
scp -o StrictHostKeyChecking=no ${BACKUP_FILE} ${BACKUP_SERVER}:${REMOTE_FILE}


 ## Remove backup files older than 30 days
find "${BACKUP_FOLDER}" -mtime +30 -type f -delete
ssh -o StrictHostKeyChecking=no ${BACKUP_SERVER} "find ${BACKUP_FOLDER} -mtime +30 -type f -delete"
