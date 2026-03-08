FROM node:24.14

WORKDIR /app

# package files and dependencies
COPY package*.json ./
RUN npm ci 

# copy the rest of the app
COPY . .

# build static app
RUN npm run build

# expose the port
EXPOSE 3000


