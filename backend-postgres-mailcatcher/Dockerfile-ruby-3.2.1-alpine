FROM ruby:3.1.2-alpine

RUN apk update && apk add --no-cache --update \
  bash curl supervisor git nodejs gcompat \
  openssl-dev postgresql-dev libpq postgresql-client sqlite-dev \
  libxml2-dev libxslt-dev build-base ruby-dev libc-dev linux-headers tzdata

WORKDIR /app

COPY Gemfile .
COPY Gemfile.lock .

RUN bundle

COPY . .

CMD ["/bin/sh", "-c" , "rm -f ./tmp/pids/* && rails s -p 3000 -b '0.0.0.0'"]
