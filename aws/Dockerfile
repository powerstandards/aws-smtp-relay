# Start from this image on https://hub.docker.com (the public docker repo)
# This gives us a known starting point to configure from for each build
FROM node:12-alpine

# Let docker know that our app is listening on port 3000 when it runs
EXPOSE 3000

# This just sets the current directory so we don't have to put '/app' everywhere
WORKDIR /app

# Environment variables
ENV ISDOCKER=TRUE

COPY package*.json ./

# copy these files from our local workspace into the container (they will end up in /app)
COPY server ./server

WORKDIR /app/server

# Run our test cases, if any fail this will fail the docker build command (non-zero exit code)
# RUN npm test

# set the startup command to npm start so when our container runs we start up the server
# this is way easier then configuring some sort of system daemon
CMD [ "npm", "start" ]
