# -------- Build stage --------
FROM node:24.14-alpine AS build

WORKDIR /app

# package file s and dependencies
COPY package*.json ./
RUN npm ci 

# copy the rest of the app
COPY . .

# build static app
RUN npm run build

# -------- Prod stage --------
FROM nginx:alpine

# copy built static files from build stage to nginx html folder
COPY --from=build /app/dist /usr/share/nginx/html
