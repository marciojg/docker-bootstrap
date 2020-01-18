#!/bin/bash

echo "Shell script [development-database-import.sh] [$(date)]: Initialized"

# Check if script is running as root or sudo.
if [ "$(id -u)" -ne 0 ]; then
  echo "Shell script [development-database-import.sh] [$(date)]: Error - You need to execute this script as root/sudo"
  echo "Shell script [development-database-import.sh] [$(date)]: Aborted"
  exit 1
fi

# Check if script is running at same folder where it exists.
if [ "$(dirname $0)" != "." ]; then
  echo "Shell script [development-database-import.sh] [$(date)]: Error - You need to execute this command at same folder where it exists. Please, cd into the folder"
  echo "Shell script [development-database-import.sh] [$(date)]: Aborted"
  exit 1
fi

cd ../../../
docker container exec -i $(docker-compose ps -q database) psql -U postgres -c "SELECT pg_terminate_backend(pg_stat_activity.pid) FROM pg_stat_activity WHERE datname = 'database_name';"
docker container exec -i $(docker-compose ps -q database) psql -U postgres -c "DROP DATABASE database_name;"
docker container exec -i $(docker-compose ps -q database) psql -U postgres -c "CREATE DATABASE database_name;"
cat backup-of-development-database.sql | docker container exec -i $(docker-compose ps -q database) psql -U postgres -d database_name

echo "Shell script [development-database-import.sh] [$(date)]: Finished"
