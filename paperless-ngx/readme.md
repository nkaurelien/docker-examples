# Paperless-ngx

Paperless-ngx is a document management system that transforms physical documents into a searchable online archive.

## Features

- OCR processing for scanned documents
- Full-text search
- Automatic document classification with tags, correspondents, and document types
- Email integration for document ingestion
- REST API

## Quick Start

1. Configure `docker-compose.env` with your settings (especially `USERMAP_UID` and `USERMAP_GID`)

2. Start the services:
```bash
docker compose up -d
```

3. Create a superuser:
```bash
docker compose exec webserver python manage.py createsuperuser
```

4. Access the web interface at http://localhost:8000

## Traefik Access

With Traefik configured, access via: `http://paperless.apps.local` (or your configured domain)

## Document Consumption

Place documents in the `./consume` folder - they will be automatically imported and processed.

## Volumes

- `data`: Application data
- `media`: Processed documents
- `pgdata`: PostgreSQL database
- `redisdata`: Redis data
- `./consume`: Drop folder for new documents
- `./export`: Export destination

## Documentation

- [Official Documentation](https://docs.paperless-ngx.com/)
- [GitHub Repository](https://github.com/paperless-ngx/paperless-ngx)
