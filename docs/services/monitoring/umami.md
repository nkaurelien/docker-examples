---
tags: analytics, umami, web-analytics, privacy, monitoring, tracking
---

# Umami Web Analytics

[Umami](https://umami.is/) is an open-source, privacy-focused, cookie-free alternative to Google Analytics.

## Features

- **Privacy-First**: No cookies used, fully GDPR compliant out of the box.
- **Lightweight**: Minimal tracking script (<2 KB) that won't slow down website load speeds.
- **Multi-Website Support**: Track unlimited domain names and web applications from a single dashboard.
- **Custom Events & Funnels**: Track button clicks, form submissions, and user flows.
- **PostgreSQL Backend**: Fast, scalable event collection and reporting.

## Quick Start

```bash
cd compose/05-monitoring-reporting/umami
cp .env.example .env
docker compose up -d
```

Access at: `https://umami.kamitbrains.fr` (or `https://analytics.kamitbrains.fr`)

## Ansible Deployment

```bash
ansible-playbook -i ansible/inventory.yml ansible/site.yml --tags umami
```

## Default Credentials

- **Username**: `admin`
- **Password**: `umami` (Change upon first login)

## Resources

- [Official Website](https://umami.is/)
- [Documentation](https://umami.is/docs)
- [GitHub Repository](https://github.com/umami-software/umami)
