#!/bin/bash

## If bot counts are being lowered, we'll disable the 'old' bots here.

BOT_COUNT=${1-}

set -eu

if [ -z "${BOT_COUNT}" ]; then
  echo "$0 requires one arg, number of bots that should be running, no parameters were provided."
  exit 1
fi

function disableOldBotFiles() {
  systemctl reset-failed triplea-bot@*.service # Cleanup crashed, non-existent bots from systemctl list-units

  # The regex below strips the bot number from the active service names
  # i.e. triplea-bot@12.service -> 12
  local botCount=$1
  for botNumber in \
      $(systemctl list-units triplea-bot@*.service --all --no-legend \
          | grep -Po "(?<=^triplea-bot@)\d+(?=\.service)"); do

    if (( botNumber > botCount )); then
      systemctl disable triplea-bot@$botNumber
    fi
  done
}

disableOldBotFiles $BOT_COUNT
