FROM ubuntu:18.04

# Build arguments.
ARG RAILS_ENV
ARG NODE_ENV
ARG NODE_OPTIONS
ARG RAILS_MASTER_KEY

# Environment variables.
ENV DEBIAN_FRONTEND=noninteractive \
  LANG=C.UTF-8 \
  TZ=America/Sao_Paulo \
  EDITOR=vim \
  RAILS_ENV=$RAILS_ENV \
  NODE_ENV=$NODE_ENV \
  NODE_OPTIONS=$NODE_OPTIONS \
  RAILS_MASTER_KEY=$RAILS_MASTER_KEY \
  PASSENGER_COMPILE_NATIVE_SUPPORT_BINARY=0 \
  PASSENGER_DOWNLOAD_NATIVE_SUPPORT_BINARY=0 \
  PASSENGER_DISABLE_SECURITY_UPDATE_CHECK=true

# Ports.
EXPOSE 3000 8989

# Basic updates and packages.
RUN apt-get update -y && \
  apt-get dist-upgrade -y && \
  apt-get install -y software-properties-common \
  tar \
  wget \
  gcc \
  make \
  gnupg2 \
  curl \
  git \
  build-essential

# Timezone.
RUN apt-get install -y tzdata && \
  ln -fs /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime && \
  dpkg-reconfigure --frontend noninteractive tzdata

# Ruby.
RUN apt-get install -y patch \
  gawk \
  g++ \
  gcc \
  autoconf \
  automake \
  bison \
  libc6-dev \
  libffi-dev \
  libgdbm-dev \
  libncurses5-dev \
  libsqlite3-dev \
  libtool \
  libyaml-dev \
  make \
  patch \
  pkg-config \
  sqlite3 \
  zlib1g-dev \
  libgmp-dev \
  libreadline-dev \
  libssl-dev && \
  wget http://ftp.ruby-lang.org/pub/ruby/2.7/ruby-2.7.0.tar.gz && \
  tar -xzvf ruby-2.7.0.tar.gz && \
  cd ruby-2.7.0/ && \
  ./configure && \
  make && make install && \
  cd ../ && \
  rm -Rf ruby-2.7.0/ ruby-2.7.0.tar.gz && \
  gem install bundler

# NodeJS + Yarn.
RUN curl -sL https://deb.nodesource.com/setup_12.x | bash - && \
  apt-get install -y nodejs && \
  npm install -g yarn

# Packages that app depends.
RUN add-apt-repository -y ppa:malteworld/ppa && \
  apt-get update -y && \
  apt-get install -y libpq-dev vim

# App.
RUN mkdir -p /app
WORKDIR /app
COPY . .
RUN mkdir -p /app/public/uploads && \
  bundle install && \
  npm cache verify
CMD yarn install && \
  yarn run build:$NODE_ENV && \
  rm -Rf /app/tmp/pids/ && bundle exec rails server -b 0.0.0.0 -p 3000
