#!/bin/bash

echo "Shell script [development-application-debug.sh] [$(date)]: Initialized"

# Check if script is running as root or sudo.
if [ "$(id -u)" -ne 0 ]; then
  echo "Shell script [development-application-debug.sh] [$(date)]: Error - You need to execute this script as root/sudo"
  echo "Shell script [development-application-debug.sh] [$(date)]: Aborted"
  exit 1
fi

# Check if script is running at same folder where it exists.
if [ "$(dirname $0)" != "." ]; then
  echo "Shell script [development-application-debug.sh] [$(date)]: Error - You need to execute this command at same folder where it exists. Please, cd into the folder"
  echo "Shell script [development-application-debug.sh] [$(date)]: Aborted"
  exit 1
fi

cd ../../../
docker container exec -it $(docker-compose ps -q application) bundle exec byebug -R localhost:8989

echo "Shell script [development-application-debug.sh] [$(date)]: Finished"
