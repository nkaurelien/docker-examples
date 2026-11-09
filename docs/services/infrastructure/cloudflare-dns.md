---
tags: automation, cli, cloudflare, dns, infrastructure
---

# Cloudflare DNS CLI Automation

Automated DNS management CLI tool powered by the official Cloudflare Python SDK (`cloudflare`).

---

## 💡 Overview

The CLI tool `scripts/cloudflare_dns.py` provides a simple, robust interface to query and manipulate Cloudflare DNS records directly using official Cloudflare SDK bindings.

---

## 🔧 Prerequisites

* Installed `cloudflare` Python package (available in `.venv`).
* Configured API Token in `.secrets/cloudflare-api-key`.
* Configured Account ID in `.secrets/cloudflare-account-id`.

---

## 💻 CLI Usage

```bash
# List all Cloudflare zones in the account
.venv/bin/python3 scripts/cloudflare_dns.py

# List all DNS records for a specific domain
.venv/bin/python3 scripts/cloudflare_dns.py list example.com

# Add an A record pointing to a server IP
.venv/bin/python3 scripts/cloudflare_dns.py add example.com A app 203.0.113.10

# Add a proxied A record (Cloudflare CDN / WAF enabled)
.venv/bin/python3 scripts/cloudflare_dns.py add example.com A app 203.0.113.10 --proxied
```

---

## 🐍 Python SDK Code Snippet

```python
from cloudflare import Cloudflare

client = Cloudflare(api_token="YOUR_API_TOKEN")

# Create DNS record
record = client.dns.records.create(
    zone_id="53e34787a1c669b8225e784e208259a3",
    type="A",
    name="app",
    content="203.0.113.10",
    proxied=False
)
```
