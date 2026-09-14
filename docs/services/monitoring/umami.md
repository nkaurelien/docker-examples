---
tags: analytics, umami, web-analytics, privacy, monitoring, tracking, ntfy, ofelia, reporting
---

# Umami Web Analytics & Automated Reporting

[Umami](https://umami.is/) is an open-source, privacy-focused, cookie-free alternative to Google Analytics.

## Key Features

- **Privacy-First**: No cookies used, fully GDPR compliant out of the box.
- **Lightweight**: Minimal tracking script (<2 KB) that won't slow down website load speeds.
- **Multi-Website Support**: Track unlimited domain names and web applications from a single dashboard.
- **Custom Events & Funnels**: Track button clicks, form submissions, and user flows.
- **Automated Push Reporting**: Scheduled traffic reports pushed to your mobile device via **Ntfy** and **Ofelia**.

## Automated Ntfy Push Reporting Architecture

The Umami stack includes an automated reporting pipeline consisting of the `umami-reporter` service, the `umami-ntfy-report.js` script, the **Ofelia** job scheduler, and **Ntfy** push notifications.

```
 ┌─────────────────────────────────────────────────────────────┐
 │                       Umami Analytics                       │
 │  - Web UI & REST API v2 (https://umami.kamitbrains.fr)      │
 └──────────────────────────────┬──────────────────────────────┘
                                │ API Fetch (Token Auth)
                                ▼
 ┌─────────────────────────────────────────────────────────────┐
 │                       umami-reporter                        │
 │  - Container: node:20-alpine                                │
 │  - Script: /opt/umami/scripts/umami-ntfy-report.js          │
 └──────────────┬──────────────────────────────▲───────────────┘
                │ Push Notification            │ Trigger via Labels
                ▼                              │
 ┌──────────────────────────────┐ ┌────────────┴────────────────┐
 │        Ntfy Service          │ │   Ofelia Job Scheduler     │
 │  - Channel: NTFY_TOPIC_URL   │ │   - Daily (20:00)          │
 └──────────────────────────────┘ │   - Weekly (Mon 09:00)     │
                                  └────────────────────────────┘
```

### Reporting Features & Metrics

The `umami-ntfy-report.js` script automatically fetches the last 7 days of web traffic metrics for all registered websites:

- **Pages Vues**: Total pageviews count.
- **Visiteurs Uniques**: Unique visitors.
- **Sessions**: Total session visits.
- **Temps Moyen**: Average duration per visit in seconds (`totaltime / visits`).
- **Taux de Rebond**: Bounce rate percentage (`(bounces / visits) * 100`).

### Scheduled Jobs

Ofelia triggers the report automatically via container labels:
- **Daily Summary**: Everyday at 20:00 PM (`0 20 * * *`).
- **Weekly Summary**: Every Monday at 09:00 AM (`0 9 * * 1`).

### Secret Protection

The target push notification URL (`NTFY_TOPIC_URL`) is kept confidential inside `.secrets/ntfy-push-secret-topic` (local gitignored file) and injected dynamically into `umami-reporter` environment variables during deployment.

## Quick Start

```bash
cd compose/05-monitoring-reporting/umami
docker compose up -d
```

Access dashboard at: `https://umami.kamitbrains.fr` (or `https://analytics.kamitbrains.fr`)

## Ansible Deployment

```bash
ansible-playbook -i ansible/inventory.yml ansible/site.yml --tags umami
```

## Manual Test Execution

To trigger an instant push report notification manually:

```bash
docker exec umami-reporter node /app/scripts/umami-ntfy-report.js
```

## Default Credentials

- **Username**: `admin`
- **Password**: Stored in `.secrets/umami-admin-password`

## Resources

- [Official Website](https://umami.is/)
- [Documentation](https://umami.is/docs)
- [GitHub Repository](https://github.com/umami-software/umami)
- [Ofelia Scheduler Documentation](../automation/ofelia.md)
- [Ntfy Notifications Documentation](../communication/ntfy.md)
