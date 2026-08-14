# Use an official Nginx image as the base image
FROM nginx:alpine

# Set the default build argument
ARG SITE=patient

# Copy the specified static site content to the Nginx web root directory
COPY ${SITE}/ /usr/share/nginx/html

# Expose port 80 to the outside world
EXPOSE 80

# Start Nginx when the container starts
CMD ["nginx", "-g", "daemon off;"]