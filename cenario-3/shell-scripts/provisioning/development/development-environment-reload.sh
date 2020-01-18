#!/bin/bash

echo "Shell script [development-environment-reload.sh] [$(date)]: Initialized"

# Check if script is running as root or sudo.
if [ "$(id -u)" -ne 0 ]; then
  echo "Shell script [development-environment-reload.sh] [$(date)]: Error - You need to execute this script as root/sudo"
  echo "Shell script [development-environment-reload.sh] [$(date)]: Aborted"
  exit 1
fi

# Check if script is running at same folder where it exists.
if [ "$(dirname $0)" != "." ]; then
  echo "Shell script [development-environment-reload.sh] [$(date)]: Error - You need to execute this command at same folder where it exists. Please, cd into the folder"
  echo "Shell script [development-environment-reload.sh] [$(date)]: Aborted"
  exit 1
fi

cd ../../../

echo "Shell script [development-environment-reload.sh] [$(date)]: Creating containers"
COMPOSE_HTTP_TIMEOUT=10000 && docker-compose up --build -d && sleep 360
echo "Shell script [development-environment-reload.sh] [$(date)]: Containers created"

echo "Shell script [development-environment-reload.sh] [$(date)]: Creating initial dummy data"
docker container exec -i $(docker-compose ps -q database) psql -U postgres -c "SELECT pg_terminate_backend(pg_stat_activity.pid) FROM pg_stat_activity WHERE datname = 'social_development';"
docker-compose exec application bundle exec rails provisioning:development:prepare
echo "Shell script [development-environment-reload.sh] [$(date)]: Initial dummy data created"

echo "Shell script [development-environment-reload.sh] [$(date)]: Finished"
