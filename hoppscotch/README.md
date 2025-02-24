

# Intro

Hoppscotch is a lightweight, web-based API development suite. It was built from the ground up with ease of use and accessibility in mind providing all the functionality needed for developers with minimalist, unobtrusive UI.

Links: 
- https://docs.hoppscotch.io/documentation/self-host/community-edition/install-and-build
- https://github.com/hoppscotch/hoppscotch


# RUN MIGRATION

Once the instance of Hoppscotch is up, you need to run migrations on the database to ensure that it has the relevant tables. Depending on how Hoppscotch was set up, the method to run the migrations changes.

```console
docker compose run hoppscotch pnpm dlx prisma migrate deploy
```