#!/bin/bash

cd $(dirname $0)
java -cp ./bin/http-server-TAG_NAME-all.jar org.triplea.server.http.spark.SparkServer
