FROM node:16-bullseye as build

WORKDIR /usr/app

RUN apt-get update && apt-get -y install chromium jq

ADD package.json package.json
ADD package-lock.json package-lock.json
RUN npm install --only=prod

ADD lib lib

ADD data data
ADD templates templates

ADD generate-article.js generate-article.js
ADD generate-static-articles.sh generate-static-articles.sh

RUN bash generate-static-articles.sh

FROM nginx:latest

COPY --from=build /usr/app/html/ /usr/share/nginx/html/
