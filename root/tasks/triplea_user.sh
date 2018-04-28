#!/bin/bash

set -eu

. /root/infrastructure/common.sh

## triplea user is the 'application' user. It is used to run application and is aware of DB password. We should
## never really need to switch to this user, either 'root' or 'admin' depending on access levels needed.

installUser triplea
