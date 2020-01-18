#!/bin/bash

echo "Shell script [development-application-edit-credentials.sh] [$(date)]: Initialized"

# Check if script is running as root or sudo.
if [ "$(id -u)" -ne 0 ]; then
  echo "Shell script [development-application-edit-credentials.sh] [$(date)]: Error - You need to execute this script as root/sudo"
  echo "Shell script [development-application-edit-credentials.sh] [$(date)]: Aborted"
  exit 1
fi

# Check if script is running at same folder where it exists.
if [ "$(dirname $0)" != "." ]; then
  echo "Shell script [development-application-edit-credentials.sh] [$(date)]: Error - You need to execute this command at same folder where it exists. Please, cd into the folder"
  echo "Shell script [development-application-edit-credentials.sh] [$(date)]: Aborted"
  exit 1
fi

cd ../../../
docker-compose exec application /bin/bash -c "rm -f config/credentials.yml.enc && cp config/credentials.yml.enc.development config/credentials.yml.enc"
docker-compose exec application /bin/bash -c "bundle exec rails credentials:edit"
docker-compose exec application /bin/bash -c "rm -f config/credentials.yml.enc.development && cp config/credentials.yml.enc config/credentials.yml.enc.development"

cd shell-scripts/provisioning/development
sh ./development-environment-restart.sh

echo "Shell script [development-application-edit-credentials.sh] [$(date)]: Attention - You MUST commit the changes in 'config/credentials.yml.development' file to make it permanently"

echo "Shell script [development-application-edit-credentials.sh] [$(date)]: Finished"
