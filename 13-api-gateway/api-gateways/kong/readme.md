
# Enable Kong Manager

If you’re running Kong Gateway with a database (either in traditional or hybrid mode), you can enable Kong Gateway’s graphical user interface (GUI), Kong Manager.

```console

docker compose exec -i kong /bin/sh -c "export KONG_ADMIN_GUI_PATH='/'; export KONG_ADMIN_GUI_URL='http://localhost:8002/manager'; kong reload; exit"
```

LINKS

- https://docs.konghq.com/gateway/latest/kong-manager/enable/
- https://docs.konghq.com/gateway/latest/install/docker/

API DOCS 
- https://docs.konghq.com/gateway/api/admin-oss/latest/

OFFICIAL COMPOSE
- https://github.com/Kong/docker-kong/blob/master/compose/docker-compose.yml