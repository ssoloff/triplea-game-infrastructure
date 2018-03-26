#!/bin/bash

RAM=${1:-'256M'}

cd $(dirname $0)
java -server -Xmx$RAM -Xms$RAM -classpath "bin/*" games.strategy.engine.lobby.server.LobbyServer
