# API Gateway

API management, GraphQL engines, and API development tools.

## API Gateways

Reverse proxies and API management platforms.

### Existing Projects

- **api-gateways/kong/** - API gateway
- **api-gateways/tyk/** - API management platform
- **api-gateways/wso2am/** - WSO2 API manager
- **api-gateways/nginx-proxy-manager/** - Nginx proxy manager

### Suggested Open Source Services

| Service | Description | GitHub |
|---------|-------------|--------|
| **Kong** | Cloud-native API gateway | [Kong/kong](https://github.com/Kong/kong) |
| **Apache APISIX** | API gateway | [apache/apisix](https://github.com/apache/apisix) |
| **Tyk** | API management platform | [TykTechnologies/tyk](https://github.com/TykTechnologies/tyk) |
| **KrakenD** | Ultra-high performance gateway | [krakendio/krakend-ce](https://github.com/krakendio/krakend-ce) |
| **Gravitee** | API management platform | [gravitee-io/gravitee-api-management](https://github.com/gravitee-io/gravitee-api-management) |
| **WSO2 API Manager** | Full lifecycle API management | [wso2/product-apim](https://github.com/wso2/product-apim) |
| **Express Gateway** | API gateway built on Express | [ExpressGateway/express-gateway](https://github.com/ExpressGateway/express-gateway) |

---

## GraphQL

GraphQL servers and engines.

### Existing Projects

- **graphql/hasura/** - Instant GraphQL APIs

### Suggested Open Source Services

| Service | Description | GitHub |
|---------|-------------|--------|
| **Hasura** | Instant GraphQL APIs | [hasura/graphql-engine](https://github.com/hasura/graphql-engine) |
| **PostGraphile** | GraphQL from PostgreSQL | [graphile/crystal](https://github.com/graphile/crystal) |
| **Apollo Server** | GraphQL server | [apollographql/apollo-server](https://github.com/apollographql/apollo-server) |
| **Graphene** | Python GraphQL framework | [graphql-python/graphene](https://github.com/graphql-python/graphene) |
| **Juniper** | Rust GraphQL server | [graphql-rust/juniper](https://github.com/graphql-rust/juniper) |

---

## API Tools

API development, testing, and documentation.

### Existing Projects

- **api-tools/hoppscotch/** - API development platform

### Suggested Open Source Services

| Service | Description | GitHub |
|---------|-------------|--------|
| **Hoppscotch** | API development platform | [hoppscotch/hoppscotch](https://github.com/hoppscotch/hoppscotch) |
| **Insomnia** | API client | [Kong/insomnia](https://github.com/Kong/insomnia) |
| **Bruno** | Offline API client | [usebruno/bruno](https://github.com/usebruno/bruno) |
| **Mockoon** | API mocking tool | [mockoon/mockoon](https://github.com/mockoon/mockoon) |
| **Swagger UI** | API documentation | [swagger-api/swagger-ui](https://github.com/swagger-api/swagger-ui) |
| **Redoc** | API documentation | [Redocly/redoc](https://github.com/Redocly/redoc) |

---

## Quick Start

```bash
# Kong
cd api-gateways/kong/
docker compose up -d

# Hasura
cd graphql/hasura/
docker compose up -d
```

Access Kong Admin at `http://admin.kong.apps.local`.
