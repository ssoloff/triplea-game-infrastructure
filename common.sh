
GITTER_TEST_ROOM="https://webhooks.gitter.im/e/21367d2247fd87a9255b"

SECRET_FILE="/home/triplea/secrets"


################################################################
## Reporting to Gitter
################################################################


## Sends a notification message to gitter
## @param $1 The message to post to gitter activity log.
function report {
  local ip=$(ip route get 1 | awk '{print $NF;exit}')
  local msg="${ip} $(hostname): ${1-}"
  curl -sd "message=${msg}" "$GITTER_TEST_ROOM"
}

## Sends an error message to gitter. Messages are posted to activity log
## in chat room (so does not flood chat), they should be short, error messages
## appear in red.
## @param $1 The error message String to be sent to gitter.
##      New line escape is not respected, msg is limited to single line.
function reportError {
  local ip=$(ip route get 1 | awk '{print $NF;exit}')
  local errMsg="${ip} $(hostname): ${1-}"
  curl -sd "message=${errMsg}" -d level=error "$GITTER_TEST_ROOM"
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

  local errorMsg="'$command' exit code $err at line $line"
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

################################################################
## Error checking
################################################################


function checkFile() {
  local file=$1
  if [ ! -f "${file}" ]; then
    reportError "File not found: ${file}"
    exit 1
  fi
}

function checkFolder() {
  local folder=$1
  if [ ! -d "${folder}" ]; then
    reportError "Folder not found: ${folder}"
    exit 1
  fi
}

function checkArg() {
  local argLabel=$1
  local argValue=${2-}
  if [ -z "${argValue}" ]; then
    reportError "Arg: ${argLabel}, needs to be specified"
    exit 1
  fi
}



function checkServiceIsRunning() {
  local serviceName=$1
  service "${serviceName}" status | grep "Active: active"  \
      || reportError"${serviceName} is NOT running"
}


function checkPortIsOpen() {
  local port=$1
  if [ -z "${port}" ]; then
    reportError "empty port param error"
    exit 1
  fi

  nc -z localhost ${port} || reportError "Port: ${port} is not open"
}


################################################################
## Reading from secrets file
# # Each host will have a file installed in a well known location
################################################################
function readSecret () {
  local secretKey=$1
  if [ ! -f ${SECRET_FILE} ]; then
    reportError "Secret file is missing: ${SECRET_FILE}"
    exit 1
  fi
  grep "${secretKey}" ${SECRET_FILE} | sed 's/.*=//'
}



################################################################
## Adding a user
################################################################
function installUser() {
  local user=$1

  grep -q ${user} /etc/passwd || adduser --disabled-password --gecos "" ${user}
  grep -q "^${user}" /etc/sudoers || echo "${user} ALL=(ALL) /usr/sbin/service ${user}" >> /etc/sudoers
  grep -q "^${user}.*htop" /etc/sudoers || echo "${user} ALL=(ALL) /usr/bin/htop*" >> /etc/sudoers
  grep -q "^${user}.*iftop" /etc/sudoers || echo "${user} ALL=(ALL) /usr/bin/iftop" >> /etc/sudoers

  mkdir -p /home/${user}/.ssh
  cat /root/infrastructure/root/files/triplea_user_authorized_keys \
      /root/infrastructure/root/files/root_user_authorized_keys > /home/${user}/.ssh/authorized_keys
  chmod 644 /home/${user}/.ssh/authorized_keys
}

################################################################
## Service file
################################################################

##
 # @param serviceName = name of the service to be installed, eg 'triplea-lobby'
 # @param localPath = the path in the git clone structure to the service file template,
 #    should begin with /root/infrastructure/...
 # @param installFolder = The location where we installed a service
 # @param  runCommand = A command relative to the installFolder used to start the service
 ##
function installService() {
  local serviceName=$1
  local localPath=$2
  local installFolder=$3
  local runCommand=$4

  local deployedFile="/lib/systemd/system/${serviceName}.service"
  cp -v ${localPath} ${deployedFile}

  sed -i "s|WorkingDirectory=.*|WorkingDirectory=${installFolder}|" ${deployedFile}
  sed -i "s|ExecStart=.*|ExecStart=${installFolder}/${runCommand}|" ${deployedFile}

  systemctl enable ${serviceName}
  systemctl daemon-reload
}

