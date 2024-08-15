# Use the official Node.js image from the Docker Hub
#FROM node:14-slim
FROM keymetrics/pm2:latest-alpine

# Set the working directory inside the container
WORKDIR /usr/src/app

# Copy package.json and package-lock.json (if available)
COPY package*.json ./

# Install app dependencies
ENV NPM_CONFIG_LOGLEVEL warn
 RUN npm install --production

# Install dependencies using npm ci for a clean installation
# RUN npm ci --only=production

# Copy the rest of the application code
COPY . .

# Prune unnecessary files to reduce image size
RUN npm prune --production

# Expose the port the app runs on
EXPOSE 3000

# Show current folder structure in logs
RUN ls -al -R

CMD [ "pm2-runtime", "start", "pm2.ecosystem.config.js" ]