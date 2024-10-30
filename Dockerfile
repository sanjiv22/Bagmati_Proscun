FROM node:18.20.3-slim as build-stage
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY ./ .
RUN npm run build

FROM nginx:alpine-slim as production-stage
RUN mkdir /app
COPY nginx.conf /etc/nginx/nginx.conf
COPY --from=build-stage /app/dist /app

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]

#docker build --no-cache --rm --squash . -t bagmati_proscun:1.0
#docker run -d -p 8080:80 --name bagmati_proscun bagmati_proscun:1.0
