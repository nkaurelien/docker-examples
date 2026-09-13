---
tags: monitoring, apm, error-tracking, glitchtip, sentry, dev-tools, logging
---

# GlitchTip Error Tracking & APM Service

[GlitchTip](https://glitchtip.com/) is an open-source, Sentry SDK compatible application performance monitoring (APM) and error tracking platform. It allows developers to collect crash reports, exceptions, performance traces, and uptime metrics from any application using standard Sentry client libraries.

---

## Service Overview

| Attribute | Details |
| :--- | :--- |
| **Service Name** | `glitchtip` |
| **Public URL** | `https://glitchtip.kamitbrains.fr` |
| **Health Check** | `https://glitchtip.kamitbrains.fr/_health/` |
| **Docker Images** | `glitchtip/glitchtip:6`, `postgres:17`, `valkey/valkey:9` |
| **Internal Port** | `8000` |
| **Reverse Proxy** | Traefik (`websecure` + Let's Encrypt TLS) |
| **Security** | CrowdSec ForwardAuth Bouncer |
| **Storage Volumes** | `glitchtip-db-data`, `glitchtip-uploads` |
| **Master Admin Email** | `admin@kamitbrains.fr` |

---

## Quick Start: Connecting Applications (Sentry SDKs)

GlitchTip is 100% API-compatible with official Sentry SDKs across all programming languages and frameworks.

### 1. Python (Django / FastAPI / Flask)

```bash
pip install sentry-sdk
```

```python
import sentry_sdk

sentry_sdk.init(
    dsn="https://<your-project-key>@glitchtip.kamitbrains.fr/<project-id>",
    traces_sample_rate=1.0,
    environment="production",
)
```

### 2. Node.js & Express / NestJS

```bash
npm install @sentry/node
```

```javascript
const Sentry = require("@sentry/node");

Sentry.init({
  dsn: "https://<your-project-key>@glitchtip.kamitbrains.fr/<project-id>",
  tracesSampleRate: 1.0,
  environment: "production",
});
```

### 3. Frontend (React / Vue / Next.js)

```javascript
import * as Sentry from "@sentry/react";

Sentry.init({
  dsn: "https://<your-project-key>@glitchtip.kamitbrains.fr/<project-id>",
  integrations: [Sentry.browserTracingIntegration()],
  tracesSampleRate: 0.2,
});
```

### 4. Go (Golang)

```go
package main

import (
	"log"
	"time"
	"github.com/getsentry/sentry-go"
)

func main() {
	err := sentry.Init(sentry.ClientOptions{
		Dsn: "https://<your-project-key>@glitchtip.kamitbrains.fr/<project-id>",
	})
	if err != nil {
		log.Fatalf("sentry.Init: %s", err)
	}
	defer sentry.Flush(2 * time.Second)
}
```

---

## Architecture & Service Topology

GlitchTip is deployed via Ansible using a 4-container stack defined in `ansible/roles/glitchtip/templates/docker-compose.yml.j2`:

```
┌───────────────────────────────────────────────────────────┐
│              Traefik Reverse Proxy (:443)                  │
└─────────────────────────────┬─────────────────────────────┘
                              │ https://glitchtip.kamitbrains.fr
                              ▼
┌───────────────────────────────────────────────────────────┐
│               glitchtip/glitchtip:6 (Granian)             │
│            Web Server & Celery Worker (:8000)             │
└──────────────┬─────────────────────────────┬──────────────┘
               │                             │
               ▼                             ▼
┌──────────────────────────┐    ┌──────────────────────────┐
│   glitchtip-db (PG 17)   │    │  glitchtip-valkey (V9)   │
│       Port :5432         │    │       Port :6379         │
└──────────────────────────┘    └──────────────────────────┘
```

---

## Secrets & Passwords Reference

Secret values are stored locally in the `.secrets/` directory and recorded in Passbolt:
- `.secrets/glitchtip-admin-password`: Web UI Admin password
- `.secrets/glitchtip-db-password`: PostgreSQL user password
- `.secrets/glitchtip-secret-key`: Django application secret key
- `.secrets/passbolt_import_secrets.csv`: CSV import file for Passbolt

---

## Maintenance & Troubleshooting

### Restart GlitchTip Stack
```bash
docker compose -f /opt/glitchtip/docker-compose.yml restart
```

### View Live Logs
```bash
docker logs glitchtip -f --tail 100
```

### Re-run Database Migrations
```bash
docker exec glitchtip python manage.py migrate
```
