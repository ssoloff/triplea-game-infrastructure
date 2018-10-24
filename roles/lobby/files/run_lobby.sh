#!/bin/bash

RAM=${1:-'256M'}

cd $(dirname $0)
java -server -Xmx$RAM -Xms$RAM -jar bin/triplea-lobby-*-all.jar
