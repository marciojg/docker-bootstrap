FROM node:16-alpine as base

ARG NODE_PORT
ARG NODE_ENV

WORKDIR /app

COPY package*.json /

EXPOSE $NODE_PORT

FROM base as production
ENV NODE_ENV=$NODE_ENV
RUN npm ci
COPY . .
CMD ["npm", "run", "start"]
