FROM node:20-alpine

WORKDIR /app

COPY package*.json ./

RUN apk update && apk upgrade --no-cache

COPY . .

EXPOSE 3000

CMD ["node", "app/server.js"]
