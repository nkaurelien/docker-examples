---
tags: document-management, dms, paperless, paperless-ngx, ocr, pdf
---

# Paperless-ngx

[Paperless-ngx](https://docs.paperless-ngx.com/) is an open-source document management system that transforms physical documents into a searchable online archive.

## Features

- **Automated OCR**: Multi-language Optical Character Recognition (fra + eng out of the box).
- **Full-Text Search**: Fast indexing and search across PDFs, scanned images, and text documents.
- **Machine Learning Tagging**: Automatic document matching and tagging based on machine learning models.
- **PostgreSQL 16 Backend**: Robust relational storage for document metadata, tags, and user permissions.
- **Valkey/Redis Task Queue**: Background asynchronous task processing for OCR processing and ingestion.

## Quick Start

```bash
cd compose/12-document-management/paperless-ngx
cp .env.example .env
docker compose up -d
```

Access at: `https://paperless.kamitbrains.fr` (or `https://docs.kamitbrains.fr`)

## Ansible Deployment

```bash
ansible-playbook -i ansible/inventory.yml ansible/site.yml --tags paperless
```

## Admin Credentials

- **Username**: `.secrets/paperless-admin-login` (`admin`)
- **Password**: `.secrets/paperless-admin-password`

## Resources

- [Official Documentation](https://docs.paperless-ngx.com/)
- [GitHub Repository](https://github.com/paperless-ngx/paperless-ngx)
