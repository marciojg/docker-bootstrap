#!/bin/bash

echo "Shell script [development-environment-create.sh] [$(date)]: Initialized"

# Check if script is running as root or sudo.
if [ "$(id -u)" -ne 0 ]; then
  echo "Shell script [development-environment-create.sh] [$(date)]: Error - You need to execute this script as root/sudo"
  echo "Shell script [development-environment-create.sh] [$(date)]: Aborted"
  exit 1
fi

# Check if script is running at same folder where it exists.
if [ "$(dirname $0)" != "." ]; then
  echo "Shell script [development-environment-create.sh] [$(date)]: Error - You need to execute this command at same folder where it exists. Please, cd into the folder"
  echo "Shell script [development-environment-create.sh] [$(date)]: Aborted"
  exit 1
fi

cd ../../../

echo "Shell script [development-environment-create.sh] [$(date)]: Destroying previous environment"
docker container rm name_of_project_sentry_cron name_of_project_sentry_worker-1 name_of_project_sentry_redis name_of_project_sentry_postgres sentry --force
docker-compose down --volumes --remove-orphans
rm -Rf tmp/* log/* node_modules/ ldap_server/ public/uploads/ public/packs/ config/credentials.yml.enc config/master.key*
echo "Shell script [development-environment-create.sh] [$(date)]: Previous environment destroyed"

echo "Shell script [development-environment-create.sh] [$(date)]: Creating environment"

echo "Shell script [development-environment-create.sh] [$(date)]: Creating LDAP configuration file"
mkdir -p ldap_server
cat >> ldap_server/user.ldif <<EOL
dn: uid=admin,dc=example,dc=org
uid: admin
cn: admin
sn: 3
objectClass: top
objectClass: posixAccount
objectClass: inetOrgPerson
loginShell: /bin/bash
homeDirectory: /home/admin
uidNumber: 14583102
gidNumber: 14564100
userPassword: admin
mail: admin@lbv.org.br
gecos: admin
EOL
echo "Shell script [development-environment-create.sh] [$(date)]: LDAP configuration file created"

echo "Shell script [development-environment-create.sh] [$(date)]: Copying credentials"
rm -f config/credentials.yml.enc && cp config/credentials.yml.enc.development config/credentials.yml.enc
echo "Shell script [development-environment-create.sh] [$(date)]: Credentials copied"

echo "Shell script [development-environment-create.sh] [$(date)]: Creating containers"
COMPOSE_HTTP_TIMEOUT=10000 && docker-compose up --build -d && sleep 360
echo "Shell script [development-environment-create.sh] [$(date)]: Containers created"

echo "Shell script [development-environment-create.sh] [$(date)]: Environment created"

echo "Shell script [development-environment-create.sh] [$(date)]: Creating initial LDAP user"
docker-compose exec ldap_server ldapadd -D "cn=admin,dc=example,dc=org" -w admin -f /container/service/slapd/assets/test/user.ldif
echo "Shell script [development-environment-create.sh] [$(date)]: Initial LDAP user created"

echo "Shell script [development-environment-create.sh] [$(date)]: Creating initial dummy data"
docker-compose exec application bundle exec rails provisioning:development:prepare
echo "Shell script [development-environment-create.sh] [$(date)]: Initial dummy data created"

echo "Shell script [development-environment-create.sh] [$(date)]: Creating Sentry containers"
docker run -d --restart always --name name_of_project_sentry_redis redis
docker run -d --restart always --name name_of_project_sentry_postgres -e POSTGRES_PASSWORD=postgres -e POSTGRES_USER=postgres postgres
sentry_secret_key=$(docker run --rm sentry config generate-secret-key)
docker run -it --rm -e SENTRY_SECRET_KEY="$sentry_secret_key" --link name_of_project_sentry_postgres:postgres --link name_of_project_sentry_redis:redis sentry upgrade
docker run -d --restart always --name sentry -p 3007:9000 -e SENTRY_SECRET_KEY="$sentry_secret_key" --link name_of_project_sentry_redis:redis --link name_of_project_sentry_postgres:postgres sentry
docker run -d --restart always --name name_of_project_sentry_cron -e SENTRY_SECRET_KEY="$sentry_secret_key" --link name_of_project_sentry_postgres:postgres --link name_of_project_sentry_redis:redis sentry run cron
docker run -d --restart always --name name_of_project_sentry_worker-1 -e SENTRY_SECRET_KEY="$sentry_secret_key" --link name_of_project_sentry_postgres:postgres --link name_of_project_sentry_redis:redis sentry run worker
docker network connect $(docker container inspect $(docker-compose ps -q application) -f "{{range .NetworkSettings.Networks}}{{.NetworkID}}{{end}}") sentry
echo "Shell script [development-environment-create.sh] [$(date)]: Sentry containers created"

echo ""
echo ""
echo ""
echo "--------------------------------------------------------"
echo "-                         Social                       -"
echo "--------------------------------------------------------"
echo ""
echo "Your environment was provisioned! Now, you can access:"
echo ""
echo "Application                -> http://localhost:3000"
echo "LDAP administration UI     -> https://localhost:3001"
echo "LDAP server                -> http://localhost:3002"
echo "Database administration UI -> http://localhost:3003"
echo "Database server            -> http://localhost:3004"
echo "Mailer UI                  -> http://localhost:3005"
echo "Mailer server              -> http://localhost:3006"
echo "Sentry                     -> http://localhost:3007"
echo "Metabase                   -> http://localhost:3008"
echo "Webpack dev server         -> http://localhost:3035"
echo "Webpack bundle analyzer UI -> http://localhost:3009"
echo "Byebug server              -> http://localhost:8989"
echo ""
echo "--------------------------------------------------------"
echo ""
echo "Application"
echo ""
echo "To login into application, use the following credential:"
echo "  > User: admin"
echo "  > Password: admin"
echo ""
echo "--------------------------------------------------------"
echo ""
echo "LDAP administration UI"
echo ""
echo "To login into LDAP administration UI, use the following"
echo "credential:"
echo "  > User: cn=admin,dc=example,dc=org"
echo "  > Password: admin"
echo ""
echo "--------------------------------------------------------"
echo ""
echo "Database administration UI"
echo ""
echo "To login into database administration UI, use the"
echo "following credential:"
echo "  > Email: admin@lbv.org.br"
echo "  > Password: admin"
echo ""
echo "--------------------------------------------------------"
echo ""
echo "Rails Credentials"
echo ""
echo "To edit Rails credentials, execute the following command "
echo "below:"
echo "  > cd shell-scripts/provisioning/development/"
echo "  > sudo sh ./development-application-edit-credentials.sh"
echo ""
echo "Then, restart the environment, to ensure that all new"
echo "credentials will be loaded and used correctly."
echo ""
echo "--------------------------------------------------------"
echo ""
echo "Sentry - Backend"
echo ""
echo "Login into Sentry with the credentials defined during the"
echo "script execution."
echo "Create a Rails project via Sentry UI, copy the generated"
echo "DSN and fill the credential 'sentry_backend_dsn' inside"
echo "'config/credentials.yml.enc' file, with the value in the"
echo "following format:"
echo "  > sentry_backend_dsn: http://[SECRET1]:[SECRET2]@sentry:9000/[PROJECT-ID] (without quotes)"
echo ""
echo "--------------------------------------------------------"
echo ""
echo "Sentry - Frontend"
echo ""
echo "Login into Sentry with the credentials defined during"
echo "the script execution."
echo "Create a Javascript project via Sentry UI, copy the"
echo "generated DSN and fill the credential 'sentry_frontend_dsn'"
echo "inside 'config/credentials.yml.enc' file, with the value"
echo "in the following format:"
echo "  > sentry_frontend_dsn: http://[SECRET]@localhost:3007/[PROJECT-ID] (without quotes)"
echo ""
echo "--------------------------------------------------------"
echo ""
echo "Metabase"
echo ""
echo "Create credentials for Metabase and login inside it."
echo "Then, connect to the project database and fill the"
echo "credential 'metabase_secret_key' inside"
echo "'config/credentials.yml.enc' file, with the value in the"
echo "following format:"
echo "  > metabase_secret_key: secret-generated-by-metabase (without quotes)"
echo ""
echo "--------------------------------------------------------"
echo ""
echo "Backup/import of database"
echo ""
echo "To backup the database, execute the command below:"
echo "  > cd shell-scripts/provisioning/development/"
echo "  > sudo sh ./development-database-backup.sh"
echo ""
echo "To import the database, execute the command below:"
echo "  > cd shell-scripts/provisioning/development/"
echo "  > sudo sh ./development-database-import.sh"
echo ""
echo "--------------------------------------------------------"
echo ""
echo "Rails console"
echo ""
echo "To use the Rails console, execute the command below:"
echo "  > cd shell-scripts/provisioning/development/"
echo "  > sudo sh ./development-application-console.sh"
echo ""
echo "To exit the console execute 'exit'."
echo ""
echo "--------------------------------------------------------"
echo ""
echo "Debug"
echo ""
echo "To debug the application, execute the steps below:"
echo "  > Insert 'remote_byebug' inside your Ruby on Rails code"
echo "  > Execute the code until this breakpoint"
echo "  > Application will 'wait' for a byebug remote connection"
echo "Then, execute these commands below:"
echo "  > cd shell-scripts/provisioning/development/"
echo "  > sudo sh ./development-application-debug.sh"
echo ""
echo "To close the byebug remote connection execute Ctrl+C."
echo ""
echo "--------------------------------------------------------"
echo ""
echo "Webpack bundle analyzer"
echo ""
echo "To view/analyze the size and dependency graph created by"
echo "Webpack, you can execute the commands below:"
echo "  > cd shell-scripts/provisioning/development/"
echo "  > sudo sh ./development-application-container-console.sh"
echo ""
echo "  > yarn run webpack:analyze-bundles"
echo ""
echo "To exit the analyzer execute Ctrl+C."
echo ""
echo "--------------------------------------------------------"
echo ""
echo "Restart environment"
echo ""
echo "To restart the environment, execute the command below:"
echo "  > cd shell-scripts/provisioning/development/"
echo "  > sudo sh ./development-environment-restart.sh"
echo ""
echo "--------------------------------------------------------"
echo ""
echo "Update dependencies"
echo ""
echo "To update the backend and frontend dependencies, execute"
echo "the command below:"
echo "  > cd shell-scripts/provisioning/development/"
echo "  > sudo sh ./development-application-update-dependencies.sh"
echo ""
echo "--------------------------------------------------------"
echo ""
echo "Enjoy!"
echo ""
echo ""

echo "Shell script [development-environment-create.sh] [$(date)]: Finished"
