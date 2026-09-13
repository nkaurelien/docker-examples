# GlitchTip

GlitchTip is an open-source error tracking and Application Performance Monitoring (APM) platform compatible with Sentry SDKs.

## Architecture
- **GlitchTip Web & Worker**: Core Python/Django application container.
- **PostgreSQL**: Primary relational database.
- **Valkey**: Redis-compatible in-memory caching and task queue.

## Usage

```bash
docker compose up -d
```
