FROM ruby:2.5.1

# Basic dependencies.
RUN apt-get update -y && apt-get install -y build-essential libpq-dev

# Node.js.
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash - \
  && apt-get install -y nodejs

# App.
ENV INSTALL_PATH /app
RUN mkdir -p $INSTALL_PATH
WORKDIR $INSTALL_PATH
COPY . .
