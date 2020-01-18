#!/bin/bash

echo "Shell script [development-database-backup.sh] [$(date)]: Initialized"

# Check if script is running as root or sudo.
if [ "$(id -u)" -ne 0 ]; then
  echo "Shell script [development-database-backup.sh] [$(date)]: Error - You need to execute this script as root/sudo"
  echo "Shell script [development-database-backup.sh] [$(date)]: Aborted"
  exit 1
fi

# Check if script is running at same folder where it exists.
if [ "$(dirname $0)" != "." ]; then
  echo "Shell script [development-database-backup.sh] [$(date)]: Error - You need to execute this command at same folder where it exists. Please, cd into the folder"
  echo "Shell script [development-database-backup.sh] [$(date)]: Aborted"
  exit 1
fi

cd ../../../
rm -f backup-of-development-database.sql
docker container exec -u postgres $(docker-compose ps -q database) pg_dump social_development > backup-of-development-database.sql

echo "Shell script [development-database-backup.sh] [$(date)]: Finished"
