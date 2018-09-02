#!/bin/bash

set -eu

. /root/infrastructure/common.sh

## TODO: slightly temporary to clean existing systems. Once this is run, we can skip this task.
rm -rf /root/.ssh/
