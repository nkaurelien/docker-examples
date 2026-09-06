# CrowdSec Security Engine & Traefik Bouncer

CrowdSec is an open-source, lightweight, collaborative Intrusion Detection System (IDS) and Intrusion Prevention System (IPS). It analyzes logs from SSH, Traefik, and Linux system services to detect malicious behaviors and block bad IP addresses in real time.

## 🚀 Quick Start

1. Set the Local API Key in `.env`:
   ```bash
   echo "CROWDSEC_LAPI_KEY=$(python3 -c 'import secrets; print(secrets.token_hex(16))')" > .env
   ```

2. Start the stack:
   ```bash
   docker compose up -d
   ```

3. Check metrics and active bans via `cscli`:
   ```bash
   docker exec crowdsec cscli metrics
   docker exec crowdsec cscli decisions list
   ```

## 🔐 Arcane Integration

This stack is pre-configured with `x-arcane:` metadata for 1-click deployment in the Arcane PaaS Manager.
