FROM nginx:1.14

# Basic dependencies.
RUN apt-get update -qq && apt-get install -y apache2-utils

# Web.
ENV RAILS_ROOT /var/www/app
WORKDIR $RAILS_ROOT
RUN mkdir -p log
COPY ./web.conf /tmp/docker_example.nginx
RUN envsubst '$RAILS_ROOT' < /tmp/docker_example.nginx > /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
