# Intro

Mailu is a simple yet full-featured mail server as a set of Docker images. It is free software (both as in free beer and as in free speech), open to suggestions and external contributions. The project aims at providing people with an easily setup, easily maintained and full-featured mail server while not shipping proprietary software nor unrelated features often found in popular groupware.

# Mailu Configuration Generator

https://setup.mailu.io/2024.06/

Hompage: 
https://mailu.io/2024.06/

# Start the Compose project

To start your compose project, simply run the Docker Compose up command using -p mailu flag for project name.

docker compose -p mailu up -d

and stop with

docker compose -p mailu down -v --remove-orphans


Before you can use Mailu, you must create the primary administrator user account. This should be admin@mailu.local. Use the following command, changing PASSWORD to your liking:

```console
docker compose -p mailu exec admin flask mailu admin admin mailu.local PASSWORD

Eg:
docker compose -p mailu exec admin flask mailu admin admin mailu.local Secret2Login

```

Login to the admin interface to change the password for a safe one, at one of the hostnames mailu.apps.local. Also, choose the "Update password" option in the left menu.
