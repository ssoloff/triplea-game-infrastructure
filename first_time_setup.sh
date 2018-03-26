#!/bin/bash

set -eux
sudo apt-get install -y git
rm -rf infrastructure
git clone https://github.com/DanVanAtta/infrastructure.git
