# Use an official Nginx image as the base image
FROM httpd:2.4

# Set the default build argument
ARG SITE=patient

# Copy the specified static site content to the Nginx web root directory
COPY ${SITE}/ /usr/local/apache2/htdocs/

# Expose port 80 to the outside world
EXPOSE 80

# Start httpd when the container starts
# CMD []