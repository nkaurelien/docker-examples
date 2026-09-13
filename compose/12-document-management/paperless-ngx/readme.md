# Paperless-ngx Document Management Stack

[Paperless-ngx](https://docs.paperless-ngx.com/) is an open-source document management system that transforms physical documents into a searchable online archive.

## Hostnames & Access

- Main URL: `https://paperless.kamitbrains.fr`
- Alias URL: `https://docs.kamitbrains.fr`
- Default Admin Login: `admin`

## Features

- **Automated OCR**: Multi-language Optical Character Recognition (fra + eng).
- **Full-Text Search**: Search inside PDF documents, images, and scanned receipts.
- **Auto-Tagging**: Machine learning document classification based on content.
- **PostgreSQL 16 & Valkey 8**: Fast, scalable database and task queue backend.
- **Reverse Proxy Protection**: Traefik TLS certificate termination & CrowdSec bouncer protection.

## Deployment with Ansible

```bash
ansible-playbook -i ansible/inventory.yml ansible/site.yml --tags paperless
```
