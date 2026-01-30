# Use an official Nginx image as the base image
FROM caddy:2-alpine

# Set the default build argument
ARG SITE=patient

WORKDIR /srv

# Copy the specified static site content to the Nginx web root directory
COPY ${SITE}/ .

# Expose port to the outside world
EXPOSE 80

# Start caddy when the container starts
#CMD ["caddy", "file-server", "--listen", ":3000"]
CMD ["caddy", "file-server"]
