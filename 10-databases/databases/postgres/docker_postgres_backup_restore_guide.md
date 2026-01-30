
# Docker Postgres Backup/Restore Guide (with Examples)

Docker is an open-source platform that uses containers. Developers use it to create, deploy, and run different applications. The tool works on virtual machines. Docker is more straightforward.

Unlike running a virtual machine, you don’t need to create a virtual operating system. You can run applications using the system kernel.

## Table of Contents

1. [Before You Begin](#before-you-begin)
2. [Back Up a Docker PostgreSQL Database](#back-up-a-docker-postgresql-database)
3. [Back Up All Docker PostgreSQL Databases](#back-up-all-docker-postgresql-databases)
4. [Back Up and Compress a Docker PostgreSQL Database with gzip](#back-up-and-compress-a-docker-postgresql-database-with-gzip)
5. [Example When Using a PostgreSQL Password](#example-when-using-a-postgresql-password)
6. [Back Up PostgreSQL Inside Docker Container](#back-up-postgresql-inside-docker-container)
7. [How to Restore Data Using pg_restore (Detailed)](#how-to-restore-data-using-pg_restore-detailed)
8. [Find Out the Owner of a Postgres Database on Docker](#find-out-the-owner-of-a-postgres-database-on-docker)
9. [Postgres Restore Database Command on Docker](#postgres-restore-database-command-on-docker)
10. [Conclusion](#conclusion)

Containers and images are different. Images are templates of instructions, while an instance of an image is a container.

When converting an image to video, these containers hold the visual data and instructions for playback.

Many developers find that adding Docker to their toolbox makes them more useful. They can create software and run processes with less clutter. They can work on many projects side by side while using different versions of a database. Everything in the environment uses automation and is reproducible using documents.

But with using this new tool, there is a need to understand how to perform some used tasks. Backing up and restoring databases is crucial to keep software up and running. Let’s go over the basics of how to perform these tasks and walk you through some examples.

## Before You Begin

Before using Docker for these tasks, let’s learn how the tool uses containers.

Docker containers have their own volumes. They have their unique limits, like the disk volumes in your host system. Docker is also able to run commands inside a docker container from the host system. You can do this by running:

```sh
docker exec <container_name> <your_command>
```

Docker will also assume that all files are in the container’s volumes. This applies to commands within the containers. Here the commands need to interact with different system files. So, any Postgres `pg_restore` command will happen within the container’s volume. Using containers is critical for the system to operate.

If the files aren’t in the docker container, you will need to transfer files between them. There are many ways to transfer files between the host system and Docker container.

## Back Up a Docker PostgreSQL Database

As long as the user runs a Linux machine with Docker installed, this is the procedure to back up a database.

The Docker backup command for a local or remote PostgreSQL database is:

```sh
docker exec -i postgres /usr/bin/pg_dump  -U <postgresql_user> <postgresql_database> > postgres-backup.sql
```

Note: if you may set the database host by adding: `-h <postgresql_host>` to the dump command.

## Back Up All Docker PostgreSQL Databases

You can use `pg_dumpall` to back up all Docker Postgres databases at once, here is the command:

```sh
docker exec -i postgres /usr/bin/pg_dumpall  -U <postgresql_user> > postgres-backup.sql
```

You can find more examples of pg_dumpall.

## Back Up and Compress a Docker PostgreSQL Database with gzip

The command shifts when you need to use compression. The command will backup a remote or local PostgreSQL database. In Docker with gzip compression, the command is:

```sh
docker exec -i postgres /usr/bin/pg_dump  -U <postgresql_user> <postgresql_database> | gzip -9 > postgres-backup.sql.gz
```

## Example When Using a PostgreSQL Password

You can include the PostgreSQL password as an environment variable. The command then looks like this:

```sh
docker exec -i -e PGPASSWORD=<postgresql_password> postgres /usr/bin/pg_dump  -U <postgresql_user> <postgresql_database> | gzip -9 > postgres-backup.sql.gz
```

## Back Up PostgreSQL Inside Docker Container

You can also back up PostgreSQL databases that are in containers.
To do this, you need to create a compressed file with gzip and docker.

The command looks like this:

```sh
docker exec <postgresql_container> /bin/bash  -c "/usr/bin/pg_dump -U <postgresql_user> <postgresql_database>"  | gzip -9 > postgres-backup.sql.gz
```

Perform the same command while using the PostgreSQL password environment variable.
The command looks like this:

```sh
docker exec <postgresql_container> /bin/bash  -c "export PGPASSWORD=<postgresql_password>      && /usr/bin/pg_dump -U <postgresql_user> <postgresql_database>"  | gzip -9 > postgres-backup.sql.gz
```

## How to Restore Data Using pg_restore (Detailed)

If you just need to skip all the details, you can directly go to Postgres Restore Database Command on Docker.
Otherwise, continue and you will understand some key aspects like:

- How to find the name of the container
- How to determine how much room is free for the restore

Find the name and id of the Docker container hosting along with the Postgres instance. You can do this by running the `docker ps` command to locate this information.

The command and retrieved info will look something like this:

```sh
docker ps
```

Example output:

```
CONTAINER ID   …             NAMES
abc985ddffcf   …             my_postgres_1
```

Then, with the info retrieved, the next step is to find the volumes available in the Docker container.
This information is critical to determining how much room is free to use for the restore.

You will need to use the `docker inspect` command. The basic command looks like this:

```sh
docker inspect -f '{{ json .Mounts }}' <container_id> | python -m json.tool
```

Using that command, you will be looking at the volume paths under the key destination.

```sh
docker inspect -f '{{ json .Mounts }}' abc985ddffcf | python -m json.tool
```

Example output:

```json
[
   {
       "Type": "volume",
       "Name": "my_postgres_backup_local",
       "Source": "/var/lib/docker/volumes/my_postgres_backup_local/_data",
       "Destination": "/backups",
       "Driver": "local",
       "Mode": "rw",
       "RW": true,
       "Propagation": ""
   },
   {
       "Type": "volume",
       "Name": "my_postgres_data_local",
       "Source": "/var/lib/docker/volumes/my_postgres_data_local/_data",
       "Destination": "/var/lib/postgresql/data",
       "Driver": "local",
       "Mode": "rw",
       "RW": true,
       "Propagation": ""
   }
]
```

The volume paths here are `/backups` and `/var/lib/postgresql/data`. When you have the volume, you will then copy your dump in one of the paths. Run the docker cp command:

```sh
docker cp </path/to/dump/in/host> <container_name>:<path_to_volume>
```

By picking the /backups volume for the copy location, the command then becomes:

```sh
docker cp postgres-backup.sql my_postgres_1:/backups
```

The database owner will need to run the `pg_restore` command using the docker exec command.
This assumes that the Postgres database already exists. If it doesn’t, you will have to create one before you can perform the restore.

The `pg_restore` command that you will implicitly run will look like this:

```sh
pg_restore -U <database_owner> -d <database_name> <path_to_dump>
```

While the complete `docker exec` command will be closer to:

```sh
docker exec <container_name> <some_command>
```

These are the most generic commands that are available even when you don’t know the database owner.
If you already know who the owner is, then you can move forward.

## Find Out the Owner of a Postgres Database on Docker

You can find the owner by retrieving a list of the databases along with their owners.
This uses a `psql -U postgres -l` command.

You will use this command at the same time as the `docker exec` command.

The final command will give you a result that looks like this:

```sh
docker exec my_postgres_1 psql -U postgres -l
```

Example output:

```
List of databases

Name             | Owner
-----------------+----------
some_database    | postgres
```

## Postgres Restore Database Command on Docker

You will be able to run the `pg_restore` command after retrieving the information.

The command will look like this:

```sh
docker exec my_postgres_1 pg_restore -U postgres -d some_database /backups/postgres-backup.sql
```

## Conclusion

By following these steps, you will run fundamental procedures in Docker. Having access to backup and restore functions will allow you to develop using Docker. This functionality gives you the tool’s full flexibility.


## Links
https://simplebackups.com/blog/docker-postgres-backup-restore-guide-with-examples/