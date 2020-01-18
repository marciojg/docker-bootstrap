#!/bin/bash

echo "Shell script [development-application-update-dependencies.sh] [$(date)]: Initialized"

# Check if script is running as root or sudo.
if [ "$(id -u)" -ne 0 ]; then
  echo "Shell script [development-application-update-dependencies.sh] [$(date)]: Error - You need to execute this script as root/sudo"
  echo "Shell script [development-application-update-dependencies.sh] [$(date)]: Aborted"
  exit 1
fi

# Check if script is running at same folder where it exists.
if [ "$(dirname $0)" != "." ]; then
  echo "Shell script [development-application-update-dependencies.sh] [$(date)]: Error - You need to execute this command at same folder where it exists. Please, cd into the folder"
  echo "Shell script [development-application-update-dependencies.sh] [$(date)]: Aborted"
  exit 1
fi

cd ../../../
docker-compose exec application bundle install
docker-compose exec application bundle update
docker-compose exec application npm cache verify
docker-compose exec application yarn install
docker-compose exec application yarn upgrade

cd shell-scripts/provisioning/development
sh ./development-environment-restart.sh

echo "Shell script [development-application-update-dependencies.sh] [$(date)]: Finished"
