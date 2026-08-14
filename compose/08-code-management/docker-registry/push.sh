#!/bin/bash


# Pull the image
docker pull hello-world

# Tag the image
docker tag hello-world:latest 192.168.0.201:25000/hello-world:latest

# Push the image
docker push 192.168.0.201:25000/hello-world:latest
