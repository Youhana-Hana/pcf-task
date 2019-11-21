#!/bin/bash
set -e

mvn -DskipTests=true clean package

APP_NAME=$1

# deploy the app
cf push -b java_buildpack --health-check-type none -p target/*.jar -i 0 --no-route ${APP_NAME}

cf stop ${APP_NAME}
