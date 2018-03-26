
GITTER_TEST_ROOM="https://webhooks.gitter.im/e/21367d2247fd87a9255b"



################################################################
## Reporting to Gitter
################################################################


## Sends a notification message to gitter
## @param $1 The message to post to gitter activity log.
function report {
  local msg="$(hostname): ${1-}"
  curl -d "message=${msg}" "$GITTER_TEST_ROOM"
}

## Sends an error message to gitter. Messages are posted to activity log
## in chat room (so does not flood chat), they should be short, error messages
## appear in red.
## @param $1 The error message String to be sent to gitter.
##      New line escape is not respected, msg is limited to single line.
function reportError {
  local ip=$(ip route get 1 | awk '{print $NF;exit}')
  local errMsg="${ip}:$(hostname): ${1-}"
  curl -d "message=${errMsg}" -d level=error "$GITTER_TEST_ROOM"
}


################################################################
## Error Handling
################################################################


## Set up error trap to report script errors to gitter activity log

set -o errtrace
trap 'traperror $? $LINENO $BASH_LINENO "$BASH_COMMAND" $(printf "::%s" ${FUNCNAME[@]})'  ERR

traperror () {
  local err=${1-} # error status
  local line=${2-} # LINENO
  local linecallfunc=${3-}
  local command="${4-}"
  local funcstack="${5-}"

  local errorMsg="ERROR@Line:$line '$command' exit code: $err"
  if [ "$funcstack" != "::" ]; then
    errorMsg="$errorMsg   ... at ${funcstack} "
    if [ "$linecallfunc" != "" ]; then
      errorMsg="$errorMsg called at line $linecallfunc"
    fi
  else
    errorMsg="$errorMsg  ... internal debug info from function ${FUNCNAME} (line $linecallfunc)"
  fi
  reportError "$errorMsg"
}

