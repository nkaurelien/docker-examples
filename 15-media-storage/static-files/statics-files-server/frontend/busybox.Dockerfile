FROM busybox:1.35

# Set the default build argument
ARG SITE=patient

# Create a non-root user to own the files and run our server
RUN adduser -D static
USER static
WORKDIR /home/static


# Copy the static website
# Use the .dockerignore file to control what ends up inside the image!
COPY ${SITE}/ .

EXPOSE 3000

# Run BusyBox httpd
CMD ["busybox", "httpd", "-f", "-v", "-p", "3000"]